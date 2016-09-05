//
//  DJIWaypointMission.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "DJISDKFoundation.h"
#import "DJIMission.h"

NS_ASSUME_NONNULL_BEGIN

@class DJIWaypoint;

/**
 *  Maximum number of waypoints allowed in a waypoint mission. This number has
 *  been set to 100.
 */
DJI_API_EXTERN const int DJIWaypointMissionMaximumWaypointCount;

/**
 *  Minimum number of waypoints allowed in a waypoint mission. This number has
 *  been set to 2.
 */
DJI_API_EXTERN const int DJIWaypointMissionMinimumWaypointCount;

/**
 *  Current waypoint mission state.
 */
typedef NS_ENUM (uint8_t, DJIWaypointMissionExecuteState){
    /**
     *  Waypoint mission is initializing, which means the mission has started
     *  and the aircraft is going to the first waypoint.
     */
    DJIWaypointMissionExecuteStateInitializing,
    /**
     *  Aircraft is currently moving toward the mission's next waypoint. This
     *  happens when the `flightPathMode` is set to
     *  `DJIWaypointMissionFlightPathNormal`.
     */
    DJIWaypointMissionExecuteStateMoving,
    /**
     *  Aircraft is currently moving. This happens when the `flightPathMode` is
     *  set to `DJIWaypointMissionFlightPathCurved`.
     */
    DJIWaypointMissionExecuteStateCurveModeMoving,
    /**
     *  Aircraft is currently turning. This happens when the `flightPathMode` is
     *  set to `DJIWaypointMissionFlightPathCurved`.
     */
    DJIWaypointMissionExecuteStateCurveModeTurning,
    /**
     *  Aircraft has reached a waypoint, has rotated to the new heading and is
     *  now processing actions.
     *  This state will be called before the waypoint actions starts executing
     *  and will occur for each waypoint action.
     */
    DJIWaypointMissionExecuteStateBeginAction,
    /**
     *  Aircraft is at a waypoint and is executing an action.
     */
    DJIWaypointMissionExecuteStateDoingAction,
    /**
     *  Aircraft is at a waypoint and has finished executing the current
     *  waypoint action. This state occurs once for each waypoint action.
     */
    DJIWaypointMissionExecuteStateFinishedAction,
    /**
     *  Aircraft has returned to the first waypoint. This happens when the
     *  `finishedAction` is set to `JIWaypointMissionFinishedGoFirstWaypoint`.
     */
    DJIWaypointMissionExecuteStateReturnToFirstWaypoint,
    /**
     *  The mission is currently paused by the user.
     */
    DJIWaypointMissionExecuteStatePaused,
};

/**
 *  Actions taken when the waypoint mission has finished.
 */
typedef NS_ENUM (uint8_t, DJIWaypointMissionFinishedAction){
    /**
     *  No further action will be taken on completion of mission. At this point,
     *  the aircraft can be controlled by the remote controller.
     */
    DJIWaypointMissionFinishedNoAction,
    /**
     *  The aircraft will go home when the mission is complete.
     *  If the aircraft is more than 20m away from the home point it will go
     *  home and land.
     *  Otherwise, it will land directly at the current location.
     */
    DJIWaypointMissionFinishedGoHome,
    /**
     *  The aircraft will land automatically at the last waypoint.
     */
    DJIWaypointMissionFinishedAutoLand,
    /**
     *  The aircraft will go back to its first waypoint and hover in position.
     */
    DJIWaypointMissionFinishedGoFirstWaypoint,
    /**
     *  When the aircraft reaches its final waypoint, it will hover without
     *  ending the mission. The joystick can still be used to pull the aircraft
     *  back along its previous waypoints. The only way this mission can end is
     *  if stopMission is called.
     */
    DJIWaypointMissionFinishedContinueUntilStop
};

/**
 *  Current waypoint mission heading mode.
 */
typedef NS_ENUM (NSUInteger, DJIWaypointMissionHeadingMode){
    /**
     *  Aircraft's heading will always be in the direction of flight.
     */
    DJIWaypointMissionHeadingAuto,
    /**
     *  Aircraft's heading will be set to the initial take-off heading.
     */
    DJIWaypointMissionHeadingUsingInitialDirection,
    /**
     *  Aircraft's heading will be controlled by the remote controller.
     */
    DJIWaypointMissionHeadingControledByRemoteController,
    /**
     *  Aircraft's heading will gradually change between waypoints.
     */
    DJIWaypointMissionHeadingUsingWaypointHeading,
    /**
     *  Aircraft's heading will always toward point of interest.
     */
    DJIWaypointMissionHeadingTowardPointOfInterest,
};

