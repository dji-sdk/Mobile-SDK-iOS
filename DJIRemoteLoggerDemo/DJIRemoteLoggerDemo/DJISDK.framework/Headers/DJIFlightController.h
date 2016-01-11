/*
 *  DJI iOS Mobile SDK Framework
 *  DJIFlightController.h
 *
 *  Copyright (c) 2015, DJI.
 *  All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <DJISDK/DJIBaseComponent.h>
#import <DJISDK/DJIFlightControllerCurrentState.h>

@class DJIFlightController;
@class DJIFlightLimitation;
@class DJILandingGear;
@class DJICompass;

NS_ASSUME_NONNULL_BEGIN

/**
 *  No fly zone. Check flysafe.dji.com for all no fly
 *  zones that are pre-set by DJI. A user or develepor
 *  is not allowed to set their own no fly zone.
 *
 *  The zone radius is a radius around the no fly zone
 *  center coordinate that determines how large the
 *  no fly zone is around the center coordinate.
 *
 *  Once the aircraft is 100 meters away from a no fly
 *  zone, the user should be continuously notified that
 *  the aircraft is approaching a no fly zone. If the
 *  aircraft enters a no fly zone, it will stop and hover
 *  at the border.
 */
//-----------------------------------------------------------------
#pragma mark DJINoFlyZone
//-----------------------------------------------------------------
typedef struct
{
    float zoneRadius;
    CLLocationCoordinate2D zoneCenterCoordinate;
} DJINoFlyZone;

//-----------------------------------------------------------------
#pragma mark DJIFlightControl
//-----------------------------------------------------------------

/**
 *  Flight control coordinate system
 */
typedef NS_ENUM(uint8_t, DJIVirtualStickFlightCoordinateSystem){
    /**
     *  Ground coordinate system
     */
    DJIVirtualStickFlightCoordinateSystemGround,
    /**
     *  Body coordinate system
     */
    DJIVirtualStickFlightCoordinateSystemBody,
};

/**
 *  Vertical control velocity MIN value -4 m/s in VirtualStickControlMode. Positive velocity is up.
 */
DJI_API_EXTERN const float DJIVirtualStickVerticalControlMinVelocity;
/**
 *  Vertical control velocity MAX value 4 m/s in VirtualStickControlMode. Positive velocity is up.
 */
DJI_API_EXTERN const float DJIVirtualStickVerticalControlMaxVelocity;

/**
 *  Vertical control position MIN for VirtualStickVerticalControlModePosition. Currently set at 0m.
 */
DJI_API_EXTERN const float DJIVirtualStickVerticalControlMinPosition;
/**
 *  Vertical control position MAX for VirtualStickVerticalControlModePosition. Currently set at 500m.
 */
DJI_API_EXTERN const float DJIVirtualStickVerticalControlMaxPosition;

/**
 *  Defines how vertical control values are interpreted by the aircraft.
 */
typedef NS_ENUM(uint8_t, DJIVirtualStickVerticalControlMode){
    /**
     *  Sets the Virtual Stick Control vertical control values to be a vertical velocity.
     *  Positive and negative vertical velocity is for the aircraft ascending and descending
     *  respectively. Maximum vertical velocity is defined as DJIVirtualStickVerticalControlMaxVelocity;
     *  Minimum vertical velocity is defined as DJIVirtualStickVerticalControlMinVelocity.
     */
    DJIVirtualStickVerticalControlModeVelocity,
    /**
     *  Sets the VirtualStickControlMode vertical control values to be an altitude. Maximum position is defined as DJIVirtualStickVerticalControlMaxPosition;
     *  Minimum position is defined as DJIVirtualStickVerticalControlMinPosition.
     *
     */
    DJIVirtualStickVerticalControlModePosition,
};

/**
 *  RollPitch control velocity MAX value 15m/s
 */
DJI_API_EXTERN const float DJIVirtualStickRollPitchControlMaxVelocity;
/**
 *  RollPitch control velocity MIN value -15m/s
 */
DJI_API_EXTERN const float DJIVirtualStickRollPitchControlMinVelocity;
/**
 *  RollPitch control angle MAX value 30 degree
 */
DJI_API_EXTERN const float DJIVirtualStickRollPitchControlMaxAngle;
/**
 *  RollPitch control angle MIN value -30 degree
 */
DJI_API_EXTERN const float DJIVirtualStickRollPitchControlMinAngle;

/**
 *  Defines how manual roll and pitch values are interpreted by the aircraft.
 */
