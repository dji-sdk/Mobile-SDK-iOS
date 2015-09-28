//
//  DJIMCSystemState.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <DJISDK/DJIMainController.h>
#import <DJISDK/DJIMCSmartGoHome.h>

/**
 *  Flight mode of main controller
 */
typedef NS_ENUM(NSUInteger, DJIMainControllerFlightMode){
    /**
     *  Manual mode. Used in phantom 2 Vision
     */
    ManualMode,
    /**
     *  Gps mode. Used in phantom 2 Vision
     */
    GPSMode,
    /**
     *  Out of control mode. Used in phantom 2 Vision
     */
    OutOfControlMode,
    /**
     *  Attitude mode. Used in phantom 2 Vision
     */
    AttitudeMode,
    /**
     *  Go home mode. Used in phantom 2 Vision
     */
    GoHomeMode,
    /**
     *  Landing mode. Used in phantom 2 Vision
     */
    LandingMode,
    
    
    /**
     *  Manual mode. Used in Inspire / Phantom3 Professional / Matrice100
     */
    MainControllerFlightModeManual = 0,
    /**
     *  Attitude mode. Used in Inspire / Phantom3 Professional / Matrice100
     */
    MainControllerFlightModeAtti = 1,
    /**
     *  Attitude course lock mode. Used in Inspire / Phantom3 Professional / Matrice100
     */
    MainControllerFlightModeAttiCourseLock = 2,
    /**
     *  Attitude hover mode. Used in Inspire / Phantom3 Professional / Matrice100
     */
    MainControllerFlightModeAttiHover = 3,
    /**
     *  Hover mode. Used in Inspire / Phantom3 Professional / Matrice100
     */
    MainControllerFlightModeHover = 4,
    /**
     *  Gps blake mode. Used in Inspire / Phantom3 Professional / Matrice100
     */
    MainControllerFlightModeGPSBlake = 5,
    /**
     *  Gps Attitude mode. Used in Inspire / Phantom3 Professional / Matrice100
     */
    MainControllerFlightModeGPSAtti = 6,
    /**
     *  Gps course lock mode. Used in Inspire / Phantom3 Professional / Matrice100
     */
    MainControllerFlightModeGPSCourseLock = 7,
    /**
     *  Gps Home mode. Used in Inspire / Phantom3 Professional / Matrice100
     */
    MainControllerFlightModeGPSHomeLock = 8,
    /**
     *  Gps hot point mode. Used in Inspire / Phantom3 Professional / Matrice100
     */
    MainControllerFlightModeGPSHotPoint = 9,
    /**
     *  Assisted takeoff mode. Used in Inspire / Phantom3 Professional / Matrice100
     */
    MainControllerFlightModeAssistedTakeOff = 10,
    /**
     *  Auto takeoff mode. Used in Inspire / Phantom3 Professional / Matrice100
     */
    MainControllerFlightModeAutoTakeOff = 11,
    /**
     *  Auto landing mode. Used in Inspire / Phantom3 Professional / Matrice100
     */
    MainControllerFlightModeAutoLanding = 12,
    /**
     *  Attitude landing mode. Used in Inspire / Phantom3 Professional / Matrice100
     */
    MainControllerFlightModeAttiLanding = 13,
    /**
     *  GPS Waypoint mode. Used in Inspire / Phantom3 Professional / Matrice100
     */
    MainControllerFlightModeGPSWaypoint = 14,
    /**
     *  Go home mode. Used in Inspire / Phantom3 Professional / Matrice100
     */
    MainControllerFlightModeGoHome = 15,
    /**
     *  Click go mode. Used in Inspire / Phantom3 Professional / Matrice100
     */
    MainControllerFlightModeClickGo = 16,
    /**
     *  Joystick mode. Used in Inspire / Phantom3 Professional / Matrice100
     */
    MainControllerFlightModeJoystick = 17,
    /**
     *  Attitude limited mode. Used in Inspire / Phantom3 Professional / Matrice100
     */
    MainControllerFlightModeAttiLimited = 23,
    /**
     *  Gps attitude limited mode. Used in Inspire / Phantom3 Professional / Matrice100
     */
    MainControllerFlightModeGPSAttiLimited = 24,
    /**
     *  Gps Follow me. Used in Inspire / Phantom3 Professional / Matrice100
     */
    MainControllerFlightModeGPSFollowMe = 25,
    /**
     *  Unknown
     */
    MainControllerFlightModeUnknown= 0xFF,
};

/**
 *  No fly status
 */
