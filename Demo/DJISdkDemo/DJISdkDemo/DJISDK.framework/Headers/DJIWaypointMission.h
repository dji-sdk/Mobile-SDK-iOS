//
//  DJINavigationWaypoint.h
//  DJISDK
//
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJINavigation.h>
#import <DJISDK/DJIWaypoint.h>

/**
 *  Waypoint mission upload and download progress handlers.
 *
 *  @param progress Progress will be in the range of [0, 100] percent.
 */
typedef void (^DJIWaypointMissionUploadProgressHandler)(uint8_t progress);
typedef void (^DJIWaypointMissionDownloadProgressHandler)(uint8_t progress);


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
     *  Aircraft is currently moving towards the mission's next waypoint.
     */
    DJIWaypointMissionExecuteStateMoving,
    /**
     *  Aircraft is currently rotating.
     */
    DJIWaypointMissionExecuteStateRotating,
    /**
     *  Aircraft has reached a waypoint and is processing the current waypoint's
     *  actions. This state is before any waypoint action is executed. This state
     *  occurs once for each waypoint action.
     */
    DJIWaypointMissionExecuteStateBeginAction,
    /**
     *  Aircraft is at a waypoint and is executing the current action.
     */
    DJIWaypointMissionExecuteStateDoingAction,
    /**
     *  Aircraft is at a waypoint and has finished executing the current waypoint
     *  action. This state occurs once for each waypoint action.
     */
    DJIWaypointMissionExecuteStateFinishedAction,
};

typedef NS_ENUM(uint8_t, DJIWaypointMissionFinishedAction)
{
    /**
     *  No action will be taken. The aircraft will exit the task and hover in the
     *  air where the task was completed. After that, the aircraft will be able 
     *  to be controlled by the remote controller.
     */
    DJIWaypointMissionFinishedNoAction,
    /**
     *  The aicraft will go home.
     */
    DJIWaypointMissionFinishedGoHome,
    /**
     *  The aircraft will land automatically.
     */
    DJIWaypointMissionFinishedAutoLand,
    /**
     *  The aircraft will go back to its first waypoint.
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
     */
    DJIWaypointMissionFinishedContinueUntilEnd
};

/**
 *  Current waypoint mission heading mode.
 */
typedef NS_ENUM(NSUInteger, DJIWaypointMissionHeadingMode){
    /**
     *  Aircraft's heading alway be the tangent to the direction of the path to each 
     *  of the waypoints in the waypoint mission. For example, when the aircarft is
     *  moving past a waypoint along a curved path, the heading of the aicraft will be
     *  tangent to the curve.
     */
    DJIWaypointMissionHeadingAuto,
    /**
     *  Aircraft's heading will be set to the initial direction the aircraft
     *  took off from.
     */
    DJIWaypointMissionHeadingUsingInitialDirection,
    /**
     *  Aircraft's heading will be controlled by the remote controller.
     */
    DJIWaypointMissionHeadingControlByRemoteController,
    /**
     *  Aircraft's heading will be set based on each individual waypoint's heading value
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
     *  adhering to the cornerRadius, which is set in DJIWaypoint.h.
     */
    DJIWaypointMissionFlightPathCurved
};

/**
 *  Current waypoint mission status.
 */
@interface DJIWaypointMissionStatus : DJINavigationMissionStatus

/**
 *  Index of the waypoint in the array of all waypoints for the
 *  waypoint mission the aircraft will move to next.
 */
@property(nonatomic, readonly) NSInteger targetWaypointIndex;

/**
 *  Whether or not the aircraft has reached a waypoint. Will return
 *  true if a waypoint has been reached.
 */
@property(nonatomic, readonly) BOOL isWaypointReached;

/**
 *  Current execution state of the aircraft.
 */
@property(nonatomic, readonly) DJIWaypointMissionExecuteState execState;

/**
 *  Last error during execution of the waypoint mission.
 */
@property(nonatomic, readonly) DJIError* error;

@end

@protocol DJIWaypointMission <DJINavigationMission>

/**
 *  Number of waypoints in the waypoint mission. 
 */
@property(nonatomic, readonly) int waypointCount;

/**
 *  Max flight speed for a waypoint mission. The maxFlightSpeed value will be
 *  the result of the autoFlightSpeed value plus the max controlled speed by remote controller,
 *  the maxFlightSpeed should be in range [2, 15]m/s.
 */
@property(nonatomic, assign) float maxFlightSpeed;

