//
//  DJIGimbalAttitudeStep.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <DJISDK/DJIMissionStep.h>
#import <DJISDK/DJIGimbalBaseTypes.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Subclass of `DJIMissionStep`. You can control the gimbal attitude using this mission step.
 *
 */
@interface DJIGimbalAttitudeStep : DJIMissionStep

/**
 *  Completion time, in seconds, for the gimbal to go to the target attitude from current attitude. Default is 1 second.
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
 *  @return Instance of `DJIGimbalAttitudeStep`.
 */
- (instancetype _Nullable)initWithAttitude:(DJIGimbalAttitude)attitude;

@end

NS_ASSUME_NONNULL_END