typedef NS_ENUM(NSUInteger, DJIMainControllerNoFlyStatus){
    /**
     *  Drone normal flying
     */
    DroneNormalFlying,
    /**
     *  Drone is in a no fly zone, take off prohibited
     */
    DroneTakeOffProhibited,
    /**
     *  Drone is in a no fly zone, will force landing
     */
    DroneFroceAutoLanding,
    /**
     *  Drone is approaching to a no fly zone
     */
    DroneApproachingNoFlyZone,
    /**
     *  Drone had reach the max flying height
     */
    DroneReachMaxFlyingHeight,
    /**
     *  Drone had reach the max flying distance
     */
    DroneReachMaxFlyingDistance,
    /**
     *  Drone is in a no fly zone, the flying heigh will limited
     */
    DroneUnderLimitFlyZone,
    /**
     *  Unknown status
     */
    UnknownStatus,
};

/**
 *  Gps Signal. used for measuring the signal quality.
 */
typedef NS_ENUM(uint8_t, DJIGpsSignalLevel){
    /**
     *  Almost no gps signal, very bad
     */
    GpsSignalLevel0,
    /**
     *  Gps signal very weak
     */
    GpsSignalLevel1,
    /**
     *  Gps signal weak, at this level, the aircraft's go home functionality still work.
     */
    GpsSignalLevel2,
    /**
     *  Gps signal good, the aricraft could hover in the air.
     */
    GpsSignalLevel3,
    /**
     *  Gps signal very good, the aircraft could record the home point.
     */
    GpsSignalLevel4,
    /**
     *  Gps signal very strong
     */
    GpsSignalLevel5,
    /**
     *  None
     */
    GpsSignalLevelNone,
};

@interface DJIMCSystemState : NSObject

/**
 *  Satellite count.
 */
@property(nonatomic, readonly) int satelliteCount;

/**
 *  Home location of the drone
 */
@property(nonatomic, readonly) CLLocationCoordinate2D homeLocation;

/**
 *  Current location of the drone
 */
@property(nonatomic, readonly) CLLocationCoordinate2D droneLocation;

/**
 *  Speed x (m/s)
 */
@property(nonatomic, readonly) float velocityX;

/**
 *  Speed y (m/s)
 */
@property(nonatomic, readonly) float velocityY;

/**
 *  Speed z (m/s)
 */
@property(nonatomic, readonly) float velocityZ;

/**
 *  Relative altitude of the drone (m), measured by barometer.
 */
@property(nonatomic, readonly) float altitude;

/**
 *  Attitude of the drone, Pitch[-180, 180], Roll[-180, 180], Yaw[-180, 180], 0 will be the true north
 */
@property(nonatomic, readonly) DJIAttitude attitude;

/**
 *  Power level of the drone: 0 - very low power warning, 1- low power warning, 2 - height power, 3 - full power
 */
@property(nonatomic, readonly) int powerLevel;

/**
 *  Whether the drone is in flying
 */
@property(nonatomic, readonly) BOOL isFlying;

/**
 *  Flight mode
 */
@property(nonatomic, readonly) DJIMainControllerFlightMode flightMode;

/**
 *  No fly status
 */
@property(nonatomic, readonly) DJIMainControllerNoFlyStatus noFlyStatus;

/**
 *  The no fly zone center coordinate
 */
@property(nonatomic, readonly) CLLocationCoordinate2D noFlyZoneCenter;

/**
 *  The no fly zone radius
 */
@property(nonatomic, readonly) int noFlyZoneRadius;

/**
 *  Smart go home data
 */
@property(nonatomic, readonly) DJIMCSmartGoHomeData* smartGoHomeData;

/**
 *  Below property will supported In Inspire/Phantom3Pro/Phantom3Advanced
 */

/**
 *  Gps signal level.
 */
@property(nonatomic, readonly) DJIGpsSignalLevel gpsSignalLevel;

/**
 *  If the remote controller signal lost, then failsafe.
 */
@property(nonatomic, readonly) BOOL isFailsafe;
/**
 *  Is IMU in pre-heating
 */
@property(nonatomic, readonly) BOOL isIMUPreheating;
/**
 *  Is compass error
 */
@property(nonatomic, readonly) BOOL isCompassError DJI_API_DEPRECATED;
/**
 *  Is ultrasonic working
 */
@property(nonatomic, readonly) BOOL isUltrasonicWorking;
/**
 *  Height of aircraft measured by the ultrasonic, data is valid while property isUltrasonicWorking set YES
 */
@property(nonatomic, readonly) float ultrasonicHeight;
/**
 *  Is vision working
 */
@property(nonatomic, readonly) BOOL isVisionWorking;
/**
 *  Is motor working
 */
@property(nonatomic, readonly) BOOL isMotorWorking;

/**
 *  Whether or not the multiple flight mode opened;
 */
@property(nonatomic, readonly) BOOL isMultipleFlightModeOpen;

/**
 *  Flight mode string. ex. "P-GPS", "P-Atti"
 */
@property(nonatomic, readonly) NSString* flightModeString;

@end
