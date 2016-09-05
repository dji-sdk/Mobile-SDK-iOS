//
//  DJIGimbalBaseTypes.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Data Structs and Enums
/*********************************************************************************/

/*********************************************************************************/
#pragma mark DJIGimbalAttitude
/*********************************************************************************/

/**
 *  The gimbal's attitude relative to the aircraft.
 */
typedef struct
{
    /**
     *  Pitch value in degrees.
     */
    float pitch;
    /**
     *  Roll value in degrees.
     */
    float roll;
    /**
     *  Yaw value in degrees.
     */
    float yaw;
} DJIGimbalAttitude;

/*********************************************************************************/
#pragma mark DJIGimbalRotateDirection
/*********************************************************************************/

/**
 *  Gimbal rotation direction when controlling gimbal movement by speed.
 */
typedef NS_ENUM (uint8_t, DJIGimbalRotateDirection){
    /**
     *  Sets the gimbal to rotate clockwise.
     */
    DJIGimbalRotateDirectionClockwise,
    /**
     *  Sets the gimbal to rotate counter-clockwise.
     */
    DJIGimbalRotateDirectionCounterClockwise,
};

/*********************************************************************************/
#pragma mark DJIGimbalRotateAngleMode
/*********************************************************************************/

/**
 *  The rotation angle of the gimbal can be defined as either Absolute (relative
 *  to the heading), or Relative (relative to its current angle).
 */
typedef NS_ENUM (uint8_t, DJIGimbalRotateAngleMode){
    /**
     *  The angle value, when the gimbal is rotating, is relative to the current
     *  angle.
     */
    DJIGimbalAngleModeRelativeAngle,
    /**
     *  The angle value, when the gimbal is rotating, is relative to 0 degrees
     *  (with respect to the aircraft heading).
     */
    DJIGimbalAngleModeAbsoluteAngle,
};

/*********************************************************************************/
#pragma mark DJIGimbalAngleRotation
/*********************************************************************************/

/**
 *  Struct used to control the gimbal by angle (either absolutely or relatively).
 */
typedef struct
{
    /**
     *  Gimbal rotation is enabled. If enable is set to NO, you will not be able
     *  to rotate the gimbal.
     */
    BOOL enabled;
    /**
     *  Gimbal rotation angle in degrees.
     */
    float angle;
    /**
     *  Gimbal rotation direction.
     */
    DJIGimbalRotateDirection direction;
} DJIGimbalAngleRotation;

/*********************************************************************************/
#pragma mark DJIGimbalSpeedRotation
/*********************************************************************************/

/**
 *  Struct used to control the gimbal by speed.
 */
typedef struct
{
    /**
     *  Gimbal rotation angular velocity in degrees/second with range [0, 120].
     */
    float angleVelocity;
    /**
     *  Gimbal rotatation direction.
     */
    DJIGimbalRotateDirection direction;
} DJIGimbalSpeedRotation;

/*********************************************************************************/
#pragma mark DJIGimbalWorkMode
/*********************************************************************************/

/**
 *  Gimbal work modes.
 */
typedef NS_ENUM (uint8_t, DJIGimbalWorkMode){
    /**
     *  The gimbal can move independently of the aircraft's yaw. In this mode, even
     *  if the aircraft yaw changes, the camera will continue pointing in the same
     *  world direction. This feature is supported by the X3, X5 and X5R camera
     *  gimbals and the Ronin-MX. This mode is only available for the Ronin-MX when
     *  the M600 landing gear is retracted.
     */
    DJIGimbalWorkModeFreeMode,
    /**
     *  The gimbal's work mode is FPV mode. In this mode, the gimbal yaw will
     *  follow the aircraft's heading, and the gimbal roll will follow the RC's
     *  roll channel value. The pitch will be available to move. This mode is only
     *  available for the Ronin-MX when the M600 landing gear is retracted.
     *  Not supported by Osmo.
     */
    DJIGimbalWorkModeFpvMode,
    /**
     *  The gimbal's work mode is such that it will follow the yaw. In this mode,
     *  the gimbal yaw will be fixed, while pitch and roll will be available to move.
     */
    DJIGimbalWorkModeYawFollowMode,
    /**
     *  The gimbal's work mode is unknown.
     */
    DJIGimbalWorkModeUnknown = 0xFF,
};

