//
//  DJIWaypoint.h
//  DJISDK
//
//  Created by Ares on 15/7/27.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <DJISDK/DJIFoundation.h>

/**
 *  Maximum number of actions a single waypoint can have. Currently, the maximum number supported is 15.
 */
DJI_API_EXTERN const int DJIMaxActionCount;
/**
 *  Maximum number of times a single waypoint action can be repeated. Currently, the maximum number 
 *  supported is 15.
 */
DJI_API_EXTERN const int DJIMaxActionRepeatTimes;

/**
 *  Aircraft heading turn modes,
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
 */
typedef NS_ENUM(NSUInteger, DJIWaypointActionType){
    /**
     *  Keeps the aircraft at the waypoint's location. The actionParam parameter
     *  will determine how much time in seconds the airactaft will stay at the
     *  location. This actionParam parameter can be set in the range of [0, 999] seconds.
     */
    DJIWaypointActionStay,
    /**
     *  Starts to take photo. The actionParam for the waypoint action will be ignored.
     *  The maximum time set to excute this waypoint action is 6 seconds. If the time,
     *  while executing the waypoint action, goes above 6 seconds, the aircraft will 
     *  stop executing the waypoint action and will move on to the next waypoint action,
     *  if there is one.
     */
    DJIWaypointActionStartTakePhoto,
    /**
     *  Starts recording. The actionParam for the waypoint action will be ignored.
     *  The maximum time set to excute this waypoint action is 6 seconds. If the time,
     *  while executing the waypoint action, goes above 6 seconds, the aircraft will
     *  stop executing the waypoint action and will move on to the next waypoint action,
     *  if there is one.
     */
    DJIWaypointActionStartRecord,
    /**
     *  Stops recording. The actionParam for the waypoint action will be ignored.
     *  The maximum time set to excute this waypoint action is 6 seconds. If the time,
     *  while executing the waypoint action, goes above 6 seconds, the aircraft will
     *  stop executing the waypoint action and will move on to the next waypoint action,
     *  if there is one.
     */
    DJIWaypointActionStopRecord,
    /**
     *  Rotates the aircraft's yaw. The rotationg direction will deternminded by the waypoint's 
     *  turnMode property. The actionParam value must be in the range of [-180, 180] degrees.
     */
    DJIWaypointActionRotateAircraft,
    /**
     *  Rotates the gimbal's pitch. The actionParam value for the Inspire 1 must be in the range
     *  of [-90, 30] degrees and for the Phantom 3 Professional & Advanced, the value must be in 
     *  the range of [-90, 0] degrees.
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
 *  Action parameter of a waypoint action. There are two situation where the action
 *  parameter value will be important. First, when the time to stay at a waypoint is
 *  set and when a part of the aircraft or the entire aircraft needs to be rotated.
 *  In that case, the action parameter will be the angle of rotation. For waypoint
 *  actions where there are no rotations involved or the aircraft is not being asked
 *  to stay at a certain location for a set amount of time, the action parameter
 *  of a waypoint action will be ignored.
 */
@property(nonatomic, assign) int16_t actionParam;

-(id) initWithActionType:(DJIWaypointActionType)type param:(int16_t)param;

@end

@interface DJIWaypoint : NSObject

/**
 *  Coordinate of the waypoint in degrees.
 */
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;

/**
 *  Altitude of the aircraft in meters when it reaches the waypoint. The altitude of the
 *  aircarft is relative to the ground. Setting this value will take the aircraft to the
 *  altitude relative to the ground (the altitude at which it initially took off). 
 *  The value of this property must be in the range of [-200, 500] meters and should not be
 *  larger then the aircraft's max limited height.
 */
@property(nonatomic, assign) float altitude;

/**
 *  Heading of aircraft when it reaches the waypoint. The value of this property must be
 *  in the range of [-180, 180] degrees, where 0 represent true north. This property will be
 *  used when the waypoint mission's headingMode is set to DJIWaypointMissionHeadingUsingWaypointHeading.
 */
@property(nonatomic, assign) float heading;

/**
 *  Dictates how many times a waypoint action is repeated. The default value is one time.
 */
@property(nonatomic, assign) NSUInteger actionRepeatTimes;

/**
 *  The maximum time set to excute all the waypoint actions for a waypoint. If the time,
 *  while executing the waypoint actions, goes above the time set, the aircraft will
 *  stop executing the waypoint actions for the current waypoint and will move on to
 *  the next waypoint. The value of this property must be in the range of [0, 999] seconds.
 *  The default value is 60 seconds.
 */
@property(nonatomic) int actionTimeout;

/**
 *  Corner radius of the waypoint. When the flight path mode is DJIWaypointMissionFlightPathCurved
 *  the flight path as the aircraft reaches a waypoint will be a rounded corner. The value of 
 *  this property must be in the range of [0.2, 1000] meters, and should smaller than the minimum distance(three dimensions) to the previous and the next waypoint.
 */
@property(nonatomic, assign) float cornerRadius;

/**
 *  Determines how the aircraft will turn when rotating. Please take a look at the
 *  enum named DJIWaypointTurnMode at the top of this file to see the two possible
 *  turn modes.
 */
@property(nonatomic) DJIWaypointTurnMode turnMode;

 /**
 *  Array of all waypoint actions for the respective waypoint. The waypoint actions will
 *  be executed one at a time consecutively from the start of the array once the aircraft
 *  reaches the waypoint.
 */
@property(nonatomic, readonly) NSArray* waypointActions;


-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 *  Adds a waypoint action to a waypoint. In order for this method to work, the
 *  number of current waypoint actions added to the waypoint should not be larger
 *  than DJIMaxActionCount. The action will only be executed when the mission's
 *  flightPathMode property is set to DJIWaypointMissionFlightPathNormal. Actions 
 *  cannot be added when the mission's flightPathMode property is set to 
 *  DJIWaypointMissionFlightPathCurved. 
 *
 *  @param action Waypoint action to be added to the waypoint.
 *
 *  @return Whether or not the waypoint action has been added to the waypoint. If the
 *  number of current waypoint actions added to the waypoint is larger
 *  than DJIMaxActionCount, the waypoint does not exist in the action list,
 *  or the waypoint action's actionParam is invalid, this method returns NO.
 */
-(BOOL) addAction:(DJIWaypointAction*)action;

/**
 *  Removes a waypoint action from the waypoint.
 *
 *  @param action Waypoint action to be removed from the waypoint.
 *
 *  @return Whether or not the waypoint action has been removed from the waypoint.
 */
-(BOOL) removeAction:(DJIWaypointAction*)action;

/**
 *  Remove a waypoint action by index.
 *
 *  @param index Waypoint action to be removed at index.
 *
 *  @return Whether or not the waypoint action has been removed from the waypoint.
 */
-(BOOL) removeActionAtIndex:(int)index;

@end