//
//  DJIHotPointMission.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "DJIMission.h"

/**
 *  Maximum radius in meters of the circlular path the aircraft will fly around the point of interest. Currently 500m.
 */
DJI_API_EXTERN const float DJIHotPointMaxRadius;

/**
 *  Minimum radius in meters of the circlular path the aircraft will fly around the point of interest. Currently 5m.
 */
DJI_API_EXTERN const float DJIHotPointMinRadius;

/**
 *  Aircraft start point relative to hot point.
 */
typedef NS_ENUM (NSUInteger, DJIHotPointStartPoint){
    /**
     *  Start from the North.
     */
    DJIHotPointStartPointNorth,
    /**
     *  Start from the South.
     */
    DJIHotPointStartPointSouth,
    /**
     *  Start from the West.
     */
    DJIHotPointStartPointWest,
    /**
     *  Start from the East
     */
    DJIHotPointStartPointEast,
    /**
     *  Start the circle surrounding the hotpoint at the nearest point
     *  on the circle to the aircraft's current location.
     */
    DJIHotPointStartPointNearest,
};

/**
 *  Heading of the aircraft while orbiting the hot point.
 */
typedef NS_ENUM (NSUInteger, DJIHotPointHeading){
    /**
     *  Heading is in the forward direction of travel along the circular path.
     */
    DJIHotPointHeadingAlongCircleLookingForward,
    /**
     *  Heading is in the backward direction of travel along the circular path.
     */
    DJIHotPointHeadingAlongCircleLookingBackward,
    /**
     *  Heading is toward the hotpoint.
     */
    DJIHotPointHeadingTowardHotPoint,
    /**
     *  Heading is in the direction of the vector defined by the hotpoint and the aircraft in the direction away from the hotpoint.
     */
    DJIHotPointHeadingAwayFromHotPoint,
    /**
     *  Heading is controlled by the remote controller.
     */
    DJIHotPointHeadingControlledByRemoteController,
    /**
     *  The heading remains as the heading of the aircraft when the mission started.
     */
    DJIHotPointHeadingUsingInitialHeading
};

/**
 *  All possible hot point mission execution states.
 */
typedef NS_ENUM (uint8_t, DJIHotpointMissionExecutionState){
    /**
     *  The mission has been started and the aircraft is flying to the start point.
     */
    DJIHotpointMissionExecutionStateInitializing,
    /**
     *  The aircraft is currently moving.
     */
    DJIHotpointMissionExecutionStateMoving,
    /**
     *  The mission is currently paused by the user.
     */
    DJIHotpointMissionExecutionStatePaused,
};

/**
 *  This class provides the real-time status of the executing hot-point mission.
 *
 */
@interface DJIHotPointMissionStatus : DJIMissionProgressStatus

/**
 *  Returns the current execution state of the hot point mission.
 */
@property(nonatomic, readonly) DJIHotpointMissionExecutionState executionState;

/**
 *  The current horizontal distance between the aircraft and the hot point in meters.
 */
@property(nonatomic, readonly) float currentDistanceToHotpoint;

@end

/*********************************************************************************/
#pragma mark - Mission
/*********************************************************************************/

/**
 *  The class represents a hotpoint mission, which can be executed by the mission manager. User can control the aircraft to fly around the hotpoint with specific radius and altitude. During the execution, user can also using the physical remote controller to modify its radius and speed.
 *
 */
@interface DJIHotPointMission : DJIMission

/*********************************************************************************/
#pragma mark - Mission Presets
/*********************************************************************************/
/**
 *  Sets the coordinate of the hot point.
 */
@property(nonatomic, assign) CLLocationCoordinate2D hotPoint;

/**
 *  Sets the altitude of the hot point orbit in meters with range [5,120] meters. The altitude is relative
 *  to the ground altitude from which the aircraft took off.
 */
@property(nonatomic, assign) float altitude;

/**
 *  Sets the circular flight path radius the aircraft will fly around the hotpoint.
 *  the hot point is. The value of this property should be in range of [DJIHotPointMinRadius, DJIHotPointMaxRadius] meters.
 */
@property(nonatomic, assign) float radius;

/**
 *  YES if the aircraft is to travel around the hotpoint in the clockwise direction.
 */
@property(nonatomic, assign) BOOL isClockwise;

/**
 *  Sets the angular velocity (in degrees/second) of the aircraft as it orbits the hot point.
 *  The default value is 20 degrees/s.
 *  The angular velocity is relative to the orbit radius. You can use the maxAngularVelocityForRadius:radius method
 *  to get the maximum supported angular velocity for a given radius.
 */
@property(nonatomic, assign) float angularVelocity;

/**
 *  Aircraft's initial point on the circular flight path when starting the hot point mission.
 */
@property(nonatomic, assign) DJIHotPointStartPoint startPoint;

/**
 *  Aircraft's heading while flying around the hot point. It can be pointed towards or away from the hot point,
 *  forwards or backwards along its flight route, or be controlled by the remote controller.
 */
@property(nonatomic, assign) DJIHotPointHeading heading;

/**
 *  Returns the supported maximum angular velocity in degrees/second for the given
 *  hot point radius in meters.
 *
 *  @param radius Hot point radius with range [5,500] meters to calculate maximum angular velocity.
 *
 *  @return Returns the supported maximum angular velocity for the given radius. Will return 0 if an unsupported radius is input.
 */
+ (float)maxAngularVelocityForRadius:(float)radius;

@end
