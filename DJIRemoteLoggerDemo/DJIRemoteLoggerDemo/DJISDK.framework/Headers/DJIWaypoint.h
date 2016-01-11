/*
 *  DJI iOS Mobile SDK Framework
 *  DJIWaypoint.h
 *
 *  Copyright (c) 2015, DJI.
 *  All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "DJIBaseProduct.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Maximum number of actions a single waypoint can have. Currently, the maximum number supported is 15.
 */
DJI_API_EXTERN const int DJIMaxActionCount;

/**
 *  Maximum number of times a single waypoint action can be repeated. Currently, the maximum number
 *  supported is 15.
 *
 */
DJI_API_EXTERN const int DJIMaxActionRepeatTimes;

/**
 *  How the aircraft will turn at a waypoint to transition between headings.
 */
typedef NS_ENUM(NSUInteger, DJIWaypointTurnMode){
    /**
     *  Changes the heading of the aircraft by rotating the aircraft clockwise.
     */
    DJIWaypointTurnClockwise,
    /**
     *  Changes the heading of the aircraft by rotating the aircraft anti-clockwise.
     */
    DJIWaypointTurnCounterClockwise,
};

/**
 *  Waypoint action types.
 *
 */
typedef NS_ENUM(NSUInteger, DJIWaypointActionType){
    /**
     *  Keeps the aircraft at the waypoint's location. The actionParam parameter
     *  will determine how much time in milliseconds the aircraft will stay at the
     *  location. This actionParam parameter can be set in the range of [0, 32767] milliseconds.
     */
    DJIWaypointActionStay,
    /**
     *  Starts to shoot photo. The actionParam for the waypoint action will be ignored.
     *  The maximum time set to excute this waypoint action is 6 seconds. If the time,
     *  while executing the waypoint action, goes above 6 seconds, the aircraft will
     *  stop executing the waypoint action and will move on to the next waypoint action,
     *  if there is one.
     *
     */
    DJIWaypointActionStartTakePhoto,
    /**
     *  Starts recording. The actionParam for the waypoint action will be ignored.
     *  The maximum time set to excute this waypoint action is 6 seconds. If the time,
     *  while executing the waypoint action, goes above 6 seconds, the aircraft will
     *  stop executing the waypoint action and will move on to the next waypoint action,
     *  if there is one.
     *
     */
    DJIWaypointActionStartRecord,
    /**
     *  Stops recording. The actionParam for the waypoint action will be ignored.
     *  The maximum time set to excute this waypoint action is 6 seconds. If the time,
     *  while executing the waypoint action, goes above 6 seconds, the aircraft will
     *  stop executing the waypoint action and will move on to the next waypoint action,
     *  if there is one.
     *
     */
    DJIWaypointActionStopRecord,
    /**
     *  Rotates the aircraft's yaw. The rotationg direction will determined by the waypoint's
     *  turnMode property. The actionParam value must be in the range of [-180, 180] degrees.
     */
    DJIWaypointActionRotateAircraft,
    /**
     *  Rotates the gimbal's pitch. The actionParam value should be in range [-90, 0] degrees.
     */
    DJIWaypointActionRotateGimbalPitch,
};

@interface DJIWaypointAction : NSObject

/**
 *  Waypoint action of type DJIWaypointActionType the aircraft will execute once the aircraft
 *  reaches the waypoint. Please find all the possible actions in the enum named
 *  DJIWaypointActionType above.
 */
@property(nonatomic, assign) DJIWaypointActionType actionType;

/**
 *  Action parameter of a waypoint action. See enum DJIWaypointAction for details on which actions will use actionParam.
 */
@property(nonatomic, assign) int16_t actionParam;

/**
 * Initializer with actions type
 * 
 * @param type DJIWaypointActionType
 * @param param value relevant for the action required such as gimbal's pitch angle in DJIWaypointActionRotateGimbalPitch
 */
-(id) initWithActionType:(DJIWaypointActionType)type param:(int16_t)param;

@end

@interface DJIWaypoint : NSObject

/**
 *  Waypoint coordinate latitude and longitude in degrees.
 */
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;

