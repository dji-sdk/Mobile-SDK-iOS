//
//  VideoPreviewer.h
//  SDK
//
//  Copyright (c) 2016. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VideoFrameExtractor.h"
#import "MovieGLView.h"
#import "DJILinkQueues.h"

//! Project version number for VideoPreviewer.
FOUNDATION_EXPORT double VideoPreviewerVersionNumber;

//! Project version string for VideoPreviewer.
FOUNDATION_EXPORT const unsigned char VideoPreviewerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <VideoPreviewer/PublicHeader.h>


#define RENDER_FRAME_NUMBER (4)

#define kDJIDecoderDataSoureNone                    (0)
#define kDJIDecoderDataSoureInspire                 (1)
#define kDJIDecoderDataSourePhantom3Advanced        (4)
#define kDJIDecoderDataSourePhantom3Professional    (5)

typedef struct{
    BOOL isInit:1;      // The initialized status
    BOOL isRunning:1;   // whether or not the decoding thread is running
    BOOL isPause:1;     // whether or not the decoding thread is paused
    BOOL isFinish:1;    // whether or not the decoding thread is finished
    BOOL hasImage:1;    // has image
    BOOL isGLViewInit:1;// OpenGLView is init
    BOOL isBackground:1;// enter background
    uint8_t other:1;    // Reserved
}VideoPreviewerStatus;

typedef NS_ENUM(NSUInteger, VideoPreviewerEvent){
    VideoPreviewerEventNoImage,     //
    VideoPreviewerEventHasImage,    //
};

@protocol VideoPreviewerDelegate <NSObject>

@optional

- (void)previewDidUpdateStatus;

- (void)previewDidReceiveEvent:(VideoPreviewerEvent)event;

@end

@interface VideoPreviewer : NSObject
{
    NSThread *_decodeThread;
    MovieGLView *_glView;
    VideoFrameYUV *_renderYUVFrame[RENDER_FRAME_NUMBER];
    int _decodeFrameIndex;
    int _renderFrameIndex;
    
    dispatch_queue_t _dispatchQueue;
}

@property(nonatomic, assign) BOOL isHardwareDecoding;

/**
 *  Frame extractor
 */
@property (retain) VideoFrameExtractor *videoExtractor;
/**
 *  Video data queue, used for cache raw video data.
 */
@property(retain) DJILinkQueues *dataQueue;
/**
 *  Status of previewer
 */
@property (assign,readonly) VideoPreviewerStatus status;

@property (weak,nonatomic) id<VideoPreviewerDelegate> delegate;

+(VideoPreviewer*) instance;
+(void) removePreview;

/**
 *  Set the render view.
 *
 */
- (BOOL)setView:(UIView *)view;

/**
 *  Remove the render view
 */
- (void)unSetView;

/**
 *  Start decode thread
 *
 */
- (BOOL)start;

/**
 *  Resume decode thread
 */
- (void)resume;

/**
 *  Pause decode thread
 */
- (void)pause;

/**
 *  Close decode thread
 *
 *  @deprecated use stop instead
 */
- (void)close __attribute__ ((__deprecated__));

/**
 *  Stop decode thread
 *
 */
- (void)stop;

/**
 *  Reset decoder. Call when the decoder could not work correctly.
 *
 */
-(void) reset;

/**
 *  Set decoder's data source
 *
 *  @param type See reference kDJIDecoderDataSoureXXX
 */
- (void) setDecoderDataSource:(int)type;

@end
