//
//  DJIFlightControllerBaseTypes.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#ifndef DJIFlightControllerBaseTypes_h
#define DJIFlightControllerBaseTypes_h

#import "DJISDKFoundation.h"

/*********************************************************************************/
#pragma mark DJIAttitude
/*********************************************************************************/

/**
 *  Aircraft attitude. The attitude of the aircraft is made up of the pitch,
 *  roll, and yaw.
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
 *  Flight controller flight modes. For more information, see 
 *  http://wiki.dji.com/en/index.php/Phantom_3_Professional-Aircraft.
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
#pragma mark DJIFlightControllerNoFlyStatus
/*********************************************************************************/

/**
 *  No fly status. See
 *  http://wiki.dji.com/en/index.php/Phantom_3_Professional-_Flight_Limits_and_No-Fly_Zones
 *  for more information on no fly zones.
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
     *  Some no fly zones have several areas. These include a central area where
     *  no aircraft can fly or take off, and an intermediate area where flight
     *  height is restricted. This intermediate area can have a gradually
     *  relaxing height restriction as the aircraft moves further from the no
     *  fly zone center. If the aircraft is flying in this intermediate area,
     *  the `DJIFlightControllerNoFlyStatusHeightLimited` enum will be used.
     *
     *  Note that the no fly zone state update that alerts you if an aircraft is
     *  within 100m of a no fly zone, will trigger to the outermost area of a
     *  multi-area no fly zone.
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

/**
 *  Contains all the virtual stick control data needed to move the aircraft in
 *  all directions.
 */