typedef NS_ENUM(uint8_t, DJIVirtualStickRollPitchControlMode){
    /**
     *  Sets the VirtualStickControlMode roll and pitch values to be an angle relative to
     *  a level aircraft. Positive and negative pitch angle is for the aircraft moving
     *  forward and backwards respectively. Positive and negative roll angle is when the
     *  aircraft moves right and left respectively. Maximum angle is defined as
     *  DJIVirtualStickRollPitchControlMaxAngle; Minimum angle is defined as DJIVirtualStickRollPitchControlMinAngle;
     */
    DJIVirtualStickRollPitchControlModeAngle,
    /**
     *  Sets the VirtualStickControlMode roll and pitch values to be a velocity.
     *  Positive and negative pitch velocity is for the aircraft moving forward and backwards
     *  respectively. Positive and negative roll velocity is when the aircraft moves right and
     *  left respectively. Maximum velocity is defined as DJIVirtualStickRollPitchControlMaxVelocity;
     *  Minimum velocity is defined as DJIVirtualStickRollPitchControlMinVelocity.
     */
    DJIVirtualStickRollPitchControlModeVelocity,
};

/**
 *  Yaw control angle MAX value 180 degree
 */
DJI_API_EXTERN const float DJIVirtualStickYawControlMaxAngle;
/**
 *  Yaw control angle MIN value -180 degree
 */
DJI_API_EXTERN const float DJIVirtualStickYawControlMinAngle;
/**
 *  Yaw control angular velocity MAX value 100 degree/s
 */
DJI_API_EXTERN const float DJIVirtualStickYawControlMaxAngularVelocity;
/**
 *  Yaw control angular velocity MIN value -100 degree/s
 */
DJI_API_EXTERN const float DJIVirtualStickYawControlMinAngularVelocity;

/**
 *  Defines how manual yaw values are interpreted by the aircraft.
 */
typedef NS_ENUM(uint8_t, DJIVirtualStickYawControlMode){
    /**
     * Sets the VirtualStickControlMode yaw values to be an angle relative to the front of the aircraft.
     * Positive and negative yaw angle is for the aircraft rotating clockwise and anticlockwise
     * respectively. Maximum yaw angle is defined as DJIVirtualStickYawControlMaxAngle; Minimum yaw
     * angle is defined as DJIVirtualStickYawControlMinAngle;
     */
    DJIVirtualStickYawControlModeAngle,
    /**
     * Sets the VirtualStickControlMode yaw values to be an angular velocity. Positive and negative
     * angular velocity is for the aircraft rotating clockwise and anticlockwise respectively. Maximum
     * yaw angular velocity is defined as DJIVirtualStickYawControlMaxAngularVelocity; Minimum yaw angular
     * velocity is defined as DJIVirtualStickYawControlMinAngularVelocity;
     */
    DJIVirtualStickYawControlModeAngularVelocity,
};


/**
 * Contains all the virtual stick control data needed to move the aircraft in all directions
 */
typedef struct
{
    /**
     *  Velocity (m/s) or Angle (degrees) value for pitch. Use DJIVirtualStickRollPitchControlMode to
     *  set velocity or angle mode.
     */
    float pitch;
    /**
     *  Velocity (m/s) or Angle (degrees) value for roll. Use DJIVirtualStickRollPitchControlMode to
     *  set velocity or angle mode.
     */
    float roll;
    /**
     *  Angular Velocity (degrees/s) or Angle (degrees) value for yaw.
     *  Use DJIVirtualStickYawControlMode to set angular velocity or angle mode.
     */
    float yaw;
    /**
     *  Velocity (m/s) or Alititude (m) value for verticalControl.
     *  Use DJIVirtualStickVerticalControlMode to set velocity or altitude mode.
     */
    float verticalThrottle;
} DJIVirtualStickFlightControlData;

/*********************************************************************************/
#pragma mark - DJIFlightOrientationMode
/*********************************************************************************/

/**
 *  Tells the aircraft how to interpret flight commands for forward, backward, left and right.
 *  Additional information should be seen in the getting started guide.
 */
typedef NS_ENUM(uint8_t, DJIFlightOrientationMode){
    /**
     * The aicraft should move relative to a locked course heading.
     */
    DJIFlightOrientationModeCourseLock,
    /**
     * The aicraft should move relative radially to the Home Point.
     */
    DJIFlightOrientationModeHomeLock,
    /**
     *  The aicraft should move relative to the front of the aircraft.
     */
    DJIFlightOrientationModeDefaultAircraftHeading,
};

/*********************************************************************************/
#pragma mark - DJIFlightControllerDelegate
/*********************************************************************************/
@protocol DJIFlightControllerDelegate <NSObject>

@optional

/**
 *  Callback function that updates the flight controller's current state data. This method gets
 *  called 10 times per second after startUpdatingFlightControllerCurrentState is called.
 *
 *  @param fc    Instance of the flight controller for which the data will be updated.
 *  @param state Current state of the flight controller.
 */
