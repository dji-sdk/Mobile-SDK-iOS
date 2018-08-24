//
//  DJIVideoPreviewer.h
//
//  Copyright (c) 2013 DJI. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "DJIStreamCommon.h"
#import "DJICustomVideoFrameExtractor.h"
#import "DJIMovieGLView.h"
#import "DJIH264VTDecode.h"
#import "DJIVideoHelper.h"
#import "DJISmoothDecode.h"
#import "DJISoftwareDecodeProcessor.h"
#import "DJIVideoPresentViewAdjustHelper.h"
#import "DJIImageCalibrateHelper.h"

// Excluded from SDK
@class DJIDataDumper;


#define __WAIT_STEP_FRAME__   (0) //For debug test_queue_pull

#define VIDEO_PREVIEWER_DISPATCH "video_preview_create_thread_dispatcher"
#define VIDEO_PREVIEWER_EVEN_NOTIFICATIOIN @"video_preview_even_notification"

typedef struct{
    BOOL isInit:1;  // YES when DJIVideoPreviewer is initialized
    BOOL isRunning:1;   // YES when the decoding thread is running
    BOOL isPause:1;     // YES when the decoder is paused
    BOOL isFinish:1;    // YES when it is finished
    BOOL hasImage:1;    // YES when it has image
    BOOL isGLViewInit:1; // YES when the GLView is initialized
    BOOL isBackground:1;    // YES when VideoPreview is in background
    uint8_t other:1;    // reserved
}DJIVideoPreviewerStatus;

typedef enum : NSUInteger {
    DJIVideoDecoderStatus_Normal, //normal status
    DJIVideoDecoderStatus_NoData,  //no data
    DJIVideoDecoderStatus_DecoderError,   //decode error
} DJIVideoDecoderStatus;

typedef NS_ENUM(NSUInteger, DJIVideoPreviewerEvent){
    DJIVideoPreviewerEventNoImage,     //decode no image
    DJIVideoPreviewerEventHasImage,    //decode has image
    DJIVideoPreviewerEventResumeReady,      //after safe resume resume decode
};

typedef NS_ENUM(NSUInteger, DJIVideoPreviewerType){
    DJIVideoPreviewerTypeAutoAdapt,    //auto just to adapt size
    DJIVideoPreviewerTypeFullWindow,   //full window
    DJIVideoPreviewerTypeNone, //none
};


/**
 *	Frame state
 */
@protocol DJIVideoPreviewerFrameControlDelegate <NSObject>

@required

- (BOOL)parseDecodingAssistInfoWithBuffer:(uint8_t *)buffer length:(int)length assistInfo:(DJIDecodingAssistInfo *)assistInfo;

- (BOOL)isNeedFitFrameWidth;

- (void)syncDecoderStatus:(BOOL)isNormal;

- (void)decodingDidSucceedWithTimestamp:(uint32_t)timestamp;

- (void)decodingDidFail;

@end


#pragma mark - data input

/**
 *  UI component used to show the video feed streamed from DJI device. FFmpeg is
 *  required. It consists of decoder, data buffer queue and OpenGL renderer。
 *  Set the view before calling the `start` method。
 */
@interface DJIVideoPreviewer : NSObject


/*
 Real-time monitoring of frame rate for encoder-related services (video buffer, no SD card recording, live broadcast, quickmovie)
   Since the frameRate values in the streamInfo of 230 and 240 are all wrong, here we monitor the real-time frame rate as a parameter and pass it to the encoder.
 */
@property (nonatomic, assign, readonly) NSUInteger realTimeFrameRate;

// Whether to use dynamic frame rate, if set to YES, use realTimeFrameRate to calculate PTS
// If not supported, use the frameRate parameter in streamInfo to calculate the PTS
// Currently 230 and 240 support dynamic frame rate, other models use the frameRate parameter in streamInfo
@property (nonatomic, assign) BOOL detectRealtimeFrameRate;


//0 means invalid.
@property (nonatomic, assign, readonly) uint32_t globalTimeStamp;


