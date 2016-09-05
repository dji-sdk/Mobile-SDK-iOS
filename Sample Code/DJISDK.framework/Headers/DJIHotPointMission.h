//
//  DJIHotPointMission.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "DJIMission.h"
#import "DJISDKFoundation.h"

/**
 *  Maximum radius, in meters, of the circular path the aircraft will fly
 *  around the point of interest. Currently 500m.
 */
DJI_API_EXTERN const float DJIHotPointMaxRadius;

/**
 *  Minimum radius, in meters, of the circular path the aircraft will fly
 *  around the point of interest. Currently 5m.
 */
DJI_API_EXTERN const float DJIHotPointMinRadius;

/**
 *  Aircraft starting point relative to the hot point.
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
     *  Start the circle surrounding the hotpoint at the nearest point on the
     *  circle to the aircraft's current location.
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
     *  Heading is in the direction of the vector, defined by the hotpoint and
     *  the aircraft, in the direction away from the hotpoint.
     */
    DJIHotPointHeadingAwayFromHotPoint,
    /**
     *  Heading is controlled by the remote controller.
     */
    DJIHotPointHeadingControlledByRemoteController,
    /**
     *  The heading remains as the heading of the aircraft when the mission
     *  started.
     */
    DJIHotPointHeadingUsingInitialHeading
};

/**
 *  All possible hot point mission execution states.
 */
typedef NS_ENUM (uint8_t, DJIHotpointMissionExecutionState){
    /**
     *  The mission has been started and the aircraft is flying to the start
     *  point.
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
 *  The current horizontal distance between the aircraft and the hot point in
 *  meters.
 */
@property(nonatomic, readonly) float currentDistanceToHotpoint;

@end

/*********************************************************************************/
#pragma mark - Mission
/*********************************************************************************/

/**
 *  The class represents a hotpoint mission, which can be executed by the
 *  mission manager. In a hot point mission, the aircraft will repeatedly fly
 *  circles of a constant radius around a specified point called a Hot Point.
 *  The user can control the aircraft to fly around the hotpoint with a specific
 *  radius and altitude. During execution, the user can also use the physical
 *  remote controller to modify its radius and speed.
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
 *  Sets the altitude of the hot point orbit, in meters, with a range [5,500]
 *  meters. The altitude is relative to the ground altitude from which the
 *  aircraft took off.
 */
@property(nonatomic, assign) float altitude;

/**
 *  Sets the circular flight path radius with which the aircraft will fly around
 *  the hotpoint.
 *  The value of this property should be in the range of
 *  `[DJIHotPointMinRadius, DJIHotPointMaxRadius]` meters.
 */
@property(nonatomic, assign) float radius;

/**
 *  YES if the aircraft is to travel around the hotpoint in the clockwise
 *  direction.
 */
@property(nonatomic, assign) BOOL isClockwise;

/**
 *  Sets the angular velocity (in degrees/second) of the aircraft as it orbits
 *  the hot point. The default value is 20 degrees/s.
 *  The angular velocity is relative to the orbit radius. Call the
 *  `maxAngularVelocityForRadius:radius` method to get the maximum supported
 *  angular velocity for a given radius.
 */
@property(nonatomic, assign) float angularVelocity;

/**
 *  Aircraft's initial point on the circular flight path when starting the hot
 *  point mission.
 */
@property(nonatomic, assign) DJIHotPointStartPoint startPoint;

/**
 *  Aircraft's heading while flying around the hot point. It can be pointed
 *  toward or away from the hot point, forward or backward along its flight
 *  route, and can be controlled by the remote controller.
 */
@property(nonatomic, assign) DJIHotPointHeading heading;

/**
 *  Returns the supported maximum angular velocity, in degrees/second, for the
 *  hot point radius (specified in meters).
 *
 *  @param radius   Hot point radius with a range of [5,500] meters. This is
                    used to calculate the maximum angular velocity.
 *  @return         Returns the maximum supported angular velocity for the
                    specified radius.
                    Returns 0 if an unsupported radius is specified.
 */
+ (float)maxAngularVelocityForRadius:(float)radius;

@end
