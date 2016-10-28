//
//  ESGLView.h
//  kxmovie
//
//  Created by Kolyvan on 22.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/kxmovie
//  this file is part of KxMovie
//  KxMovie is licenced under the LGPL v3, see lgpl-3.0.txt
#import <UIKit/UIKit.h>
#import "DJIStreamCommon.h"
#include <sys/types.h>


#define THUMBNAIL_ENABLE (1)
#define THUMBNAIL_IMAGE_WIDTH (154)
#define THUMBNAIL_IMAGE_HIGHT (87)

@class MovieGLView;
@protocol MovieGLViewDelegate <NSObject>
@optional
-(void) movieGlView:(MovieGLView*)view didChangedFrame:(CGRect)frame;
@end

typedef void (^snapshotBlock)(UIImage* image);

@interface MovieGLView : UIView

// rotation of the preview content
@property (assign, nonatomic) VideoStreamRotationType rotation;

//render the view with grayscale
@property (assign, nonatomic) BOOL grayScale;
//enable over exposed texture
@property (assign, nonatomic) float overExposedMark;
//scale on output luminance
@property (assign, nonatomic) float luminanceScale;
@property (assign, nonatomic) float focusWarningThreshold;

/**
 *  Rect represents the content to be clipped. It is relative rect proportional
 *  to the rect of the scene. the x, y, width, and height values must all be
 *  between 0 and 1.0.
 */
@property (assign, nonatomic) CGRect contentClipRect;

//use sobel process
@property (assign, nonatomic) BOOL useSobelProcess;
//sobel range in (0, 1)
@property (assign, nonatomic) CGRect sobelRange;

#if THUMBNAIL_ENABLE
/**
 *  Callback that receives a thumbnail snapshot from the next rendered frame. 
 *  After the snapshot is generated, the property will be reset to nil.
 */
@property (copy, nonatomic) snapshotBlock snapshotThumbnailCallback;
#endif

/**
 *  Callback that receives a snapshot from the next rendered frame.
 *  After the snapshot is generated, the property will be reset to nil.
 */
@property (copy, nonatomic) snapshotBlock snapshotCallback;

- (id)initWithFrame:(CGRect)frame;

//adjust self frame with input frame size
- (BOOL)adjustSize;
//push and render a new yuv frame, use nil frame to repaint
- (void)render: (VideoFrameYUV *) frame;

//the way that glview adjust self
@property (assign,nonatomic) VideoPresentContentMode type;
@property (nonatomic, weak) id<MovieGLViewDelegate> delegate;
@end
