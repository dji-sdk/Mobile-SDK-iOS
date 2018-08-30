//
//  DJIVideoPreviewSmoothHelper.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJIWidget/DJIVideoPreviewer.h>

// Given a delay time, control the overall delay through sleep in the loop of the frame processing to achieve a smooth effect
@interface DJIVideoPreviewSmoothHelper : NSObject <DJISmoothDecodeProtocol>

/*
 * ms precision time
 */
+(double) getTick;

/*
 * number of cached frames
 */
-(double) frameBuffered;

/*
 * decode loop input
 */
-(double) sleepTimeForCurrentFrame:(double)currentTime framePushInQueueTime:(double)inQueueTime decodeCostTime:(double)decodeTime;

/*
 * reset smoothing
 */
-(void) resetSmooth;

/*
 * enter the desired frame interval (s)
 */
@property (nonatomic, assign) double requiredFrameDelta;

/*
 * enter the desired delay(s)
 */
@property (nonatomic, assign) double requiredDelay;

/*
 * The upper limit of the delay, for example, the limit 100ms is required. If the delay exceeds 100ms, 0delay is directly output.
 */
@property (nonatomic, assign) double delayUpperLimits;
@end