typedef struct
{
    /**
     *  Velocity (m/s) along the y-axis or angle value (in degrees) for pitch.
     *  Use `DJIVirtualStickRollPitchControlMode` to set the velocity or angle
     *  mode. Note that the argument has different meanings in different
     *  coordinate systems.
     *  See the <i>Flight Controller User Guide</i> for more information.
     */
    float pitch;
    /**
     *  Velocity (m/s) along the x-axis or angle value (in degrees) for roll.
     *  Use `DJIVirtualStickRollPitchControlMode` to set the velocity or angle
     *  mode. Note that the argument has different meanings in different
     *  coordinate systems.
     *  See the <i>Flight Controller User Guide</i> for more information.
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

/**
 *  Defines how vertical control values are interpreted by the aircraft.
 */
typedef NS_ENUM (uint8_t, DJIVirtualStickVerticalControlMode){
    /**
     *  Sets the Virtual Stick Control vertical control values to be a vertical
     *  velocity. Positive and negative vertical velocity is for the aircraft
     *  ascending and descending respectively.
     *  Maximum vertical velocity is defined as `DJIVirtualStickVerticalControlMaxVelocity`.
     *  Minimum vertical velocity is defined as `DJIVirtualStickVerticalControlMinVelocity`.
     */
    DJIVirtualStickVerticalControlModeVelocity,
    /**
     *  Sets the `VirtualStickControlMode` vertical control values to be an
     *  altitude.
     *  Maximum position is defined as `DJIVirtualStickVerticalControlMaxPosition`.
     *  Minimum position is defined as `DJIVirtualStickVerticalControlMinPosition`.
     */
    DJIVirtualStickVerticalControlModePosition,
};


/**
 *  Defines how manual roll and pitch values are interpreted by the aircraft.
 */
typedef NS_ENUM (uint8_t, DJIVirtualStickRollPitchControlMode){
    /**
     *  Sets the `VirtualStickControlMode` roll and pitch values to be an angle
     *  relative to a level aircraft. In the body coordinate system, positive
     *  and negative pitch angle is for the aircraft rotating about the y-axis
     *  in the positive direction or negative direction, respectively. Positive
     *  and negative roll angle is the positive direction or negative direction
     *  rotation angle about the x-axis, respectively.
     *  However in the ground coordinate system, positive and negative pitch
     *  angle is the angle value for the aircraft moving south and north,
     *  respectively. Positive and negative roll angle is the angle when the
     *  aircraft is moving east and west, respectively.
     *  Maximum angle is defined as `DJIVirtualStickRollPitchControlMaxAngle`.
     *  Minimum angle is defined as `DJIVirtualStickRollPitchControlMinAngle`.
     */
    DJIVirtualStickRollPitchControlModeAngle,
    /**
     *  Sets the `VirtualStickControlMode` roll and pitch values to be a velocity.
     *  In the body coordinate system, positive and negative pitch velocity is
     *  for the aircraft moving towards the positive direction or negative
     *  direction along the pitch axis and y-axis, respectively. Positive and
     *  negative roll velocity is when the aircraft is moving towards the
     *  positive direction or negative direction along the roll axis and x-axis,
     *  respectively.
     *  However, in the ground coordinate system, positive and negative pitch
     *  velocity is for the aircraft moving east and west, respectively. 
     *  Positive and negative roll velocity is when the aircraft is moving north
     *  and south, respectively.
     *  Maximum velocity is defined as `DJIVirtualStickRollPitchControlMaxVelocity`.
     *  Minimum velocity is defined as `DJIVirtualStickRollPitchControlMinVelocity`.
     */
    DJIVirtualStickRollPitchControlModeVelocity,
};

/**
 *  Defines how manual yaw values are interpreted by the aircraft.
 */
typedef NS_ENUM (uint8_t, DJIVirtualStickYawControlMode){
    /**
     *  Sets the `VirtualStickControlMode` yaw values to be an angle relative to
     *  the front of the aircraft. Positive and negative yaw angle is for the
     *  aircraft rotating clockwise and counterclockwise, respectively.
     *  Maximum yaw angle is defined as `DJIVirtualStickYawControlMaxAngle`.
     *  Minimum yaw angle is defined as `DJIVirtualStickYawControlMinAngle`.
     */
    DJIVirtualStickYawControlModeAngle,
    /**
     *  Sets the `VirtualStickControlMode` yaw values to be an angular velocity.
     *  Positive and negative angular velocity is for the aircraft rotating
     *  clockwise and counterclockwise, respectively. 
     *  Maximum yaw angular velocity is defined as
     *  `DJIVirtualStickYawControlMaxAngularVelocity`.
     *  Minimum yaw angular velocity is defined as
     *  `DJIVirtualStickYawControlMinAngularVelocity`.
     */
    DJIVirtualStickYawControlModeAngularVelocity,
};

/**
 *  Flight control coordinate system.
 */
typedef NS_ENUM (uint8_t, DJIVirtualStickFlightCoordinateSystem){
    /**
     *  Ground coordinate system.
     */
    DJIVirtualStickFlightCoordinateSystemGround,
    /**
     *  Body coordinate system.
     */
    DJIVirtualStickFlightCoordinateSystemBody,
};

/**
 *  Control mode of the flight controller. It determines how the pilot can control
 *  the aircraft.
 *  It is only supported by A3. By default, it is in smart control mode.
 */
typedef NS_ENUM(uint8_t, DJIFlightControllerControlMode) {
    /**
     *  Smart control mode. The aircraft can stabilize its altitude and attitude
     *  in manual mode.
     */
    DJIFlightControllerControlModeSmart,
    /**
     *  Manual control mode. The aircraft will not stabilize its altitude and
     *  attitude in manual mode. This mode is for advanced pilots only, and
     *  should only be used when the pilot understands the risk of operating in
     *  this mode. Any damage to the product when operating in this mode will
     *  not be covered under warranty.
     */
    DJIFlightControllerControlModeManual,
    /**
     *  Unknown control mode.
     */
    DJIFlightControllerControlModeUnknown = 0xFF
};

/**
 *  The vertical control velocity MIN value is -4 m/s in `VirtualStickControlMode`.
 *  Positive velocity is up.
 */
DJI_API_EXTERN const float DJIVirtualStickVerticalControlMinVelocity;
/**
 *  The vertical control velocity MAX value is 4 m/s in VirtualStickControlMode.
 *  Positive velocity is up.
 */
DJI_API_EXTERN const float DJIVirtualStickVerticalControlMaxVelocity;

/**
 *  The vertical control position MIN value is 0 m for
 *  `VirtualStickVerticalControlModePosition`.
 */
DJI_API_EXTERN const float DJIVirtualStickVerticalControlMinPosition;
/**
 *  The vertical control position MAX value is 500 m for
 *  `VirtualStickVerticalControlModePosition`.
 */
DJI_API_EXTERN const float DJIVirtualStickVerticalControlMaxPosition;


/**
 *  Roll/Pitch control velocity MAX value is 15m/s.
 */
DJI_API_EXTERN const float DJIVirtualStickRollPitchControlMaxVelocity;
/**
 *  Roll/Pitch control velocity MIN value is -15m/s.
 */
DJI_API_EXTERN const float DJIVirtualStickRollPitchControlMinVelocity;
/**
 *  Roll/Pitch control angle MAX value is 30 degrees.
 */
DJI_API_EXTERN const float DJIVirtualStickRollPitchControlMaxAngle;
/**
 *  Roll/Pitch control angle MIN value is -30 degrees.
 */
DJI_API_EXTERN const float DJIVirtualStickRollPitchControlMinAngle;


/**
 *  Yaw control angle MAX value is 180 degrees.
 */
DJI_API_EXTERN const float DJIVirtualStickYawControlMaxAngle;
/**
 *  Yaw control angle MIN value is -180 degrees.
 */
DJI_API_EXTERN const float DJIVirtualStickYawControlMinAngle;
/**
 *  Yaw control angular velocity MAX value is 100 degrees/second.
 */
DJI_API_EXTERN const float DJIVirtualStickYawControlMaxAngularVelocity;
/**
 *  Yaw control angular velocity MIN value is -100 degrees/second.
 */
DJI_API_EXTERN const float DJIVirtualStickYawControlMinAngularVelocity;



#endif /* DJIFlightControllerBaseTypes_h */
