//
//  DJIImageCalibrationFrameQueue.h
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#ifndef DJIImageCalibrationFrameQueue_h
#define DJIImageCalibrationFrameQueue_h

#import <DJIWidget/DJIImageCalibrationFastFrame.h>

@interface DJIImageCalibrationFrameQueue : NSObject

-(instancetype)initWithQueueCapacity:(NSUInteger)capacity
                       andThreadSafe:(BOOL)threadSafe;

-(BOOL)push:(DJIImageCalibrationFastFrame*)frame;

-(DJIImageCalibrationFastFrame*)pull;

@end

#endif /* DJIImageCalibrationFrameQueue_h */
