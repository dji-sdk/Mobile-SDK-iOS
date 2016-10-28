//
//  DJIHotpointStep.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <DJISDK/DJIMissionStep.h>

NS_ASSUME_NONNULL_BEGIN

@class DJIHotPointMission;

/**
 *  This class represents a hot-point step for a custom mission. By creating an object of this class and adding it to
 *  a custom mission, a hot-point action will be performed during the custom mission execution.
 *  @see DJIHotpointMission
 */
@interface DJIHotpointStep : DJIMissionStep

/**
 *  Surrounding angle in degrees. The surrounding angle should be consistent with the hotpoint mission's
 *  direction (`isClockwise`). The default is 360 degrees if `isClockwise` is YES, and -360 degrees if `isClockwise` is NO.
 */
@property(nonatomic, assign) double surroundingAngle;

/**
 *  Initialized instance with a hotpoint mission.
 *
 *  @param mission Hotpoint mission.
 *
 *  @return Instance of DJIHotpointStep.
 */
- (instancetype _Nullable)initWithHotpointMission:(DJIHotPointMission *)mission;

@end

NS_ASSUME_NONNULL_END