//
//  DJIDecodeFrameRateMonitor.h
//
//  Copyright (c) 2013 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIStreamCommon.h"



@interface DJIDecodeFrameRateMonitor : NSObject

- (void)newFrameArrived;

- (NSUInteger)realTimeFrameRate;

- (void)reset;


@end
