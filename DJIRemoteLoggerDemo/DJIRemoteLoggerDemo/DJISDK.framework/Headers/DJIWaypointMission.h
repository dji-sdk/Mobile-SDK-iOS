/*
 *  DJI iOS Mobile SDK Framework
 *  DJIWaypointMission.h
 *
 *  Copyright (c) 2015, DJI.
 *  All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "DJIMission.h"

NS_ASSUME_NONNULL_BEGIN

@class DJIWaypoint;

/**
 *  Maximum number of waypoints allowed in a waypoint mission. This
 *  number has been set to 100.
 */
DJI_API_EXTERN const int DJIWaypointMissionMaximumWaypointCount;

/**
 *  Minimum number of waypoints allowed in a waypoint mission. This
 *  number has been set to 2.
 */
DJI_API_EXTERN const int DJIWaypointMissionMinimumWaypointCount;


/**
 *  Current waypoint mission state.
 */
typedef NS_ENUM(uint8_t, DJIWaypointMissionExecuteState){
    /**
     *  Waypoint mission is initializing, which means the mission has
     *  started and the aircraft is going to the first waypoint.
     */
    DJIWaypointMissionExecuteStateInitializing,
    /**
     *  Aircraft is currently moving toward the mission's next waypoint.
     */
    DJIWaypointMissionExecuteStateMoving,
    /**
     *  Aircraft is currently rotating at a waypoint to the waypoint's assigne heading.
     */
    DJIWaypointMissionExecuteStateRotating,
    /**
     *  Aircraft has reached a waypoint, has rotated to the new heading and is now processing actions.
     * This state will be called before the waypoint actions starts executing and will occur for each waypoint action.
     */
    DJIWaypointMissionExecuteStateBeginAction,
    /**
     *  Aircraft is at a waypoint and is executing an action.
     */
    DJIWaypointMissionExecuteStateDoingAction,
    /**
     *  Aircraft is at a waypoint and has finished executing the current waypoint
     *  action. This state occurs once for each waypoint action.
     */
    DJIWaypointMissionExecuteStateFinishedAction,
};

/**
 *  Actions for when the waypoint mission has finished.
 */
typedef NS_ENUM(uint8_t, DJIWaypointMissionFinishedAction)
{
    /**
     *  No further action will be taken on completion of mission. At this point, the aircraft can be controlled by the remote controller.
     */
    DJIWaypointMissionFinishedNoAction,
    /**
     *  The aicraft will go home when the mission is complete.
     *  If the aircraft is more than 20m away from the home point it will go home and land.
     *  Otherwise, it will land directly at the current location.
     *
     */
    DJIWaypointMissionFinishedGoHome,
    /**
     *  The aircraft will land automatically at the last waypoint.
     *
     */
    DJIWaypointMissionFinishedAutoLand,
    /**
     *  The aircraft will go back to its first waypoint and hover in position.
     *
     */
    DJIWaypointMissionFinishedGoFirstWaypoint,
    /**
     *  If the user attempts to pull the aircraft back along the flight path as the
     *  mission is being executed, the aircarft will move towards the previous waypoint
     *  and will continue to do so until there are no more waypoint to move back to or
     *  the user has stopped attempting to move the aircraft back. In the process of moving the
     *  aircraft back, if the user ever stops attempting to do so the aircraft will,
     *  automatically continue the mission until the end.
     *
     *  If the aircraft had been pulled back along the flight path all the way to the
     *  first waypoint, and the user continued to pull the back, the aircarft would continue
     *  to hover at the first waypoint. Now, if the user stopped attempting to pull the aircraft
     *  back, the aicraft would execute the mission from start to finish, as it would've if you
     *  had just started the waypoint mission for the first time.
     *
     */
    DJIWaypointMissionFinishedContinueUntilEnd
};

/**
 *  Current waypoint mission heading mode.
 */
typedef NS_ENUM(NSUInteger, DJIWaypointMissionHeadingMode){
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
     *  Aircraft's heading will be set to the previous waypoint's heading while travelling between waypoints.
     *
     */
    DJIWaypointMissionHeadingUsingWaypointHeading,
};

typedef NS_ENUM(NSUInteger, DJIWaypointMissionFlightPathMode)
{
    /**
     *  The flight path will be normal and the aircraft will
     *  move from one waypoint to the next in straight lines.
     */
    DJIWaypointMissionFlightPathNormal,
    /**
     *  The flight path will be curved and the aircraft will
     *  move from one waypoint to the next in a curved motion,
     *  adhering to the cornerRadiusInMeters, which is set in DJIWaypoint.h.
     *
     */
    DJIWaypointMissionFlightPathCurved
};

@interface DJIWaypointMissionStatus : DJIMissionProgressStatus

/**
 *  Index of the waypoint in the waypoint array for the mission that the aircraft will move to next.
 */
@property(nonatomic, readonly) NSInteger targetWaypointIndex;

/**
 *  Whether or not the aircraft has reached a waypoint. Will return
 *  true if a waypoint has been reached.
 *
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
@interface DJIWaypointMission : DJIMission
/*********************************************************************************/
#pragma mark - Mission Presets
/*********************************************************************************/

