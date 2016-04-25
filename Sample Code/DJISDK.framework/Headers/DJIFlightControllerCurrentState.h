//
//  DJIFlightControllerCurrentState.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

/*********************************************************************************/
#pragma mark - Data Structs and Enums
/*********************************************************************************/

/*********************************************************************************/
#pragma mark DJIAttitude
/*********************************************************************************/

/**
 *  Aircraft attitude. The attitude of the aircraft is made up of the pitch, roll, and yaw.
 */
typedef struct
{
    /**
     *  Aircraft's pitch attitude value.
     */
    double pitch;
    /**
     *  Aircraft's roll attitude value.
     */
    double roll;
    /**
     *  Aircraft's yaw attitude value.
     */
    double yaw;
} DJIAttitude;

/*********************************************************************************/
#pragma mark DJIFlightControllerFlightMode
/*********************************************************************************/

/**
 *  Flight controller flight modes. For more information, see http://wiki.dji.com/en/index.php/Phantom_3_Professional-Aircraft.
 *
 */
typedef NS_ENUM (NSUInteger, DJIFlightControllerFlightMode){
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
     *  ActiveTrack mode.
     */
    DJIFlightControllerFlightModeActiveTrack = 26,
    /**
     *  TapFly mode.
     */
    DJIFlightControllerFlightModeTapFly = 27,
    /**
     *  Sport mode.
     */
    DJIFlightControllerFlightModeSport = 31,
    /**
     *  GPS Novice mode.
     */
    DJIFlightControllerFlightModeGPSNovice = 32,
    /**
     *  The main controller flight mode is unknown.
     */
    DJIFlightControllerFlightModeUnknown = 0xFF,
};

/*********************************************************************************/
#pragma mark DJIFlightControllerGoHomeExecutionStatus
/*********************************************************************************/

/**
 *  A class used to identify the different stages of the go-home command.
 */
typedef NS_ENUM (NSUInteger, DJIFlightControllerGoHomeExecutionStatus){
    /**
     *  The aircraft is not executing a Go-Home command.
     */
    DJIFlightControllerGoHomeExecutionStatusNotExecuting,
    /**
     *  The aircraft is turning the heading direction to the home point.
     */
    DJIFlightControllerGoHomeExecutionStatusTurnDirectionToHomePoint,
    /**
     *  The aircraft is going up to the height for go-home command.
     */
    DJIFlightControllerGoHomeExecutionStatusGoUpToHeight,
    /**
     *  The aircraft is flying horizontally to home point.
     */
    DJIFlightControllerGoHomeExecutionStatusAutoFlyToHomePoint,
    /**
     *  The aircraft is going down after arriving at the home point.
     */
    DJIFlightControllerGoHomeExecutionStatusGoDownToGround,
    /**
     *  The aircraft is braking to avoid collision.
     */
    DJIFlightControllerGoHomeExecutionStatusBraking,
    /**
     *  The aircraft is bypassing over the obstacle.
     */
    DJIFlightControllerGoHomeExecutionStatusBypassing,
    /**
     *  The go-home command is completed.
     */
    DJIFlightControllerGoHomeExecutionStatusCompleted,
    /**
     *  The go-home status is unknown.
     */
    DJIFlightControllerGoHomeExecutionStatusUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark - DJIFlightOrientationMode
/*********************************************************************************/

/**
 *  Tells the aircraft how to interpret flight commands for forward, backward, left and right.
 *  See the <i>Flight Controller User Guide</i> for more information.
 */
typedef NS_ENUM (uint8_t, DJIFlightOrientationMode){
    /**
     * The aircraft should move relative to a locked course heading.
     */
    DJIFlightOrientationModeCourseLock,
    /**
     * The aircraft should move relative radially to the Home Point.
     */
    DJIFlightOrientationModeHomeLock,
    /**
     *  The aircraft should move relative to the front of the aircraft.
     */
    DJIFlightOrientationModeDefaultAircraftHeading,
};

/*********************************************************************************/
#pragma mark DJIFlightControllerNoFlyStatus
/*********************************************************************************/

/**
 *  No fly status. See http://wiki.dji.com/en/index.php/Phantom_3_Professional-_Flight_Limits_and_No-Fly_Zones for more information on no fly zones.
 */
typedef NS_ENUM (NSUInteger, DJIFlightControllerNoFlyStatus){
    /**
     *  The aircraft is normally flying.
     */
    DJIFlightControllerNoFlyStatusFlyingNormally,
    /**
     *  The aircraft is in a no fly zone, so take-off is prohibited.
     */
    DJIFlightControllerNoFlyStatusTakeOffProhibited,
    /**
     *  The aircraft is in a no fly zone, so it is executing a force landing.
     */
    DJIFlightControllerNoFlyStatusForceAutoLanding,
    /**
     *  The aircraft is within 100m of a no fly zone boundary.
     */
    DJIFlightControllerNoFlyStatusApproachingNoFlyZone,
    /**
     *  The aircraft has reached its maximum flying height.
     */
    DJIFlightControllerNoFlyStatusReachMaxFlyingHeight,
    /**
     *  The aircraft has reached its maximum flying distance.
     */
    DJIFlightControllerNoFlyStatusReachMaxFlyingDistance,
    /**
     * Some no fly zones have several areas. These include a central area where no aircraft can fly or take off, and
     * an intermediate area where flight height is restricted. This intermediate area can have a gradually
     * relaxing height restriction as the aircraft moves further from the no fly zone center. If the aircraft
     * is flying in this intermediate area, the `DJIFlightControllerNoFlyStatusHeightLimited` enum will be used.
     *
     * Note that the no fly zone state update that alerts you if an aircraft is within 100m of a no fly zone, will trigger to
     * the outermost area of a multi-area no fly zone.
     */
    DJIFlightControllerNoFlyStatusHeightLimited,
    /**
     *  The aircraft's no fly status is unknown.
     */
    DJIFlightControllerNoFlyStatusUnknownStatus,
};

/*********************************************************************************/
#pragma mark DJIGPSSignalStatus
/*********************************************************************************/

/**
 *  GPS signal levels, which are used to measure the signal quality.
 */
typedef NS_ENUM (uint8_t, DJIGPSSignalStatus){
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
