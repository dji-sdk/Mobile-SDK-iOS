//
//  DJIWaypointStep.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <DJISDK/DJIMissionStep.h>

NS_ASSUME_NONNULL_BEGIN

@class DJIWaypointMission;

/**
 *  This class represents a waypoint step for a custom mission. By creating an object of this class and adding it into a custom mission, a waypoint action will be performed during the custom mission.
 *
 *  @warning Data related to a waypoint mission will be uploaded to the aircraft right before the execution of each waypoint mission step. The uploading process may take minutes depending on the number of waypoints and the connection status.
 *
 *  @see DJIWaypointMission
 */
@interface DJIWaypointStep : DJIMissionStep

/**
 *  Initialized instance with a waypoint mission.
 *
 *  @param mission Waypoint mission.
 *
 *  @return Instance of `DJIWaypointStep`.
 */
- (instancetype _Nullable)initWithWaypointMission:(DJIWaypointMission *_Nonnull)mission;

@end

NS_ASSUME_NONNULL_END