/**
 *  Altitude of the aircraft in meters when it reaches waypoint. The altitude of the
 *  aircraft is relative to the ground at the take-off location, has a range of [-200,500] and should not be larger than the aircraft's max limited altitude. If two adjacent waypoints have different alitutdes, then the alitude will gradually change as the aircraft flys between waypoints.
 *
 */
@property(nonatomic, assign) float altitude;

/**
 *  Heading the aircraft will rotate to after it reaches the waypoint. The aircraft will fly at the previous waypoints heading until it reaches the current waypoint. Once it reaches the waypoint, it will rotate to the new heading, then execute actions (if available). Heading has a range of [-180, 180] degrees, where 0 represents True North. This property will be
 *  used when the waypoint mission's headingMode is set to DJIWaypointMissionHeadingUsingWaypointHeading.
 *
 */
@property(nonatomic, assign) float heading;

/**
 *  Dictates how many times a waypoint action is repeated. The default value is one time.
 *
 */
@property(nonatomic, assign) NSUInteger actionRepeatTimes;

/**
 *  The maximum time set to excute all the waypoint actions for a waypoint. If the time,
 *  while executing the waypoint actions, goes above the time set, the aircraft will
 *  stop executing the waypoint actions for the current waypoint and will move on to
 *  the next waypoint. The value of this property must be in the range of [0, 999] seconds.
 *  The default value is 60 seconds.
 */
@property(nonatomic) int actionTimeoutInSeconds;

/**
 *  Corner radius of the waypoint. When the flight path mode is DJIWaypointMissionFlightPathCurved
 *  the flight path through a waypoint will be a curve (rounded corner) with radius [0 or 0.2,1000].
 *  By default, the radius is 0 m (no curve).
 *  If a radius is desired, then a minimum of 0.2m is can be set.
 *  The radius should not be larger than the three dimensional distance between the any two of
 *  the three waypoints which make the corner.
 *  If a radius is defined, then the aircraft will not travel directly between the waypoints. Rather it will
 *  fly out of the corner lines to form the tangent with the curve.
 *
 */
@property(nonatomic, assign) float cornerRadiusInMeters;

/**
 *  Determines whether the aircraft will turn clockwise or anticlockwise when changing its heading as it travels
 *  toward this waypoint.
 *  This is used when the property headingMode of the waypoint mission (DJIWaypointMission class)
 *  is DJIWaypointMissionHeadingMode
 *
 */
@property(nonatomic) DJIWaypointTurnMode turnMode;

/**
 *  Array of all waypoint actions for the respective waypoint. The waypoint actions will
 *  be executed consecutively from the start of the array once the aircraft
 *  reaches the waypoint.
 */
@property(nonatomic, readonly) NSArray* waypointActions;


/**
 */
-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 *  Adds a waypoint action to a waypoint. The number of waypoint actions should not be
 *  larger than DJIMaxActionCount. The action will only be executed when the mission's
 *  flightPathMode property is set to DJIWaypointMissionFlightPathNormal and will be
 *  not be executed when the mission's flightPathMode property is set to
 *  DJIWaypointMissionFlightPathCurved.
 *
 *  @param action Waypoint action to be added to the waypoint.
 *
 *  @return Yes if the waypoint action has been added to the waypoint. NO if the waypoint action
 *  count is too high, or if the waypoint action was incorrectly setup.
 *
 */
-(BOOL) addAction:(DJIWaypointAction*)action;

/**
 *  Removes the last waypoint action from the waypoint.
 *
 *  @param action Waypoint action to be removed from the waypoint.
 *  @return Whether or not the waypoint action has been removed from the waypoint.
 */
-(BOOL) removeAction:(DJIWaypointAction*)action;

/**
 *  Removes a waypoint action from the waypoint by index. After removal, all actions higher in index will
 *  be shifted down by one index.
 *
 *  @param index Waypoint action to be removed at index.
 *
 *  @return YES if waypoint action has been removed from the waypoint.
 */
-(BOOL) removeActionAtIndex:(int)index;

@end

NS_ASSUME_NONNULL_END
