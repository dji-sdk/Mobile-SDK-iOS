//
//  DJIFlightControllerCurrentState.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <DJISDK/DJIFlightOrientationMode.h>
#import <DJISDK/DJIFlightControllerBaseTypes.h>

NS_ASSUME_NONNULL_BEGIN

/*********************************************************************************/
#pragma mark - Data Structs and Enums
/*********************************************************************************/


/*********************************************************************************/
#pragma mark DJIFlightControllerSmartGoHomeStatus
/*********************************************************************************/

/**
 *  The Flight Controller Smart Go Home Status
 */
typedef struct
{
    /**
     *  The estimated remaining time, in seconds, it will take the aircraft to go home with a 10% battery buffer remaining.
     *  This time includes landing the aircraft.
     */
    NSUInteger remainingFlightTime;

    /**
     *  The estimated time, in seconds, needed for the aircraft to go home from its
     *  current location.
     */
    NSUInteger timeNeededToGoHome;

    /**
     *  The estimated time, in seconds, needed for the aircraft to land from its current
     *  height. The time calculated will be for the aircraft to land, moving
     *  straight down, from its current height.
     */
    NSUInteger timeNeededToLandFromCurrentHeight;

    /**
     *  The estimated battery percentage, in the range of [0 - 100], needed for the aircraft
     *  to go home and have 10% battery remaining. This includes landing of the aircraft.
     */
    NSUInteger batteryPercentageNeededToGoHome;

    /**
     *  The battery percentage, in the range of [0 - 100], needed for the aircraft
     *  to land from its current height. The battery percentage needed will be for
     *  the aircraft to land, moving straight down, from its current height.
     */
    NSUInteger batteryPercentageNeededToLandFromCurrentHeight;

    /**
     *  The maximum radius, in meters, an aircraft can fly from its home location
     *  and still make it all the way back home based on certain factors including
     *  altitude, distance, battery, etc. If the aircraft goes out farther than the
     *  max radius, it will fly as far back home as it can and land.
     */
    float maxRadiusAircraftCanFlyAndGoHome;

    /**
     *  Returns whether the aircraft is requesting to go home. If the value of
     *  `aircraftShouldGoHome` is YES and the user does not respond after 10 seconds,
     *  the aircraft will automatically go back to its home location. This can be cancelled
     *  at any time with the `cancelGoHome` method (which will also clear `aircraftShouldGoHome`). It is recommended
     *  that an alert view is shown to the user when `aircraftShouldGoHome` returns YES.
     *  During this time, the Remote Controller will beep.
     *
     *  The flight controller calculates whether the aircraft should go home based
     *  on the aircraft's altitude, distance, battery, etc.
     *
     *  The two main situations in which `aircraftShouldGoHome` will return YES are if the
     *  aircraft's battery is too low or if the aircraft has flown too far away.
     */
    BOOL aircraftShouldGoHome;
} DJIFlightControllerSmartGoHomeStatus;

/*********************************************************************************/
#pragma mark DJIAircraftPowerLevel
/*********************************************************************************/

/**
 *  Remaining battery life state. This state describes the recommended action based on remaining battery life.
 */
typedef NS_ENUM (uint8_t, DJIAircraftRemainingBatteryState){
    /**
     *  Remaining battery life sufficient for normal flying.
     */
    DJIAircraftRemainingBatteryStateNormal,
    /**
     *  Remaining battery life sufficient to go home.
     */
    DJIAircraftRemainingBatteryStateLow,
    /**
     *  Remaining battery life sufficient to land immediately.
     */
    DJIAircraftRemainingBatteryStateVeryLow,
    /**
     *  Reserved for future use.
     */
    DJIAircraftRemainingBatteryStateReserved,
};

/*********************************************************************************/
#pragma mark - DJIFlightControllerCurrentState
/*********************************************************************************/

/**
 *
 *  This class contains the current state of the flight controller.
 *
 */
@interface DJIFlightControllerCurrentState : NSObject

/**
 *  GPS satellite count.
 */
@property(nonatomic, readonly) int satelliteCount;

/**
 *  Home location of the aircraft as a coordinate.
 */
@property(nonatomic, readonly) CLLocationCoordinate2D homeLocation;

/**
 *  Current location of the aircraft as a coordinate.
 */
@property(nonatomic, readonly) CLLocationCoordinate2D aircraftLocation;