/*********************************************************************************/
#pragma mark DJIGimbalAdvancedSettingsProfile
/*********************************************************************************/

/**
 *  The Advanced Settings Profile contains presets for SmoothTrack and the Physical
 *  Controller sensitivity. SmoothTrack and Controller settings can only be
 *  manually changed if Custom1 or Custom2 profiles are selected.
 *  Only supported by Osmo.
 */
typedef NS_ENUM (uint8_t, DJIGimbalAdvancedSettingsProfile){
    /**
     *  The gimbal's SmoothTrack and Controller sensitivity is high.
     *  When the gimbal is using this profile, user cannot change the Advanced
     *  Settings manually.
     */
    DJIGimbalAdvancedSettingsProfileFast,
    /**
     *  The gimbal's SmoothTrack and Controller sensitivity is medium.
     *  When the gimbal is using this profile, user cannot change the Advanced
     *  Settings manually.
     */
    DJIGimbalAdvancedSettingsProfileMedium,
    /**
     *  The gimbal's SmoothTrack and Controller sensitivity is low.
     *  When the gimbal is using this profile, user cannot change the Advanced
     *  Settings manually.
     */
    DJIGimbalAdvancedSettingsProfileSlow,
    /**
     *  The gimbal uses a custom configuration in memory slot 1 where the yaw and
     *  pitch speed, deadband, and acceleration can be defined.
     */
    DJIGimbalAdvancedSettingsProfileCustom1,
    /**
     *  The gimbal uses a custom configuration in memory slot 2 where the yaw and
     *  pitch speed, deadband, and acceleration can be defined.
     */
    DJIGimbalAdvancedSettingsProfileCustom2,
    /**
     *  The gimbal's user config type is unknown.
     */
    DJIGimbalAdvancedSettingsProfileUnknown = 0xFF,
    
};

/*********************************************************************************/
#pragma mark DJIGimbalAxis
/*********************************************************************************/

/**
 *  Gimbal axis.
 */
typedef NS_ENUM (uint8_t, DJIGimbalAxis){
    /**
     *  Gimbal's yaw axis.
     */
    DJIGimbalAxisYaw,
    /**
     *  Gimbal's pitch axis.
     */
    DJIGimbalAxisPitch,
    /**
     *  Gimbal's roll axis.
     */
    DJIGimbalAxisRoll
};

/*********************************************************************************/
#pragma mark DJIGimbalEndpointDirection
/*********************************************************************************/

/**
 *  Gimbal endpoint setting.
 *  This is only supported by the Ronin-MX gimbal.
 */
typedef NS_ENUM (uint8_t, DJIGimbalEndpointDirection){
    /**
     *  Pitch (also called tilt) endpoint setting in the upwards direction.
     */
    DJIGimbalEndpointDirectionPitchUp,
    /**
     *  Pitch (also called tilt) endpoint setting in the downwards direction.
     */
    DJIGimbalEndpointDirectionPitchDown,
    /**
     *  Yaw (also called pan) endpoint setting in the left direction.
     */
    DJIGimbalEndpointDirectionYawLeft,
    /**
     *  Yaw (also called pan) endpoint setting in the right direction.
     */
    DJIGimbalEndpointDirectionYawRight,
};

/*********************************************************************************/
#pragma mark DJIGimbalMotorControlPreset
/*********************************************************************************/

/**
 *  For gimbals that allow payloads to be changed, the motor control configuration
 *  can be used to optimize gimbal performance for the different payloads.
 *  Only supported by the Ronin-MX gimbal.
 */
