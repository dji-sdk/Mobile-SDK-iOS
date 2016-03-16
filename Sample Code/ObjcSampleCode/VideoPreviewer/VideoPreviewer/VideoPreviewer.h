//
//  VideoPreviewer.h
//
//  Copyright (c) 2013 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoFrameExtractor.h"
#import "VideoPreviewerQueue.h"
#import "H264VTDecode.h"
#import "DJIStreamCommon.h"
#import "MovieGLView.h"
#import "SoftwareDecodeProcessor.h"
#import "LB2AUDHackParser.h"

#define VIDEO_PREVIEWER_DISPATCH "video_preview_create_thread_dispatcher"
#define VIDEO_PREVIEWER_EVEN_NOTIFICATIOIN @"video_preview_even_notification"

@class DJIBaseProduct; 

typedef struct{
    BOOL isInit:1;  // YES when VideoPreviewer is initialized
    BOOL isRunning:1;   // YES when the decoding thread is running
    BOOL isPause:1;     // YES when the decoder is paused
    BOOL isFinish:1;    // YES when it is finished
    BOOL hasImage:1;    // YES when it has image
    BOOL isGLViewInit:1; // YES when the GLView is initialized
    BOOL isBackground:1;    // YES when VideoPreview is in background
    uint8_t other:1;    // reserved
}VideoPreviewerStatus;

typedef enum : NSUInteger {
    VideoDecoderStatus_Normal,
    VideoDecoderStatus_NoData,
    VideoDecoderStatus_DecoderError,
} VideoDecoderStatus;

typedef NS_ENUM(NSUInteger, VideoPreviewerEvent){
    VideoPreviewerEventNoImage,
    VideoPreviewerEventHasImage,
    VideoPreviewerEventResumeReady,
};

typedef NS_ENUM(NSUInteger, VideoPreviewerType){
    VideoPreviewerTypeAutoAdapt,
    VideoPreviewerTypeFullWindow,
    VideoPreviewerTypeNone,
};

typedef NS_ENUM(NSUInteger, VideoPreviewerDecoderType){
    VideoPreviewerDecoderTypeSoftwareDecoder,
    VideoPreviewerDecoderTypeHardwareDecoder
};

/**
 *  UI component used to show the video feed streamed from DJI device. FFmpeg is required. It consists of decoder, data buffer queue and OpenGL renderer。
 *  Set the view before calling the `start` method。
 */
@interface VideoPreviewer : NSObject <VideoFrameProcessor>

@property (retain) VideoFrameExtractor *videoExtractor;

/**
 *  The queue to store the input video data.
 */
@property(retain) VideoPreviewerQueue *dataQueue;

/**
 *  Current status of Video Previewer.
 */
@property (assign,readonly) VideoPreviewerStatus status;

/**
 *  Current status of the decoder inside Video Previewer.
 */
@property (nonatomic, readonly) VideoDecoderStatus decoderStatus;

/**
 *  The display type used by the Video Previewer
 */
@property (nonatomic, assign) VideoPreviewerType type;

/**
 *  Format of the output frame
 */
@property (readonly, nonatomic) VPFrameType frameOutputType;

+(VideoPreviewer*) instance;

/**
 *  Push video data
 *
 */
-(void) push:(uint8_t*)videoData length:(int)len;

/**
 *  Clear video data
 */
-(void) clearVideoData;

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

/**
 *  Convert a point on the view to the coordinate system used by the video stream.
 *
 *  @param point coordinate of the point in the view.
 *  @param view the instance of the UIView.
 *  @return the location of point in the video stream coordinate
 */
-(CGPoint) convertPoint:(CGPoint)point toVideoViewFromView:(UIView*)view;

/**
 *  Convert a point on from the video stream coordinate to the coordinate system used by the UIView.
 *
 *  @param point coordinate of the point in video stream.
 *  @param view the instance of the UIView.
 *  @return the location of point in the UIView
 */
-(CGPoint) convertPoint:(CGPoint)point fromVideoViewToView:(UIView *)view;

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
 *  Resume the decoding process. When using hardware decoder, the image may be abnormal for seconds when it just resumed.
 */
- (void)resume;

/**
 * Resume the decoding process. When using the hardware decoder, it will skip some frame to avoid abnormal images.
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

/**
 *  Called when the application is about to enter background.
 */
- (void)enterBackground;

/**
 *  Called when the application is about to enter the foreground.
 */
- (void)enterForegournd;

/**
 *  Get the frame dimension.
 */
-(CGRect) frame;

/**
 *  @param processor Processor registered to receive the video data. 
 */
-(void) registStreamProcessor:(id<VideoStreamProcessor>)processor;
-(void) registFrameProcessor:(id<VideoFrameProcessor>)processor;
-(void) unregistProcessor:(id)processor;

- (NSUInteger)  __attribute__((deprecated)) runLoopCount;
- (NSUInteger)  __attribute__((deprecated)) frameCount;


/**
 *  Sets video stream decoder based on the product and the desired decoder type.
 *  Currently, only some cameras support hardware decoders.
 *
 *  @param product  The camera that uses the video previewer.
 *  @param decoder  The desired decoder type.
 *  @return Yes if there is suitable decoder for the camera on the product and the decoder is enabled successfully.
 */
- (BOOL) setDecoderWithProduct:(DJIBaseProduct*)product andDecoderType:(VideoPreviewerDecoderType)decoder;

@end