-(void) flightController:(DJIFlightController*)fc didUpdateSystemState:(DJIFlightControllerCurrentState*)state;

/**
 *  Callback function that updates the data received from an external device.
 *  Method is only supported for the Matrice 100.
 *
 *  @param fc    Instance of the flight controller for which the data will be updated.
 *  @param data  Data received from an external device. The size of the data will not be larger
 *  than 100 bytes.
 */
-(void) flightController:(DJIFlightController *)fc didReceivedDataFromExternalDevice:(NSData*)data;

@end

/*********************************************************************************/
#pragma mark - DJIFlightController
/*********************************************************************************/
@interface DJIFlightController : DJIBaseComponent
/**
 *  Flight controller's delegate.
 */
@property(nonatomic, weak) id<DJIFlightControllerDelegate> delegate;

/**
 *  Flight limitation object. This object sets, gets and tracks state of the maximum flight height
 *  and radius allowed.
 */
@property(nonatomic, readonly) DJIFlightLimitation* flightLimitation;

/**
 *  Landing Gear object. For products with moveable landing gear only.
 */
@property(nonatomic, readonly) DJILandingGear* landingGear;

/**
 *  Compass
 */
@property(nonatomic, readonly) DJICompass* compass;

/**
 *  Vertical control mode
 */
@property(nonatomic, assign) DJIVirtualStickVerticalControlMode verticalControlMode;
/**
 *  RollPitch control mode
 */
@property(nonatomic, assign) DJIVirtualStickRollPitchControlMode rollPitchControlMode;
/**
 *  Yaw control mode
 */
@property(nonatomic, assign) DJIVirtualStickYawControlMode yawControlMode;
/**
 *  RollPitch control coordinate system
 */
@property(nonatomic, assign) DJIVirtualStickFlightCoordinateSystem rollPitchCoordinateSystem;


/**
 *  Starts updating the flight controller's current state.
 */
-(void) startFlightControllerCurrentStateUpdates;

/**
 *  Stops updating the flight controller's current state.
 */
-(void) stopFlightControllerCurrentStateUpdates;

//-----------------------------------------------------------------
#pragma mark Methods
//-----------------------------------------------------------------
/**
 *  Starts aircraft takeoff. Takeoff is considered complete when the aircraft is hovering 1.2 meters (4 feet)
 *  above the ground. Completion block is called when aircraft crosses 0.5 meters (1.6 feet).
 *
 */
-(void) takeoffWithCompletion:(DJICompletionBlock)completion;

/**
 *  Stops aircraft takeoff. If called before takeoffWithCompletion is complete, the aircraft will cancel
 *  takeoff (takeoffWithCompletion completion block will return an error) and hover at the current height.
 *
 */
-(void) cancelTakeoffWithCompletion:(DJICompletionBlock)completion;

/**
 *  Starts auto-landing of the aircraft. Landing is considered complete once the aircraft lands on the ground,
 *  and powers down propellors to medium throttle.
 *
 */
-(void) autoLandingWithCompletion:(DJICompletionBlock)completion;

/**
 *  Stops auto-landing the aircraft. If called before startAutoLandingWithCompletion is complete, then the auto
 *  landing will be cancelled (startAutoLandingWithCompletion completeion block will return an error) and the
 *  aircraft will hover at its current location.
 *
 */
-(void) cancelAutoLandingWithCompletion:(DJICompletionBlock)completion;

/**
 *  Turns on the aircraft's motors.
 *
 */
-(void) turnOnMotorsWithCompletion:(DJICompletionBlock)completion;

/**
 *  Turns off the aircraft's motors. If the aircraft is flying while this method is called, the aircraft's
 *  motors will turn off and it will fall to the ground.
 *
 */
-(void) turnOffMotorsWithCompletion:(DJICompletionBlock)completion;

/**
 *  The aircraft will start to go home.  This method is considered complete once the aircraft has landed at
 *  its home position.
 *
 */
-(void) goHomeWithCompletion:(DJICompletionBlock)completion;

/**
 *  The aircraft will stop going home and will hover in place. goHomeWithCompletion completion block will immediately return an error.
 *
 */
-(void) cancelGoHomeWithCompletion:(DJICompletionBlock)completion;

/**
 *  Sets the home location of the aircraft. The home location is used as the
 *  location the aircraft goes to when commanded by goHomeWithCompletion, when the
 *  signal to the aircraft is lost or when the battery is below the lowBatteryWarning
 *  threashold. The user should be careful where they set a new home point location as in
 *  some scenarios the product will not be in control of the user when going to this location.
 *
 *  @param homeLocation Home location latitude and longitude in degrees.
 *  @param completion Completion block.
 */
