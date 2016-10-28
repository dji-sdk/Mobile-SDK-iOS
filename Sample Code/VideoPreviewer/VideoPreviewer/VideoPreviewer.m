//
//  VideoPreviewer.m
//
//  Copyright (c) 2013 DJI. All rights reserved.
//


#import "VideoPreviewer.h"
#import <sys/time.h>
#include <OpenGLES/ES2/gl.h>
#import "SoftwareDecodeProcessor.h"
#import "LB2AUDHackParser.h"
#import "VideoPreviewerMacros.h"

#define FRAME_DROP_THRESHOLD  (70)
#define RENDER_DROP_THRESHOLD (5)

@interface VideoPreviewer () <
H264DecoderOutput,
MovieGLViewDelegate,
LB2AUDHackParserDelegate>{
    
    NSThread *_decodeThread;    //decode thread
    MovieGLView *_glView;   //OpenGL render
    
    BOOL videoDecoderCanReset;
    int videoDecoderFailedCount;
    int glViewRenderFrameCount; //GLView render input frame count
    int safe_resume_skip_count; //hardware decode under the safe_resume should skip frame count
    
    DJIVideoStreamBasicInfo _stream_basic_info;
    pthread_mutex_t _processor_mutex;
    pthread_mutex_t _render_mutex; //mutex for rendering protection against conducted openGL calls in the background
    
    long long _lastDataInputTime; //Last received time data
    long long _lastFrameDecodedTime; //Last time available to decode
    
    
#if __TEST_FRAME_DUMP__
    /**
     *  dumper for frame
     */
    DJIH264FrameRawLayerDumper* frameLayerDumper;
#endif
    
#if __TEST_PACK_DUMP__
    DJIDataDumper* packLayerDumper;
#endif
}

/**
 *  YES if this is the first instance
 */
@property (nonatomic, assign) BOOL isDefaultPreviewer;

/**
 *  frame buffer queue
 */
@property(nonatomic, strong) VideoPreviewerQueue *dataQueue;

//ffmpeg warpper
@property (strong, nonatomic) VideoFrameExtractor *videoExtractor;
//hardware decode use videotool box on ios8
@property (strong, nonatomic) H264VTDecode *hw_decoder;
//software decoder use ffmpeg
@property (strong, nonatomic) SoftwareDecodeProcessor* soft_decoder;
//decoder current state
@property (assign, nonatomic) VideoDecoderStatus decoderStatus;
//frame output type
@property (assign, nonatomic) VPFrameType frameOutputType;
//stream processor list
@property (strong, nonatomic) NSMutableArray* stream_processor_list;
@property (strong, nonatomic) NSMutableArray* frame_processor_list;
@property (assign, nonatomic) BOOL grayOutPause;
@property (assign, nonatomic) CGRect frame;

//remove the redundant aud in LB2's stream
@property (strong, nonatomic) LB2AUDHackParser* lb2Hack;
@end

@implementation VideoPreviewer
{
    dispatch_queue_t _dispatchQueue;
}

-(id)init
{
    self= [super init];

    _dispatchQueue = dispatch_queue_create("video_previewer_async_queue", DISPATCH_QUEUE_SERIAL);

    _decodeThread          = nil;
    _glView                = nil;
    _type                  = VideoPreviewerTypeAutoAdapt;
    _decoderStatus         = VideoDecoderStatus_Normal;
    _dataQueue             = [[VideoPreviewerQueue alloc] initWithSize:100];
    _stream_processor_list = [[NSMutableArray alloc] init];
    _frame_processor_list  = [[NSMutableArray alloc] init];
    _enableFastUpload      = YES; //default use fast upload
    safe_resume_skip_count = 0;
    
    _videoExtractor = [[VideoFrameExtractor alloc] initExtractor];
    [_videoExtractor setShouldVerifyVideoStream:YES];
    pthread_mutex_init(&_processor_mutex, nil);
    pthread_mutex_init(&_render_mutex, nil);
    
    memset(&_status, 0, sizeof(VideoPreviewerStatus));
    _status.isInit    = YES;
    _status.isRunning = NO;
    
    memset(&_stream_basic_info, 0, sizeof(_stream_basic_info));
    //default is inspire frame rate
    _stream_basic_info.frameRate   = 30;
    _stream_basic_info.encoderType = H264EncoderType_DM368_inspire;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeGround:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    
    //soft decoder
    _soft_decoder = [[SoftwareDecodeProcessor alloc] initWithExtractor:_videoExtractor];
    _soft_decoder.frameProcessor = self;
    
    
    //Simulator hardware decoding will be stuck in callback
#if !TARGET_IPHONE_SIMULATOR
    
    if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
        //use hardware decode on ios8
        _hw_decoder = [[H264VTDecode alloc] init];
        _hw_decoder.delegate = self;
    }
