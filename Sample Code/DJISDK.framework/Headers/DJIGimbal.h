//
//  DJIGimbal.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIBaseComponent.h>

@class DJIGimbal;

NS_ASSUME_NONNULL_BEGIN

/*********************************************************************************/
#pragma mark - Gimbal Capability Keys
/*********************************************************************************/

/**
 *  Gimbal feature keys used in the `gimbalCapability` dictionary that holds the complete capability of the gimbal.
 *  A negative value in the valid range represents counter-clockwise rotation.
 *  A positive value in the valid range represents clockwise rotation.
 */
extern NSString *const DJIGimbalKeyAdjustPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal supports yaw axis adjustment.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range in degrees is returned.
 *  A negative value in the valid range represents counter-clockwise rotation.
 *  A positive value in the valid range represents clockwise rotation.
 *  For Gimbal's that allow a pitch range extension (see `DJIGimbalKeyPitchRangeExtension`, the range will be representative
 *  of the extended range whether it is enabled or not.
 */
extern NSString *const DJIGimbalKeyAdjustYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal supports roll axis adjustment.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range in degrees is returned.
 *  A negative value in the valid range represents counter-clockwise rotation.
 *  A positive value in the valid range represents clockwise rotation.
 */
extern NSString *const DJIGimbalKeyAdjustRoll;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal supports Advanced Settings Profiles.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapability`.
 */
extern NSString *const DJIGimbalKeyAdvancedSettingsProfile;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal supports a range extension in pitch.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range in degrees is returned.
 */
extern NSString *const DJIGimbalKeyPitchRangeExtension;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch axis response speed to manual control can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalKeyControllerSpeedPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw axis response speed to manual control can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalKeyControllerSpeedYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch axis smoothing can be adjusted when using manual control.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalKeyControllerSmoothingPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw axis smoothing can be adjusted when using manual control.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalKeyControllerSmoothingYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's manual control pitch axis deadband can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalKeyControllerDeadbandPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's manual control yaw axis deadband can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalKeyControllerDeadbandYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch axis SmoothTrack can be toggled.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapability`.
 *  Ronin-MX cannot toggle the SmoothTrack functionality and it is always enabled.
 */