-(void) setHomeLocation:(CLLocationCoordinate2D)homePoint withCompletion:(DJICompletionBlock)completion;

/**
 *  Sets the home location of the aircraft with the current location of the aircraft.
 *  See setHomeLocation:withCompletion: for details on when the home point is used
 *
 */
-(void) setHomeLocationUsingAircraftCurrentLocationWithCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the home point of the aircraft.
 *
 */
-(void) getHomeLocationWithCompletion:(void(^)(CLLocationCoordinate2D homePoint, NSError* _Nullable error))completion;

/**
 *  Sets the minimum altitude relative to where the aircraft took off that the aircraft must be at before going
 *  home. This can be useful when the user foresees obstacles in the aircraft’s way. If the aircraft’s current
 *  altitude is higher than the minimum go home altitude, it will go home at its current altitude.
 *
 *  @param altitude Aircraft’s minimum go home altitude.
 *  @param completion Completion block.
 */
-(void) setGoHomeAltitude:(float)altitude withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the minimum altitude the aircraft must be at before going home.
 *
 *  @param completion Completion block.
 */
-(void) getGoHomeAltitudeWithCompletion:(void(^)(float altitude, NSError* _Nullable error))completion;

/**
 *  Check if the onboard SDK device is available
 */
- (BOOL)isOnboardSDKDeviceAvailable;

/**
 *  If there is a device connected to the aircraft using the Onboard SDK, then this method will send data
 *  to that device. The size of the data cannot be greater than 100 bytes, and will be sent in 40 byte
 *  increments every 14ms. This method is only supported on products that support the Onboard SDK (Matrice 100).

 *  @param data data to be sent to external device.
 *  @param completion Completion block.
 */
-(void) sendDataToOnboardSDKDevice:(NSData*)data withCompletion:(DJICompletionBlock)completion;


/**
 *  Sets the low battery warning percentage. The percentage must be in the range [25, 50].
 *
 *  @param percent Low bettery warning percentage.
 *  @param completion   Completion block
 */
-(void) setGoHomeBatteryThreshold:(uint8_t)percent withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the low battery warning percentage. The value of the percent parameter will
 *  be in the range [25, 50].
 *
 */
-(void) getGoHomeBatteryThresholdWithCompletion:(void(^)(uint8_t percent, NSError * _Nullable error))completion;

/**
 *  Sets the serious low battery warning percentage. The percentage must be in the
 *  range [10, 25].
 *
 *  @param percent Serious low bettery warning percentage.
 *  @param completion   Completion block
 */
-(void) setLandImmediatelyBatteryThreshold:(uint8_t)percent withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the serious low battery warning percentage. The value of the percent parameter will
 *  be in the range [10, 25].
 *
 */
-(void) getLandImmediatelyBatteryThresholdWithCompletion:(void(^)(uint8_t percent, NSError * _Nullable error))completion;



@end

@interface DJIFlightController (DJIFlightOrientationMode)

/**
 *  Sets the aircraft flight orientation relative to Aircraft Heading, Course Lock or Home Lock. Additional information describing flight orientation is in the getting started guide.
 *
 */
-(void) setFlightOrientationMode:(DJIFlightOrientationMode)type withCompletion:(DJICompletionBlock)completion;


/**
 *  Locks the current heading of the aircraft as the Couse Lock. Used when Flight Orientation Mode is DJIFlightOrientationModeCourseLock.
 *
 */
-(void) lockCourseUsingCurrentDirectionWithCompletion:(DJICompletionBlock)completion;

@end

@interface DJIFlightController (VirtualStickControlMode)


/**
 *  Reseponds whether the virtual stick control interface can be used. If there is a mission running in mission manager, then this property will be NO.
 */
- (BOOL) isVirtualStickControlModeAvailable;

/**
 *  Enables virtual stick control mode. By enabling virtual stick control mode, the aircraft can be controlled
 *  using sendVirtualStickFlightControlData:withCompletion: method.
 *
 */
-(void) enableVirtualStickControlModeWithCompletion:(DJICompletionBlock) completion;

/**
 *  Disables virtual stick control mode.
 *
 */
-(void) disableVirtualStickControlModeWithCompletion:(DJICompletionBlock) completion;

/**
 *  Sends flight control data using virtual stick commands. The property 'isVirtualStickControlModeAvailable' needs to be YES to use Virtual Stick Control.
 *
 *  @param controlData Flight control data
 *  @param completion Completion block
 */
-(void) sendVirtualStickFlightControlData:(DJIVirtualStickFlightControlData)controlData withCompletion:(DJICompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
