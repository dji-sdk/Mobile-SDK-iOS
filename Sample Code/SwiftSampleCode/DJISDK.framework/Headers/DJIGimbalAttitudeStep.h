//
//  DJIGimbalAttitudeStep.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <DJISDK/DJISDK.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Subclass of DJIMission Step, you can control gimbal attitude using this mission step.
 *
 */
@interface DJIGimbalAttitudeStep : DJIMissionStep

/**
 *  Completion time in seconds for gimbal go to target attitude from current attitude. Default is 1s.
 */
@property(nonatomic, assign) double completionTime;

/**
 *  Target gimbal attitude.
 */
@property(nonatomic, readonly) DJIGimbalAttitude targetAttitude;

/**
 *  Initialized instance with gimbal target attitude.
 *
 *  @param attitude  Gimbal target attitude.
 *
 *  @return Instance of DJIGimbalAttitudeStep.
 */
- (instancetype _Nullable)initWithAttitude:(DJIGimbalAttitude)attitude;

@end

NS_ASSUME_NONNULL_END
