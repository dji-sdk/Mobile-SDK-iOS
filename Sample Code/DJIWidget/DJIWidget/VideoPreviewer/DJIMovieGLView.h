//
//  MovieGLView.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJIStreamCommon.h"
#include <sys/types.h>
#import "DJILiveViewColorMonitorFilter.h"
#import <DJIWidget/DJILiveViewCalibrateFilter.h>
#import <DJIWidget/DJIImageCalibrateColorConverter.h>
#import "DJICalibratePixelBufferProvider.h"

#define __USE_PIXELBUFFER_PROVIDER__ (1)

@class DJIMovieGLView;
@protocol DJIMovieGLViewDelegate <NSObject>
@optional
-(void) movieGlView:(DJIMovieGLView*)view didChangedFrame:(CGRect)frame;
@end

#pragma mark - basics

@interface DJIMovieGLView : UIView

- (id)initWithFrame:(CGRect)frame;
//if draw called can came from multi thread, must enable this flag
- (id)initWithFrame:(CGRect)frame multiThreadSupported:(BOOL)multiThread;

//!!!!!!!! important !!!!!!!!!
//Must clean up resources before releasing
//must called before release
- (void)releaseResourece;

//adjust self frame with input frame size
- (BOOL)adjustSize;
//push and render a new yuv frame, use nil frame to repaint
- (void)render: (VideoFrameYUV *) frame;
//clear buffer, render a black image
- (void)clear;

@end

#pragma mark - geometry

@interface DJIMovieGLView ()

// rotation of the preview content
@property (assign, nonatomic) VideoStreamRotationType rotation;

/**
 *  Rect represents the content to be clipped. It is relative rect proportional
 *  to the rect of the scene. the x, y, width, and height values must all be
 *  between 0 and 1.0.
 */
@property (assign, nonatomic) CGRect contentClipRect;

//the way that glview adjust self
@property (assign,nonatomic) VideoPresentContentMode type;
//callback for geometry change
@property (nonatomic, weak) id<DJIMovieGLViewDelegate> delegate;
@end

#pragma mark - snapshot

//snapshot callback block
typedef void (^snapshotBlock)(UIImage* image);

@interface DJIMovieGLView ()

/**
 *  Callback that receives a thumbnail snapshot from the next rendered frame.
 *  After the snapshot is generated, the property will be reset to nil.
 */
@property (copy, nonatomic) snapshotBlock snapshotThumbnailCallback;

/**
 *  Callback that receives a snapshot from the next rendered frame.
 *  After the snapshot is generated, the property will be reset to nil.
 */
@property (copy, nonatomic) snapshotBlock snapshotCallback;

@end

#pragma mark - filter and effects

typedef struct {
    float hue; //[-360, 360]
    float brightness; //[0, 2]
    float saturation; //[0, 2]
}DJILiveViewRenderHSBConfig;


@interface DJIMovieGLView ()

//render the view with grayscale
@property (assign, nonatomic) BOOL grayScale;

//enable over exposed texture
@property (assign, nonatomic) float overExposedMark;

//scale on output luminance
@property (assign, nonatomic) float luminanceScale;


/////////////// use sobel process
@property (assign, nonatomic) BOOL enableFocusWarning;
//threshold for focuswarning
@property (assign, nonatomic) float focusWarningThreshold;


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

//////////// color monitor //////////
@property (nonatomic, assign) BOOL enableColorMonitor;
//read only
@property (nonatomic, strong) DJILiveViewColorMonitorFilter* colorMonitor;

//image calibration
@property (nonatomic, assign) BOOL calibrateEnabled;
//image calibration lut index
@property (nonatomic, assign) NSUInteger lutIndex;
//image calibration fov state
@property (nonatomic, assign) DJISEIInfoLiveViewFOVState fovState;
//image calibration
@property (nonatomic, strong) DJILiveViewCalibrateFilter* calibrateFilter;
//image color converter
@property (nonatomic, strong) DJIImageCalibrateColorConverter* colorConverter;
//For output calibrateFilter frameBuffer fastupload
@property (nonatomic, strong) DJICalibratePixelBufferProvider* calibratePixelBufferProvider;
@end
