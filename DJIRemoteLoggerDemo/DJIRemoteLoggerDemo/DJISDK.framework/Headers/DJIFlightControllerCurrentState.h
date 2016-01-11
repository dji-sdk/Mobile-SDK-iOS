/*
 *  DJI iOS Mobile SDK Framework
 *  DJIFlightControllerCurrentState.h
 *
 *  Copyright (c) 2015, DJI.
 *  All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

/*********************************************************************************/
#pragma mark - Data Structs and Enums
/*********************************************************************************/

//-----------------------------------------------------------------
#pragma mark DJIAttitude
//-----------------------------------------------------------------
/**
 *  Aircraft attitude. The attitude of the aircraft is made up of the pitch, roll, and yaw.
 */
typedef struct
{
    double pitch;
    double roll;
    double yaw;
} DJIAttitude;

//-----------------------------------------------------------------
#pragma mark DJIFlightControllerFlightMode
//-----------------------------------------------------------------
/**
 *  Flight controller flight modes.
 *  Dhanush Comment: Need a link to a document that explains these modes. P3 Manual may be?
 */
typedef NS_ENUM(NSUInteger, DJIFlightControllerFlightMode){
    /**
     *  Manual mode.
     */
    DJIFlightControllerFlightModeManual = 0,
    /**
     *  Attitude mode.
     */
    DJIFlightControllerFlightModeAtti = 1,
    /**
     *  Attitude course lock mode.
     */
    DJIFlightControllerFlightModeAttiCourseLock = 2,
    /**
     *  Attitude hover mode.
     */
    DJIFlightControllerFlightModeAttiHover = 3,
    /**
     *  Hover mode.
     */
    DJIFlightControllerFlightModeHover = 4,
    /**
     *  GPS blake mode.
     */
    DJIFlightControllerFlightModeGPSBlake = 5,
    /**
     *  GPS Attitude mode.
     */
    DJIFlightControllerFlightModeGPSAtti = 6,
    /**
     *  GPS course lock mode.
     */
    DJIFlightControllerFlightModeGPSCourseLock = 7,
    /**
     *  GPS Home mode.
     */
    DJIFlightControllerFlightModeGPSHomeLock = 8,
    /**
     *  GPS hot point mode.
     */
    DJIFlightControllerFlightModeGPSHotPoint = 9,
    /**
     *  Assisted takeoff mode.
     */
    DJIFlightControllerFlightModeAssistedTakeOff = 10,
    /**
     *  Auto takeoff mode.
     */
    DJIFlightControllerFlightModeAutoTakeOff = 11,
    /**
     *  Auto landing mode.
     */
    DJIFlightControllerFlightModeAutoLanding = 12,
    /**
     *  Attitude landing mode.
     */
    DJIFlightControllerFlightModeAttiLanding = 13,
    /**
     *  GPS waypoint mode.
     */
    DJIFlightControllerFlightModeGPSWaypoint = 14,
    /**
     *  Go home mode.
     */
    DJIFlightControllerFlightModeGoHome = 15,
    /**
     *  Click go mode.
     */
    DJIFlightControllerFlightModeClickGo = 16,
    /**
     *  Joystick mode.
     */
    DJIFlightControllerFlightModeJoystick = 17,
    /**
     *  Attitude limited mode.
     */
    DJIFlightControllerFlightModeAttiLimited = 23,
    /**
     *  GPS attitude limited mode.
     */
    DJIFlightControllerFlightModeGPSAttiLimited = 24,
    /**
     *  GPS follow me mode.
     */
    DJIFlightControllerFlightModeGPSFollowMe = 25,
    /**
     *  The main controller flight mode is unknown.
     */
    DJIFlightControllerFlightModeUnknown= 0xFF,
};

//-----------------------------------------------------------------
#pragma mark DJIFlightControllerNoFlyStatus
//-----------------------------------------------------------------
/**
 *  No fly status. Please refer to  http://wiki.dji.com/en/index.php/Phantom_3_Professional-_Flight_Limits_and_No-Fly_Zones for more information on no fly zones.
 */
typedef NS_ENUM(NSUInteger, DJIFlightControllerNoFlyStatus){
    /**
     *  The aircraft is normally flying.
     */
    DJIFlightControllerNoFlyStatusFlyingNormally,
    /**
     *  The aircraft is in a no fly zone, so take off is prohibited.
     */
    DJIFlightControllerNoFlyStatusTakeOffProhibited,
    /**
     *  The aircraft is in a no fly zone, so it is executing a force landing.
     */
    DJIFlightControllerNoFlyStatusForceAutoLanding,
    /**
     *  The aircraft is approaching a no fly zone.
     *
     */
    DJIFlightControllerNoFlyStatusApproachingNoFlyZone,
    /**
     *  The aircraft has reached its max flying height.
     */
    DJIFlightControllerNoFlyStatusReachMaxFlyingHeight,
    /**
     *  The aircraft has reached its max flying distance.
     */
    DJIFlightControllerNoFlyStatusReachMaxFlyingDistance,
    /**
     *  The aircraft is under limit fly zone, which means it's max flying height
     *  and distance are limited.
     *
     */
    DJIFlightControllerNoFlyStatusUnderLimitFlyZone,
    /**
     *  The aircraft's no fly status is unknown.
     */
    DJIFlightControllerNoFlyStatusUnknownStatus,
};


