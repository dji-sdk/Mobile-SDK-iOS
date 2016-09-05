//
//  DJIAircraftYawStep.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#import <DJISDK/DJIMissionStep.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class represents an aircraft yaw rotation step for a custom mission. By creating an object of this class
 *  and adding it to a custom mission, an aircraft yaw rotation action will be performed during the custom mission
 *  execution.
 */
@interface DJIAircraftYawStep : DJIMissionStep

/**
 *  Initialized mission step with an angle relative to current heading. The velocity is the yaw rotation angular velocity
 *  which has a range of [0, 100] degree/s and a default of 20 degree/s.
 */
- (instancetype _Nullable)initWithRelativeAngle:(double)angle andAngularVelocity:(double)velocity;

@end

NS_ASSUME_NONNULL_END