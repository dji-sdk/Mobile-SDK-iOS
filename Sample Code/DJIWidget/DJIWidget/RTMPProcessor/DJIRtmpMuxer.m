//
//  DJIRtmpMuxer.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//


#if !TARGET_IPHONE_SIMULATOR
#import <CoreAudioKit/CoreAudioKit.h>
#endif

#import <AudioToolbox/AudioToolbox.h>
#include "libavcodec/avcodec.h"
#include "libavformat/avformat.h"
#include "libavutil/opt.h"

#import <DJIWidget/DJIVideoHelper.h>
#import "DJIRtmpMuxer.h"
#import "DJIWidgetLinkQueue.h"
#import <DJIWidget/DJIVideoPreviewer.h>
#import "DJIAudioSampleBuffer.h"
#import "DJIVideoPreviewSmoothHelper.h"
#import <DJIWidget/DJIVTH264Encoder.h>
#import "DJIRtmpIFrameProvider.h"




typedef enum {
    VideoMuxerFrameType_None = 0,
    VideoMuxerFrameType_Video,
    VideoMuxerFrameType_Audio,
} VideoMuxerFrameType;


typedef struct _VideoMuxerFrame{
    int size;
    int type;
    double time_tag;
    uint8_t* data;
} VideoMuxerFrame;

//dump for debug
#define LOG_VIDEO_INFO (0)
#define DUMP_VIDEO_STREAM (0)
#define DUMP_AUDIO_STREAM (0)

//time base & sample rate
#define FLV_TIME_BASE (1000)
#define AUDIO_SAMPLE_RATE (44100)

#define AAC_FRAMES_PER_PACKET (1024)
#define AUDIO_QUEUE_BUFFER_COUNT (3)
#define AAC_COMPRESS_BUFFER_SIZE (128000)

//drop frames and buffer
#define MUXER_DROP_FRAME_THRESHOLD (200)
#define MUXER_MAX_BUFFER_FRAME_NUM (500)

#define LOGI(fmt, ...) NSLog(@"[rtmp log]"fmt, ##__VA_ARGS__)
#define INFO(fmt, ...) NSLog(@"[rtmp log]"fmt, ##__VA_ARGS__)
#define ERROR(fmt, ...) NSLog(@"[rtmp log]"fmt, ##__VA_ARGS__)

#if	LOG_VIDEO_INFO
#import <DJIMidWare/DJIVideoStuckTester.h>
#endif

static void AudioInputCallback( void                                *aqData,             // 1
                               AudioQueueRef                       inAQ,                // 2
                               AudioQueueBufferRef                 inBuffer,            // 3
                               const AudioTimeStamp                *inStartTime,        // 4
                               UInt32                              inNumPackets,        // 5
                               const AudioStreamPacketDescription  *inPacketDesc        // 6
){
    DJIRtmpMuxer *muxer = (__bridge DJIRtmpMuxer*) aqData;
    if (muxer && inBuffer->mAudioDataByteSize && inBuffer->mAudioData) {
        //This is not actually an aacframe, but it doesn't matter just about this structure
        if (![muxer pushAudioFrame:inBuffer->mAudioData size:inBuffer->mAudioDataByteSize]) {
        }
    }
    AudioQueueEnqueueBuffer (inAQ,
                             inBuffer,
                             0,
                             NULL);
}


@interface DJIRtmpMuxer() <DJIVTH264EncoderOutput> {
    
    DJIWidgetLinkQueue* videoCache;
    NSThread* workThread;
    dispatch_semaphore_t threadExitWait;
    
    AVFormatContext* fmt_context;
    AVFormatContext* i_fmt_context;
    
    AVStream *video_stream;
    AVStream *audio_stream;
    
    int64_t last_frame_pts;
    int64_t last_audio_pts;
    int64_t audio_samples_written;
    int64_t video_samples_written;
    
    //Audio Queue Input
    AudioStreamBasicDescription  audioRecordDataFormat;
    AudioStreamBasicDescription  audioOutputDataFormat;
    AudioQueueRef                audioQueue;
    AudioQueueBufferRef          audioQueueBuffers[AUDIO_QUEUE_BUFFER_COUNT];
    UInt32                       audioQueueBufferByteSize;
    
    //must push a video idr before start
    BOOL videoIDRPushed;
    BOOL audioQueueCanUse;
    BOOL streamConfigDidChanged;
    
    //debug dump
    FILE* dump_video_file;
    FILE* dump_audio_file;
    
    //audio buffer
    DJIAudioSampleBuffer* audioBuffer;
}

@property (nonatomic, assign) DJIRtmpMuxerStatus status;
@property (nonatomic, strong) DJIVTH264Encoder* encoder;
@property (nonatomic, assign) DJIVideoStreamBasicInfo streamInfo;

@property (nonatomic, assign) double startedDuration;
@property (nonatomic, assign) double outputFps;
@property (nonatomic, assign) int outputKbitPerSec;
@property (nonatomic, assign) int outputAudioKbitPerSec;
@property (nonatomic, assign) int videoFrameNum;
@property (nonatomic, assign) int audioFrameNum;
@property (nonatomic, assign) int bufferCount;
@property (nonatomic, assign) double audioGainLevel;

@property (nonatomic, strong) DJIRtmpIFrameProvider* iFrameProvider;
/**
 * Used for frame rate smoothing
 */
@property (nonatomic, strong) DJIVideoPreviewSmoothHelper* smoothHelper;
@property (nonatomic, weak) DJIVideoPreviewer* videoPreviewer;
@end

@implementation DJIRtmpMuxer