//-----------------------------------------------------------------
#pragma mark DJIGPSSignalStatus
//-----------------------------------------------------------------
/**
 *  GPS signal levels, which are used to measure the signal quality.
 */
typedef NS_ENUM(uint8_t, DJIGPSSignalStatus){
    /**
     *  The GPS has almost no signal, which is very bad.
     */
    DJIGPSSignalStatusLevel0,
    /**
     *  The GPS signal is very weak.
     */
    DJIGPSSignalStatusLevel1,
    /**
     *  The GPS signal is weak. At this level, the aircraft's go home
     *  functionality will still work.
     */
    DJIGPSSignalStatusLevel2,
    /**
     *  The GPS signal is good. At this level, the aircraft can hover in
     *  the air.
     */
    DJIGPSSignalStatusLevel3,
    /**
     *  The GPS signal is very good. At this level, the aircraft
     *  can record the home point.
     */
    DJIGPSSignalStatusLevel4,
    /**
     *  The GPS signal is very strong.
     */
    DJIGPSSignalStatusLevel5,
    /**
     *  There is no GPS signal.
     */
    DJIGPSSignalStatusNone,
};

//-----------------------------------------------------------------
#pragma mark DJIFlightControllerSmartGoHomeStatus
//-----------------------------------------------------------------
typedef struct
{
    /**
     *  The remaining time, in seconds, it will take the aircraft to go home.
     *  This time includes landing the aircraft.
     *
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
     *  to go home. This includes landing of the aircraft.
     *
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
     *  Returns whether or not the aircraft is requesting to go home. If the value of
     *  aircraftShouldGoHome is YES and the user does not respond after 10 seconds,
     *  the aircraft will automatically go back to its home location. It is recommended
     *  that an alert view is shown to the user when aircraftShouldGoHome returns YES.
     *  During this time, the Remote Controller will beep.
     *
     *  The flight controller calculates whether or not the aircraft should go home based
     *  on the aircraft's altitude, distance, battery, etc.
     *
     *  The two main situations in which aircraftShouldGoHome will return YES are if the
     *  aircraft's battery is too low or if the airacraft has flown too far away.
     *
     */
    BOOL aircraftShouldGoHome;
} DJIFlightControllerSmartGoHomeStatus;

//-----------------------------------------------------------------
#pragma mark DJIAircraftPowerLevel
//-----------------------------------------------------------------
/**
 *  Remaining battery life state. This state describes the recommended action based on remaining battery life.
*/
typedef NS_ENUM(uint8_t, DJIAircraftRemainingBatteryState){
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
 *  Current speed of the aircraft in the x direction in meters per second.
 */
@property(nonatomic, readonly) float velocityX;

/**
 *  Current speed of the aircraft in the y direction in meters per second.
 */
@property(nonatomic, readonly) float velocityY;

/**
 *  Current speed of the aircraft in the z direction in meters per second.
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
 *
 */
@property(nonatomic, readonly) int noFlyZoneRadius;

/**
 *  Aircraft’s smart go home data. If smart go home is enabled, all the
 *  smart go home data will be available in DJIFlightControllerSmartGoHomeStatus.
 */
@property(nonatomic, readonly) DJIFlightControllerSmartGoHomeStatus smartGoHomeStatus;

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
 *  YES if the compass has an error.
 *
 */
@property(nonatomic, readonly) BOOL hasCompassError;
/**
 *  YES if the ultrasonic sensor is being used. It is only used when equal to or less than XXm above the ground.
 *
 */
@property(nonatomic, readonly) BOOL isUltrasonicBeingUsed;
/**
 *  Height of aircraft measured by the ultrasonic sensor in meters. The data will only be
 *  available if isUltrasonicBeingUsed returns YES.
 *
 */
@property(nonatomic, readonly) float ultrasonicHeight;
/**
 *  YES if vision sensor is being used.
 *
 */
@property(nonatomic, readonly) BOOL isVisionSensorBeingUsed;
/**
 *  YES if motors are on.
 */
@property(nonatomic, readonly) BOOL areMotorsOn;

/**
 *  Returns the flight mode as a string. For example, "P-GPS" or "P-Atti".
 */
@property(nonatomic, readonly) NSString* flightModeString;

@end

NS_ASSUME_NONNULL_END