/**
 *  The automatically flight speed for a waypoint mission. The autoFlightSpeed's absolute value
 *  should be smaller than the maxFlightSpeed value.the autoFlightSpeed should be in range [-15, 15]m/s.
 */
@property(nonatomic, assign) float autoFlightSpeed;

/**
 *  Action the aircraft will take when the waypoint mission is complete.
 */
@property(nonatomic, assign) DJIWaypointMissionFinishedAction finishedAction;

/**
 *  Heading mode the aircraft will adhere to during the waypoint mission.
 */
@property(nonatomic, assign) DJIWaypointMissionHeadingMode headingMode;

/**
 *  Flight path mode of the waypoint mission.
 */
@property(nonatomic, assign) DJIWaypointMissionFlightPathMode flightPathMode;

/**
 *  Add a waypoint to the waypoint mission. The maximum number of waypoints should not larger then DJIWaypointMissionMaximumWaypointCount. and DJIWaypointMissionMinimumWaypointCount at least. The distance(three dimensions) between adjacent two waypoints should be in range (2, 2000) meters.
 *
 *  @param Waypoint to be added to the waypoint mission.
 */
-(void) addWaypoint:(DJIWaypoint*)waypoint;

/**
 *  Adds an array of waypoints to the waypoint mission.
 *
 *  @param Array of waypoints to be added to the waypoint mission.
 */
-(void) addWaypoints:(NSArray*)waypoints;

/**
 *  Removes the waypoint passed in as a parameter from the waypoint mission.
 *
 *  @param waypoint Waypoint object to be removed.
 */
-(void) removeWaypoint:(DJIWaypoint*)waypoint;

/**
 *  Removes the waypoint at the index passed in as a parameter from the array of
 *  all waypoints in the waypoint mission.
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
 *  Gets a waypoint from the array of waypoints in a waypoint mission based on
 *  the index passsed into the method.
 *
 *  @param index Index of the waypoint wanting to be retrieved from the array of waypoints in the
 *  waypoint mission.
 *
 *  @return Waypoint of type DJIWaypoint if the index exists.
 */
-(DJIWaypoint*) waypointAtIndex:(int)index;

/**
 *  Sets up the upload progress handler, which will tell the user how much progress has been
 *  made in uploading the waypoint mission. The handler will return an integer in the range 
 *  of [0, 100] percent.
 *
 *  @param handler Upload progress handler.
 */
-(void) setUploadProgressHandler:(DJIWaypointMissionUploadProgressHandler)handler;

/**
 *  Sets up the download progress handler, which will tell the user how much progress has been
 *  made in downloading the waypoint mission. The handler will return an integer in the range 
 *  of [0, 100] percent.
 *
 *  @param handler Download progress handler.
 */
-(void) setDownloadProgressHandler:(DJIWaypointMissionDownloadProgressHandler)handler;

/**
 *  Uploads the waypoint mission.
 *
 *  @param block Remote execute result callback.
 */
-(void) uploadMissionWithResult:(DJIExecuteResultBlock)block;

/**
 *  Downloads the waypoint mission from the aircraft. If the download is successful, the
 *  mission's properties will be updated.
 *
 *  @param block Remote execute result callback.
 */
-(void) downloadMissionWithResult:(DJIExecuteResultBlock)block;

/**
 *  Starts the waypoint mission.
 *
 *  @param block Remote execute result.
 */
-(void) startMissionWithResult:(DJIExecuteResultBlock)block;

/**
 *  Pauses the waypoint mission.
 *
 *  @param block Remote execute result callback.
 */
-(void) pauseMissionWithResult:(DJIExecuteResultBlock)block;

/**
 *  Resumes the waypoint mission.
 *
 *  @param block Remote execute result callback.
 */
-(void) resumeMissionWithResult:(DJIExecuteResultBlock)block;

/**
 *  Stops the waypoint mission. If mission stops successfully, the user will not be able to start 
 *  the mission again.
 *
 *  @param block Remote execute result callback.
 */
-(void) stopMissionWithResult:(DJIExecuteResultBlock)block;

/**
 *  Resets the auto flight speed. This can be used to change the auto flight speed during a 
 *  waypoint mission.
 *
 *  @param speed Auto flight speed to be set. The autoFlightSpeed value should be smaller than the
 *  maxFlightSpeed value, should be greater than the DJIWaypointMissionMinimumAutoFlightSpeed value,
 *  and should not exceed the DJIWaypointMissionMaxAutoFlightSpeed value.
 *
 *  @param block Remote execute result callback.
 */
-(void) resetAutoFlightSpeed:(float)speed withResult:(DJIExecuteResultBlock)block;

@end