/**
 *  Waypoint mission flight path mode.
 */
typedef NS_ENUM (NSUInteger, DJIWaypointMissionFlightPathMode){
    /**
     *  The flight path will be normal and the aircraft will
     *  move from one waypoint to the next in straight lines.
     */
    DJIWaypointMissionFlightPathNormal,
    /**
     *  The flight path will be curved and the aircraft will
     *  move from one waypoint to the next in a curved motion,
     *  adhering to the `cornerRadiusInMeters`, which is set in `DJIWaypoint`.
     *
     */
    DJIWaypointMissionFlightPathCurved
};

/**
 *  Waypoint mission go to waypoint mode.
 */
typedef NS_ENUM (NSInteger, DJIWaypointMissionGotoWaypointMode) {
    /**
     *  Go to the waypoint safely. The aircraft will rise to the same altitude
     *  of the waypoint if the current altitude is lower then the waypoint
     *  altitude. It then goes to the waypoint coordinate from the current
     *  altitude, and proceeds to the altitude of the waypoint.
     */
    DJIWaypointMissionGotoWaypointSafely,
    /**
     *  Go to the waypoint directly from the current aircraft point.
     */
    DJIWaypointMissionGotoWaypointPointToPoint,
};

/**
 *  This class provides the real-time status of an executing waypoint mission.
 */
@interface DJIWaypointMissionStatus : DJIMissionProgressStatus

/**
 *  Index of the waypoint for the next mission to which the aircraft will proceed.
 */
@property(nonatomic, readonly) NSInteger targetWaypointIndex;

/**
 *  YES when the aircraft reaches a waypoint. After the waypoint actions and
 *  heading change is complete, the `targetWaypointIndex` will increment and
 *  this property will become NO.
 */
@property(nonatomic, readonly) BOOL isWaypointReached;

/**
 *  Current execution state of the aircraft.
 */
@property(nonatomic, readonly) DJIWaypointMissionExecuteState execState;

@end

/*********************************************************************************/
#pragma mark - Mission
/*********************************************************************************/

/**
 *  In the waypoint mission, the aircraft will travel between waypoints, execute
 *  actions at waypoints, and adjust heading and altitude between waypoints.
 *  Waypoints are physical locations to which the aircraft will fly. Creating a
 *  series of waypoints, in effect, will program a flight route for the aircraft
 *  to follow. Actions can also be added to waypoints, which will be carried out
 *  when the aircraft reaches the waypoint.
 *
 *  The aircraft travels between waypoints automatically at a base speed.
 *  However, the user can change the speed by using the pitch joystick. If the
 *  stick is pushed up, the speed will increase. If the stick is pushed down,
 *  the speed will slow down. The stick can be pushed down to stop the aircraft
 *  and further pushed to start making the aircraft travel back along the path
 *  it came. When the aircraft is traveling through waypoints in the reverse
 *  order, it will not execute waypoint actions at each waypoint. If the stick
 *  is released, the aircraft will again travel through the waypoints in the
 *  original order, and continue to execute waypoint actions (even if executed
 *  previously).
 *
 *  If the aircraft is pulled back along the waypoint mission all the way to the
 *  first waypoint, then it will hover in place until the stick is released
 *  enough for it to again progress through the mission from start to finish.
 */

@interface DJIWaypointMission : DJIMission

/*********************************************************************************/
#pragma mark - Mission Presets
/*********************************************************************************/

/**
 *  Number of waypoints in the waypoint mission.
 */
@property(nonatomic, readonly) int waypointCount;

/**
 *  While the aircraft is traveling between waypoints, you can offset its speed
 *  by using the throttle joystick on the remote controller. `maxFlightSpeed` is
 *  this offset when the joystick is pushed to maximum deflection. For example,
 *  If maxFlightSpeed is 10 m/s, then pushing the throttle joystick all the way
 *  up will add 10 m/s to the aircraft speed, while pushing down will subtract
 *  10 m/s from the aircraft speed. If the remote controller stick is not at
 *  maximum deflection, then the offset speed will be interpolated between
 *  `[0, maxFlightSpeed]` with a resolution of 1000 steps.
 *  If the offset speed is negative, then the aircraft will fly backwards to
 *  previous waypoints. When it reaches the first waypoint, it will then hover
 *  in place until a positive speed is applied.
 *  `maxFlightSpeed` has a range of [2,15] m/s.
 */
@property(nonatomic, assign) float maxFlightSpeed;

