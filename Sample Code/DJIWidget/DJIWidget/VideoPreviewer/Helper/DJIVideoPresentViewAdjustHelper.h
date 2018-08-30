//
//  DJIVideoPresentViewAdjustHelper.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJIStreamCommon.h"

/**
 *  Helper used to assist the view renderer (glView) in size adjustment.
 */
@interface DJIVideoPresentViewAdjustHelper : NSObject
/**
 *  Rect represents the content to be clipped. It is relative rect proportional
 *  to the rect of the scene. the x, y, width, and height values must all be
 *  between 0 and 1.0.
 *  When either width or height is 0, the full frame will be used. 
 *  Renderer will adjust the view's size based on the rect.
 */
@property (assign, nonatomic) CGRect contentClipRect;

// bound of video container
@property (assign, nonatomic) CGRect boundingFrame;

// video size in stream space
@property (assign, nonatomic) CGSize videoSize;

// last frame of video content
@property (assign, nonatomic) CGRect lastFrame;

// rotation of the stream
@property (assign, nonatomic) VideoStreamRotationType rotation;

// content fill mode
@property (assign, nonatomic) VideoPresentContentMode contentMode;

//get the final frame
-(CGRect) getFinalFrame;

+(CGRect) normalizeFrame:(CGRect)frame withIdentityRect:(CGRect)rect;
+(CGRect) aspectFitWithFrame:(CGRect)frame size:(CGSize)size;
+(CGRect) aspectFillWithFrame:(CGRect)frame size:(CGSize)size;

@end
