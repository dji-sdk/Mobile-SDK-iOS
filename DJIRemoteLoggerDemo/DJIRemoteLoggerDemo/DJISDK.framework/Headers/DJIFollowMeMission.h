/*
 *  DJI iOS Mobile SDK Framework
 *  DJIFollowMeMission.h
 *
 *  Copyright (c) 2015, DJI.
 *  All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "DJIMission.h"

/**
 *  Aircraft's heading during a follow me mission.
 */
typedef NS_ENUM(uint8_t, DJIFollowMeHeading){
    /**
     *  Aircraft's heading will be controlled by the remote controller.
     */
    DJIFollowMeHeadingControlledByRemoteController,

    /**
     *  Aircraft's heading remains toward the coordinate it is following.
     */
    DJIFollowMeHeadingTowardFollowPosition,
};

/**
 *  All possible follow me mission execution states.
 */
typedef NS_ENUM(uint8_t, DJIFollowMeMissionExecutionState){
    /**
     *  The mission is currently being initialized.
     *
     */
    DJIFollowMeMissionExecutionStateInitializing,
    /**
     *  The aircraft is currently moving.
     */
    DJIFollowMeMissionExecutionStateMoving,
    /**
     *  The mission is currently waiting to continue. For example,
     *  if the GPS quality is poor or the connection is broken, the
     *  aircraft will continue to wait.
     */
    DJIFollowMeMissionExecuteStateWaiting,
};

@interface DJIFollowMeMissionStatus : DJIMissionProgressStatus

/**
 *  Returns the current execution state of the follow me mission.
 */
@property(nonatomic, readonly) DJIFollowMeMissionExecutionState executionState;

/**
 *  Returns the horizontal distance in meters between the aircraft and the coordinate the
 *  aircraft needs to follow.
 *
 */
@property(nonatomic, readonly) float horizontalDistance;

@end

/*********************************************************************************/
#pragma mark - Mission
/*********************************************************************************/

@interface DJIFollowMeMission : DJIMission

/*********************************************************************************/
#pragma mark - Mission Presets
/*********************************************************************************/

/**
 *  User's initial coordinate.
 */
@property(nonatomic, assign) CLLocationCoordinate2D followMeCoordinate;

/**
 *  The aircraft's heading during the mission.
 */
@property(nonatomic, assign) DJIFollowMeHeading heading;

/*********************************************************************************/
#pragma mark - Mission Updates
/*********************************************************************************/
/**
 *  Updates the coordinate the aircraft will follow. Once the follow me mission is initialized,
 *  this method is used to continuously update the coordinate to follow. If the aircraft doesn't receive an update
 *  within 6 seconds, it will hover in position until the next update arrives.
 *  This is the only property or method in this class that can communicate with the aircraft during a mission.
 *  All other properties and methods are used offline to prepare the mission which is then uploaded to the aircraft.
 *
 *  @param coordinate Coordinate the aricraft will follow. Should be within 200m of current location.
 *  @param completion Completion block.
 *
 */
+(void) updateFollowMeCoordinate:(CLLocationCoordinate2D)coordinate withCompletion:(DJICompletionBlock)completion;

@end
