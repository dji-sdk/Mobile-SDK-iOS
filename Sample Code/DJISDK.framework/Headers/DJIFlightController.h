//
//  DJIFlightController.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <DJISDK/DJIBaseComponent.h>
#import <DJISDK/DJIFlightControllerCurrentState.h>
#import <DJISDK/DJIIMUState.h>
#import <DJISDK/DJIFlightControllerBaseTypes.h>

@class DJIFlightController;
@class DJIFlightLimitation;
@class DJILandingGear;
@class DJICompass;
@class DJIRTK;
@class DJIIntelligentFlightAssistant;
@class DJISimulator;

NS_ASSUME_NONNULL_BEGIN

/**
 *  No fly zone. Check flysafe.dji.com for all no fly
 *  zones that are pre-set by DJI. A user or developer
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

/*********************************************************************************/
#pragma mark DJINoFlyZone
/*********************************************************************************/

/**
 *  Defines the No Fly Zone Data structure.
 */
typedef struct
{
    /**
     *  Radius of the No Fly Zone in meters.
     */
    float zoneRadius;
    /**
     *  Center Coordinate of the No Fly Zone.
     */
    CLLocationCoordinate2D zoneCenterCoordinate;
} DJINoFlyZone;

/*********************************************************************************/
#pragma mark DJIFlightControl
/*********************************************************************************/

/**
 *  Defines aircraft failsafe action when signal between the remote controller
 *  and the aircraft is lost.
 */
typedef NS_ENUM (uint8_t, DJIFlightFailsafeOperation){
    /**
     *  Hover
     */
    DJIFlightFailsafeOperationHover,
    /**
     *  Landing
     */
    DJIFlightFailsafeOperationLanding,
    /**
     *  Return-to-Home
     */
    DJIFlightFailsafeOperationGoHome,
    /**
     *  Unknown
     */
    DJIFlightFailsafeOperationUnknown = 0xFF
};


/*********************************************************************************/
#pragma mark - DJIFlightControllerDelegate
/*********************************************************************************/

/**
 *  This protocol provides delegate methods to update flight controller's
 *  current state.
 */
@protocol DJIFlightControllerDelegate <NSObject>

@optional

/**
 *  Callback function that updates the flight controller's current state data.
 *  This method is called 10 times per second.
 *
 *  @param fc       Instance of the flight controller for which the data will be
 *                  updated.
 *  @param state    Current state of the flight controller.
 */
- (void)flightController:(DJIFlightController *_Nonnull)fc didUpdateSystemState:(DJIFlightControllerCurrentState *_Nonnull)state;

/**
 *  Callback function that updates the data received from an external device
 *  (e.g. the onboard device).
 *  It is only supported for the Matrice 100.
 *
 *  @param fc   Instance of the flight controller for which the data will be
 *              updated.
 *  @param data Data received from an external device. The size of the data will
 *              not be larger than 100 bytes.
 */
- (void)flightController:(DJIFlightController *_Nonnull)fc didReceiveDataFromExternalDevice:(NSData *_Nonnull)data;

/**
 *  Update IMU State.
 *
 *  @param fc       Instance of the flight controller for which the data will be
                    updated.
 *  @param imuState DJIIMUState object.
 *
 */
- (void)flightController:(DJIFlightController *_Nonnull)fc didUpdateIMUState:(DJIIMUState *_Nonnull)imuState;

@end

/*********************************************************************************/
#pragma mark - DJIFlightController
/*********************************************************************************/

/**
 *  This class contains components of the flight controller and provides methods
 *  to send different commands to the flight controller.
 */
@interface DJIFlightController : DJIBaseComponent

/**
 *  Flight controller delegate.
 */
@property(nonatomic, weak) id<DJIFlightControllerDelegate> delegate;

/**
 *  Flight limitation object. This object sets, gets and tracks the state of the
 *  maximum flight height and radius allowed.
 */
@property(nonatomic, readonly) DJIFlightLimitation *_Nullable flightLimitation;

/**
 *  Landing Gear object. For products with moveable landing gear only.
 *  It is supported by Inspire 1 and Matrice 600.
 */
@property(nonatomic, readonly) DJILandingGear *_Nullable landingGear;

/**
 *  Compass object.
 */
@property(nonatomic, readonly) DJICompass *_Nullable compass;

/**
 *  RTK positioning object.
 */
@property(nonatomic, readonly) DJIRTK *_Nullable rtk;

/**
 *  Intelligent flight assistant.
 */
@property(nonatomic, readonly) DJIIntelligentFlightAssistant *_Nullable intelligentFlightAssistant;

