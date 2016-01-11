//
//  DJIHotpointStep.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <DJISDK/DJISDK.h>

NS_ASSUME_NONNULL_BEGIN

@class DJIHotPointMission;

/**
 *  This class represents a hot-point step for a custom mission. By creating an object of this class and adding it into
 *  a custom mission, a hot-point action will be performed during the custom mission execution.
 *  @see DJIHotpointMission
 */
@interface DJIHotpointStep : DJIMissionStep

/**
 *  Surrounding angle in degrees. The surrounding angle should be consistant with the hotpoint mission's
 *  direction (isClockwise), default is 360 degree if 'isClockwise' is YES or -360 degree if 'isClockwise' is NO.
 */
@property(nonatomic, assign) double surroundingAngle;

- (instancetype _Nullable)initWithHotpointMission:(DJIHotPointMission *)mission;

@end

NS_ASSUME_NONNULL_END