@property (nonatomic,assign,getter=isPerformanceCountEnabled) BOOL performanceCountEnabled;

// a tag for video processor and frame processor
@property (assign, nonatomic) uint8_t videoChannelTag;

/*
 * create a new preview, this instance is not the default one
 */
-(instancetype) init;

/**
 *  Push video data
 */
-(void) push:(uint8_t*)videoData length:(int)len;

/**
 *  Clear video data buffer
 */
-(void) clearVideoData;

/**
 * image calibration controller
 */
@property (nonatomic,weak) id<DJIImageCalibrateDelegate> calibrateDelegate;

/**
 * Frame state control
 */
@property (nonatomic,weak) id<DJIVideoPreviewerFrameControlDelegate> frameControlHandler;

@end

#pragma mark - instance

@interface DJIVideoPreviewer (Instance)

/**
 *  YES if this is the first instance
 */
@property (nonatomic, readonly) BOOL isDefaultPreviewer;

/**
 *  get default previewer
 */
+(DJIVideoPreviewer*) instance;

// SDK
/**
 *  Release the default instance.
 */
+(void)releaseInstance;

@end

#pragma mark - geometry

@interface DJIVideoPreviewer (Geometry)
/**
 *  for kvo, preview content frame
 */
@property (nonatomic, readonly) CGRect frame;

/*
 * for internal use only
 */
@property (nonatomic, readonly) DJIMovieGLView* internalGLView;
@end

@interface DJIVideoPreviewer ()

/**
 *  rotation of the preview content
 */
@property (assign, nonatomic) VideoStreamRotationType rotation;

// content clipping [0~1] in width, [0~1] in height,
// use all 0 as default
// use this rect to mark the usable part of the input stream
// glview will use this part to do auto size adjust
@property (assign, nonatomic) CGRect contentClipRect;

/**
 *  The display type used by the Video Previewer
 */
@property (nonatomic, assign) DJIVideoPreviewerType type;

/**
 *  set the UIView which will display the rendering video stream
 *
 *  @param view the UIView instance to display the video stream
 *
 *  @return `YES` if it is set successfully.
 */
- (BOOL)setView:(UIView *)view;

/**
 *  Unset the view which is set previously.
 */
- (void)unSetView;

/*
 * resize
 */
- (void)adjustViewSize;

/**
 *  Convert a point on the view to the coordinate system used by the video stream.
 *
 *  @param point coordinate of the point in the view.
 *  @param view the instance of the UIView.
 *  @return the location of point in the video stream coordinate
 */
-(CGPoint) convertPoint:(CGPoint)point toVideoViewFromView:(UIView*)view;

/**
 *  Convert a point on from the video stream coordinate to the coordinate system
 *  used by the UIView.
 *
 *  @param point coordinate of the point in video stream.
 *  @param view the instance of the UIView.
 *  @return the location of point in the UIView
 */
-(CGPoint) convertPoint:(CGPoint)point fromVideoViewToView:(UIView *)view;

@end

#pragma mark - decoder control

@interface DJIVideoPreviewer (DecoderControl)
/**
 *  Current status of Video Previewer.
 */
@property (assign, readonly) DJIVideoPreviewerStatus status;

/**
 *  Current status of the decoder inside Video Previewer.
 */
@property (nonatomic, readonly) DJIVideoDecoderStatus decoderStatus;

/*
 * current stream info for rkvo
 */
@property (nonatomic, readonly) DJIVideoStreamBasicInfo currentStreamInfo;
/**
 *  Format of the output frame
 */
@property (readonly, nonatomic) VPFrameType frameOutputType;
@end

@interface DJIVideoPreviewer ()  <VideoFrameProcessor>

/**
 *  enable hadeware decode
 */
@property (assign, nonatomic) BOOL enableHardwareDecode;

/**
 *  Use for choice the H264 steam type, default is inspire.
 */
@property (assign,nonatomic) H264EncoderType encoderType;