/**
 *  The base automatic speed of the aircraft as it moves between waypoints with
 *  range [-15, 15] m/s.
 *
 *  The aircraft's actual speed is a combination of the base automatic speed,
 *  and the speed control given by the throttle joystick on the remote controller.
 *
 *  If `autoFlightSpeed >0`: Actual speed is `autoFlightSpeed` + Joystick Speed
 *  (with combined max of `maxFlightSpeed`)
 *  If `autoFlightSpeed =0`: Actual speed is controlled only by the remote
 *  controller joystick.
 *  If `autoFlightSpeed <0` and the aircraft is at the first waypoint, the
 *  aircraft will hover in place until the speed is made positive by the remote
 *  controller joystick.
 */
@property(nonatomic, assign) float autoFlightSpeed;

/**
 *  Action the aircraft will take when the waypoint mission is complete.
 */
@property(nonatomic, assign) DJIWaypointMissionFinishedAction finishedAction;

/**
 *  Heading of the aircraft as it moves between waypoints.
 *  Default is `DJIWaypointMissionHeadingAuto`.
 */
@property(nonatomic, assign) DJIWaypointMissionHeadingMode headingMode;

/**
 *  Flight path mode of the waypoint mission.
 */
@property(nonatomic, assign) DJIWaypointMissionFlightPathMode flightPathMode;

/**
 *  Determines the aricraft how to go to first waypoint frome current position.
 *  Default is `DJIWaypointMissionGotoWaypointSafely`.
 */
@property(nonatomic, assign) DJIWaypointMissionGotoWaypointMode gotoFirstWaypointMode;

/**
 *  Determines whether exit mission when RC signal lost. Default is NO.
 */
@property(nonatomic, assign) BOOL exitMissionOnRCSignalLost;

/**
 *  Property is used when `headingMode` is
 *  `DJIWaypointMissionHeadingTowardPointOfInterest`. Aircraft will always be
 *  heading to point while executing mission.
 *  Default is `kCLLocationCoordinate2DInvalid`.
 */
@property(nonatomic, assign) CLLocationCoordinate2D pointOfInterest;

/**
 *  Determines whether the aircraft can rotate gimbal pitch when executing
 *  waypoint mission. If `YES`, the aircraft will control gimbal pitch rotation
 *  between waypoints using the `gimbalPitch` of the `DJIWaypoint`.
 */
@property(nonatomic, assign) BOOL rotateGimbalPitch;

/**
 *  Repeat times for mission execution. Default is 1.
 */
@property(nonatomic, assign) int repeatTimes;

/**
 *  Add a waypoint to the waypoint mission. The number of waypoints should be in
 *  the range `[DJIWaypointMissionMinimumWaypointCount, DJIWaypointMissionMaximumWaypointCount]`.
 *  A waypoint will only be valid if the distance (in three dimensions) between
 *  two adjacent waypoints is in range [0.5,2000] meters.
 *
 *  @param Waypoint to be added to the waypoint mission.
 */
- (void)addWaypoint:(DJIWaypoint *_Nonnull)waypoint;

/**
 *  Adds an array of waypoints to the waypoint mission.
 *
 *  @param Array of waypoints to be added to the waypoint mission.
 */
- (void)addWaypoints:(NSArray *_Nonnull)waypoints;

/**
 *  Removes a specific waypoint that was previously added.
 *
 *  @param waypoint Waypoint object to be removed.
 *
 */
- (void)removeWaypoint:(DJIWaypoint *_Nonnull)waypoint;

/**
 *  Removes the waypoint at an index.
 *
 *  @param index Index of the waypoint to be removed from the waypoint mission.
 */
- (void)removeWaypointAtIndex:(int)index;

/**
 *  Removes all waypoints from the waypoint mission.
 */
- (void)removeAllWaypoints;

/**
 *  Gets the waypoint at the specified index in the mission waypoint array.
 *
 *  @param index Index of the waypoint to be retrieved.
 *
 *  @return Waypoint of type `DJIWaypoint`, if the index exists.
 */
- (DJIWaypoint *_Nullable)getWaypointAtIndex:(int)index;

/*********************************************************************************/
#pragma mark - Mission Updates
/*********************************************************************************/

/**
 *  Set the flight speed while the mission is executing automatically (without
 *  manual joystick speed input). This is the only property or method in this
 *  class that can communicate with the aircraft during a mission. All other
 *  properties and methods are used offline to prepare the mission which is then
 *  uploaded to the aircraft.
 *
 *  @param speed      Auto flight speed to be set. The absolute value of the auto
 *                    flight speed should be less than or equal to the `maxFlightSpeed`.
 *                    Its range is `[-maxFlightSpeed, maxFlightSpeed]` m/s.
 *  @param completion Completion block.
 */
+ (void)setAutoFlightSpeed:(float)speed withCompletion:(DJICompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