/**
 *  Simulator object.
 */
@property(nonatomic, readonly) DJISimulator *_Nullable simulator;

/**
 *  The number of IMU module in the flight controller.
 *  Most products have 1 IMU 
 *
 *  Exceptions:
 *  - Phantom 4 has 2 IMUs
 *  - A3 has 3 IMUs
 */
@property(nonatomic, readonly) NSUInteger numberOfIMUs;

/**
 *  Vertical control mode.
 */
@property(nonatomic, assign) DJIVirtualStickVerticalControlMode verticalControlMode;
/**
 *  Roll/Pitch control mode.
 */
@property(nonatomic, assign) DJIVirtualStickRollPitchControlMode rollPitchControlMode;
/**
 *  Yaw control mode.
 */
@property(nonatomic, assign) DJIVirtualStickYawControlMode yawControlMode;
/**
 *  Roll/Pitch control coordinate system.
 */
@property(nonatomic, assign) DJIVirtualStickFlightCoordinateSystem rollPitchCoordinateSystem;
/**
 *  `YES` if Virtual Stick advanced mode is enabled. By default, it is `NO`.
 *  When advanced mode is enabled, the aircraft will compensate for wind when
 *  hovering and the GPS signal is good.
 *  For the Phantom 4, collision avoidance can be enabled for virtual stick
 *  control if advanced mode is on, and collision avoidance is enabled in
 *  `DJIIntelligentFlightAssistant`.
 *
 *  It is only supported by flight controller firmware versions 3.1.x.x or above.
 */
@property(nonatomic, assign) BOOL virtualStickAdvancedModeEnabled;

/*********************************************************************************/
#pragma mark Methods
/*********************************************************************************/

/**
 *  YES if the landing gear is supported for the connected aircraft.
 */
- (BOOL)isLandingGearMovable;

/**
 *  Starts aircraft takeoff. Takeoff is considered complete when the aircraft is
 *  hovering 1.2 meters (4 feet) above the ground. Completion block is called
 *  when aircraft crosses 0.5 meters (1.6 feet).
 *
 *  If the motors are already on, this command can not be executed.
 *
 */
- (void)takeoffWithCompletion:(DJICompletionBlock)completion;

/**
 *  Stops aircraft takeoff. If called before `takeoffWithCompletion` is complete,
 *  the aircraft will cancel takeoff (`takeoffWithCompletion` completion block
 *  will return an error) and hover at the current height.
 *
 */
- (void)cancelTakeoffWithCompletion:(DJICompletionBlock)completion;

/**
 *  Starts auto-landing of the aircraft. Landing is considered complete once the
 *  aircraft lands on the ground, and powers down propellors to medium throttle.
 *
 */
- (void)autoLandingWithCompletion:(DJICompletionBlock)completion;

/**
 *  Stops auto-landing the aircraft. If called before
 *  `startAutoLandingWithCompletion` is complete, the auto landing will be
 *  cancelled (`startAutoLandingWithCompletion` completeion block will return an
 *  error) and the aircraft will hover at its current location.
 *
 */
- (void)cancelAutoLandingWithCompletion:(DJICompletionBlock)completion;

/**
 *  Turns on the aircraft's motors.
 *  Currently, this method will be supported by Matrice 100 with upcoming
 *  firmware version.
 */
- (void)turnOnMotorsWithCompletion:(DJICompletionBlock)completion;

/**
 *  Turns off the aircraft's motors. The method can only be called when the
 *  aircraft is on the ground.
 */
- (void)turnOffMotorsWithCompletion:(DJICompletionBlock)completion;

/**
 *  The aircraft will start to go home.  This method is considered complete once
 *  the aircraft has landed at its home position.
 *
 */
- (void)goHomeWithCompletion:(DJICompletionBlock)completion;

/**
 *  The aircraft will stop going home and will hover in place. The
 *  `goHomeWithCompletion` completion block will immediately return an error.
 *
 */
- (void)cancelGoHomeWithCompletion:(DJICompletionBlock)completion;

/**
 *  Sets the home location of the aircraft. The home location is where the
 *  aircraft goes to when commanded by goHomeWithCompletion, when the signal to
 *  the aircraft is lost or when the battery is below the lowBatteryWarning
 *  threshold. The user should be careful where they set a new home point
 *  location as in some scenarios the product will not be under user control
 *  when going to this location. A home location is valid if it is within 30m of
 *  initial take-off location, current aircraft's location, current mobile
 *  location with at least kCLLocationAccuracyNearestTenMeters accuracy level,
 *  or current remote controller's location as shown by RC GPS.
 *
 *  Note: If setting home point around mobile location, before calling this
 *  method, the locationServicesEnabled must be true in CLLocationManager, the
 *  NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription key
 *  needs to be specified in the applications Info.plist and the
 *  requestWhenInUseAuthorization or requestAlwaysAuthorization method of
 *  CLLocationManager object needs to be called to get the user's permission to
 *  access location services.
 *
 *  @param homeLocation Home location latitude and longitude in degrees.
 *  @param completion Completion block.
 */