#endif
    
    [self registStreamProcessor:_soft_decoder];
    [self registStreamProcessor:_hw_decoder];
    
    //default is inspire
    self.encoderType = H264EncoderType_DM368_inspire;
    
    //lb2 hack
    self.lb2Hack = [[LB2AUDHackParser alloc] init];
    self.lb2Hack.delegate = self;

    return self;
}

-(void) dealloc
{
    if (_videoExtractor) {
        _videoExtractor.delegate = nil;
    }
    
    [_videoExtractor freeExtractor];
    [self close];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) appDidEnterBackground:(NSNotification*)notify
{
    [self enterBackground];
}

-(void) appWillEnterForeGround:(NSNotification *)notify
{
    [self enterForegournd];
}

#pragma mark - public

+(VideoPreviewer*) instance
{
    static VideoPreviewer* previewer = nil;
    if(previewer == nil)
    {
        @synchronized (self) {
            if (previewer == nil) {
                previewer = [[VideoPreviewer alloc] init];
                previewer.isDefaultPreviewer = YES;
            }
        }
    }
    return previewer;
}

-(void) push:(uint8_t*)videoData length:(int)len
{
    _lastDataInputTime = [self getTickCount];
    if (_status.isRunning) {
        if (_encoderType == H264EncoderType_LightBridge2) {
            ////Remove the extra aud in lb2
            [_lb2Hack parse:videoData inSize:len];
        }else{
            [_videoExtractor parseVideo:videoData length:len withFrame:^(VideoFrameH264Raw *frame) {
                if (!frame) {
                    return;
                }
                
                if (self.dataQueue.count > FRAME_DROP_THRESHOLD) {
                    NSLog(@"decode dataqueue drop %d", FRAME_DROP_THRESHOLD);
                    [self.dataQueue clear];
                }
                [self.dataQueue push:(uint8_t*)frame length:sizeof(VideoFrameH264Raw) + frame->frame_size];
            }];
        }
    }
    else
    {
        [self.dataQueue clear];
    }
}

-(void) clearVideoData
{
    [self.dataQueue clear];
}

-(void) snapshotPreview:(void(^)(UIImage* snapshot))block{
    if (!_glView || _status.isPause || safe_resume_skip_count) {
        if (block) {
            block(nil);
        };
        return;
    }
    
    _glView.snapshotCallback = block;
}

-(void) snapshotThumnnail:(void(^)(UIImage* snapshot))block{
    if (!_glView || _status.isPause || safe_resume_skip_count) {
        if (block) {
            block(nil);
        };
        return;
    }
    
    _glView.snapshotThumbnailCallback = block;
}


-(BOOL)setView:(UIView *)view
{
    BEGIN_DISPATCH_QUEUE
    if(_glView == nil){
        _glView = [[MovieGLView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, view.frame.size.width, view.frame.size.height)];
        _glView.delegate = self;
        _glView.rotation = self.rotation;
        _glView.contentClipRect = self.contentClipRect;
        //set self frame property
        [self movieGlView:_glView didChangedFrame:_glView.frame];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_glView.superview != view){
            [view addSubview:_glView];
        }
        [view sendSubviewToBack:_glView];
        [_glView adjustSize];
        _status.isGLViewInit = YES;
    });
    END_DISPATCH_QUEUE
    return NO;
}