/**
 *  Number of waypoints in the waypoint mission.
 */
@property(nonatomic, readonly) int waypointCount;

/**
 *  While the aircraft is travelling between waypoints, you can offset its speed by using the throttle joystick on the
 *  remote controller. maxFlightSpeed is this offset when the joystick is pushed to maximum deflection. For example,
 *  If maxFlightSpeed is 10 m/s, then pushing the throttle joystick all the way up will add 10 m/s to the aircraft speed,
 *  while pushing down will subtrace 10 m/s from the aircraft speed. If the remote controller stick is not at maximum
 *  deflection, then the offset speed will be interpolated between [0, maxFlightSpeed] with a resolution of 1000 steps.
 *  If the offset speed is negative, then the aircraft will fly backwards to previous waypoints. When it reaches the first
 *  waypoint, it will then hover in place until a positive speed is applied.
 *  maxFlightSpeed has a range of [2,10] m/s.
 *
 */
@property(nonatomic, assign) float maxFlightSpeed;

/**
 *  The base automatic speed of the aircraft as it moves between waypoints with range [-15, 15] m/s.
 *
 *  The aircraft's actual speed is a combination of the base automatic speed, and the speed control
 *  given by the throttle joystick on the remote controller.
 *
 *  If autoFlightSpeed <>0: Actual speed is autoFlightSpeed + Joystick Speed (with combined max of maxFlightSpeed)
 *  If autoFlightSpeed =0: Actual speed is controlled only by the remote controller joystick.
 *  If autoFlightSpeed <0 and the aircraft is at the first waypoint, then the aircraft will hover in place until the speed is made positive by the remote controller joystick.
 *
 */
@property(nonatomic, assign) float autoFlightSpeed;

/**
 *  Action the aircraft will take when the waypoint mission is complete.
 */
@property(nonatomic, assign) DJIWaypointMissionFinishedAction finishedAction;

/**
 *  Heading of the aircraft as it moves between waypoints. Default is DJIWaypointMissionHeadingAuto.
 */
@property(nonatomic, assign) DJIWaypointMissionHeadingMode headingMode;

/**
 *  Flight path mode of the waypoint mission.
 */
@property(nonatomic, assign) DJIWaypointMissionFlightPathMode flightPathMode;

/**
 * Tracks the upload progress
 */
@property (nonatomic, strong) DJIMissionProgressHandler uploadProgressListener;

/**
 * Tracks the upload completion
 */
@property (nonatomic, strong) DJICompletionBlock uploadCompletionListener;

/**
 * Tracks the upload completion
 */
@property (nonatomic, strong) DJICompletionBlock executionCompletionListener;

/**
 *  Add a waypoint to the waypoint mission. The maximum number of waypoints should not larger than DJIWaypointMissionMaximumWaypointCount. A waypoint will only be valid if the distance (in three dimensions) between two adjacent waypoints is in range [2,2000] meters.
 *
 *  @param Waypoint to be added to the waypoint mission.
 */
-(void) addWaypoint:(DJIWaypoint* _Nonnull)waypoint;

/**
 *  Adds an array of waypoints to the waypoint mission.
 *
 *  @param Array of waypoints to be added to the waypoint mission.
 */
-(void) addWaypoints:(NSArray* _Nonnull)waypoints;

/**
 *  Removes the specific waypoint previously added.
 *
 *  @param waypoint Waypoint object to be removed.
 *
 */
-(void) removeWaypoint:(DJIWaypoint* _Nonnull)waypoint;

/**
 *  Removes the waypoint at an index.
 *
 *  @param index Index of waypoint to be removed from the waypoint mission from
 *  the array of all waypoints.
 */
-(void) removeWaypointAtIndex:(int)index;

/**
 *  Removes all waypoints from the waypoint mission.
 */
-(void) removeAllWaypoints;

/**
 *  Gets a waypoint at an index in the mission waypoint array.
 *
 *  @param index Index of the waypoint wanting to be retrieved from the array of waypoints in the
 *  waypoint mission.
 *
 *  @return Waypoint of type DJIWaypoint if the index exists.
 */
-(DJIWaypoint* _Nullable) getWaypointAtIndex:(int)index;

/*********************************************************************************/
#pragma mark - Mission Updates
/*********************************************************************************/

/**
 *  Set the flight speed while the mission is executing automatically (without manual joystick speed input). This is the only property or method in this class that can communicate with the aircraft during a mission. All other properties and methods are used offline to prepare the mission which is then uploaded to the aircraft.
 *
 *  @param speed Auto flight speed to be set. The absolute value of the auto flight speed should be less than or equal to the maxFlightSpeed. It's range is then [-maxFlightSpeed, maxFlightSpeed] m/s.
 *
 *  @param completion Completion block.
 *
 */
+(void) setAutoFlightSpeed:(float)speed withCompletion:(DJICompletionBlock)completion;



@end

NS_ASSUME_NONNULL_END
