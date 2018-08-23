//
//  DJIVideoPreviewSmoothHelper.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//


#import <sys/time.h>
#import "DJIVideoPreviewSmoothHelper.h"

#define DEBUG_DELTA (0)
#define REAL_TIME_DEBUG (1)


@interface DJIVideoPreviewSmoothHelper (){
    FILE* dumpData;
}
// processing time of the previous frame
@property (nonatomic, assign) double prevFrameTime;

// Automatic frame rate statistics
@property (nonatomic, assign) uint32_t autoframeRateCounter;
@property (nonatomic, assign) double autoFrameRateLastCounterTime;
@property (nonatomic, assign) double autoFrameRateDelay; //Automatic frame rate result
@end

@implementation DJIVideoPreviewSmoothHelper

-(id) init{
    if (self = [super init]) {
        self.autoFrameRateDelay = 0;
        self.requiredFrameDelta = 0;
        self.requiredDelay = 0.08;
        
#if DEBUG_DELTA
        NSString* path = [[self class] getDocumentsPath] stringByAppendingPathComponent:@"video_delta.csv"];
        dumpData = fopen(path.UTF8String, "w");
#endif
    }
    
    return self;
}

+(NSString *)getDocumentsPath
{
	static NSString* ret = nil;
	if (ret)
	{
		return ret;
	}
	NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	ret = (NSString *)[paths objectAtIndex:0] ;
	return ret;
}

-(void) resetSmooth{
    self.autoFrameRateLastCounterTime = 0;
    self.autoframeRateCounter = 0;
    self.autoFrameRateDelay = 0;
}

-(double) sleepTimeForCurrentFrame:(double)currentTime framePushInQueueTime:(double)inQueueTime decodeCostTime:(double)decodeTime{
    
    double sleepTime = 0;
    
    //The offset needed for acceleration
    double speedUpDelta = 0.005;
    //The offset needed to decelerate
    double slowDownDelta = 0.005;
    // acceptable delay range
    double delayBounds = 0.01;
    
    // Automatic frame rate statistics
    if(inQueueTime < self.autoFrameRateLastCounterTime){
        [self resetSmooth];
    }
    
    double currentTotleDelay = currentTime - inQueueTime;
    
    double deltaCounterTime = inQueueTime - _autoFrameRateLastCounterTime;
    if (deltaCounterTime > 2.0) {
        // Automatic statistics
        if (_autoframeRateCounter) {
            _autoFrameRateDelay = deltaCounterTime/_autoframeRateCounter;
            _autoframeRateCounter = 0;
#if DEBUG
            NSLog(@"[smooth] auto detect:%f cur:%f", _autoFrameRateDelay, currentTime-inQueueTime);
#endif
            
#if REAL_TIME_DEBUG && __INNER_TOOL__
            NSArray* data = @[@(_autoFrameRateDelay*1000000), @(currentTotleDelay*100000)];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"smooth_decode_debug" object:data];
            });
#endif
        }
        _autoFrameRateLastCounterTime = inQueueTime;
    }
    else{
        _autoframeRateCounter++;
    }
    
    //Calculate the time interval from the previous frame
    double currentFrameDelta = self.requiredFrameDelta;
    if(currentFrameDelta == 0){
        // Use auto-statistic frame rate
        currentFrameDelta = self.autoFrameRateDelay;
    }

    
    if(_requiredDelay > 0.3){
        //300 ms is a long time, we can control the smoothing P
        delayBounds = 0;
        double delta = MIN(fabs(currentTotleDelay - self.requiredDelay), self.requiredDelay);
        speedUpDelta = speedUpDelta*(delta/(self.requiredDelay*0.1));
        slowDownDelta = slowDownDelta*(delta/(self.requiredDelay*0.1));
    }
    
    if (currentTotleDelay >= self.requiredDelay + delayBounds)
    {
        currentFrameDelta -= speedUpDelta;
    }
    else if(currentTotleDelay <= self.requiredDelay - delayBounds)
    {
        currentFrameDelta += slowDownDelta;
    }
    
    // Check the delta deviation from the expected previous frame time
    sleepTime = currentFrameDelta - decodeTime;
    sleepTime = MAX(0, sleepTime);
    
#if DEBUG_DELTA
    if(dumpData){
        fprintf(dumpData, "%d\n", (int)((currentTime - _prevFrameTime)*1000000));
    }
#endif
    
    self.prevFrameTime = currentTime;
    
    if(_delayUpperLimits != 0
       && currentTotleDelay > _delayUpperLimits){
        sleepTime = 0;
    }
    
    return sleepTime;
}

-(double) frameBuffered{
    if(_requiredFrameDelta){
        return _requiredDelay/_requiredFrameDelta;
    }
    else if (_autoFrameRateDelay) {
        return _requiredDelay/_autoFrameRateDelay;
    }
    
    return 0;
}

+(double) getTick{
    double interval = CFAbsoluteTimeGetCurrent();
    return interval;
}

@end
