//
//  DJIDecodeFrameRateMonitor.m
//
//  Copyright (c) 2013 DJI. All rights reserved.
//

#import "DJIDecodeFrameRateMonitor.h"

#define DJI_FPS_MEASURE_VALID_MIN_VALUE (0.0143)
#define DJI_FPS_MEASURE_VALID_MAX_VALUE (0.05)
#define DJI_FPS_MEASURE_THRESHOLD (20)
#define DJI_FPS_MESURE_TS_QUEUE_SIZE (30)



@interface DJIDecodeFrameRateMonitor()

@property (nonatomic, strong) NSMutableArray* tsQueue;
@property (nonatomic, assign) double lastInputTime;
@property (nonatomic, assign) double totalTimeInterval;
@property (nonatomic, assign) double currentAvgFrameRate;
@property (nonatomic, copy) NSArray* fpsCommonValues;

@end



@implementation DJIDecodeFrameRateMonitor

// The decoding callback is no longer the same thread, but in a serial queue.

- (void)newFrameArrived {
    double currentTime =  CFAbsoluteTimeGetCurrent();
    if (self.lastInputTime == 0) {
        self.lastInputTime = currentTime;
        return;
    }
    
    double timeInterval = currentTime - self.lastInputTime;
    
    if ([self intervalValid:timeInterval] == NO) {
        self.lastInputTime = currentTime;
        return;
    }
    
    if (self.tsQueue.count < DJI_FPS_MESURE_TS_QUEUE_SIZE) {
        self.totalTimeInterval += timeInterval;
        [self.tsQueue addObject:@(timeInterval)];
    }
    else {
        self.totalTimeInterval -= [self.tsQueue.firstObject floatValue];
        [self.tsQueue removeObjectAtIndex:0];
        self.totalTimeInterval += timeInterval;
        [self.tsQueue addObject:@(timeInterval)];
    }
    self.currentAvgFrameRate = self.tsQueue.count / self.totalTimeInterval;
    self.lastInputTime = currentTime;
}

- (BOOL)intervalValid:(double)interval {
    if (interval < DJI_FPS_MEASURE_VALID_MIN_VALUE || interval > DJI_FPS_MEASURE_VALID_MAX_VALUE) {
        return NO;
    }
    return YES;
}

- (NSUInteger)realTimeFrameRate {
    return [self fpsForCommonValues];
}

- (NSUInteger)fpsForCommonValues {
    double currentAvgFps =  self.currentAvgFrameRate;
    if (currentAvgFps <= 0) {
        return 30;
    }
    for (NSUInteger i = 0; i < self.fpsCommonValues.count; i ++) {
        if (i == self.fpsCommonValues.count - 1) {
            break;
        }
        int value = [self.fpsCommonValues[i] unsignedIntegerValue] +
        ([self.fpsCommonValues[i + 1] unsignedIntegerValue] - [self.fpsCommonValues[i] unsignedIntegerValue]) / 100.0f * DJI_FPS_MEASURE_THRESHOLD;
        if (currentAvgFps < value ) {
            return [self.fpsCommonValues[i] unsignedIntegerValue];
        }
    }
    return [self.fpsCommonValues.lastObject unsignedIntegerValue];
}

- (void)reset {
    [self.tsQueue removeAllObjects];
    self.lastInputTime = 0;
    self.totalTimeInterval = 0;
    self.currentAvgFrameRate = 0;
}

- (NSArray *)fpsCommonValues {
    if (_fpsCommonValues) {
        return _fpsCommonValues;
    }
    _fpsCommonValues = @[@(24),@(25),@(30),@(48),@(50),@(60),@(100),@(120)];
    return _fpsCommonValues;
}

- (NSMutableArray *)tsQueue {
    if (_tsQueue) {
        return _tsQueue;
    }
    _tsQueue = [[NSMutableArray alloc] init];
    return _tsQueue;
}

@end