- (void)setHomeLocation:(CLLocationCoordinate2D)homePoint
         withCompletion:(DJICompletionBlock)completion;

/**
 *  Sets the home location of the aircraft with the current location of the
 *  aircraft.
 *  See setHomeLocation:withCompletion: for details on when the home point is used.
 *
 */
- (void)setHomeLocationUsingAircraftCurrentLocationWithCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the home point of the aircraft.
 *
 */
- (void)getHomeLocationWithCompletion:(void (^_Nonnull)(CLLocationCoordinate2D homePoint, NSError *_Nullable error))completion;

/**
 *  Sets the minimum altitude, relative to where the aircraft took off, at which
 *  the aircraft must be before going home. This can be useful when the user
 *  foresees obstacles in the aircraft’s way. If the aircraft’s current altitude
 *  is higher than the minimum go home altitude, it will go home at its current
 *  altitude.
 *  The valid range for the altitude is from 20m to 500m.
 *
 *  @param altitude Aircraft’s minimum go home altitude.
 *  @param completion Completion block.
 */
- (void)setGoHomeAltitude:(float)altitude withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the minimum altitude the aircraft must be at before going home.
 *
 *  @param completion Completion block.
 */
- (void)getGoHomeAltitudeWithCompletion:(void (^_Nonnull)(float altitude, NSError *_Nullable error))completion;

/**
 *  Sets the FailSafe action for when the connection between remote controller
 *  and aircraft is lost.
 *
 *  @param operation    The Failsafe action.
 *  @param completion   Completion block.
 */
- (void)setFlightFailsafeOperation:(DJIFlightFailsafeOperation)operation
                    withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the FailSafe action for when the connection between remote controller
 *  and aircraft is lost.
 */
- (void)getFlightFailsafeOperationWithCompletion:(void (^_Nonnull)(DJIFlightFailsafeOperation operation, NSError *_Nullable error))completion;
/**
 *  Check if the onboard SDK device is available.
 */
- (BOOL)isOnboardSDKDeviceAvailable;

/**
 *  If there is a device connected to the aircraft using the Onboard SDK, this
 *  method will send data to that device. The size of the data cannot be greater
 *  than 100 bytes, and will be sent in 40 byte increments every 14ms. This
 *  method is only supported on products that support the Onboard SDK (Matrice
 *  100).
 *
 *  @param data Data to be sent to the external device.
 *  @param completion Completion block.
 *
 */
- (void)sendDataToOnboardSDKDevice:(NSData *_Nonnull)data
                    withCompletion:(DJICompletionBlock)completion;

/**
 *  Sets the low battery go home percentage threshold. The percentage must be in
 *  the range [25, 50].
 *
 *  @param percent Low battery warning percentage.
 *  @param completion   Completion block.
 */
- (void)setGoHomeBatteryThreshold:(uint8_t)percent
                   withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the go home battery percentage threshold. The value of the percent
 *  parameter must be in the range [25, 50].
 *
 */
- (void)getGoHomeBatteryThresholdWithCompletion:(void (^_Nonnull)(uint8_t percent, NSError *_Nullable error))completion;

/**
 *  Sets the serious battery land immediately percentage threshold. The
 *  percentage must be in the range [10, 25].
 *
 *  @param percent Serious low battery warning percentage.
 *  @param completion   Completion block.
 */
- (void)setLandImmediatelyBatteryThreshold:(uint8_t)percent
                            withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the land immediately battery percentage threshold. The value of the
 *  percent parameter must be in the range [10, 25].
 *
 */
- (void)getLandImmediatelyBatteryThresholdWithCompletion:(void (^_Nonnull)(uint8_t percent, NSError *_Nullable error))completion;

/**
 *  Start the calibration for IMU. For aircrafts with multiple IMUs, this method
 *  will start the calibration for all IMUs. Please keep stationary and
 *  horizontal during calibration. The calibration will take 5 ~ 10 minutes. The
 *  completion block will be called once the calibration is started. Please use
 *  the [flightController:didUpdateIMUState:] method in
 *  'DJIFlightControllerDelegate' to check the execution status of the IMU
 *  calibration.
 *
 *  @param completion Completion block to check if the calibration starts successfully.
 */
