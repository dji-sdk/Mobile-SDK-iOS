//
//  DJIRtmpMuxer.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <DJIWidget/DJIStreamCommon.h>

@class DJIVideoPreviewer;
@class DJIRtmpMuxer;

typedef enum : NSUInteger {
    DJIRtmpMuxerStatus_Init,
    DJIRtmpMuxerStatus_prepareIFrame,
    DJIRtmpMuxerStatus_Connecting,
    DJIRtmpMuxerStatus_Streaming,
    DJIRtmpMuxerStatus_Broken,
    DJIRtmpMuxerStatus_Stoped,
} DJIRtmpMuxerStatus;

@protocol DJIRtmpMuxerStatusUpdateDelegate<NSObject>

- (void)rtmpMuxer:(DJIRtmpMuxer *_Nonnull)camera didUpdateStreamState:(DJIRtmpMuxerStatus)status;

@end



@interface DJIRtmpMuxer : NSObject  <VideoStreamProcessor,VideoFrameProcessor>

// Status callback delegate
@property (nonatomic, weak) id <DJIRtmpMuxerStatusUpdateDelegate> _Nullable delegate;

@property (nonatomic, assign) BOOL enabled; // Total switch
// Current state, attention to changes may not be in the main thread
@property (nonatomic, readonly) DJIRtmpMuxerStatus status;
// Push address, shaped like rtmp://
@property (nonatomic, strong) NSString* _Nonnull serverURL;
// Use local audio for mixed streaming, need to be set before starting to be effective
@property (nonatomic, assign) BOOL enableAudio;
//Mute, if enabled, mute the audio but still need the audio clock input
@property (nonatomic, assign) BOOL muteAudio;
// Failed retries
@property (nonatomic, assign) NSUInteger retryCount;
// video rotation property
@property (nonatomic, assign) VideoStreamRotationType rotate;

/**
 * Whether to convert GDR code stream into GOP code stream, but currently it cannot be used on LB2
 */
@property (nonatomic, assign) BOOL convertGDR;

/*
 * Delay for smoothing the video stream. This setting depends on the correct fps frame rate of the video stream.
 */
@property (nonatomic, assign) double smoothDelayTimeSeconds;

//stream status info
@property (nonatomic, readonly) double startedDuration;
@property (nonatomic, readonly) double outputFps;
@property (nonatomic, readonly) int outputKbitPerSec;
@property (nonatomic, readonly) int outputAudioKbitPerSec;
@property (nonatomic, readonly) int bufferCount;
@property (nonatomic, readonly) int videoFrameNum;
@property (nonatomic, readonly) int audioFrameNum;
/**
 *  Volume level, between 0~1
 */
@property (nonatomic, readonly) double audioGainLevel;

-(instancetype _Nullable ) init OBJC_UNAVAILABLE("You must use the initWithVideoPreviewer");

+ (instancetype _Nullable)sharedInstance;

-(void) setupVideoPreviewer:(DJIVideoPreviewer*_Nullable)videoPreviewer;

/**
 *  Push a frame into the video cache
 *
 *  @param data
 *  @param size
 *
 *  @return If the push succeeds, you do not need to call manually when using the streamProcessor interface
 */
//-(BOOL) pushFrame:(VideoFrameH264Raw*)frame;
//-(BOOL) pushFrame:(uint8_t*)data size:(int)size;
-(BOOL) pushAudioFrame:(uint8_t* _Nullable)data size:(int)size;

-(BOOL) start;
-(void) stop;
@end