/**
 *  Current speed of the aircraft in the x direction in meters per second using the N-E-D (North-East-Down) coordinate system.
 */
@property(nonatomic, readonly) float velocityX;

/**
 *  Current speed of the aircraft in the y direction in meters per second using the N-E-D (North-East-Down) coordinate system.
 */
@property(nonatomic, readonly) float velocityY;

/**
 *  Current speed of the aircraft in the z direction in meters per second using the N-E-D (North-East-Down) coordinate system.
 */
@property(nonatomic, readonly) float velocityZ;

/**
 *  Relative altitude of the aircraft relative to take off location, measured by the barometer, in meters.
 */
@property(nonatomic, readonly) float altitude;

/**
 * Attitude of the aircraft where the pitch, roll, and yaw values will be in the range of [-180, 180].
 * If the values of the pitch, roll, and yaw are 0, the aircraft will be hovering level with a True North heading.
 */
@property(nonatomic, readonly) DJIAttitude attitude;

/**
 *  Recommended action based on remaining battery life.
 */
@property(nonatomic, readonly) DJIAircraftRemainingBatteryState remainingBattery;

/**
 *  YES if aircraft is flying.
 */
@property(nonatomic, readonly) BOOL isFlying;

/**
 *  The accumulated flight time in seconds since the aircraft was powered on.
 */
@property(nonatomic, readonly) NSUInteger flightTime;

/**
 *  Aircraft's current flight mode.
 */
@property(nonatomic, readonly) DJIFlightControllerFlightMode flightMode;

/**
 *  Aircraft's current no fly status.
 */
@property(nonatomic, readonly) DJIFlightControllerNoFlyStatus noFlyStatus;

/**
 *  No fly zone's center coordinate.
 */
@property(nonatomic, readonly) CLLocationCoordinate2D noFlyZoneCenter;

/**
 *  No fly zone's radius in meters.
 */
@property(nonatomic, readonly) int noFlyZoneRadius;

/**
 *  Aircraft’s smart go home data. If smart go home is enabled, all the
 *  smart go home data will be available in `DJIFlightControllerSmartGoHomeStatus`.
 */
@property(nonatomic, readonly) DJIFlightControllerSmartGoHomeStatus smartGoHomeStatus;

/**
 *  The current status of the executing go-home status.
 */
@property(nonatomic, readonly) DJIFlightControllerGoHomeExecutionStatus goHomeExecutionStatus;

/**
 *  Aircraft's current orientation mode.
 */
@property(nonatomic, readonly) DJIFlightOrientationMode orientationMode;

/**
 *  Aircraft's current GPS signal quality.
 */
@property(nonatomic, readonly) DJIGPSSignalStatus gpsSignalStatus;

/**
 *  YES if the signal lost between remote controller and aircraft fail safe is enabled.
 */
@property(nonatomic, readonly) BOOL isFailsafe;
/**
 *  YES if IMU is preheating.
 */
@property(nonatomic, readonly) BOOL isIMUPreheating;
/**
 *  YES if the ultrasonic sensor is being used. Variables that can impact the quality of the ultrasound measurement
 *  and whether it is used or not are height above ground and the type of ground (if it reflects sound waves well).
 *  Usually the ultrasonic sensor works when the aircraft is less than 8m above ground.
 */
@property(nonatomic, readonly) BOOL isUltrasonicBeingUsed;
/**
 *  Height of aircraft measured by the ultrasonic sensor in meters. The data will only be
 *  available if `isUltrasonicBeingUsed` returns YES. Height has a precision of 0.1m.
 */
@property(nonatomic, readonly) float ultrasonicHeight;
/**
 *  YES if a vision sensor is being used. Variables that can impact the quality of the vision measurement
 *  and whether it is used or not are height above ground and the type of ground (if it has sufficiently rich texture).
 *  Usually the vision sensor works when the aircraft is less than 3m above ground.
 */
@property(nonatomic, readonly) BOOL isVisionSensorBeingUsed;
/**
 *  YES if motors are on.
 */
@property(nonatomic, readonly) BOOL areMotorsOn;

/**
 *  Returns the flight mode as a string. For example, "P-GPS" or "P-Atti".
 */
@property(nonatomic, readonly) NSString *_Nonnull flightModeString;

@end

NS_ASSUME_NONNULL_END