-(void)unSetView
{
    BEGIN_DISPATCH_QUEUE
    if(_glView != nil && _glView.superview !=nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_glView removeFromSuperview];
            //_glView = nil; // Deliberately not release dglView, Avoid each entry view flickering。
            _status.isGLViewInit = NO;
        });
    }
    END_DISPATCH_QUEUE
}

-(void)adjustViewSize{
    BEGIN_DISPATCH_QUEUE
    pthread_mutex_lock(&_render_mutex);
    if (_glView && [self glviewCanRender]) {
        [_glView adjustSize];
    }
    pthread_mutex_unlock(&_render_mutex);
    END_DISPATCH_QUEUE
}

-(CGPoint) convertPoint:(CGPoint)point toVideoViewFromView:(UIView*)view{
    if (!_glView) {
        return CGPointZero;
    }
    
    return [_glView convertPoint:point fromView:view];
}

-(CGPoint) convertPoint:(CGPoint)point fromVideoViewToView:(UIView *)view{
    if (!_glView) {
        return CGPointZero;
    }
    
    return [_glView convertPoint:point toView:view];
}

- (BOOL)start
{
    BEGIN_DISPATCH_QUEUE
    if(_decodeThread == nil && !_status.isRunning)
    {
        _decodeThread = [[NSThread alloc] initWithTarget:self selector:@selector(decodeRunloop) object:nil];
        _decodeThread.qualityOfService = NSQualityOfServiceUserInteractive;
        [_decodeThread start];
    }
    END_DISPATCH_QUEUE
    return YES;
}

-(void) reset
{
    BEGIN_DISPATCH_QUEUE
    if(_decodeThread && _status.isRunning)
    {
        safe_resume_skip_count = 0;
        _status.isRunning = NO;
        while (!_status.isFinish) {
            usleep(10000);
        }
        [_decodeThread cancel];
        while (!_decodeThread.isFinished) {
            usleep(10000);
        }
        _decodeThread = nil;
        [_videoExtractor clearBuffer];
        [_dataQueue clear];
        _decodeThread = [[NSThread alloc] initWithTarget:self selector:@selector(decodeRunloop) object:nil];
        [_decodeThread start];
        
        if (_hw_decoder) {
            [_hw_decoder resetLater];
            
        }

        for (id<VideoStreamProcessor> processor in _stream_processor_list) {
            if ([processor respondsToSelector:@selector(streamProcessorReset)]) {
                [processor streamProcessorReset];
            }
        }
    }
    END_DISPATCH_QUEUE
}

- (void)resume{
    BEGIN_DISPATCH_QUEUE
    _status.isPause = NO;
    NSLog(@"Resume the decoding");
    END_DISPATCH_QUEUE
}

- (void)safeResume{
    NSLog(@"begin Try safe resuming");
    safe_resume_skip_count = 25;
    [self resume];
}

- (void)pause{
    [self pauseWithGrayout:YES];
}

- (void)pauseWithGrayout:(BOOL)isGrayout{
    BEGIN_DISPATCH_QUEUE
    _status.isPause = YES;
    _grayOutPause = isGrayout;
    NSLog(@"Pause decoding");
    //Wake up waiting threads will immediately render a black white image
    [self.dataQueue wakeupReader];
    
    for (id<VideoStreamProcessor> processor in _stream_processor_list) {
        if ([processor respondsToSelector:@selector(streamProcessorPause)]) {
            [processor streamProcessorPause];
        }
    }
    END_DISPATCH_QUEUE
}

- (void)close{
    BEGIN_DISPATCH_QUEUE
    [_dataQueue clear];
    if(_decodeThread!=nil){
        [_decodeThread cancel];
        _decodeThread = nil;
    }
    _status.isRunning = NO;
    END_DISPATCH_QUEUE
}