extern NSString *const DJIGimbalKeySmoothTrackEnabledPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw axis SmoothTrack can be toggled.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapability`.
 *  Ronin-MX cannot toggle the SmoothTrack functionality and it is always enabled.
 */
extern NSString *const DJIGimbalKeySmoothTrackEnabledYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch axis SmoothTrack accelaration can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalKeySmoothTrackAccelerationPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw axis SmoothTrack accelaration can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalKeySmoothTrackAccelerationYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch axis SmoothTrack speed can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalKeySmoothTrackSpeedPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw axis SmoothTrack speed can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalKeySmoothTrackSpeedYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch axis SmoothTrack deadband can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range in degrees is returned.
 */
extern NSString *const DJIGimbalKeySmoothTrackDeadbandPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw axis SmoothTrack deadband can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range in degrees is returned.
 */
extern NSString *const DJIGimbalKeySmoothTrackDeadbandYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch up endpoint can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range in degrees is returned.
 */
extern NSString *const DJIGimbalKeyEndpointPitchUp;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch down endpoint can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range in degrees is returned.
 */
extern NSString *const DJIGimbalKeyEndpointPitchDown;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw left endpoint can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range in degrees is returned.
 */
extern NSString *const DJIGimbalKeyEndpointYawLeft;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw right endpoint can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range in degrees is returned.
 */
extern NSString *const DJIGimbalKeyEndpointYawRight;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch axis motor control stiffness can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalKeyMotorControlStiffnessPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw axis motor control stiffness can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalKeyMotorControlStiffnessYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's roll axis motor control stiffness can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalKeyMotorControlStiffnessRoll;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch axis motor control strength can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalKeyMotorControlStrengthPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw axis motor control strength can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalKeyMotorControlStrengthYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's roll axis motor control strength can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalKeyMotorControlStrengthRoll;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch axis motor control gyro filtering can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalKeyMotorControlGyroFilteringPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw axis motor control gyro filtering can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalKeyMotorControlGyroFilteringYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's roll axis motor control gyro filtering can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalKeyMotorControlGyroFilteringRoll;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's pitch axis motor control "precontrol" can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalKeyMotorControlPrecontrolPitch;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's yaw axis motor control "precontrol" can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalKeyMotorControlPrecontrolYaw;
/**
 *  Key string in `gimbalCapability` associated with whether the gimbal's roll axis motor control "precontrol" can be adjusted.
 *  The corresponding value in `gimbalCapability` is an instance of `DJIParamCapabilityMinMax` meaning both the feature's
 *  existance as well as its possible range (unitless) is returned.
 */
extern NSString *const DJIGimbalKeyMotorControlPrecontrolRoll;

/*********************************************************************************/
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
 *  The rotation angle of the gimbal can be defined as either Absolute (relative to the heading), or Relative (relative to its current angle).
 */
typedef NS_ENUM (uint8_t, DJIGimbalRotateAngleMode){
    /**
     *  The angle value, when the gimbal is rotating, is relative to the current angle.
     */
    DJIGimbalAngleModeRelativeAngle,
    /**
     *  The angle value, when the gimbal is rotating, is relative to 0 degrees (with respect to the aircraft heading).
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
     *  The gimbal can move independently of the aircraft's yaw. In this mode, even if the aircraft yaw changes, the camera will continue pointing in the same world direction. This feature is supported by the X3, X5 and X5R camera gimbals and the Ronin-MX. This mode is only available for the Ronin-MX when the M600 landing gear is retracted.
     */
    DJIGimbalWorkModeFreeMode,
    /**
     *  The gimbal's work mode is FPV mode. In this mode, the gimbal yaw will follow the aircraft's heading, and the gimbal roll will follow the RC's roll channel value. The pitch will be available to move. This mode is only available for the Ronin-MX when the M600 landing gear is retracted.
     *  Not supported by Osmo.
     */
    DJIGimbalWorkModeFpvMode,
    /**
     *  The gimbal's work mode is such that it will follow the yaw. In this mode, the gimbal yaw will be fixed, while pitch and roll will be available to move.
     *
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
 *  The Advanced Settings Profile contains presets for SmoothTrack and the Physical Controller sensitivity. SmoothTrack and Controller settings can
 *  only be manually changed if Custom1 or Custom2 profiles are selected.
 *  Only supported by Osmo.
 */
typedef NS_ENUM (uint8_t, DJIGimbalAdvancedSettingsProfile){
    /**
     *  The gimbal's SmoothTrack and Controller sensitivity is high.
     *  When the gimbal is using this profile, user cannot change the Advanced Settings manually.
     */
    DJIGimbalAdvancedSettingsProfileFast,
    /**
     *  The gimbal's SmoothTrack and Controller sensitivity is medium.
     *  When the gimbal is using this profile, user cannot change the Advanced Settings manually.
     */
    DJIGimbalAdvancedSettingsProfileMedium,
    /**
     *  The gimbal's SmoothTrack and Controller sensitivity is low.
     *  When the gimbal is using this profile, user cannot change the Advanced Settings manually.
     */
    DJIGimbalAdvancedSettingsProfileSlow,
    /**
     *  The gimbal uses a custom configuration in memory slot 1 where the yaw and pitch speed, deadband, and acceleration can be defined.
     */
    DJIGimbalAdvancedSettingsProfileCustom1,
    /**
     *  The gimbal uses a custom configuration in memory slot 2 where the yaw and pitch speed, deadband, and acceleration can be defined.
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
 *  For gimbals that allow payloads to be changed, the motor control configuration can be used to optimize gimbal performance for the different payloads.
 *  Only supported by the Ronin-MX gimbal.
 */
typedef NS_ENUM (uint8_t, DJIGimbalMotorControlPreset){
    /**
     *  The gimbal's motor control configuration is optimized for RED cameras.
     */
    DJIGimbalMotorControlPresetRED,
    /**
     *  The gimbal's motor control configuration is optimized for most DSLR cameras.
     */
    DJIGimbalMotorControlPresetDSLRCamera
};

/*********************************************************************************/
#pragma mark DJIGimbalBalanceTestResult
/*********************************************************************************/

/**
 *  For gimbals that allow payloads to be changed, a balance test should be performed to ensure the camera is mounted correctly.
 *  Only supported by Ronin-MX.
 */
typedef NS_ENUM (uint8_t, DJIGimbalBalanceTestResult){
    /**
     *  The balance test result is great.
     */
    DJIGimbalBalanceTestResultGreat,
    /**
     *  The balance test result is good. When this result is returned, it is possible there was some noise in the balance measurement.
     *  For best results, it is recommended to run the balance test again and adjust the payload position until the result becomes great.
     */
    DJIGimbalBalanceTestResultGood,
    /**
     *  The balance test result is bad. The payload should be adjusted when this result is returned.
     */
    DJIGimbalBalanceTestResultBad,
    /**
     *  The balance test result is unknown.
     */
    DJIGimbalBalanceTestResultUnknown = 0xFF
};

/**
 *  The control mode for the gimbal physical controller (joystick for Osmo). The total controller deflection is a combination of horizontal and vertical deflection. This translates to gimbal movement around the yaw and pitch axes.
 *  The gimbal can be set to either move in both yaw and pitch simultaneously based on horizontal and vertical deflection of the controller, or
 *  move in only yaw or pitch exclusively based on whether horizontal or vertical deflection is larger.
 *  Only supported by Osmo.
 */
typedef NS_ENUM (uint8_t, DJIGimbalControllerMode){
    /**
     * Gimbal movement will be exclusively in yaw or pitch depending on whether the controller horizontal or vertical deflection is greater respectively.
     */
    DJIGimbalControllerModeHorizontalVertical,
    /**
     * Gimbal movement will be in both yaw and pitch simultaneously relative to the horizontal and vertical deflection of the controller respectively.
     */
    DJIGimbalControllerModeFree,
    /**
     * The gimbal controller control mode is unknown.
     */
    DJIGimbalControllerModeUnknown = 0xFF,
};

/*********************************************************************************/
#pragma mark - DJIGimbalState
/*********************************************************************************/

/**
 *  This class provides the current state of the gimbal.
 *
 */
@interface DJIGimbalState : NSObject
/**
 *  The current gimbal attitude in degrees. Roll, pitch and yaw are 0 if the gimbal is level with the aircraft and points in the forward direction of the aircraft.
 */
@property(nonatomic, readonly) DJIGimbalAttitude attitudeInDegrees;

/**
 *  Returns the gimbal's roll fine-tune value. The range for the fine-tune value is
 *  [-10, 10] degrees. If the fine-tune value is negative, the gimbal will be fine tuned
 *  the specified number of degrees in the counterclockwise direction.
 */
@property(nonatomic, readonly) float rollFineTuneInDegrees;

/**
 *  Returns the gimbal's current work mode.
 */
@property(nonatomic, readonly) DJIGimbalWorkMode workMode;

/**
 *  Returns whether the attitude has been reset. If the gimbal is not in the
 *  original position, this value will return NO.
 */
@property(nonatomic, readonly) BOOL isAttitudeReset;

/**
 *  `YES` if the gimbal calibration succeeded.
 */
@property(nonatomic, readonly) BOOL isCalibrationSuccessful;

/**
 *  `YES` if the gimbal is calibrating.
 */
@property(nonatomic, readonly) BOOL isCalibrating;

/**
 *  Returns whether the gimbal's pitch value is at its limit.
 */
@property(nonatomic, readonly) BOOL isPitchAtStop;

/**
 *  Returns whether the gimbal's roll value is at its limit.
 */
@property(nonatomic, readonly) BOOL isRollAtStop;

/**
 *  Returns whether the gimbal's yaw value is at its limit.
 */
@property(nonatomic, readonly) BOOL isYawAtStop;

/**
 *  `YES` if the gimbal is currently testing payload balance. Only used by Ronin-MX.
 */
@property(nonatomic, readonly) BOOL isTestingBalance;

/**
 *  Returns the pitch axis balance test result. Only used by Ronin-MX.
 */
@property(nonatomic, readonly) DJIGimbalBalanceTestResult pitchTestResult;

/**
 *  Returns the roll axis balance test result. Only used by Ronin-MX.
 */
@property(nonatomic, readonly) DJIGimbalBalanceTestResult rollTestResult;

@end

/*********************************************************************************/
#pragma mark - DJIGimbalAdvancedSettingsState
/*********************************************************************************/

/**
 *  The current advanced settings of the gimbal. These include settings for SmoothTrack and the Controller.
 *  Only supported by Osmo.
 */
@interface DJIGimbalAdvancedSettingsState : NSObject

/**
 *  Advanced settings profile. `DJIGimbalAdvancedSettingsProfileFast`, `DJIGimbalAdvancedSettingsProfileMedium` and `DJIGimbalAdvancedSettingsProfileSlow` are preset profiles. In these profiles, SmoothTrack and Controller settings cannot be manually changed. When the profile is `DJIGimbalAdvancedSettingsProfileCustom1` or `DJIGimbalAdvancedSettingsProfileCustom2`, the SmoothTrack and Controller settings can be manually changed. When a profile is changed from a custom setting, the current settings will be saved in that custom setting.
 */
@property(nonatomic, readonly) DJIGimbalAdvancedSettingsProfile profile;

/**
 *  YES if gimbal SmoothTrack is enabled for the yaw axis.
 */
@property(nonatomic, readonly) BOOL isSmoothTrackEnabledYaw;

/**
 *  YES if gimbal SmoothTrack is enabled for the pitch axis.
 */
@property(nonatomic, readonly) BOOL isSmoothTrackEnabledPitch;

/**
 *  SmoothTrack yaw axis speed determines how fast the gimbal will catch up with the translated yaw handle movement.
 *  Range is [0,100].
 */
@property(nonatomic, readonly) NSInteger smoothTrackSpeedYaw;

/**
 *  SmoothTrack pitch axis speed determines how fast the gimbal will catch up with the translated pitch handle movement.
 *  Range is [0,100].
 */
@property(nonatomic, readonly) NSInteger smoothTrackSpeedPitch;

/**
 *   A larger SmoothTrack yaw axis deadband requires more yaw handle movement to translate into gimbal motion.
 *  Range is [0,90] degrees.
 */
@property(nonatomic, readonly) NSInteger smoothTrackDeadbandYaw;

/**
 *   A larger SmoothTrack pitch axis deadband requires more pitch handle movement to translate into gimbal motion.
 *  Range is [0,90] degrees.
 */
@property(nonatomic, readonly) NSInteger smoothTrackDeadbandPitch;

/**
 *  SmoothTrack yaw axis acceleration determines how closely the gimbal's yaw axis will follow the translated controller movement.
 *  Range is [0,30].
 */
@property(nonatomic, readonly) NSInteger smoothTrackAccelerationYaw;

/**
 *  SmoothTrack pitch axis acceleration determines how closely the gimbal's yaw axis will follow the translated controller movement.
 *  Range is [0,30].
 */
@property(nonatomic, readonly) NSInteger smoothTrackAccelerationPitch;

/**
 *  Controller yaw axis smoothing controls the deceleration of the gimbal. A small value will cause the gimbal to stop abruptly.
 *  Range is [0,30].
 */
@property(nonatomic, readonly) NSInteger controllerSmoothingYaw;

/**
 *  Controller pitch axis smoothing controls the deceleration of the gimbal. A small value will cause the gimbal to stop abruptly.
 *  Range is [0,30].
 */
@property(nonatomic, readonly) NSInteger controllerSmoothingPitch;

/**
 *  Controller yaw axis speed determines how sensitively the gimbal's yaw axis will follow the controller movement.
 *  Range is [0,100].
 */
@property(nonatomic, readonly) NSInteger controllerSpeedYaw;

/**
 *  Controller pitch axis speed determines how sensitively the gimbal's pitch axis will follow the controller movement.
 *  Range is [0,100].
 */
@property(nonatomic, readonly) NSInteger controllerSpeedPitch;

@end

/*********************************************************************************/
#pragma mark - DJIGimbalDelegate
/*********************************************************************************/

/**
 *
 *  This protocol provides delegate methods to receive the updated state and user configuration.
 *
 */
@protocol DJIGimbalDelegate <NSObject>

@optional

/**
 *  Updates the gimbal's current state.
 */
- (void)gimbal:(DJIGimbal *_Nonnull)gimbal didUpdateGimbalState:(DJIGimbalState *_Nonnull)gimbalState;

/**
 *  Update the gimbal's user configuration data. This method is only supported for Osmo.
 */
- (void)gimbal:(DJIGimbal *_Nonnull)gimbal didUpdateAdvancedSettingsState:(DJIGimbalAdvancedSettingsState *_Nonnull)settingsState;

/**
 *  Update the gimbal's remaining energy in percentage. This method is only supported for Ronin-MX.
 */
- (void)gimbal:(DJIGimbal *_Nonnull)gimbal didUpdateGimbalBatteryRemainingEnergy:(NSInteger)energy;

@end

/*********************************************************************************/
#pragma mark - DJIGimbal
/*********************************************************************************/

/**
 *
 *  This class provides multiple methods to control the gimbal. These include setting the gimbal work mode, rotating the gimbal with angle, starting the gimbal auto calibration, etc.
 *
 */
@interface DJIGimbal : DJIBaseComponent

/**
 *  Returns the delegate of DJIGimbal.
 */
@property(nonatomic, weak) id<DJIGimbalDelegate> delegate;

/**
 *  Returns the latest gimbal attitude data, or nil if none is available.
 */
@property(nonatomic, readonly) DJIGimbalAttitude attitudeInDegrees;

/**
 *  Sets the completion time, in seconds, to complete an action to control the gimbal. If
 *  the method `rotateGimbalWithAngleMode:pitch:roll:yaw:withCompletion` is used to control the gimbal's absolute
 *  angle，this property will be used to determine in what duration of time the gimbal should
 *  rotate to its new position. For example, if the value of this property is set to 2.0
 *  seconds, the gimbal will rotate to its target position in 2.0 seconds.
 *  Range is [0.1, 25.5] seconds.
 */
@property(nonatomic, assign) double completionTimeForControlAngleAction;

/**
 *  Returns the gimbal's features and possible range of settings.
 *  Each dictionary key is a possible gimbal feature and uses the DJIGimbalKey prefix.
 *  The value for each key is an instance of `DJIParamCapability` or its sub-classes.
 *  The `isSupported` property can be used to query if a feature is supported by the gimbal
 *  and the `min` and `max` properties of `DJIParamCapabilityMinMax` can be used to query
 *  the valid range for the setting. When a feature is not supported, the values for
 *  `min` and `max` are undefined.
 */
@property(nonatomic, readonly) NSDictionary *_Nonnull gimbalCapability;

/*********************************************************************************/
#pragma mark Set Gimbal Work Mode
/*********************************************************************************/

/**
 *  Sets the gimbal's work mode. See enum `DJIGimbalWorkMode` for modes.
 *
 *  @param workMode Gimbal work mode to be set.
 *  @param block   Remote execution result error block.
 */
- (void)setGimbalWorkMode:(DJIGimbalWorkMode)workMode withCompletion:(DJICompletionBlock)block;

/*********************************************************************************/
#pragma mark Gimbal Control
/*********************************************************************************/

/**
 *  Rotate the gimbal's pitch, roll, and yaw in Angle Mode.
 *  See `gimbalCapability` for which axes can be moved for the gimbal being used.
 *
 *  @param pitch Gimbal's pitch rotation.
 *  @param roll Gimbal's roll rotation.
 *  @param yaw Gimbal's yaw rotation.
 *  @param block Execution result error block.
 */
- (void)rotateGimbalWithAngleMode:(DJIGimbalRotateAngleMode)angleMode pitch:(DJIGimbalAngleRotation)pitch roll:(DJIGimbalAngleRotation)roll yaw:(DJIGimbalAngleRotation)yaw withCompletion:(DJICompletionBlock)block;

/**
 *  Rotate the gimbal's pitch, roll, and yaw using speed. The direction can either be set to clockwise or counter-clockwise.
 *  See `gimbalCapability` for which axes can be moved for the gimbal being used.
 *
 *  @param pitch Gimbal's pitch rotation.
 *  @param roll Gimbal's roll rotation.
 *  @param yaw Gimbal's yaw rotation.
 *  @param block Execution result error block.
 */
- (void)rotateGimbalBySpeedWithPitch:(DJIGimbalSpeedRotation)pitch roll:(DJIGimbalSpeedRotation)roll yaw:(DJIGimbalSpeedRotation)yaw withCompletion:(DJICompletionBlock)block;

/**
 *  Resets the gimbal. The gimbal's pitch, roll, and yaw will be set to the origin, which is the standard position for the gimbal.
 *
 *  @param block Remote execution result error block.
 */
- (void)resetGimbalWithCompletion:(DJICompletionBlock)block;

/*********************************************************************************/
#pragma mark Gimbal Calibration
/*********************************************************************************/

/**
 *  Starts calibrating the gimbal. The product should be stationary (not flying, or being held) and horizontal during calibration.
 *  For gimbal's with adjustable payloads, the payload should be present and balanced before doing a calibration.
 *
 *  @param block Remote execution result error block.
 */
- (void)startGimbalAutoCalibrationWithCompletion:(DJICompletionBlock)block;

/**
 *  The gimbal roll can be fine tuned with a custom offset. The range for the custom offset is
 *  [-10, 10] degrees. If the offset is negative, the gimbal will be fine tuned the specified
 *  number of degrees in the counterclockwise direction.
 *
 *  @param offset   Fine-tuned offset, in degrees, to be tuned.
 *  @param block    Completion block.
 */
- (void)fineTuneGimbalRollInDegrees:(float)offset withCompletion:(DJICompletionBlock)block;

/**
 *  Starts testing the balance of the gimbal payload.
 *  For gimbals that allow payloads to be changed, a balance test should be performed to ensure the camera is mounted correctly.
 *  The product should be stationary (not flying, or being held) and horizontal during testing. See `DJIGimbalState` for the test result.
 *  Only supported by Ronin-MX.
 *
 *  @param block Completion block that receives the execution result. The completion block will return when the balance test is successfully started.
 */
- (void)startGimbalBalanceTestWithCompletion:(DJICompletionBlock)block;

/*********************************************************************************/
#pragma mark - Gimbal Advanced Setting
/*********************************************************************************/

/**
 *  Sets the advanced settings profile. The advanced settings profile has options for both preset and custom profiles
 *  for SmoothTrack and Controller settings. Settings for SmoothTrack and Controller can only be set manually when using a custom profile.
 *  Use `DJIGimbalKeyAdvancedSettingsProfile` in `gimbalCapability` to check if it is supported by the gimbal.
 *  Only supported by Osmo.
 *
 *  @param profile Profile to set.
 *  @param block Completion block that receives the execution result.
 */
- (void)setAdvancedSettingsProfile:(DJIGimbalAdvancedSettingsProfile)profile withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the advanced settings profile.
 *  Use `DJIGimbalKeyAdvancedSettingsProfile` to check if it is supported by the gimbal.
 *  Only supported by Osmo.
 *
 *  @param block Completion block that receives the execution result.
 */
- (void)getAdvancedSettingsProfileWithCompletion:(void (^_Nonnull)(DJIGimbalAdvancedSettingsProfile profile, NSError *_Nullable error))block;

/**
 *  Restores the gimbal's settings to factory settings.
 *
 *  @param block    The completion block that receives execution result.
 */
- (void)loadFactorySettings:(DJICompletionBlock)block;

/*********************************************************************************/
#pragma mark Gimbal Range Extension
/*********************************************************************************/

/**
 *  Extends the pitch range of gimbal. Currently, it is only supported by Phantom 3 Series and Phantom 4. If extended, the gimbal's pitch control range can be [-30, 90], otherwise, it's [0, 90].
 *  Use `DJIGimbalKeyPitchRangeExtension` to check if it is supported by the gimbal.
 *
 *  @param shouldExtend Whether the pitch range should be extended
 *  @param block The completion block that receives execution result.
 */
- (void)setPitchRangeExtensionEnabled:(BOOL)shouldExtend withCompletion:(DJICompletionBlock)block;

/**
 *  Get the extend gimbal pitch range state.
 *  Use `DJIGimbalKeyPitchRangeExtension` to check if it is supported by the gimbal.
 *
 *  @param shouldExtend Whether the pitch range should be extended
 *  @param block        The completion block that receives execution result.
 */
- (void)getPitchRangeExtensionEnabledWithCompletion:(void (^_Nonnull)(BOOL isExtended, NSError *_Nullable error))block;

/*********************************************************************************/
#pragma mark Gimbal Motor Control Configuration
/*********************************************************************************/

/**
 *  Configures gimbal's motor control with a preset configuration applicable for most popular cameras.
 *  In order to the optimize the performance, motor control tuning is still required.
 *
 *  @param preset   The preset configuration to set.
 *  @param block    The completion block that receives execution result.
 */
- (void)configureMotorControlWithPreset:(DJIGimbalMotorControlPreset)preset withCompletion:(DJICompletionBlock)block;

/**
 *  Sets the coefficient of speed error control. It can be seen as the coefficient for the proportional term in the PID controller. Only supported by Ronin-MX.
 *  Use `DJIGimbalKeyMotorControlStiffnessPitch`, `DJIGimbalKeyMotorControlStiffnessYaw` and `DJIGimbalKeyMotorControlStiffnessRoll` with `gimbalCapability` to check if the gimbal supports this feature and the range of possible values (unitless).
 *
 *   @param stiffness   The stiffness value to set.
 *   @param axis        The axis that the setting is applied to.
 *   @param block       The completion block that receives execution result.
 */
- (void)setMotorControlStiffness:(NSInteger)stiffness onAxis:(DJIGimbalAxis)axis withCompletion:(DJICompletionBlock)block;
/**
 *  Gets the coefficient of speed error control. It can be seen as the coefficient for the proportional term in the PID controller. Only supported by Ronin-MX.
 *  Use `DJIGimbalKeyMotorControlStiffnessPitch`, `DJIGimbalKeyMotorControlStiffnessYaw` and `DJIGimbalKeyMotorControlStiffnessRoll` with `gimbalCapability` to check if the gimbal supports this feature and the range of possible values (unitless).
 *
 *  @param axis     The axis to query.
 *  @param block    The completion block that receives execution result.
 */
- (void)getMotorControlStiffnessOnAxis:(DJIGimbalAxis)axis withCompletion:(void (^_Nonnull)(NSInteger stiffness, NSError *_Nullable error))block;

/**
 *  Sets the coefficient of attitude accuracy control. It can be seen as the coefficient for the integral term in the PID controller. Only supported by Ronin-MX.
 *  Use `DJIGimbalKeyMotorControlStrengthPitch`, `DJIGimbalKeyMotorControlStrengthYaw` and `DJIGimbalKeyMotorControlStrengthRoll` with `gimbalCapability` to check if the gimbal supports this feature and the range of possible values (unitless).
 *
 *   @param strength    The strength value to set.
 *   @param axis        The axis that the setting is applied to.
 *   @param block       The completion block that receives execution result.
 */
- (void)setMotorControlStrength:(NSInteger)strength onAxis:(DJIGimbalAxis)axis withCompletion:(DJICompletionBlock)block;
/**
 *  Gets the coefficient of attitude accuracy control. It can be seen as the coefficient for the integral term in the PID controller. Only supported by Ronin-MX.
 *  Use `DJIGimbalKeyMotorControlStrengthPitch`, `DJIGimbalKeyMotorControlStrengthYaw` and `DJIGimbalKeyMotorControlStrengthRoll` with `gimbalCapability` to check if the gimbal supports this feature and the range of possible values (unitless).
 *
 *  @param axis     The axis to query.
 *  @param block    The completion block that receives execution result.
 */
- (void)getMotorControlStrengthOnAxis:(DJIGimbalAxis)axis withCompletion:(void (^_Nonnull)(NSInteger strength, NSError *_Nullable error))block;

/**
 *  Sets the coefficient of denoising the output. Only supported by Ronin-MX.
 *  Use `DJIGimbalKeyMotorControlGyroFilteringPitch`, `DJIGimbalKeyMotorControlGyroFilteringYaw` and `DJIGimbalKeyMotorControlGyroFilteringRoll` with `gimbalCapability` to check if the gimbal supports this feature and the range of possible values (unitless).
 *
 *   @param filtering   The gyro filtering value to set.
 *   @param axis        The axis that the setting is applied to.
 *   @param block       The completion block that receives execution result.
 */
- (void)setMotorControlGyroFiltering:(NSInteger)filtering onAxis:(DJIGimbalAxis)axis withCompletion:(DJICompletionBlock)block;
/**
 *  Gets the coefficient of denoising the output. Only supported by Ronin-MX.
 *  Use `DJIGimbalKeyMotorControlGyroFilteringPitch`, `DJIGimbalKeyMotorControlGyroFilteringYaw` and `DJIGimbalKeyMotorControlGyroFilteringRoll` with `gimbalCapability` to check if the gimbal supports this feature and the range of possible values (unitless).
 *
 *  @param axis     The axis to query.
 *  @param block    The completion block that receives execution result.
 */
- (void)getMotorControlGyroFilteringOnAxis:(DJIGimbalAxis)axis withCompletion:(void (^_Nonnull)(NSInteger filtering, NSError *_Nullable error))block;

/**
 *  Sets the value for pre-adjust. It can be seen as the coefficient for the derivative term in the PID controller. Only supported by Ronin-MX.
 *  Use `DJIGimbalKeyMotorControlPrecontrolPitch`, `DJIGimbalKeyMotorControlPrecontrolYaw` and `DJIGimbalKeyMotorControlPrecontrolRoll` with `gimbalCapability` to check if the gimbal supports this feature and the range of possible values (unitless).
 *
 *   @param precontrol  The Precontrol value to set.
 *   @param axis        The axis that the setting is applied to.
 *   @param block       The completion block that receives execution result.
 */
- (void)setMotorControlPrecontrol:(NSInteger)precontrol onAxis:(DJIGimbalAxis)axis withCompletion:(DJICompletionBlock)block;
/**
 *  Gets the value for pre-adjust. It can be seen as the coefficient for the derivative term in the PID controller. Only supported by Ronin-MX.
 *  Use `DJIGimbalKeyMotorControlPrecontrolPitch`, `DJIGimbalKeyMotorControlPrecontrolYaw` and `DJIGimbalKeyMotorControlPrecontrolRoll` with `gimbalCapability` to check if the gimbal supports this feature and the range of possible values (unitless).
 *
 *  @param axis     The axis to query.
 *  @param block    The completion block that receives execution result.
 */
- (void)getMotorControlPrecontrolOnAxis:(DJIGimbalAxis)axis withCompletion:(void (^_Nonnull)(NSInteger precontrol, NSError *_Nullable error))block;

/*********************************************************************************/
#pragma mark Gimbal Controller Setting
/*********************************************************************************/

/**
 *  Sets physical controller (e.g. the joystick on Osmo or the remote controller of the aircraft) deadband on an axis. A larger deadband requires more controller movement to start gimbal motion.
 *  Use `DJIGimbalKeyControllerDeadbandYaw` and `DJIGimbalKeyControllerDeadbandPitch` with `gimbalCapability` to check if the gimbal supports this feature and the range of possible values (unitless).
 *
 *  @param deadband The deadband value to be set.
 *  @param axis     The axis that the setting will be applied to.
 *  @param block    The completion block that receives execution result.
 */
- (void)setControllerDeadband:(NSInteger)deadband onAxis:(DJIGimbalAxis)axis withCompletion:(DJICompletionBlock)block;
/**
 *  Gets physical controller deadband value on an axis. A larger deadband requires more controller movement to start gimbal motion.
 *  Use `DJIGimbalKeyControllerDeadbandYaw` and `DJIGimbalKeyControllerDeadbandPitch` with `gimbalCapability` to check if the gimbal supports this feature and the range of possible values (unitless).
 *  @param axis     The axis to query.
 *  @param block    The completion block that receives execution result.
 */
- (void)getControllerDeadbandOnAxis:(DJIGimbalAxis)axis withCompletion:(void (^_Nonnull)(NSInteger deadband, NSError *_Nullable error))block;

/**
 *  Sets physical controller (e.g. the joystick on Osmo or the remote controller of the aircraft) speed on an axis. Speed setting controls the mapping between the movement of the controller and the gimbal speed.
 *  Use `DJIGimbalKeyControllerSpeedYaw` and `DJIGimbalKeyControllerSpeedPitch` with `gimbalCapability` to check if the gimbal supports this feature and the range of possible values (unitless).

 *  @param speed    The speed value to be set.
 *  @param axis     The axis that the setting will be applied to.
 *  @param block    The completion block that receives execution result.
 */
- (void)setControllerSpeed:(NSInteger)speed onAxis:(DJIGimbalAxis)axis withCompletion:(DJICompletionBlock)block;
/**
 *  Gets physical controller speed value on an axis. Speed setting controls the mapping between the movement of the controller and the gimbal speed.
 *  Use `DJIGimbalKeyControllerSpeedYaw` and `DJIGimbalKeyControllerSpeedPitch` with `gimbalCapability` to check if the gimbal supports this feature and the range of possible values (unitless).

 *  @param axis     The axis to query.
 *  @param block    The completion block that receives execution result.
 */
- (void)getControllerSpeedOnAxis:(DJIGimbalAxis)axis withCompletion:(void (^_Nonnull)(NSInteger speed, NSError *_Nullable error))block;

/**
 *  Sets physical controller (e.g. the joystick on Osmo or the remote controller of the aircraft) smoothing on an axis. Smoothing controls the deceleration of the gimbal.
 *  Use `DJIGimbalKeyControllerSmoothingYaw` and `DJIGimbalKeyControllerSmoothingPitch` with `gimbalCapability` to check if the gimbal supports this feature and the range of possible values (unitless).
 *
 *  @param smoothing    The smoothing value to be set.
 *  @param axis         The axis that the setting will be applied to.
 *  @param block        The completion block that receives execution result.
 */
- (void)setControllerSmoothing:(NSInteger)smoothing onAxis:(DJIGimbalAxis)axis withCompletion:(DJICompletionBlock)block;
/**
 *  Gets physical controller smoothing value on an axis. Smoothing controls the deceleration of the gimbal.
 *  Use `DJIGimbalKeyControllerSmoothingYaw` and `DJIGimbalKeyControllerSmoothingPitch` with `gimbalCapability` to check if the gimbal supports this feature and the range of possible values (unitless).
 *
 *  @param axis     The axis to query.
 *  @param block    The completion block that receives execution result.
 */
- (void)getControllerSmoothingOnAxis:(DJIGimbalAxis)axis withCompletion:(void (^_Nonnull)(NSInteger smoothing, NSError *_Nullable error))block;
/*********************************************************************************/
#pragma mark Gimbal Smooth Track Setting
/*********************************************************************************/

/**
 *  Enables SmoothTrack for the axis. Only supported by Osmo. Ronin-MX supports SmoothTrack but it is always enabled for both pitch axis and yaw axis.
 *  Use `DJIGimbalKeySmoothTrackEnabledPitch` and `DJIGimbalKeySmoothTrackEnabledYaw` with `gimbalCapability` to check if the gimbal supports this feature.
 *
 *  @param enabled  `YES` to enable SmoothTrack on the axis.
 *  @param axis     The axis that the setting will be applied to.
 *  @param block    The completion block that receives execution result.
 */
- (void)setSmoothTrackEnabled:(BOOL)enabled onAxis:(DJIGimbalAxis)axis withCompletion:(DJICompletionBlock)block;

/**
 *  Gets whether an axis has SmoothTrack enabled. Only supported by Osmo. Ronin-MX supports SmoothTrack but it is always enabled for both pitch axis and yaw axis.
 *  Use `DJIGimbalKeySmoothTrackEnabledPitch` and `DJIGimbalKeySmoothTrackEnabledYaw` with `gimbalCapability` to check if the gimbal supports this feature.
 *
 *  @param axis     The axis to query.
 *  @param block    The completion block that receives execution result.
 */
- (void)getSmoothTrackEnabledOnAxis:(DJIGimbalAxis)axis withCompletion:(void (^_Nonnull)(BOOL isEnabled, NSError *_Nullable error))block;

/**
 *  Sets gimbal SmoothTrack catch up speed on an axis. SmoothTrack speed determines how fast the gimbal will catch up with a large, translated handle movement.
 *  Use `DJIGimbalKeySmoothTrackSpeedPitch` and `DJIGimbalKeySmoothTrackSpeedYaw` with `gimbalCapability` to check if the gimbal supports this feature and the range of possible values (unitless).
 *
 *  @param speed    SmoothTrack speed [0,100].
 *  @param axis     The axis that the setting will be applied to.
 *  @param block    The completion block that receives execution result.
 */
- (void)setSmoothTrackSpeed:(NSInteger)speed onAxis:(DJIGimbalAxis)axis withCompletion:(DJICompletionBlock)block;

/**
 *  Gets gimbal SmoothTrack speed on an axis. SmoothTrack speed determines how fast the gimbal will catch up with a large, translated handle movement.
 *  Use `DJIGimbalKeySmoothTrackSpeedPitch` and `DJIGimbalKeySmoothTrackSpeedYaw` with `gimbalCapability` to check if the gimbal supports this feature and the range of possible values (unitless).
 *
 *  @param axis     The axis to query.
 *  @param block    The completion block that receives execution result.
 */
- (void)getSmoothTrackSpeedOnAxis:(DJIGimbalAxis)axis withCompletion:(void (^_Nonnull)(NSInteger speed, NSError *_Nullable error))block;

/**
 *  Sets SmoothTrack deadband on an axis. A larger deadband requires more handle movement to translate into gimbal motion.
 *  Use `DJIGimbalKeySmoothTrackDeadbandPitch` and `DJIGimbalKeySmoothTrackDeadbandYaw` with `gimbalCapability` to check if the gimbal supports this feature and the range of possible values in degrees.
 *
 *  @param deadband SmoothTrack deadband [0,90].
 *  @param axis     The axis that the setting will be applied to.
 *  @param block    The completion block that receives execution result.
 */

- (void)setSmoothTrackDeadband:(NSInteger)deadband onAxis:(DJIGimbalAxis)axis withCompletion:(DJICompletionBlock)block;

/**
 *  Gets SmoothTrack deadband on an axis. A larger deadband requires more handle movement to translate into gimbal motion.
 *  Use `DJIGimbalKeySmoothTrackDeadbandPitch` and `DJIGimbalKeySmoothTrackDeadbandYaw` with `gimbalCapability` to check if the gimbal supports this feature and the range of possible values in degrees.
 *
 *  @param axis     The axis to query.
 *  @param block    The completion block that receives execution result.
 */

- (void)getSmoothTrackDeadbandOnAxis:(DJIGimbalAxis)axis withCompletion:(void (^_Nonnull)(NSInteger deadband, NSError *_Nullable error))block;

/**
 *  Sets SmoothTrack acceleration on an axis. Acceleration determines how closely the camera will follow the translated yaw handle movement.
 *  Use `DJIGimbalKeySmoothTrackAccelerationPitch` and `DJIGimbalKeySmoothTrackAccelerationYaw` with `gimbalCapability` to check if the gimbal supports this feature and the range of possible values (unitless).
 *
 *  @param acceleration SmoothTrack acceleration [0,30].
 *  @param axis         The axis that the setting will be applied to.
 *  @param block        The completion block that receives execution result.
 */

- (void)setSmoothTrackAcceleration:(NSInteger)acceleration onAxis:(DJIGimbalAxis)axis withCompletion:(DJICompletionBlock)block;

/**
 *  Gets SmoothTrack acceleration on an axis. Acceleration determines how closely the camera will follow the translated yaw handle movement.
 *  Use `DJIGimbalKeySmoothTrackAccelerationPitch` and `DJIGimbalKeySmoothTrackAccelerationYaw` with `gimbalCapability` to check if the gimbal supports this feature and the range of possible values (unitless).
 *
 *  @param axis     The axis to query.
 *  @param block    The completion block that receives execution result.
 */
- (void)getSmoothTrackAccelerationOnAxis:(DJIGimbalAxis)axis withCompletion:(void (^_Nonnull)(NSInteger acceleration, NSError *_Nullable error))block;

/*********************************************************************************/
#pragma mark Gimbal Endpoint Setting
/*********************************************************************************/

/**
 *  Endpoint settings determine the farthest points to which the gimbal will rotate during manual controller input.
 *  Only supported by Ronin-MX.
 *  Use `DJIGimbalKeyEndpointPitchUp`, `DJIGimbalKeyEndpointPitchDown`, `DJIGimbalKeyEndpointYawLeft` and `DJIGimbalKeyEndpointYawRight` in `gimbalCapability` to check if the gimbal supports this feature and what the valid range of enpoints are.
 *
 *  @param endpoint     The endpoint value to set.
 *  @param direction    The endpoint direction.
 *  @param block        The completion block that receives execution result.
 */
- (void)setEndpoint:(NSInteger)endpoint inDirection:(DJIGimbalEndpointDirection)direction withCompletion:(DJICompletionBlock)block;
/**
 *  Gets the farthest points to which the gimbal will rotate during manual controller input.
 *  Only supported by Ronin-MX.
 *  Use `DJIGimbalKeyEndpointPitchUp`, `DJIGimbalKeyEndpointPitchDown`, `DJIGimbalKeyEndpointYawLeft` and `DJIGimbalKeyEndpointYawRight` with `gimbalCapability` to check if the gimbal supports this feature.
 *
 *  @param direction    The endpoint direction.
 *  @param block        The completion block that receives execution result.
 */- (void)getEndpointInDirection:(DJIGimbalEndpointDirection)direction withCompletion:(void (^_Nonnull)(NSInteger endpoint, NSError *_Nullable error))block;

/*********************************************************************************/
#pragma mark Others
/*********************************************************************************/

/**
 *  Allows the camera to be mounted in the upright position (on top of the aircraft instead of underneath).
 *  Only supported by Ronin-MX.
 *
 *  @param enabled  `YES` to allow the camera to be upright.
 *  @param block    The completion block that receives execution result.
 */
- (void)setCameraUprightEnabled:(BOOL)enabled withCompletion:(DJICompletionBlock)block;
/**
 *  Gets if the camera is allowed to be in the upright position.
 *  Only supported by Ronin-MX.
 *
 *  @param block    The completion block that receives execution result.
 */
- (void)getCameraUprightEnabledWithCompletion:(void (^_Nonnull)(BOOL enabled, NSError *_Nullable error))block;

/**
 *  Turns on and off the gimbal motors. `NO` means the gimbal power remains on, however the motors will not work.
 *  Only supported by Ronin-MX.
 *
 *  @param enabled  `YES` to enable the motor.
 *  @param block    The completion block that receives execution result.
 */
- (void)setMotorEnabled:(BOOL)enabled withCompletion:(DJICompletionBlock)block;
/**
 *  Gets if the gimbal motors are enabled to work or not. Only supported by Ronin-MX.
 *
 *  @param block    The completion block that receives execution result.
 */
- (void)getMotorEnabledWithCompletion:(void (^_Nonnull)(BOOL enabled, NSError *_Nullable error))block;

/**
 *  Resets gimbal position to selfie setup. If the gimbal yaw is not at 180 degrees, then calling this method will rotate the gimbal yaw to 180 degrees (effectively pointing the camera to the person holding the gimbal). If the gimbal yaw is at 180 degrees, then the gimbal will rotate in yaw to 0 degrees.
 *  Only supported by Osmo.
 *
 *  @param block    The completion block that receives execution result.
 */
- (void)toggleGimbalSelfieWithCompletion:(DJICompletionBlock)block;

/**
 *  Sets the gimbal's controller mode.
 *  The control mode for the gimbal controller (joystick for Osmo). The total controller deflection
 *  is a combination of horizontal and vertical deflection. This translates to gimbal movement around the yaw and pitch axes.
 *  The gimbal can be set to either move in both yaw and pitch simultaneously based on horizontal and vertical deflection of the controller, or
 *  move in only yaw or pitch exclusively based on whether horizontal or vertical deflection is larger.
 *  Only supported by Osmo.
 *
 *  @param controlMode  The stick control mode to set.
 *  @param block        The completion block that receives execution result.
 */
- (void)setGimbalControllerMode:(DJIGimbalControllerMode)controlMode withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the gimbal's controller mode.
 *  Only supported by Osmo.
 *
 *  @param block    The completion block that receives execution result.
 */
- (void)getGimbalControllerModeWithCompletion:(void (^_Nonnull)(DJIGimbalControllerMode controlMode, NSError *_Nullable error))block;

@end

NS_ASSUME_NONNULL_END
