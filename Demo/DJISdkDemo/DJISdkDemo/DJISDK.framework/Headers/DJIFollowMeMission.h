//
//  DJIFollowMe.h
//  DJISDK
//
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <DJISDK/DJIFoundation.h>
#import <DJISDK/DJIObject.h>
#import <DJISDK/DJINavigation.h>

/**
 *  Aircraft's heading during a follow me mission.
 */
typedef NS_ENUM(uint8_t, DJIFollowMeHeadingMode){
    /**
     *  Aircraft's heading will be controlled by the remote controller.
     */
    DJIFollowMeHeadingControlledByRemoteController,
    /**
     *  Aircraft's heading will be towards the coordinate it needs 
     *  to follow. When the mission is first initialized, the heading 
     *  will be towards the initial coordinate (userCoordinate) and 
     *  from there onwards, it's heading will be dicated to what the 
     *  userCoordinate's value is updated to.
     */
    DJIFollowMeHeadingTowardsFollowPosition,
};

/**
 *  All possible follow me mission execution states.
 */
typedef NS_ENUM(uint8_t, DJIFollowMeMissionExecuteState){
    /**
     *  The mission is currently being initialized.
     */
    DJIFollowMeMissionExecuteStateInitializing,
    /**
     *  The aircraft is currently moving.
     */
    DJIFollowMeMissionExecuteStateMoving,
    /**
     *  The mission is currently waiting to continue. For example, 
     *  if the GPS quality is poor or the connection is broken, the
     *  aircraft will continue to wait.
     */
    DJIFollowMeMissionExecuteStateWaiting,
};

@interface DJIFollowMeMissionStatus : DJINavigationMissionStatus

/**
 *  Returns the current execute state of the follow me mission.
 */
@property(nonatomic, readonly) DJIFollowMeMissionExecuteState execState;

/**
 *  Returns the horizontal distance in meters between the aircraft and the coordinate the
 *  aircraft needs to follow.
 */
@property(nonatomic, readonly) float distance;

/**
 *  Returns the error that occured in executing the follow me mission, if interruped
 *  unexpectedly. This will show the user why the follow me mission stopped unexpectedly. 
 *  If error.errorCode returns ERR_Succeeded, then there was no error. 
 */
@property(nonatomic, readonly) DJIError* error;

@end

@protocol DJIFollowMeMission <DJINavigationMission>

/**
 *  User's initial coordinate.
 */
@property(nonatomic, assign) CLLocationCoordinate2D userCoordinate;

/**
 *  The aircraft's heading mode during the mission.
 */
@property(nonatomic, assign) DJIFollowMeHeadingMode headingMode;


/**
 *  Starts the follow me mission.
 *
 *  @param block Remote execute result.
 */
-(void) startMissionWithResult:(DJIExecuteResultBlock)block;

/**
 *  Pauses the follow me mission.
 *
 *  @param block Remote execute result.
 */
-(void) pauseMissionWithResult:(DJIExecuteResultBlock)block;

/**
 *  Resumes the follow me mission.
 *
 *  @param block Remote execute result.
 */
-(void) resumeMissionWithResult:(DJIExecuteResultBlock)block;

/**
 *  Stops the follow me mission.
 *
 *  @param block Remote execute result.
 */
-(void) stopMissionWithResult:(DJIExecuteResultBlock)block;

/**
 *  Updates the user's coordinates the aircraft will follow. Once the follow me mission is initialized,
 *  this method will be used to dictate where the aircraft will move to next.
 *
 *  @param coordinate User coordinate the aricraft will follow.
 *  @param block      Remote execute result callback.
 */
-(void) updateUserCoordinate:(CLLocationCoordinate2D)coordinate withResult:(DJIExecuteResultBlock)block;

@end