- (void)setType:(VideoPreviewerType)type{
    if(_type == type)return;
    if(_glView == nil)return;
    BEGIN_DISPATCH_QUEUE
    pthread_mutex_lock(&_render_mutex);
    _type = type;
    if(_type == VideoPreviewerTypeFullWindow){
        [_glView setType:VideoPresentContentModeAspectFill];
        
        if ([self glviewCanRender]) {
            [_glView render:nil];
        }
    }
    else if(_type == VideoPreviewerTypeAutoAdapt){
        [_glView setType:VideoPresentContentModeAspectFit];
        
        if ([self glviewCanRender]) {
            [_glView render:nil];
        }
    }
    pthread_mutex_unlock(&_render_mutex);
    END_DISPATCH_QUEUE
}

-(void) setRotation:(VideoStreamRotationType)rotation{
    if (_rotation == rotation) {
        return;
    }
    
    _rotation = rotation;
    [_glView setRotation:rotation];
}

-(void) setContentClipRect:(CGRect)rect{
    if (CGRectEqualToRect(rect, _contentClipRect)) {
        return;
    }
    
    _contentClipRect = rect;
    [_glView setContentClipRect:rect];
}

-(BOOL) glviewCanRender{
    return !_status.isBackground && _status.isGLViewInit;
}

-(void) enableOverExposedWarning:(float)threshold
{
    _glView.overExposedMark = threshold;
}

-(void) enableFocusWarning:(BOOL)status
{
    _glView.useSobelProcess  = status;
}

-(void) setFocusWarningRange:(CGRect)range{
    _glView.sobelRange = range;
}

- (void)setFocusWarningThreshold:(float)threshold{
    _glView.focusWarningThreshold = threshold;
}

-(void) setLuminanceScale:(float)scale{
    _glView.luminanceScale = scale;
}

-(void) setEncoderType:(H264EncoderType)encoderType{
    if (_encoderType == encoderType) {
        return;
    }
    
    _encoderType = encoderType;
    _stream_basic_info.encoderType = encoderType;
}

-(void) setEnableHardwareDecode:(BOOL)enableHardwareDecode{
    if (_enableHardwareDecode == enableHardwareDecode) {
        return;
    }
    
    _enableHardwareDecode = enableHardwareDecode;
    [_hw_decoder resetLater];
}


-(void) registStreamProcessor:(id<VideoStreamProcessor>)processor{
    if (processor) {
        
        pthread_mutex_lock(&_processor_mutex);
        [_stream_processor_list addObject:processor];
        pthread_mutex_unlock(&_processor_mutex);
    }
}

-(void) unregistStreamProcessor:(id)processor{
    pthread_mutex_lock(&_processor_mutex);
    [_stream_processor_list removeObject:processor];
    pthread_mutex_unlock(&_processor_mutex);
}

-(void) registFrameProcessor:(id<VideoFrameProcessor>)processor{
    if (processor) {
        
        pthread_mutex_lock(&_processor_mutex);
        [_frame_processor_list addObject:processor];
        pthread_mutex_unlock(&_processor_mutex);
    }
}

-(void) unregistFrameProcessor:(id)processor{
    
    pthread_mutex_lock(&_processor_mutex);
    [_frame_processor_list removeObject:processor];
    pthread_mutex_unlock(&_processor_mutex);
}

#pragma mark - private
- (void)enterBackground{
    //It is not allowed to call OpenGL's interface in the background. Ensure all work is done before entering the background.
    pthread_mutex_lock(&_render_mutex);
    NSLog(@"videoPreviewer background");
    _status.isBackground = YES;
    pthread_mutex_unlock(&_render_mutex);
}

- (void)enterForegournd{
    NSLog(@"videoPreviewer active");
    _status.isBackground = NO;
}

// Update the decoder's status according to the timestamp when the previous data is received
- (void)updateDecoderStatus{
    if (_status.isPause) {//not update under the pause state
        return;
    }
    
    long long current = [self getTickCount];

    if (current - _lastDataInputTime > 2000*1000) {
        self.decoderStatus = VideoDecoderStatus_NoData;
        return;
    }
    
    if (current - _lastFrameDecodedTime > 2000*1000) {
        self.decoderStatus = VideoDecoderStatus_DecoderError;
        return;
    }
    
    self.decoderStatus = VideoDecoderStatus_Normal;
    return;
}

