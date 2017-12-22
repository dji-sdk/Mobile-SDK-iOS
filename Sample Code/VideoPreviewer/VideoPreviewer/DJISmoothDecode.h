//
//  DJISmoothDecode.h
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DJISmoothDecodeProtocol <NSObject>

@required

/*
 * 获取ms精度的时间
 */
-(double) getTick;

/*
 * 缓存的帧数
 */
-(double) frameBuffered;

/*
 * 解码循环输入
 * @return interval to sleep
 */
-(double) sleepTimeForCurrentFrame:(double)currentTime framePushInQueueTime:(double)inQueueTime decodeCostTime:(double)decodeTime;

/*
 * 重置平滑器
 */
-(void) resetSmooth;

@end