typedef NS_ENUM (uint8_t, DJIGimbalMotorControlPreset){
    /**
     *  The gimbal's motor control configuration is optimized for RED cameras.
     */
    DJIGimbalMotorControlPresetRED,
    /**
     *  The gimbal's motor control configuration is optimized for most DSLR
     *  cameras.
     */
    DJIGimbalMotorControlPresetDSLRCamera,
    /**
     *  The gimbal's motor control configuration is optimized for most
     *  mirrorless cameras.
     */
    DJIGimbalMotorControlPresetMirrorlessCamera
};

/*********************************************************************************/
#pragma mark DJIGimbalBalanceTestResult
/*********************************************************************************/

/**
 *  For gimbals that allow payloads to be changed, a balance test should be 
 *  performed to ensure the camera is mounted correctly.
 *  Only supported by Ronin-MX.
 */
typedef NS_ENUM (uint8_t, DJIGimbalBalanceTestResult){
    /**
     *  The balance test result is great.
     */
    DJIGimbalBalanceTestResultGreat,
    /**
     *  The balance test result is good. When this result is returned, it is possible
     *  there was some noise in the balance measurement.
     *  For best results, it is recommended to run the balance test again and adjust
     *  the payload position until the result becomes great.
     */
    DJIGimbalBalanceTestResultGood,
    /**
     *  The balance test result is bad. The payload should be adjusted when this
     *  result is returned.
     */
    DJIGimbalBalanceTestResultBad,
    /**
     *  The balance test result is unknown.
     */
    DJIGimbalBalanceTestResultUnknown = 0xFF
};

/**
 *  The control mode for the gimbal physical controller (joystick for Osmo). The
 *  total controller deflection is a combination of horizontal and vertical
 *  deflection. This translates to gimbal movement around the yaw and pitch axes.
 *  The gimbal can be set to either move in both yaw and pitch simultaneously
 *  based on horizontal and vertical deflection of the controller, or move in only
 *  yaw or pitch exclusively based on whether horizontal or vertical deflection is
 *  larger.
 *  Only supported by Osmo.
 */
typedef NS_ENUM (uint8_t, DJIGimbalControllerMode){
    /**
     * Gimbal movement will be exclusively in yaw or pitch depending on whether
     *  the controller horizontal or vertical deflection is greater respectively.
     */
    DJIGimbalControllerModeHorizontalVertical,
    /**
     *  Gimbal movement will be in both yaw and pitch simultaneously relative to
     *  the horizontal and vertical deflection of the controller respectively.
     */
    DJIGimbalControllerModeFree,
    /**
     * The gimbal controller control mode is unknown.
     */
    DJIGimbalControllerModeUnknown = 0xFF,
};

/**
 *  The loading balance status of the gimbal. The gimbal loading is changeable
 *  for Osmo Mobile. When the mounted mobile device is changed, in order to 
 *  optimize the gimbal performance, user can adjust the gimbal physically based
 *  on the status.
 *  Only supported by Osmo Mobile.
 */
typedef NS_ENUM (uint8_t, DJIGimbalLoadingBalanceStatus){
    /**
     *  The gimbal is balanced.
     */
    DJIGimbalLoadingBalanceStatusBalanced,
    /**
     *  The gimbal is tilting left. Adjust the photo to the right hand side to
     *  balance the gimbal.
     */
    DJIGimbalLoadingBalanceStatusTiltingLeft,
    /**
     *  The gimbal is tilting right. Adjust the photo to the left hand side to
     *  balance the gimbal.
     */
    DJIGimbalLoadingBalanceStatusTiltingRight,
    /**
     *  The balance status is unknown. 
     */
    DJIGimbalLoadingBalanceStatusUnknown = 0xFF,
};


/*********************************************************************************/
#pragma mark - Gimbal Capability Keys
/*********************************************************************************/

/**
 *  Gimbal feature keys used in the `gimbalCapability` dictionary that holds the
 *  complete capability of the gimbal.
 *  A negative value in the valid range represents counter-clockwise rotation.
 *  A positive value in the valid range represents clockwise rotation.
 */