-(long long) getTickCount
{
    struct timeval t;
    gettimeofday(&t, NULL);
    long long microSec = t.tv_sec*1000*1000 + t.tv_usec;
    
    return microSec;
}

-(void) decodeRunloop
{
    _status.isRunning = YES;
    _status.isFinish = NO;
    safe_resume_skip_count = 0;
    
    videoDecoderCanReset = NO;
    videoDecoderFailedCount = 0;
    DJIVideoStreamBasicInfo current_stream_info = {0};
    memcpy(&current_stream_info, &_stream_basic_info, sizeof(DJIVideoStreamBasicInfo));
    
    while(_status.isRunning)
    {
        @autoreleasepool {
            VideoFrameH264Raw* frameRaw = nil;
            int inputDataSize = 0;
            uint8_t *inputData = nil;
            
            int queueNodeSize;
            //Normal access to data
            frameRaw = (VideoFrameH264Raw*)[_dataQueue pull:&queueNodeSize];

            if (frameRaw && frameRaw->frame_size + sizeof(VideoFrameH264Raw) == queueNodeSize) {
                inputData = frameRaw->frame_data;
                inputDataSize = frameRaw->frame_size;
            }
            [self updateDecoderStatus];
            
#if __TEST_FRAME_DUMP__
            if (!frameLayerDumper) {
                frameLayerDumper = [[DJIH264FrameRawLayerDumper alloc] init];
            }
            [frameLayerDumper dumpFrame:frameRaw];
#endif
            
            if(inputData == NULL)
            {
                if (safe_resume_skip_count) {
                    //waiting for safe resume
                    _status.hasImage = NO; // no image, but it won't trigger the NoImage notification
                    continue;
                }
                
                videoDecoderCanReset = NO;
                pthread_mutex_lock(&_render_mutex);
                if([self glviewCanRender]){
                    // render as grey when it is paused
                    _glView.grayScale = _grayOutPause;
                    [_glView render:nil];
                    _glView.grayScale = NO;
                }
                pthread_mutex_unlock(&_render_mutex);
                
                if(_status.hasImage && !_status.isPause){
                    _status.hasImage = NO;
                    
                    if (self.isDefaultPreviewer) {
                        //only notify if this is default previewer
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:VIDEO_PREVIEWER_EVEN_NOTIFICATIOIN
                                                                                object:@(VideoPreviewerEventNoImage)];
                        });
                    }
                }
                continue;
            }
            
            if(!_status.hasImage){
                _status.hasImage = YES;
                if (self.isDefaultPreviewer) {
                    //only notify if this is default previewer
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:VIDEO_PREVIEWER_EVEN_NOTIFICATIOIN
                                                                            object:@(VideoPreviewerEventHasImage)];
                    });
                }
            }
            
            BOOL stream_info_changed = NO;
            _stream_basic_info.frameRate = _videoExtractor.frameRate;
            _stream_basic_info.frameSize = CGSizeMake(_videoExtractor.outputWidth, _videoExtractor.outputHeight);
            if (memcmp(&current_stream_info, &_stream_basic_info, sizeof(current_stream_info)) !=0 ) {
                current_stream_info = _stream_basic_info;
                stream_info_changed = YES;
            }
            
            
            if (frameRaw->type_tag == TYPE_TAG_VideoFrameH264Raw) {
                
                //decoder select
                if(_hw_decoder && !_hw_decoder.hardwareUnavailable && _enableHardwareDecode){
                    //decode use video toolbox
                    _hw_decoder.enabled = YES;
                    _hw_decoder.enableFastUpload = self.enableFastUpload;
                    _soft_decoder.enabled = NO;
                    
                    if (self.enableFastUpload) {
                        //fast upload，the output format is difference
                        self.frameOutputType = VPFrameTypeYUV420SemiPlaner;
                    }
                    else{
                        self.frameOutputType = VPFrameTypeYUV420Planer;
                    }
                }
                else{
                    _hw_decoder.enabled = NO;
                    _soft_decoder.enabled = YES;
                    self.frameOutputType = VPFrameTypeYUV420Planer;
                }

                // Phantom 4 workaround: frames of Phantom 4 may set the IDR
                // flag mistakenly. To be save, unset the IDR flag for all frames.
                if (_encoderType == H264EncoderType_1860_phantom4x) {
                    frameRaw->frame_info.frame_flag.has_idr = 0;
                }
                
                //rotation info set
                //will effect video cache system
                frameRaw->frame_info.rotate = _rotation;
                
                pthread_mutex_lock(&_processor_mutex);
                NSArray* streamProcessorCopyList = [NSArray arrayWithArray:_stream_processor_list];
                pthread_mutex_unlock(&_processor_mutex);
                
                //processors
                for (id<VideoStreamProcessor> processor in streamProcessorCopyList) {
                    if (![processor conformsToProtocol:@protocol(VideoStreamProcessor)]) {
                        continue;
                    }
                    
                    if (stream_info_changed && [processor respondsToSelector:@selector(streamProcessorInfoChanged:)]) {
                        [processor streamProcessorInfoChanged:&current_stream_info];
                    }
                    
                    if (![processor streamProcessorEnabled]) {
                        continue;
                    }
                    
                    DJIVideoStreamProcessorType processor_type = [processor streamProcessorType];
                    
                    if (processor_type == DJIVideoStreamProcessorType_Decoder) {
                        //A decoder having a special treatment
                        if(!_status.isBackground){ //Background without decoding
#if __TEST_VIDEO_STUCK__
                            [DJIVideoStuckTester startDecodeFrameWithIndex:frameRaw->frame_uuid];
#endif
                            bool isSuccess = false;
                            if ([processor streamProcessorHandleFrameRaw:frameRaw]) {
                                //success decoding! reset failCount
                                videoDecoderFailedCount = 0;
                                
                                videoDecoderCanReset = YES;
                                isSuccess = true;
                            }else{
#if __TEST_VIDEO_STUCK__
                                [DJIVideoStuckTester finisedDecodeFrameWithIndex:frameRaw->frame_uuid withState:false];
#endif
                                [self videoProcessFailedFrame];
                            }
                        }
                    }
                    else if(processor_type == DJIVideoStreamProcessorType_Modify
                             || processor_type == DJIVideoStreamProcessorType_Passthrough){
                        //It does not affect the subsequent processor
                        [processor streamProcessorHandleFrameRaw:frameRaw];
                        //[processor streamProcessorHandleFrame:inputData size:inputDataSize];
                    }
                    else if (processor_type == DJIVideoStreamProcessorType_Consume){
                        if(processor != _stream_processor_list.lastObject) {
                            //consume not in need of a last copy data
                            VideoFrameH264Raw* data_copy = (VideoFrameH264Raw*)malloc(queueNodeSize);
                            memcpy(data_copy, frameRaw, queueNodeSize);
                            if (![processor streamProcessorHandleFrameRaw:data_copy]) {
                                free(data_copy);
                            }
                        }
                        else if([processor streamProcessorHandleFrameRaw:frameRaw]){
                            //Consumed data, no copy
                            frameRaw = NULL;
                        }
                    }
                }
            }
            
