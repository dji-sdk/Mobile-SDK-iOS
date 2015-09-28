//
//  DJIHotPointSurround.h
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
 *  Maximum surrounding radius, which is set to 500 meters. The 
 *  surrounding radius dictates how big the circle around the hot
 *  point is, which the aircraft will travel around as it surrounds
 *  the hot point.
 */
DJI_API_EXTERN const float DJIMaxSurroundingRadius;

/**
 *  Minimum surrounding radius, which is set to 5 meters. The
 *  surrounding radius dictates how big the circle around the hot
 *  point is, which the aircraft will travel around as it surrounds
 *  the hot point.
 */
DJI_API_EXTERN const float DJIMinSurroundingRadius;

/**
 *  Aircraft entry point relative to hot point.
 */
typedef NS_ENUM(NSUInteger, DJIHotPointEntryPoint){
    /**
     *  Entry from the North.
     */
    DJIHotPointEntryFromNorth,
    /**
     *  Entry from the South.
     */
    DJIHotPointEntryFromSouth,
    /**
     *  Entry from the West.
     */
    DJIHotPointEntryFromWest,
    /**
     *  Entry from the East
     */
    DJIHotPointEntryFromEast,
    /**
     *  Entry into the circle surrounding 
     *  the hot point at the nearest point 
     *  on the circle to the aircraft.
     */
    DJIHotPointEntryFromNearest,
};

/**
 *  Heading mode for aircraft while surrounding the hot point.
 */
typedef NS_ENUM(NSUInteger, DJIHotPointHeadingMode){
    /**
     *  Along the circle looking forward.
     */
    DJIHotPointHeadingAlongTheCircleLookingForwards,
    /**
     *  Along the circle looking backwards.
     */
    DJIHotPointHeadingAlongTheCircleLookingBackwards,
    /**
     *  Towards the hotpoint. As the aircraft 
     *  moves along the circle surrounding the 
     *  hot point, the heading will change to ensure 
     *  it is always towards the hot point.
     */
    DJIHotPointHeadingTowardsTheHotPoint,
    /**
     *  Backwards the hotpoint. As the aircraft
     *  moves along the circle surrounding the
     *  hot point, the heading will change to ensure
     *  it is always backward the hot point.
     */
    DJIHotPointHeadingBackwardsTheHotPoint,
    /**
     *  The heading will be controlled by the remote
     *  controller.
     */
    DJIHotPointHeadingControlledByRemoteController,
    /**
     *  The heading will be based on the initial direction
     *  of the aircraft. The initial direction is the 
     *  aircraft's yaw's heading when the mission started.
     */
    DJIHotPointHeadingUsingInitialDirection
};

/**
 *  All possible hot point mission execution states.
 */
typedef NS_ENUM(uint8_t, DJIHotpointMissionExecuteState){
    /**
     *  The mission is currently being initialized. the initializing state will happen after the hot mission is started and flying to the entry point.
     */
    DJIHotpointMissionExecuteStateInitializing,
    /**
     *  The aircraft is currently moving.
     */
    DJIHotpointMissionExecuteStateMoving,
    /**
     *  The mission is currently pausing.
     */
    DJIHotpointMissionExecuteStatePausing,
};

@interface DJIHotpointMissionStatus : DJINavigationMissionStatus

/**
 *  Returns the current execute state of the hot point mission.
 */
@property(nonatomic, readonly) DJIHotpointMissionExecuteState execState;

/**
 *  The distance of the radius between the aircraft and the hot point.
 */
@property(nonatomic, readonly) float currentRadius;

/**
 *  Returns the error that occured in executing the hot point mission.
 */
@property(nonatomic, readonly) DJIError* error;

@end

@protocol DJIHotPointMission <DJINavigationMission>

/**
 *  Sets the coordinate of the hot point.
 */
@property(nonatomic, assign) CLLocationCoordinate2D hotPoint;

/**
 *  Sets the altitude of the hot point in meters. The value of this property is relative 
 *  to the ground (altitude from which the aircraft took off).
 */
@property(nonatomic, assign) float altitude;

/**
 *  Sets the surrounding radius, which dictates how big or small the circle 
 *  around the hotpoint the aircraft will travel around as it surrounds
 *  the hot point is. The value of this property should be in range of [5, 500] meters.
 */
@property(nonatomic, assign) float surroundRadius;

/**
 *  Sets whether or not the aircraft will travel along the circle around the hot point 
 *  in a clockwise or counter-clockwise fashion. If the property is set to YES, the aircraft
 *  will travel in a clockwise fashion and if set to NO, the aircraft will travel in a
 *  counter-clockwise fashion.
 */
@property(nonatomic, assign) BOOL clockwise;

/**
 *  Sets the angular velocity of the drone in degrees/second. The value of this property
 *  should be in the range of [0, 30] degrees/second. The default value is 20 degrees/second. 
 *  The angular velocity is relative to the surroundRadius. Depending on what the
 *  surroundRadius value is, you can use the maxAngularVelocityForRadius: method to get 
 *  the maximum supported angular velocity for a specific surroundRadius value. 
 */
@property(nonatomic, assign) float angularVelocity;

/**
 *  Aircraft's entry point to enter the flight path when starting the hot point mission. 
 */
@property(nonatomic, assign) DJIHotPointEntryPoint entryPoint;

/**
 *  Heading of aircraft while surrounding the hot point.
 */
@property(nonatomic, assign) DJIHotPointHeadingMode headingMode;

/**
 *  Returns the supported maximum angular velocity in degrees/second for the given 
 *  surrounding radius.
 *
 *  @param surroundRadius Surrounding radius for which to retrieve the maximum angular
 *  velocity. The input value should be in the range of [5, 500] meters or the value 0
 *  will be returned.
 *
 *  @return Returns the supported maximum angular velocity for the given surroundRadius.
 */
-(float) maxAngularVelocityForRadius:(float)surroundRadius;

/**
 *  Gets the mission from the aircraft.
 *
 *  @param block Remote execute result block.
 */
-(void) getMissionWithResult:(DJIExecuteResultBlock)block;

/**
 *  Starts to execute the hot point mission. The aircraft 
 *  will enter NavigationMissionHotpoint mode.
 *
 *  @param result Remote execute result.
 */
-(void) startMissionWithResult:(DJIExecuteResultBlock)result;

/**
 *  Pauses the hot point mission.
 *
 *  @param result Remote execute result.
 */
-(void) pauseMissionWithResult:(DJIExecuteResultBlock)result;

/**
 *  Resumes the hot point mission.
 *
 *  @param result Remote execute result.
 */
-(void) resumeMissionWithResult:(DJIExecuteResultBlock)result;

/**
 *  Stops the hot point mission.
 *
 *  @param result Remote execute result.
 */
-(void) stopMissionWithResult:(DJIExecuteResultBlock)result;

@end

