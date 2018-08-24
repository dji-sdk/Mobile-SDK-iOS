//
//  DJISmoothDecode.h
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DJISmoothDecodeProtocol <NSObject>

@required

/*
 * The number of cached frames
 */
-(double) frameBuffered;

/*
 * Decode loop input
 * @return interval to sleep
 */
-(double) sleepTimeForCurrentFrame:(double)currentTime framePushInQueueTime:(double)inQueueTime decodeCostTime:(double)decodeTime;

/*
 * reset smooth decoding
 */
-(void) resetSmooth;

@end