#if __PERFROMANCE_COUNT__
            //Performance Testing
            [self performanceCount:inputDataSize];
#endif
            
            if(safe_resume_skip_count){
                safe_resume_skip_count--;
                //NSLog(@"safe resume frame:%d", safe_resume_skip_count);
                if (safe_resume_skip_count == 0) { //Recovering from decoding pause
                    NSLog(@"safe resume complete");
                    
                    if (self.isDefaultPreviewer) {
                        //only notify if this is default previewer
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:VIDEO_PREVIEWER_EVEN_NOTIFICATIOIN object:@(VideoPreviewerEventResumeReady)];
                        });
                    }
                }
            }
            
            
            if (frameRaw) {
                free(frameRaw);
                frameRaw = NULL;
            }
        }
    }
    
    _status.isFinish = YES;
}

// This method has to be executed with render mutex locked.
-(void) decoderRenderFrame:(VideoFrameYUV*)frame{
    //Out frame processing
    BOOL dropFrame = NO;
    if (self.dataQueue.count >= 2*RENDER_DROP_THRESHOLD)
    {
        if (glViewRenderFrameCount% 3!=0) {
            dropFrame = YES;
        }
    }
    else if(self.dataQueue.count > RENDER_DROP_THRESHOLD)
    {
        if (glViewRenderFrameCount%2 != 0) {
            dropFrame = YES;
        }
    }
    
    if (!dropFrame) {
        [_glView render:frame];
    }
        
    glViewRenderFrameCount++;
}
#pragma mark - glview frame change

