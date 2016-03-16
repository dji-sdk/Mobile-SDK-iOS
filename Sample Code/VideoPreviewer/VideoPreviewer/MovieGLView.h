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
#include <sys/types.h>

#import "DJIStreamCommon.h"

#define THUMBNAIL_ENABLE (1)
#define THUMBNAIL_IMAGE_WIDTH (154)
#define THUMBNAIL_IMAGE_HIGHT (87)

//@protocol KxMovieGLRenderer
//- (BOOL) isValid;
//- (void) resolveUniformsYUV: (GLuint) program;
//- (void) setFrameSize:(CGSize)size;
//- (void) setFrame: (VideoFrameYUV *) frame;
//- (void) setLuminanceScale:(float)scale;
//- (void) setEnableGrayScale:(BOOL)enable;
//- (void) setEnableOverexposedMark:(float)enable;
//- (BOOL) prepareRender;
//- (void) frameRenderFinished;
//@end

typedef NS_ENUM(NSUInteger, MovieGLViewType){
    MovieGLViewTypeAutoAdjust,
    MovieGLViewTypeFullWindow,
    MovieGLViewTypeNone,
};

typedef void (^snapshotBlock)(UIImage* image);

@interface MovieGLView : UIView

//render the view with grayscale
@property (assign, nonatomic) BOOL grayScale;
//enable over exposed texture
@property (assign, nonatomic) float overExposedMark;
//scale on output luminance
@property (assign, nonatomic) float luminanceScale;
@property (assign, nonatomic) float focusWarningThreshold;

//use sobel process
@property (assign, nonatomic) BOOL useSobelProcess;
//sobel range in (0, 1)
@property (assign, nonatomic) CGRect sobelRange;

#if THUMBNAIL_ENABLE
//capture next frame thumbnail image, return to thumbnail delegate
@property (copy, nonatomic) snapshotBlock snapshoutThumbnailCallback;
#endif

//take snapshot
@property (copy, nonatomic) snapshotBlock snapshoutCallback;

- (id)initWithFrame:(CGRect)frame;

//adjust self frame with input frame size
- (BOOL)adjustSize;
//push and render a new yuv frame, use nil frame to repaint
- (void)render: (VideoFrameYUV *) frame;

@property (assign,nonatomic) MovieGLViewType type;
@end