- (void)startIMUCalibrationWithCompletion:(DJICompletionBlock)completion;

/**
 *  Start the calibration for IMU with a specific ID. Please keep stationary and
 *  horizontal during calibration. The calibration will take 5 ~ 10 minutes. The
 *  completion block will be called once the calibration is started. Use the
 *  [flightController:didUpdateIMUState:] method in `DJIFlightControllerDelegate`
 *  to check the execution status of the IMU calibration.
 *  Only supported by Matrice 600.
 *
 *  @param imuID        The IMU with the specific ID to calibrate.
 *  @param completion   Completion block to check if the calibration starts successfully.
 */
- (void)startIMUCalibrationForID:(NSUInteger)imuID withCompletion:(DJICompletionBlock)completion;

/**
 *  Turns on/off the LEDs in the front. The LEDs are used to indicate the status
 *  of the aircraft. By default, it is on.
 *  It is only supported by Phantom 3 series and Phantom 4.
 *
 *  @param enabled      `YES` to turn on the front LEDs, `NO` to turn off.
 *  @param completion   Completion block that receives the setter execution result.
 */
- (void)setLEDsEnabled:(BOOL)enabled withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets if the LEDs in the front is enabled or not.
 *  It is only supported by Phantom 3 series and Phantom 4.
 *
 *  @param completion Completion block that receives the getter execution result.
 */
- (void)getLEDsEnabled:(void (^_Nonnull)(BOOL enabled, NSError *_Nullable error))completion;

/**
 *  Sets the control mode of the flight controller. By default the value is 
 *  `DJIFlightControllerControlModeSmart`. It is highly recommended to keep the
 *  default value. See `DJIFlightControllerControlMode` for details.
 *  It is only supported by stand-alone A3.
 *
 *  @param mode         Control mode to set.
 *  @param completion   Completion block that receives the setter execution result.
 */
- (void)setControlMode:(DJIFlightControllerControlMode)mode withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the control mode of the flight controller.
 *  It is only supported by A3. 
 *
 *  @param completion Completion block that receives the getter execution result.
 */
- (void)getControlModeWithCompletion:(void (^_Nonnull)(DJIFlightControllerControlMode mode, NSError *_Nullable error))completion;

@end

/**
 *  This class provides method to set flight orientation mode of the flight
 *  controller. Also, it provides a method for you to lock the current heading
 *  of the aircraft as the Course Lock.
 */
@interface DJIFlightController (DJIFlightOrientationMode)

/**
 *  Sets the aircraft flight orientation relative to the Aircraft Heading,
 *  Course Lock, or Home Lock.
 *  See the <i>Flight Controller User Guide</i> for more information about
 *  flight orientation.
 *
 */
- (void)setFlightOrientationMode:(DJIFlightOrientationMode)type
                  withCompletion:(DJICompletionBlock)completion;

/**
 *  Locks the current heading of the aircraft as the Course Lock. Used when
 *  Flight Orientation Mode is `DJIFlightOrientationModeCourseLock`.
 *
 */
- (void)lockCourseUsingCurrentDirectionWithCompletion:(DJICompletionBlock)completion;

@end

/**
 *  This class provides methods to manage Virtual Stick Control of the flight
 *  controller.
 */
@interface DJIFlightController (VirtualStickControlMode)

/**
 *  Indicates whether the virtual stick control interface can be used. If there
 *  is a mission running in the mission manager, this property will be NO.
 */
- (BOOL)isVirtualStickControlModeAvailable;

/**
 *  Enables virtual stick control mode. By enabling virtual stick control mode,
 *  the aircraft can be controlled using the
 *  `sendVirtualStickFlightControlData:withCompletion:` method.
 *
 */
- (void)enableVirtualStickControlModeWithCompletion:(DJICompletionBlock)completion;

/**
 *  Disables virtual stick control mode.
 *
 */
- (void)disableVirtualStickControlModeWithCompletion:(DJICompletionBlock)completion;

/**
 *  Sends flight control data using virtual stick commands. The
 *  `isVirtualStickControlModeAvailable` property must be YES to use virtual
 *  stick commands. Virtual stick commands should be sent to the aircraft
 *  between 5 Hz and 25 Hz. If virtual stick commands are not sent frequently
 *  enough the aircraft may regard the connection as broken which will cause the
 *  aircraft to hover in place until the next command comes through.
 *
 *  @param controlData  Flight control data.
 *  @param completion   Completion block.
 */
- (void)sendVirtualStickFlightControlData:(DJIVirtualStickFlightControlData)controlData
                           withCompletion:(DJICompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