-(void) movieGlView:(MovieGLView *)view didChangedFrame:(CGRect)frame{
    self.frame = frame;
}

#pragma mark - lb2 hack delegate

-(void) lb2AUDHackParser:(id)parser didParsedData:(void *)data size:(int)size{
    
    [_videoExtractor parseVideo:data length:size withFrame:^(VideoFrameH264Raw *frame) {
        if (!frame) {
            return;
        }
        
        if (self.dataQueue.count > FRAME_DROP_THRESHOLD) {
            NSLog(@"decode dataqueue drop %d", FRAME_DROP_THRESHOLD);
            [self.dataQueue clear];
        }
        [self.dataQueue push:(uint8_t*)frame length:sizeof(VideoFrameH264Raw) + frame->frame_size];
    }];
}

#pragma mark - frame processor interface

-(BOOL) videoProcessorEnabled
{
    return YES;
}

-(void) videoProcessFrame:(VideoFrameYUV *)frame{
    _lastFrameDecodedTime = [self getTickCount];
    
    if (safe_resume_skip_count || _status.isPause) {
        //Decoding need to skip a certain number of frames
        return;
    }
    
    pthread_mutex_lock(&_render_mutex);
    if ([self glviewCanRender]) {
        [self decoderRenderFrame:frame];
    }
    pthread_mutex_unlock(&_render_mutex);
    
    pthread_mutex_lock(&_processor_mutex);
    NSArray* frameProcessorCopyList = [NSArray arrayWithArray:_frame_processor_list];
    pthread_mutex_unlock(&_processor_mutex);
    
    for (id<VideoFrameProcessor> processor in frameProcessorCopyList) {
        if ([processor conformsToProtocol:@protocol(VideoFrameProcessor)]) {
            
            if (![processor videoProcessorEnabled]) {
                continue;
            }
            
            [processor videoProcessFrame:frame];
        }
    }
}

//decode single frame failed.
-(void) videoProcessFailedFrame{
    
    videoDecoderFailedCount++;
    
    if (videoDecoderFailedCount >= 6) {
        if (videoDecoderCanReset || _enableHardwareDecode){
            [self reset];
            videoDecoderCanReset = NO;
        }
        
        videoDecoderFailedCount = 0;
    }
    
    pthread_mutex_lock(&_processor_mutex);
    NSArray* frameProcessorCopyList = [NSArray arrayWithArray:_frame_processor_list];
    pthread_mutex_unlock(&_processor_mutex);
    
    for (id<VideoFrameProcessor> processor in frameProcessorCopyList) {
        if ([processor conformsToProtocol:@protocol(VideoFrameProcessor)]) {
            
            if (![processor videoProcessorEnabled]) {
                continue;
            }
            
            [processor videoProcessFailedFrame];
        }
    }
}

#pragma mark - videotoolbox decode callback

