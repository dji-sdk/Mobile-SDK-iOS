//
//  DJIFollowMeMission.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "DJIMission.h"
#import "DJISDKFoundation.h"

/**
 *  Aircraft's heading during a follow me mission.
 */
typedef NS_ENUM (uint8_t, DJIFollowMeHeading){
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
typedef NS_ENUM (uint8_t, DJIFollowMeMissionExecutionState){
    /**
     *  The mission is currently being initialized (uploaded to the aircraft).
     */
    DJIFollowMeMissionExecutionStateInitializing,
    /**
     *  The aircraft is currently moving.
     */
    DJIFollowMeMissionExecutionStateMoving,
    /**
     *  The mission is currently waiting to continue. This will happen if the
     *  follow me coordinate is not updated in 6 seconds, or the GPS signal
     *  quality is poor or broken.
     */
    DJIFollowMeMissionExecuteStateWaiting,
};

/**
 *  This class provides the real-time status of the executing follow-me mission.
 */
@interface DJIFollowMeMissionStatus : DJIMissionProgressStatus

/**
 *  Returns the current execution state of the follow me mission.
 */
@property(nonatomic, readonly) DJIFollowMeMissionExecutionState executionState;

/**
 *  Returns the horizontal distance in meters between the aircraft and the
 *  coordinate the aircraft must follow.
 */
@property(nonatomic, readonly) float horizontalDistance;

@end

/*********************************************************************************/
#pragma mark - Mission
/*********************************************************************************/

/**
 *  The class represents a follow me mission. In a follow me mission, the
 *  aircraft is programmed to track and maintain a constant distant relative to
 *  some object, such as a person or a moving vehicle.
 *  You can use it to make the aircraft follow a GPS device, such as a remote
 *  controller with a GPS signal or a mobile device.
 */
@interface DJIFollowMeMission : DJIMission

/*********************************************************************************/
#pragma mark - Mission Presets
/*********************************************************************************/

/**
 *  User's initial coordinate.
 */
@property(nonatomic, assign) CLLocationCoordinate2D followMeCoordinate;

/**
 *  User's initial altitude (above sea level). If not using altitude follow, set this property to zero.
 */
@property(nonatomic, assign) float followMeAltitude;

/**
 *  The aircraft's heading during the mission.
 */
@property(nonatomic, assign) DJIFollowMeHeading heading;

/*********************************************************************************/
#pragma mark - Mission Updates
/*********************************************************************************/

/**
 *  Updates the coordinate that the aircraft will follow. Once the follow me
 *  mission is initialized, this method is used to continuously update the
 *  coordinate to follow. If the aircraft doesn't receive an update within 6
 *  seconds, it will hover in position until the next update arrives.
 *  This is the only property or method in this class that can communicate with
 *  the aircraft during a mission.
 *  All other properties and methods are used offline to prepare the mission
 *  which is then uploaded to the aircraft.
 *
 *  @param coordinate Coordinate the aircraft will follow. Should be within 200m
 *                    horizontal distance of the current location.
 *  @param completion Completion block.
 *
 */
+ (void)updateFollowMeCoordinate:(CLLocationCoordinate2D)coordinate
                  withCompletion:(DJICompletionBlock)completion;

/**
 *  Updates the coordinate that the aircraft will follow with a customized
 *  altitude.
 *
 *  @param coordinate Coordinate the aircraft will follow. Should be within 200m
 *                    horizontal distance of the current location.
 *  @param altitude   The following altitude.
 *  @param completion Completion block.
 *
 */
+ (void)updateFollowMeCoordinate:(CLLocationCoordinate2D)coordinate
                        altitude:(float)altitude
                  withCompletion:(DJICompletionBlock)completion;

@end