- (instancetype) _init
{
	self = [super init];
	if (self) {
		
		self.iFrameProvider = [[DJIRtmpIFrameProvider alloc] init];
		
		self.status = DJIRtmpMuxerStatus_Init;
		self.smoothHelper = [[DJIVideoPreviewSmoothHelper alloc] init];
		
		videoCache = [[DJIWidgetLinkQueue alloc] initWithSize:MUXER_MAX_BUFFER_FRAME_NUM];
		audioBuffer = [[DJIAudioSampleBuffer alloc] init];
		_serverURL = @"";
		
		// The default works in 1280*720 video mode
		_streamInfo.frameSize.width = 1280;
		_streamInfo.frameSize.height = 720;
		_streamInfo.frameRate = 30;
		_retryCount = INT_MAX;
		
		// enable local audio by default
		_enableAudio = YES;
	}
	return self;
}

+ (instancetype)sharedInstance {
	static DJIRtmpMuxer *logic = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		logic = [[DJIRtmpMuxer alloc] _init];
	});
	return logic;
}

-(void) setupVideoPreviewer:(DJIVideoPreviewer*)videoPreviewer
{
	self.videoPreviewer = videoPreviewer;
	[self.videoPreviewer registFrameProcessor:self];
	[self.videoPreviewer registStreamProcessor:self];
}

-(BOOL) streamProcessorHandleFrame:(uint8_t *)data size:(int)size {
    return NO;
}

-(void) setStatus:(DJIRtmpMuxerStatus)status
{
	_status = status;
	if (self.delegate && [self.delegate respondsToSelector:@selector(rtmpMuxer:didUpdateStreamState:)]) {
		[self.delegate rtmpMuxer:self didUpdateStreamState:_status];
	}
}

-(void) dealloc{
    if (_status == DJIRtmpMuxerStatus_Streaming
        || _status == DJIRtmpMuxerStatus_Connecting) {
        [self stop];
    }
    
    if (_encoder) {
        [_encoder invalidate];
        _encoder = nil;
    }
	
	self.videoPreviewer = nil;
    [self clearBuffer];
}

- (void) clearBuffer {
    
    //video buffer clear
    while ([videoCache count] != 0) {
        int pull_size = 0;
        VideoMuxerFrame* frame = (VideoMuxerFrame*)([videoCache pull:&pull_size]);
        
        if (frame && frame->data) {
            free(frame->data);
        }
        
        if (frame) {
            free(frame);
        }
    }
    
    //audio buffer clear
    [audioBuffer audioBufferClear];
}

-(BOOL) pushFrame:(VideoFrameH264Raw *)rawframe {
    
    if (!videoCache ||
        (_status != DJIRtmpMuxerStatus_Streaming && _status != DJIRtmpMuxerStatus_Connecting) ||
        !rawframe) {
        return NO;
    }
    
    if ([videoCache count] == MUXER_MAX_BUFFER_FRAME_NUM) {
        ERROR(@"buffer full on push video %d", [videoCache count]);
        [self clearBuffer];
        videoIDRPushed = NO;
    }
    
    if ([videoCache count] >= MUXER_DROP_FRAME_THRESHOLD) {
        //There are more frames stacked in the buffer. If you encounter an idr, clear the buffer.
        if (rawframe->frame_info.frame_flag.has_idr) {
            INFO(@"drop frames before idr:%d", rawframe->frame_uuid);
            [self clearBuffer];
        }
    }
    
    if (!videoIDRPushed && !rawframe->frame_info.frame_flag.has_idr) {
        //need idr frame
        return NO;
    }
    
    //idr cworkaround
    //rtmp must has at least one idr frame to start
    if (rawframe->frame_info.frame_flag.has_idr) {
        videoIDRPushed = YES;
    }
    
	VideoMuxerFrame* frame = (VideoMuxerFrame*)malloc(sizeof(VideoMuxerFrame));
    if (!frame) {
        return NO;
    }
    
    frame->type = VideoMuxerFrameType_Video;
    frame->data = (uint8_t*)rawframe;
    frame->size = sizeof(VideoFrameH264Raw)+rawframe->frame_size;
    frame->time_tag = [DJIVideoPreviewSmoothHelper getTick];
    
    if(![videoCache push:(uint8_t*)frame length:sizeof(VideoMuxerFrame)]){
        ERROR(@"buffer full on push video %d", [videoCache count]);
        return NO;
    }
    
    return YES;
}

- (BOOL)enqueueAudioFrame:(void* )data size:(int)size {
    
    // After receiving the original audio data, if you need gdp2gop, you need to put in the same transcoding queue to achieve synchronization
    // Otherwise it will be directly into the team
    if (!videoCache ||
        (_status != DJIRtmpMuxerStatus_Streaming && _status != DJIRtmpMuxerStatus_Connecting)) {
        return NO;
    }
    
    VideoMuxerFrame* frame = (VideoMuxerFrame*)malloc(sizeof(VideoMuxerFrame));
    if (!frame) {
        return NO;
    }
    
    frame->type = VideoMuxerFrameType_Audio;
    frame->data = malloc(size);
    frame->size = size;
    frame->time_tag = 0;
    memcpy(frame->data, data, size);
    
    if(![videoCache push:(uint8_t*)frame length:sizeof(VideoMuxerFrame)]){
        INFO(@"buffer full on push audio %d", [videoCache count]);
        return NO;
    }
    
    return YES;
}

-(BOOL) pushAudioFrame:(uint8_t*)data size:(int)size{
    
    if (!videoCache || (_status != DJIRtmpMuxerStatus_Streaming
                        && _status != DJIRtmpMuxerStatus_Connecting)) {
        return NO;
    }
    
    // Need to convert the code stream
    if (_convertGDR) {
        AudioFrameAACRaw* aacFrame = (AudioFrameAACRaw*)malloc(size+sizeof(AudioFrameAACRaw));
        aacFrame->type_tag = TYPE_TAG_AudioFrameAACRaw;
        aacFrame->frame_size = size;
        memcpy(aacFrame->frame_data, data, size);
        [_encoder pushAudioPacket:aacFrame];
        return YES;
    }
    
    if ([videoCache count] == MUXER_MAX_BUFFER_FRAME_NUM) {
        INFO(@"buffer full on push audio %d", [videoCache count]);
        return NO;
    }
    
    [self enqueueAudioFrame:data size:size];
    return YES;
}

- (BOOL)start {
	[self.videoPreviewer registFrameProcessor:self];
	[self.videoPreviewer registStreamProcessor:self];
	
    if (_status == DJIRtmpMuxerStatus_Streaming
        || _status == DJIRtmpMuxerStatus_Connecting
        || _status == DJIRtmpMuxerStatus_prepareIFrame) {
        return NO;
    }
    
    if (![_serverURL hasPrefix:@"rtmp://"] &&
        ![_serverURL hasPrefix:@"rtmps://"]) {
        return NO;
    }
    
    if (_enableAudio) {
        //Start audio queue input when streaming audio is enabled
        if (![self audio_queue_init]) {
            self.status = DJIRtmpMuxerStatus_Stoped;
            [self stop];
            return NO;
        }
        audioQueueCanUse = YES;
    }
    else{
        audioQueueCanUse = NO;
    }
    
    self.status = DJIRtmpMuxerStatus_Connecting;
    _outputFps = 0;
    _outputKbitPerSec = 0;
    _outputAudioKbitPerSec = 0;
    _videoFrameNum = 0;
    _audioFrameNum = 0;
    
    //rtmp work
    workThread = [[NSThread alloc] initWithTarget:self selector:@selector(rtmpWork) object:nil];
    [workThread setName:@"rtmp work thread"];
    threadExitWait = dispatch_semaphore_create(0);
    
    [self clearBuffer];
    [audioBuffer audioBufferClear];
    
    if (_enableAudio) {
        [self setMuteAudio:NO];
    }
    
    [workThread start];

    return YES;
};

-(void) stop {
    //notify thread
    if (workThread && [workThread isExecuting]) {
        [workThread cancel];
    }
	
	[self.videoPreviewer unregistFrameProcessor:self];
	[self.videoPreviewer unregistStreamProcessor:self];
    [self audio_queue_stop];
    self.outputFps = 0;
    self.outputKbitPerSec = 0;
    self.outputAudioKbitPerSec = 0;
    self.audioFrameNum = 0;
    self.videoFrameNum = 0;
    self.startedDuration = 0;
    self.encoder.enabled = NO;
    [self.iFrameProvider reset];
}

- (void)setMuteAudio:(BOOL)muteAudio {
    _muteAudio = muteAudio;
    if (muteAudio == NO && _enableAudio) {
        [self audio_queue_stop];
        [self audio_queue_init];
        [self audio_queue_start];
    }
}

#pragma mark - stream processor interface

-(BOOL) streamProcessorEnabled{
    return _enabled;
}

-(void) streamProcessorInfoChanged:(DJIVideoStreamBasicInfo *)info{
    _streamInfo = *info;
    _encoder.streamInfo = *(info);
    streamConfigDidChanged = YES;
}

-(void) streamProcessorPause{
    //do nothing
}

-(void) streamProcessorReset{
    //do nothing
}

-(BOOL) streamProcessorHandleFrameRaw:(VideoFrameH264Raw *)frame{
    //do nothing
    return NO;
}

-(DJIVideoStreamProcessorType) streamProcessorType{
    return DJIVideoStreamProcessorType_Consume;
}

#pragma mark - frame prossor interface

- (BOOL)videoProcessorEnabled{
    return _enabled;
}

-(void) videoProcessFrame:(VideoFrameYUV *)frame{
    [_encoder pushVideoFrame:frame];
}

#pragma mark - live encoder

- (BOOL)vtH264Encoder:(DJIVTH264Encoder *)encoder output:(VideoFrameH264Raw *)packet {
    // After starting the live broadcast, first open the encoder and get the I-frame to initialize the codec_context
    if (self.iFrameProvider.status != DJIRtmpIFrameProviderStatusFinish) {
        if (self.iFrameProvider.status != DJIRtmpIFrameProviderStatusProcessing) {
            [self.iFrameProvider processFrame:packet sps:encoder.currentSps pps:encoder.currentPps];
        }
        return NO;
    }
    if (packet->type_tag == TYPE_TAG_AudioFrameAACRaw) {
        AudioFrameAACRaw* raw = (AudioFrameAACRaw*)packet;
        [self enqueueAudioFrame:raw->frame_data size:raw->frame_size];
        free(packet);
        return YES;
    }
    return [self pushFrame:packet];
}

#pragma mark - thread work

- (void)rtmpWork {
    
#if LOG_VIDEO_INFO
    [DJIVideoStuckTester startTest];
#endif
    
    // create encoder
    DJIVTH264CompressConfiguration* config = [[DJIVTH264CompressConfiguration alloc] initWithUsageType:DJIVTH264CompressConfigurationUsageTypeLiveStream];
    _encoder = [[DJIVTH264Encoder alloc] initWithConfig:config delegate:self];
    DJIVideoStreamBasicInfo streamInfo = [DJIVideoPreviewer instance].currentStreamInfo;
    if ([DJIVideoPreviewer instance].detectRealtimeFrameRate) {
        streamInfo.frameRate = (int)[DJIVideoPreviewer instance].realTimeFrameRate;
    }
    self.streamInfo = streamInfo;
    _encoder.enabled = YES;
    
    
    BOOL stopWithBrokenStatus = NO;
    NSDate* startTime = [NSDate date];
    int connect_failed_count = 0;
    
    
    while (!workThread.isCancelled) {
        
        // Prepare iframes until done
        self.status = DJIRtmpMuxerStatus_prepareIFrame;
        while (!workThread.isCancelled && self.iFrameProvider.status != DJIRtmpIFrameProviderStatusFinish) {
            usleep(10000);
            continue;
        }
        
        // Set the state again, because reconnect will run the logic here
        self.status = DJIRtmpMuxerStatus_Connecting;
        INFO(@"rtmp session begin");
        if (![self ffmpeg_init]) {
            NSLog(@"init muxer faield");
            [self stop];
            break;
        }
        
        streamConfigDidChanged = NO;
        
        if (!fmt_context
            || !audio_stream
            || !video_stream) {
            continue;
        }
        
        AVDictionary *opt = NULL;
        INFO(@"connect to rtmp server:%@", _serverURL);
        
        if (avio_open2(&fmt_context->pb,[_serverURL UTF8String], AVIO_FLAG_WRITE, NULL, &opt) < 0) {
            ERROR(@"ERROR: Could not open rtmp url %@ retry:%d", _serverURL, connect_failed_count);
            connect_failed_count++;
            [self ffmpeg_shutdown];
            [self ffmpeg_free];
            
            if (connect_failed_count > self.retryCount) {
                //No longer try
                [self stop];
                stopWithBrokenStatus = YES;
                break;
            }
            
            if (connect_failed_count > 10) {
                usleep(3*1000*1000);
                continue;
            }
            
            usleep(1000*1000);
            continue;
        }
        connect_failed_count = 0;
        
        // Write file header
        if (workThread.isCancelled){
            continue;
        }
        
        //set the rotation of the video stream
        if (_rotate != 0) {
            
            //set rotation
            int rotate = 0;
            switch (_rotate) {
                case VideoStreamRotationDefault:
                    break;
                case VideoStreamRotationCW90:
                    rotate = 90;
                    break;
                case VideoStreamRotationCW180:
                    rotate = 180;
                    break;
                case VideoStreamRotationCW270:
                    rotate = 270;
                    break;
            }
            
            char rotation[10] = {0};
            sprintf(rotation, "%d", rotate);
            av_dict_set(&video_stream->metadata, "rotate", rotation, 0);
        }
        
        INFO(@"rtmp Writing output header");
        if(avformat_write_header(fmt_context, NULL) != 0) {
            ERROR(@"rtmp error: av_write_header failed");
            [self ffmpeg_shutdown];
            [self ffmpeg_free];
            continue;
        }
        
        video_samples_written = 0;
        audio_samples_written = 0;
        dump_video_file = nil;
        dump_audio_file = nil;
        
#if DUMP_VIDEO_STREAM
        NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* file = [docPath[0] stringByAppendingPathComponent:@"dump_liveStream.264"];
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
        dump_video_file = fopen(file.UTF8String, "wb");
#endif
        
#if DUMP_AUDIO_STREAM
        NSArray *docPath1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* file1 = [docPath1[0] stringByAppendingPathComponent:@"dump_liveStream.aac"];
        [[NSFileManager defaultManager] removeItemAtPath:file1 error:nil];
        dump_audio_file = fopen(file1.UTF8String, "wb");
#endif
        
        last_audio_pts = 0;
        last_frame_pts = 0;
        int stream_write_error_count = 0;
        int audio_last_count_time = 0;
        int video_last_count_time = 0;
        VideoMuxerFrame* frame = NULL;
        videoIDRPushed = NO;
        
        
        // The overhead in the loop
        uint64_t frame_cost_us = 0;
        self.status = DJIRtmpMuxerStatus_Streaming;
        self.audioGainLevel = 0;
        
        for (;;) {
            int pull_size = 0;
            frame = (VideoMuxerFrame*)([videoCache pull:&pull_size]);
            
            if ([workThread isCancelled]
                || !fmt_context
                || !audio_stream
                || !video_stream
                || streamConfigDidChanged) {
                INFO(@"restart transfer with reason:\n%d %d %d %d %d"
                     ,[workThread isCancelled]
                     ,!fmt_context
                     ,!audio_stream
                     ,!video_stream
                     ,streamConfigDidChanged);
                break;
            }
            
            if (!frame) {
                //continue without frame data
                continue;
            }
            
            double loopBegin = [DJIVideoPreviewSmoothHelper getTick];
            if (frame->size && frame->type == VideoMuxerFrameType_Video) {
                VideoFrameH264Raw* rawFrame = (VideoFrameH264Raw*)frame->data;
                if (rawFrame->frame_size != frame->size - sizeof(VideoFrameH264Raw)) {
                    //error frame
                    [self frameCleanup:frame];
                    frame = nil;
                    continue;
                }
                
                //idr check
                //move the idr check to push buffer
                //nature pts per video frame
                int nature_pts_one_frame = FLV_TIME_BASE/30;
                if (rawFrame->frame_info.fps) {
                    nature_pts_one_frame = FLV_TIME_BASE/rawFrame->frame_info.fps;
                }
                
                //add a slience audio when disable audio record
                if (!audioQueueCanUse) {
                    int audio_simple_count = (int)(AUDIO_SAMPLE_RATE/30.0);
                    if (_streamInfo.frameRate != 0) {
                        audio_simple_count = (int)(AUDIO_SAMPLE_RATE/(double)_streamInfo.frameRate);
                    }
                    [self ffmpeg_encodeAudioFrame:nil length:audio_simple_count];
                }
                else{
                    //send audio pack use audio data
                }
                
                //video pts from audio
                AVPacket v_pkt;
                av_init_packet(&v_pkt);
                
                //Sync video to audio
                uint64_t frame_pts = last_frame_pts+nature_pts_one_frame;
                if (frame_pts < (last_audio_pts - 3*nature_pts_one_frame)) {
                    //pts can not be the same
                    frame_pts = MAX(last_audio_pts+1, last_frame_pts+1);
                }
                if(frame_pts > (last_audio_pts + 3*nature_pts_one_frame)){
                    frame_pts = MAX(last_audio_pts+1, last_frame_pts+1);
                }
                
                
                v_pkt.pts = frame_pts;
                last_frame_pts = v_pkt.pts;
                
                //key frame mark
                if (rawFrame->frame_info.frame_flag.has_idr) {
                    v_pkt.flags |= AV_PKT_FLAG_KEY;
                }
                
                v_pkt.stream_index = video_stream->index;
                v_pkt.data = rawFrame->frame_data;
                v_pkt.size = rawFrame->frame_size;
                //INFO(@"pts:%lld", v_pkt.pts);
                
                if (workThread.cancelled
                    || !fmt_context){
                    av_free_packet(&v_pkt);
                    break;
                }
                
#if LOG_VIDEO_INFO
                [DJIVideoStuckTester startDecodeFrameWithIndex:_videoFrameNum+1];
#endif
                
                if(av_interleaved_write_frame(fmt_context, &v_pkt) != 0) {
                    stream_write_error_count++;
                    ERROR(@"Error writing video frame %d", stream_write_error_count);
                    if (stream_write_error_count > 3) {
                        av_free_packet(&v_pkt);
                        break;
                    }
                }
                
                else {
                    stream_write_error_count = 0;
                    _videoFrameNum++;
                    video_samples_written++;
                    
                    if (dump_video_file) {
                        fwrite(rawFrame->frame_data, rawFrame->frame_size, 1, dump_video_file);
                    }
                }
                av_free_packet(&v_pkt);
                
#if LOG_VIDEO_INFO
                [DJIVideoStuckTester finisedDecodeFrameWithIndex:_videoFrameNum withState:YES];
#endif
                
                //smooth control
                if (_smoothDelayTimeSeconds != 0) {
                    self.smoothHelper.requiredDelay = _smoothDelayTimeSeconds;
                    
                    // Use automatic frame rate detection
                    self.smoothHelper.requiredFrameDelta = 0;
                    self.smoothHelper.delayUpperLimits = 2.5*_smoothDelayTimeSeconds;
                    
                    double current_tick = [DJIVideoPreviewSmoothHelper getTick];
                    
                    double loopCost = [DJIVideoPreviewSmoothHelper getTick] - loopBegin;
                    frame_cost_us += loopCost;
                    
                    uint32_t ms_to_sleep = [self.smoothHelper sleepTimeForCurrentFrame:current_tick
                                                                  framePushInQueueTime:frame->time_tag
                                                                        decodeCostTime:loopCost];
                    if (ms_to_sleep < 1000) {
                        usleep(ms_to_sleep*1000);
                    }
                    
                    frame_cost_us = 0;
                    loopBegin = [DJIVideoPreviewSmoothHelper getTick];
                }
                
                //status check
                int tEndTime = (1000*(-[startTime timeIntervalSinceNow]));
                {
                    static int frame_count = 0;
                    static int bits_count = 0;
                    
                    frame_count++;
                    bits_count += frame->size*8;
                    
                    int diff = (int)((tEndTime - video_last_count_time));
                    if (diff >= 1000) {
                        _bufferCount = [videoCache count];
                        _outputFps = 1000*frame_count/(double)diff;
                        _outputKbitPerSec = (1000/(double)1024)*(bits_count/(double)diff);
                        
                        INFO(@"rtmp dur:%.0f fps:%.2f rate:%dkbps buffer:%d v:%d a:%d", _startedDuration, _outputFps, _outputKbitPerSec, [videoCache count], _videoFrameNum, _audioFrameNum);
                        
                        frame_count = 0;
                        bits_count = 0;
                        video_last_count_time = tEndTime;
                        self.startedDuration = [[NSDate date] timeIntervalSinceDate:startTime];
                    }
                }
            }
            
            else if(frame->size && frame->type == VideoMuxerFrameType_Audio && _enableAudio && audioQueueCanUse && videoIDRPushed){
                int send_data = [self ffmpeg_encodeAudioFrame:(short*)frame->data length:frame->size/2];
                if (send_data < 0){
                    stream_write_error_count++;
                    ERROR(@"Error writing audio frame %d", stream_write_error_count);
                    if (stream_write_error_count > 3) {
                        break;
                    }
                }
                else{
                    stream_write_error_count = 0;
                    _audioFrameNum++;
                }
                
                //status check
                int tEndTime = (1000*(-[startTime timeIntervalSinceNow]));
                {
                    static int frame_count = 0;
                    static int bits_count = 0;
                    
                    frame_count++;
                    bits_count += send_data*8;
                    
                    int diff = (int)((tEndTime - audio_last_count_time));
                    if (diff >= 1000) {
                        int audio_rate = (1000/(double)1024)*(bits_count/(double)diff);
                        
                        //INFO(@"rtmp audio fps:%.2f rate:%dkbps buffer:%d", audio_fps, audio_rate, [videoCache count]);
                        _outputAudioKbitPerSec = audio_rate;
                        frame_count = 0;
                        bits_count = 0;
                        audio_last_count_time = tEndTime;
                    }
                    else if(diff >= 100){
                        //10hz speed to refresh audio gain
                        if (self.muteAudio) {
                            self.audioGainLevel = 0;
                        }else{
                            self.audioGainLevel = [self calcAudioGain:(short*)frame->data sampleCount:frame->size/2];
                        }
                    }
                }
            }
            else {
                //do nothing with the frame
            }
            
            //clean up
            [self frameCleanup:frame];
            frame = nil;
            uint64_t loopCost = [DJIVideoPreviewSmoothHelper getTick] - loopBegin;
            frame_cost_us += loopCost;
        }//for (;;)
        
        //clean up
        [self frameCleanup:frame];
        frame = nil;
        
        if (dump_video_file) {
            fclose(dump_video_file);
            dump_video_file = nil;
        }
        
        if (dump_audio_file) {
            fclose(dump_audio_file);
            dump_audio_file = nil;
        }
        
        [self ffmpeg_shutdown];
        [self ffmpeg_free];
        _encoder.enabled = NO;
    }//while (!workThread.isCancelled)
    
ThreadEnd:
    {
        //release encoder
        DJIVTH264Encoder* encoder = _encoder;
        _encoder = nil;
        _audioGainLevel = 0;
        [encoder invalidate];
        
        [self ffmpeg_shutdown];
        [self ffmpeg_free];
        if (stopWithBrokenStatus) {
            self.status = DJIRtmpMuxerStatus_Broken;
        }
        else{
            self.status = DJIRtmpMuxerStatus_Stoped;
        }
        dispatch_semaphore_signal(threadExitWait);
        INFO(@"rtmp thread exit");
        
#if LOG_VIDEO_INFO
        [DJIVideoStuckTester endTest];
#endif
    }
}

- (void)frameCleanup:(VideoMuxerFrame*)frame{
    if (frame) {
        if (frame->data) {
            free(frame->data);
        }
        free(frame);
    }
}

#pragma mark - audio queue

- (BOOL)audio_queue_init{
	@synchronized(self){
		AVAudioSession *audioSession = [AVAudioSession sharedInstance];
		NSError *err = nil;
		[audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&err];
		if(err) {
			NSLog(@"set audio session to record %@", err);
		}
		
		//init format
		audioRecordDataFormat.mFormatID         = kAudioFormatLinearPCM;
		audioRecordDataFormat.mSampleRate       = AUDIO_SAMPLE_RATE;
		audioRecordDataFormat.mChannelsPerFrame = 1;
		audioRecordDataFormat.mBitsPerChannel   = 16;
		audioRecordDataFormat.mBytesPerPacket   =
		audioRecordDataFormat.mBytesPerFrame =
		audioRecordDataFormat.mChannelsPerFrame * (audioRecordDataFormat.mBitsPerChannel / 8);
		audioRecordDataFormat.mFramesPerPacket  = 1;
		
		//    kLinearPCMFormatFlagIsBigEndian
		audioRecordDataFormat.mFormatFlags =
		kLinearPCMFormatFlagIsSignedInteger
		| kLinearPCMFormatFlagIsPacked;
		
		
		if(0 != AudioQueueNewInput (&audioRecordDataFormat,
									AudioInputCallback,
									(__bridge void *)(self),
									NULL,
									kCFRunLoopCommonModes,
									0,
									&audioQueue)
		   ){
			return NO;
		}
		
		//make it 1 audio frame per video frame
		if (_streamInfo.frameRate != 0) {
			audioQueueBufferByteSize = 2*audioRecordDataFormat.mBitsPerChannel*AUDIO_SAMPLE_RATE/(8*_streamInfo.frameRate);
		}
		else{
			audioQueueBufferByteSize = 2*audioRecordDataFormat.mBitsPerChannel*AUDIO_SAMPLE_RATE/(8*30);
		}
		
		//create audio queue buffers
		for (int i = 0; i < AUDIO_QUEUE_BUFFER_COUNT; ++i) {
			AudioQueueAllocateBuffer (audioQueue,
									  audioQueueBufferByteSize,
									  &audioQueueBuffers[i]);
			
			AudioQueueEnqueueBuffer (audioQueue,
									 audioQueueBuffers[i],
									 0,
									 NULL);
		}
		return YES;
	}
}


- (void)audio_queue_start {
	@synchronized(self){
		if (audioQueue) {
			OSStatus status = AudioQueueStart(audioQueue, NULL);
			if(0 != status){
				NSLog(@"start audio queue failed %d, disable audio", status);
				audioQueueCanUse = NO;
			}
		}
		
		if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
			[[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
				if (granted) {
				}
				else {
					NSLog(@"start audio queue failed, disable audio");
                    self->audioQueueCanUse = NO;
				}
			}];
		}
	}
}

- (void)audio_queue_stop {
	@synchronized(self){
		if (audioQueue) {
			AudioQueuePause(audioQueue);
			AudioQueueReset(audioQueue);
			AudioQueueStop(audioQueue, true);
			AudioQueueDispose(audioQueue, true); //clean all buffers also
			audioQueue = NULL;
			for (int i=0; i<AUDIO_QUEUE_BUFFER_COUNT; i++) {
				audioQueueBuffers[i] = nil;
			}
		}
	}
}


#pragma mark - ffmpeg

- (BOOL)ffmpeg_init {
    
    if (self.iFrameProvider.status != DJIRtmpIFrameProviderStatusFinish) {
        return NO;
    }
    
    avcodec_register_all();
    av_register_all();
    avformat_network_init();
    
    fmt_context = avformat_alloc_context();
    i_fmt_context = avformat_alloc_context();
    
    AVOutputFormat* ofmt = av_guess_format("flv", NULL, NULL);
    if (ofmt) {
        NSLog(@"av_guess_format returned %s", ofmt->long_name);
    }
    else {
        NSLog(@"av_guess_format fail");
        goto cleanup;
    }
    
    fmt_context->oformat = ofmt;
    fmt_context->bit_rate = 2000 * 1000;
    
    NSLog(@"creating video stream");
    video_stream = avformat_new_stream(fmt_context, NULL);
    video_stream->id = 0;
    
    NSLog(@"creating audio stream");
    audio_stream = avformat_new_stream(fmt_context, NULL);
    audio_stream-> id = 1;
    
    // Here to read an I-frame from the local initialization codec_context
    if (self.iFrameProvider.iFrameFilePath == nil) {
        NSLog(@"the i frame file is not exsiting!");
        goto cleanup;
    }
    
    if (avformat_open_input(&i_fmt_context,self.iFrameProvider.iFrameFilePath.UTF8String, 0, 0) < 0) {
        NSLog(@"can't open input file !");
        goto cleanup;
    }
    
    if (avformat_find_stream_info(i_fmt_context, 0) < 0) {
        NSLog(@"can't find stream info !");
        goto cleanup;
    }
    
    AVCodecContext* video_codec_ctx = (*(i_fmt_context->streams))->codec;
    int dataLength = (int)self.iFrameProvider.extraData.length;
    uint8_t* data = malloc(dataLength);
    [self.iFrameProvider.extraData getBytes:data length:self.iFrameProvider.extraData.length];
    video_codec_ctx->extradata = data;
    video_codec_ctx->extradata_size = dataLength;
    video_codec_ctx -> has_b_frames = 0;
    video_codec_ctx->codec_type = AVMEDIA_TYPE_VIDEO;
    video_codec_ctx->level = 31;
    video_codec_ctx->width = (int)_streamInfo.frameSize.width;
    video_codec_ctx->height = (int)_streamInfo.frameSize.height;
    video_codec_ctx->pix_fmt = PIX_FMT_YUV420P;
    video_codec_ctx->rc_max_rate = 0;
    video_codec_ctx->rc_buffer_size = 0;
    video_codec_ctx->gop_size = 12;
    video_codec_ctx->max_b_frames = 0;
    video_codec_ctx->slices = 8;
    video_codec_ctx->b_frame_strategy = 1;
    video_codec_ctx->coder_type = 0;
    video_codec_ctx->me_cmp = 1;
    video_codec_ctx->me_range = 16;
    video_codec_ctx->qmin = 10;
    video_codec_ctx->qmax = 51;
    video_codec_ctx->keyint_min = 25;
    video_codec_ctx->refs= 3;
    video_codec_ctx->thread_count = 1;
    video_codec_ctx->slice_count = 1;
    video_codec_ctx->trellis = 0;
    video_codec_ctx->scenechange_threshold = 40;
    video_codec_ctx->flags |= CODEC_FLAG_LOOP_FILTER;
    video_codec_ctx->me_method = ME_HEX;
    video_codec_ctx->me_subpel_quality = 6;
    video_codec_ctx->i_quant_factor = 0.71;
    video_codec_ctx->qcompress = 0.6;
    video_codec_ctx->max_qdiff = 4;
    video_codec_ctx->time_base.den = 30;
    video_codec_ctx->time_base.num = 1;
    video_codec_ctx->bit_rate = 1000 * 1000;
    video_codec_ctx->bit_rate_tolerance = 0;
    video_codec_ctx->flags2 |= 0x00000100;
    
    //Option settings
    av_opt_set(video_codec_ctx,"partitions","i8x8,i4x4,p8x8,b8x8",0);
    av_opt_set_int(video_codec_ctx, "direct-pred", 1, 0);
    av_opt_set_int(video_codec_ctx, "rc-lookahead", 0, 0);
    av_opt_set_int(video_codec_ctx, "fast-pskip", 1, 0);
    av_opt_set_int(video_codec_ctx, "mixed-refs", 1, 0);
    av_opt_set_int(video_codec_ctx, "8x8dct", 0, 0);
    av_opt_set_int(video_codec_ctx, "weightb", 0, 0);
    if(fmt_context->oformat->flags & AVFMT_GLOBALHEADER) {
        video_codec_ctx->flags |= CODEC_FLAG_GLOBAL_HEADER;
    }
    
    AVDictionary *vopts = NULL;
    av_dict_set(&vopts, "profile", "main", 0);
    //av_dict_set(&vopts, "vprofile", "main", 0);
    av_dict_set(&vopts, "rc-lookahead", 0, 0);
    av_dict_set(&vopts, "tune", "film", 0);
    av_dict_set(&vopts, "preset", "ultrafast", 0);
    av_opt_set(video_codec_ctx->priv_data,"tune","film",0);
    av_opt_set(video_codec_ctx->priv_data,"preset","ultrafast",0);
    av_opt_set(video_codec_ctx->priv_data,"tune","film",0);
    
    // Copy the read codec_context to videoStrem
    avcodec_copy_context(video_stream -> codec,video_codec_ctx);
    
    
    
    // Open Audio Codec.
    // ======================
    if (true) {
        [audioBuffer audioBufferClear];
        AVCodec *audio_codec = avcodec_find_encoder(AV_CODEC_ID_AAC);
        if (!audio_codec) {
            NSLog(@"Did not find the audio codec");
            goto cleanup;
        }
        else {
            NSLog(@"Audio codec found!");
        }
        
        AVCodecContext *audio_codec_ctx = audio_stream->codec;
        audio_codec_ctx->codec_id = audio_codec->id;
        audio_codec_ctx->codec_type = AVMEDIA_TYPE_AUDIO;
        audio_codec_ctx->bit_rate = 128000;
        audio_codec_ctx->channels = 1;
        audio_codec_ctx->channel_layout = AV_CH_LAYOUT_MONO;
        //audio_codec_ctx->profile = FF_PROFILE_AAC_LOW;
        audio_codec_ctx->sample_fmt = AV_SAMPLE_FMT_FLT;
        audio_codec_ctx->sample_rate = AUDIO_SAMPLE_RATE;
        
        NSLog(@"Opening audio codec");
        AVDictionary *opts = NULL;
        av_dict_set(&opts, "strict", "experimental", 0);
        int open_res = 0;
        open_res = avcodec_open2(audio_codec_ctx, audio_codec, &opts);
        NSLog(@"audio frame size: %i", audio_codec_ctx->frame_size);
        if (open_res < 0) {
            NSLog(@"Error opening audio codec: %i", open_res);
            goto cleanup;
        }
    }
    
    last_audio_pts = 0;
    last_frame_pts = 0;
    audio_samples_written = 0;
    video_samples_written = 0;
    
    NSLog(@"ffmpeg encoding init done");
    return true;
    
cleanup:
    [self ffmpeg_shutdown];
    [self ffmpeg_free];
    return false;
}

-(void) ffmpeg_shutdown{
    if (!fmt_context) {
        return;
    }
    if (fmt_context->pb) {
        avio_close(fmt_context->pb);
        fmt_context->pb = nil;
    }
    
    if (video_stream) {
        avcodec_close(video_stream->codec);
        video_stream = nil;
    }
    
    if (audio_stream) {
        avcodec_close(audio_stream->codec);
        audio_stream = nil;
    }
}

- (void)ffmpeg_free {
    if (fmt_context) {
        av_free(fmt_context);
        fmt_context = NULL;
        video_stream = NULL;
        audio_stream = NULL;
    }
    if (i_fmt_context) {
        av_free(i_fmt_context);
        i_fmt_context = NULL;
    }
}

-(int) ffmpeg_encodeAudioFrame:(int16_t*)audio_data length:(int)length{
    
    if (!fmt_context || !audio_stream) {
        return 0;
    }
    
    AVCodecContext *audio_codec_ctx = audio_stream->codec;
    int total_compressed = 0;
    
    if (_muteAudio) {
        // Audio data is not pushed when muted
        [audioBuffer audioBufferPush:nil count:length];
    }
    else{
        [audioBuffer audioBufferPush:audio_data count:length];
    }
    
    while ([audioBuffer audioBufferSize] >= audio_codec_ctx->frame_size
           && fmt_context
           && audio_stream
           && !workThread.isCancelled) {
        
        AVPacket pkt = {0};
        AVFrame* frame = av_frame_alloc();
        frame->linesize[0] = audio_codec_ctx->frame_size*sizeof(float);
        frame->nb_samples = audio_codec_ctx->frame_size;
        frame->channels = 1;
        frame->channel_layout = AV_CH_LAYOUT_MONO;
        frame->format = AV_SAMPLE_FMT_FLT;
        frame->data[0] = (uint8_t*)[audioBuffer audioBufferGet];
        
        int got_pkt = 0;
        int compressed_length = 0;
        avcodec_encode_audio2(audio_codec_ctx, &pkt, frame, &got_pkt);
        if (got_pkt) {
            compressed_length = pkt.size;
        }
        
        //int compressed_length = avcodec_encode_audio(audio_codec_ctx, outputBuffer, AAC_COMPRESS_BUFFER_SIZE, (short*)AudioBuffer_Get());
        [audioBuffer audioBufferPop:audio_codec_ctx->frame_size];
        
        total_compressed += compressed_length;
        audio_samples_written += audio_codec_ctx->frame_size;
        
        int new_pts = (int)((audio_samples_written * FLV_TIME_BASE) / AUDIO_SAMPLE_RATE);
        last_audio_pts = new_pts;
        
        if (compressed_length > 0) {
            pkt.size = compressed_length;
            pkt.pts = new_pts;
            //LOGI("audio_samples_written: %i  comp_length: %i   pts: %i", (int)audio_samples_written, (int)compressed_length, (int)new_pts);
            pkt.flags |= 0x0001;
            pkt.stream_index = audio_stream->index;
            
            if (dump_audio_file) {
                fwrite(pkt.data, pkt.size, 1, dump_audio_file);
            }
            
            if (av_interleaved_write_frame(fmt_context, &pkt) != 0) {
                LOGI("Error writing audio frame");
                av_frame_free(&frame);
                av_free_packet(&pkt);
                return -1;
            }
        }
        
        av_frame_free(&frame);
        av_free_packet(&pkt);
    }
    
    return total_compressed;
}

-(double) calcAudioGain:(short*)sample sampleCount:(int)count{
    if (count == 0) {
        return 0;
    }
    
    // Calculate the volume level, originally need fft, add directly for convenience
    double sum = 0;
    for (int i=0; i<count; i++) {
        sum += abs(sample[i]);
    }
    
    //This 100 is roughly calculated, scrambling
    sum = 100*sum/(count*32767);
    return MIN(sum, 1.0);
}

@end