//handle 264 frame output from videotoolbox
-(void) decompressedFrame:(CVImageBufferRef)image frameInfo:(VideoFrameH264Raw *)frame
{
    if (image == nil) {
#if __TEST_VIDEO_STUCK__
        if (frame != NULL)
        {
            [DJIVideoStuckTester finisedDecodeFrameWithIndex:frame->frame_uuid withState:false];
        }
#endif
        [self videoProcessFailedFrame];
        return;
    }
#if __TEST_VIDEO_STUCK__
    if (frame != NULL)
    {
        [DJIVideoStuckTester finisedDecodeFrameWithIndex:frame->frame_uuid withState:true];
    }
#endif
    //check status
    if(_status.isPause || _status.isBackground){
        return;
    }
    
    CFTypeID imageType = CFGetTypeID(image);
    if (imageType == CVPixelBufferGetTypeID()
        && (kCVPixelFormatType_420YpCbCr8Planar == CVPixelBufferGetPixelFormatType(image)
            || kCVPixelFormatType_420YpCbCr8PlanarFullRange == CVPixelBufferGetPixelFormatType(image))) {
            //make sure this is a yuv420 image
            CGSize size = CVImageBufferGetDisplaySize(image);
            if(kCVReturnSuccess != CVPixelBufferLockBaseAddress(image, 0))
                return;
            
            VideoFrameYUV yuvImage = {0};
            yuvImage.luma = CVPixelBufferGetBaseAddressOfPlane(image, 0);
            yuvImage.chromaB = CVPixelBufferGetBaseAddressOfPlane(image, 1);
            yuvImage.chromaR = CVPixelBufferGetBaseAddressOfPlane(image, 2);
            yuvImage.lumaSlice = (int)CVPixelBufferGetBytesPerRowOfPlane(image, 0);
            yuvImage.chromaBSlice = (int)CVPixelBufferGetBytesPerRowOfPlane(image, 1);
            yuvImage.chromaRSlice = (int)CVPixelBufferGetBytesPerRowOfPlane(image, 2);
            yuvImage.width = size.width;
            yuvImage.height = size.height;
            yuvImage.frame_uuid = -1;
            yuvImage.frame_info.frame_index = H264_FRAME_INVALIED_UUID;
            
            if (frame && frame->frame_uuid != H264_FRAME_INVALIED_UUID) {
                yuvImage.frame_info = frame->frame_info;
                yuvImage.frame_uuid = frame->frame_uuid;
            }

            [self videoProcessFrame:&yuvImage];
            
            CVPixelBufferUnlockBaseAddress(image, 0);
        }
    else if (imageType == CVPixelBufferGetTypeID()
             && (kCVPixelFormatType_420YpCbCr8BiPlanarFullRange == CVPixelBufferGetPixelFormatType(image)
                 || kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange == CVPixelBufferGetPixelFormatType(image))) {

                 CGSize size = CVImageBufferGetDisplaySize(image);
                 if(kCVReturnSuccess != CVPixelBufferLockBaseAddress(image, 0))
                     return;

                 VideoFrameYUV yuvImage = {0};
                 yuvImage.luma = CVPixelBufferGetBaseAddressOfPlane(image, 0);
                 yuvImage.chromaB = CVPixelBufferGetBaseAddressOfPlane(image, 1);
                 yuvImage.lumaSlice = (int)CVPixelBufferGetBytesPerRowOfPlane(image, 0);
                 yuvImage.chromaBSlice = (int)CVPixelBufferGetBytesPerRowOfPlane(image, 1);
                 yuvImage.width = size.width;
                 yuvImage.height = size.height;
                 yuvImage.frame_uuid = -1;
                 yuvImage.frameType = VPFrameTypeYUV420SemiPlaner;
                 yuvImage.frame_info.frame_index = H264_FRAME_INVALIED_UUID;

                 if (frame && frame->frame_uuid != H264_FRAME_INVALIED_UUID) {
                     yuvImage.frame_info = frame->frame_info;
                     yuvImage.frame_uuid = frame->frame_uuid;
                 }
                 yuvImage.cv_pixelbuffer_fastupload = image;
                 [self videoProcessFrame:&yuvImage];

                 CVPixelBufferUnlockBaseAddress(image, 0);
             }
}

-(void) hardwareDecoderUnavailable{
    //use soft decoder
    self.enableHardwareDecode = NO;
}

@end