extern NSString *const DJIGimbalParamAdjustPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal supports
 *  yaw axis adjustment.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range in degrees is returned.
 *  A negative value in the valid range represents counter-clockwise rotation.
 *  A positive value in the valid range represents clockwise rotation.
 *  For Gimbal's that allow a pitch range extension (see
 *  `DJIGimbalParamPitchRangeExtensionEnabled`, the range will be representative
 *  of the extended range whether it is enabled or not.
 */
extern NSString *const DJIGimbalParamAdjustYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal supports
 *  roll axis adjustment. The corresponding value in `gimbalCapability` is an
 *  instance of `DJIParamCapabilityMinMax` meaning both the feature's existance
 *  as well as its possible range in degrees is returned.
 *  A negative value in the valid range represents counter-clockwise rotation.
 *  A positive value in the valid range represents clockwise rotation.
 */
extern NSString *const DJIGimbalParamAdjustRoll;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal supports
 *  Advanced Settings Profiles.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapability`.
 */
extern NSString *const DJIGimbalParamAdvancedSettingsProfile;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal supports
 *  a range extension in pitch.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range in degrees is returned.
 */
extern NSString *const DJIGimbalParamPitchRangeExtensionEnabled;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch
 *  axis response speed to manual control can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamControllerSpeedPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw
 *  axis response speed to manual control can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamControllerSpeedYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch
 *  axis smoothing can be adjusted when using manual control.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamControllerSmoothingPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw
 *  axis smoothing can be adjusted when using manual control.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamControllerSmoothingYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's manual
 *  control pitch axis deadband can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamControllerDeadbandPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's manual
 *  control yaw axis deadband can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamControllerDeadbandYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch
 *  axis SmoothTrack can be toggled.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapability`.
 *  Ronin-MX cannot toggle the SmoothTrack functionality and it is always enabled.
 */
extern NSString *const DJIGimbalParamSmoothTrackEnabledPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw
 *  axis SmoothTrack can be toggled.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapability`.
 *  Ronin-MX cannot toggle the SmoothTrack functionality and it is always enabled.
 */
extern NSString *const DJIGimbalParamSmoothTrackEnabledYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch
 *  axis SmoothTrack accelaration can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamSmoothTrackAccelerationPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw
 *  axis SmoothTrack accelaration can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamSmoothTrackAccelerationYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch
 *  axis SmoothTrack speed can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamSmoothTrackSpeedPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw
 *  axis SmoothTrack speed can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamSmoothTrackSpeedYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch
 *  axis SmoothTrack deadband can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamSmoothTrackDeadbandPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw
 *  axis SmoothTrack deadband can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamSmoothTrackDeadbandYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch
 *  up endpoint can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamEndpointPitchUp;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch
 *  down endpoint can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamEndpointPitchDown;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw
 *  left endpoint can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamEndpointYawLeft;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw
 *  right endpoint can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamEndpointYawRight;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch
 *  axis motor control stiffness can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamMotorControlStiffnessPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw
 *  axis motor control stiffness can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamMotorControlStiffnessYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's roll
 *  axis motor control stiffness can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamMotorControlStiffnessRoll;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch
 *  axis motor control strength can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamMotorControlStrengthPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw
 *  axis motor control strength can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamMotorControlStrengthYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's roll
 *  axis motor control strength can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamMotorControlStrengthRoll;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch
 *  axis motor control gyro filtering can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamMotorControlGyroFilteringPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw
 *  axis motor control gyro filtering can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamMotorControlGyroFilteringYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's roll
 *  axis motor control gyro filtering can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamMotorControlGyroFilteringRoll;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch
 *  axis motor control "precontrol" can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamMotorControlPrecontrolPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw
 *  axis motor control "precontrol" can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamMotorControlPrecontrolYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's roll
 *  axis motor control "precontrol" can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of
 *  `DJIParamCapabilityMinMax` meaning both the feature's existance as well as
 *  its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalParamMotorControlPrecontrolRoll;
