//
//  DJIVideoPoolMp4Muxer.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import "DJIVideoPoolMp4Muxer.h"
#import "djiffremux.h"
#import "DJIVideoHelper.h"
#import "DJIVideoPreviewer.h"

#define FIRST_GOT_AUDIO_FRAME_NEVER (-1) // never received audio frames

@interface DJIVideoPoolMp4Muxer (){
    djiff_ffremux_handle_t muxer_handle;
    djiff_ffremux_config_t cfg;
}

//fixed on 44100
@property (nonatomic, assign) NSUInteger audioSampleRate;
@property (nonatomic, assign) NSTimeInterval videoFrameInterval;
@property (nonatomic, assign) NSTimeInterval audioFrameInterval;

// The first audio frame may come later than the video frame, which needs to be synchronized
@property (nonatomic, assign) NSInteger firstAudioFrameSyncOnVideoIndex;
@property (nonatomic, assign) NSUInteger videoPTS;
@property (nonatomic, assign) NSUInteger audioPTS;
@end

@implementation DJIVideoPoolMp4Muxer

-(id) initWithDstFile:(NSString *)path streamInfo:(VideoFrameH264BasicInfo*)info{
    self = [super init];
    if (self) {
        _dstFilePath = path;
        NSFileManager* fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:path error:nil];
        memset(&cfg, 0, sizeof(cfg));
        
        muxer_handle = nil;
        _audioSampleRate = 44100;
        _headWrited = NO;
        _muxerEnded = NO;
        _firstAudioFrameSyncOnVideoIndex = FIRST_GOT_AUDIO_FRAME_NEVER; // never received audio frames
    }
    return self;
}

-(BOOL) pushFrame:(VideoFrameH264Raw *)frame{
    if( !frame || _muxerEnded) {
        return NO;
    }
    
    if (!_headWrited) {
        if (!frame->frame_info.frame_flag.has_sps) {
            return NO;
        }
        
        //init encoder
        uint8_t buffer[1024] = {0};
        uint8_t* spsbuf = buffer;
        uint8_t* ppsbuf = buffer + 512;
        int spsSize = 0;
        int ppsSize = 0;
        int find_ret = find_SPS_PPS(frame->frame_data, frame->frame_size, spsbuf, &spsSize, ppsbuf, &ppsSize);
        
        if (find_ret == 0) {
            memcpy(spsbuf+spsSize, ppsbuf, ppsSize);
            
            if (!muxer_handle) {
                cfg.numOutput = 1;
                cfg.numInput = _enableAACAudio?2:1;
                cfg.out_filename[0] = (char*)_dstFilePath.UTF8String;
                cfg.in_format[0] = DJIFF_FILE_FORMAT_H264RAW;
                cfg.in_format[1] = DJIFF_FILE_FORMAT_AACRAW;
                cfg.out_format[0] = DJIFF_FILE_FORMAT_MP4;
                
                cfg.enc_param.width = frame->frame_info.width;
                cfg.enc_param.height = frame->frame_info.height;
                cfg.enc_param.fpsNum = frame->frame_info.fps;
                cfg.enc_param.fpsDen = 1;
                cfg.enc_param.bitrate = 1000000;
                
                if(frame->frame_info.fps){
                    _videoFrameInterval = 1.0/frame->frame_info.fps;
                }
                
                //set rotation
                int rotate = 0;
                switch (frame->frame_info.rotate) {
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
                cfg.enc_param.rotate = rotate;
                
                cfg.enc_param.bitPerSample = 16;
                cfg.enc_param.sampleRate = (int)_audioSampleRate;
                cfg.enc_param.numChannels = 1;
                
                if (_audioSampleRate) {
                    _audioFrameInterval = 1024.0/(double)_audioSampleRate;
                }
                
                djiff_result_t ret = djiff_remux_init(&muxer_handle, &cfg, buffer, spsSize+ppsSize);
                if (ret) {}
            }
            
            if (!muxer_handle) {
                return NO;
            }
            
            //djiff_mux_header(muxer_handle, buffer, spsSize+ppsSize);
            _headWrited = YES;
        }
        _muxedAllFrameCount = 0;
        _muxedVideoFrameCount = 0;
        _muxedAudioFrameCount = 0;
    }
    
    if(_headWrited){
        //NoRepeatLog(1000, @"video frame:%d %d", _muxedVideoFrameCount, _muxedAllFrameCount);
        
        {//wrok around for muxer
            //The video frame is to be inserted into a suitable location
            if (_enableAACAudio && _firstAudioFrameSyncOnVideoIndex != FIRST_GOT_AUDIO_FRAME_NEVER) {
                double currentTime = _muxedAudioFrameCount*1024.0/(double)_audioSampleRate;
                double frameDuration = cfg.enc_param.fpsDen/(double)cfg.enc_param.fpsNum;
                int frameIndex = currentTime/frameDuration;
                if (frameIndex - (int)_muxedVideoFrameCount > 10) {
                    //resync video and audio
                    NSLog(@"sync frame to:%d", frameIndex);
                    _muxedVideoFrameCount = frameIndex;
                }
            }
        }
        
        _videoPTS = _muxedVideoFrameCount*_videoFrameInterval*1000;
        
        if ([DJIVideoPreviewer instance].detectRealtimeFrameRate) {
            djiff_mux_frame2(muxer_handle,
                             frame->frame_info.fps,
                             frame->frame_data,
                             frame->frame_size,
                             _muxedVideoFrameCount,
                             DJIFF_FILE_FORMAT_H264RAW,
                             frame->frame_info.frame_flag.has_idr);
        }
        else {
            djiff_mux_frame(muxer_handle,
                            frame->frame_data,
                            frame->frame_size,
                            _muxedVideoFrameCount,
                            DJIFF_FILE_FORMAT_H264RAW,
                            frame->frame_info.frame_flag.has_idr);
        }
        _muxedAllFrameCount++;
        _muxedVideoFrameCount++;
        return YES;
    }
    
    return NO;
}

-(BOOL) pushAudio:(AudioFrameAACRaw *)frame{
    if (_headWrited && _enableAACAudio) {
        //NoRepeatLog(1000, @"audio frame:%d %d", _muxedAudioFrameCount, _muxedAllFrameCount);
        
        //        int size = frame->frame_size;
        //        NSLog(@"audio frame:%d len:%d head:%x %x %x %x tail:%x %x %x %x",
        //              _muxedAudioFrameCount, frame->frame_size,
        //              frame->frame_data[0], frame->frame_data[1], frame->frame_data[2], frame->frame_data[3],
        //              frame->frame_data[size - 4], frame->frame_data[size -3], frame->frame_data[size-2], frame->frame_data[size -1]);
        
        if (_firstAudioFrameSyncOnVideoIndex == FIRST_GOT_AUDIO_FRAME_NEVER) {
            _firstAudioFrameSyncOnVideoIndex = _muxedVideoFrameCount;
            
            if (_muxedVideoFrameCount > 0) {
                //A video was written before the audio, need to be synchronized first
                double frameDuration = cfg.enc_param.fpsDen/(double)cfg.enc_param.fpsNum;
                double currentDuration = _muxedVideoFrameCount*frameDuration;
                _muxedAudioFrameCount = (int)(currentDuration*((double)_audioSampleRate)/1024.0);
            }
        }
        
        _audioPTS = _muxedAudioFrameCount*_audioFrameInterval*1000;
        //NSLog(@"[audio] %d %d", _videoPTS, _audioPTS);
        
        if (_skipPureAudio) {
            if (_audioPTS > MAX(_videoPTS + _videoFrameInterval*3*1000,
                                _videoPTS + _audioFrameInterval*2*1000))
            {
                // No video input for more than 3 frames, or more than two audio frames
                return NO;
            }
        }
        
        djiff_mux_frame(muxer_handle, frame->frame_data, frame->frame_size, _muxedAudioFrameCount, DJIFF_FILE_FORMAT_AACRAW, 0);
        _muxedAllFrameCount++;
        _muxedAudioFrameCount++;
        return YES;
    }
    
    return NO;
}

-(void) endFile{
    if (!muxer_handle) {
        return;
    }
    
    djiff_remux_deinit(muxer_handle);
    muxer_handle = nil;
    _muxerEnded = YES;
}

-(double) requiredFPS{
    if (cfg.enc_param.fpsDen == 0) {
        return 0;
    }
    
    
    return (double)cfg.enc_param.fpsNum/(double)cfg.enc_param.fpsDen;
}

@end