/**
 *  Enables the fast uploading to GPU. It is useful for hardware decoding and
 *  when it is enabled, the output image encoding format will become semi-Planar.
 */
@property (assign, nonatomic) BOOL enableFastUpload;

/**
 *  Default 0. if this value has been set, the decode output will try to match this
 *  framerate, otherwise will accourding to the framerate info of VideoFrameExtractor
 */
@property (assign, nonatomic) double customizedFramerate;

/**
 *  Start the decoding.
 *
 *  @return `YES` if it is started successfully.
 */
- (BOOL)start;

/**
 *  reset the decoding thread and re-initialize Video Frame Extractor
 */
-(void) reset;

/**
 *  Resume the decoding process. When using hardware decoder, the image may be
 *  abnormal for seconds when it just resumed.
 */
- (void)resume;

/**
 * Resume the decoding process. When using the hardware decoder, it will skip
 *  some frame to avoid abnormal images.
 */
- (void)safeResume;

/**
 *  Pause decoding.
 */
- (void)pause;

/*
 *  Pause decoding and determine if the screen is gray after the pause.
 */
-(void)pauseWithGrayout:(BOOL)isGrayout;

/**
 *  Turn off Video Previewer.
 */
- (void)close;

/*
 * clear gl view to black
 */
- (void)clearRender;

@end

#pragma mark - snapshot

@interface DJIVideoPreviewer (SnapShot)

/**
 *  Screen capture of the current view
 */
-(void) snapshotPreview:(void(^)(UIImage* snapshot))block;

/**
 *  Screen capture thumbnail
 */
-(void) snapshotThumnnail:(void(^)(UIImage* snapshot))block;

@end

#pragma mark - processor

@interface DJIVideoPreviewer (Processor)

/**
 *  @param processor Processor registered to receive the H264 stream data.
 */
-(void) registStreamProcessor:(id<VideoStreamProcessor>)processor;

/**
 *  @param processor Remove registered processor list.
 */
-(void) unregistStreamProcessor:(id)processor;

/*
 *  @param processor Processor registered to receive the VideoFrameYUV frame data.
 */
-(void) registFrameProcessor:(id<VideoFrameProcessor>)processor;

/**
 *  @param processor Remove registered processor list.
 */
-(void) unregistFrameProcessor:(id)processor;

@end

// Excluded from SDK
#pragma mark - debug tools

@interface DJIVideoPreviewer (Debug)

@end

#pragma mark - filters and effects
///////////////// Filter's config ///////////////////////////

@interface DJIVideoPreviewer ()

/**
 * Enable overexposure tips
 */
@property (nonatomic, assign) float overExposedWarningThreshold;


/**
 * Setting Exposure Compensation
 */
@property (nonatomic, assign) float luminanceScale;


/////////////// use sobel process //////////
/**
 * Enable focus tips
 */
@property (nonatomic, assign) BOOL enableFocusWarning;
/**
 *  Setting the Focus range rendering prompt
 */
@property (nonatomic, assign) float focusWarningThreshold;


////////////// revers d-log filter from camera ///////
@property (assign, nonatomic) DLogReverseLookupTableType dLogReverse;


///////////// hsb config //////////////////
@property (assign, nonatomic) BOOL enableHSB;
@property (assign, nonatomic) DJILiveViewRenderHSBConfig hsbConfig;


///////////// shadow and highlight ///////////
@property (assign, nonatomic) BOOL enableShadowAndHighLightenhancement;
/**
 * 0 - 1, increase to lighten shadows.
 * @default 0
 */
@property(readwrite, nonatomic) CGFloat shadowsLighten;

/**
 * 0 - 1, increase to darken highlights.
 * @default 0
 */
@property(readwrite, nonatomic) CGFloat highlightsDecrease;

@end


#pragma mark - smooth decode
///////////////// delay the decode and smooth config ///////////////////////////

@interface DJIVideoPreviewer ()
@property (nonatomic, strong) id<DJISmoothDecodeProtocol> smoothDecode;
@end
