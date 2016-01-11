//
//  DJIWaypointStep.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <DJISDK/DJISDK.h>

NS_ASSUME_NONNULL_BEGIN

@class DJIWaypointMission;

/**
 *  This class represents a way-point step for a custom mission. By creating an object of this class and adding it into
 *  a custom mission, a way-point action will be performed during the custom mission.
 *  @see DJIWaypointMission
 */
@interface DJIWaypointStep : DJIMissionStep

/**
 *  Initialized instance with a waypoint mission.
 *
 *  @param mission Waypoint mission.
 *
 *  @return Instance of DJIWaypointStep.
 */
- (instancetype _Nullable)initWithWaypointMission:(DJIWaypointMission *_Nonnull)mission;

@end

NS_ASSUME_NONNULL_END