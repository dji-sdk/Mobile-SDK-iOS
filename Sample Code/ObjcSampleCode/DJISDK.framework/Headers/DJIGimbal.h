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
#pragma mark - Data Structs and Enums
/*********************************************************************************/

//-----------------------------------------------------------------
#pragma mark DJIGimbalAttitude
//-----------------------------------------------------------------
/**
 *  The gimbal's attitude in degrees relative to the aircraft.
 */
typedef struct
{
    /**
     *  Pitch value.
     */
    float pitch;
    /**
     *  Roll value.
     */
    float roll;
    /**
     *  Yaw value.
     */
    float yaw;
} DJIGimbalAttitude;

//-----------------------------------------------------------------
#pragma mark DJIGimbalRotateDirection
//-----------------------------------------------------------------
/**
 *  Gimbal rotate direction.
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

//-----------------------------------------------------------------
#pragma mark DJIGimbalRotateAngleMode
//-----------------------------------------------------------------
/**
 *  The rotation angle of gimbal can be defined as either Absolute (relative to heading), or Relative (relative to it's current angle).
 */
typedef NS_ENUM (uint8_t, DJIGimbalRotateAngleMode){
    /**
     *  The angle value, when the gimbal is rotating, will be relative to the current angle.
     */
    DJIGimbalAngleModeRelativeAngle,
    /**
     *  The angle value, when the gimbal is rotating, will be relative to 0 degrees (aircraft heading).
     */
    DJIGimbalAngleModeAbsoluteAngle,
};

//-----------------------------------------------------------------
#pragma mark DJIGimbalAngleRotation
//-----------------------------------------------------------------
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
     *  Gimbal rotate direction
     */
    DJIGimbalRotateDirection direction;
} DJIGimbalAngleRotation;

//-----------------------------------------------------------------
#pragma mark DJIGimbalSpeedRotation
//-----------------------------------------------------------------
/**
 *  Struct used to control the gimbal by speed.
 */
typedef struct
{
    /**
     *  Gimbal rotation angle velocity in degree/second.
     */
    float angleVelocity;
    /**
     *  Gimbal rotate direction
     */
    DJIGimbalRotateDirection direction;
} DJIGimbalSpeedRotation;

//-----------------------------------------------------------------
#pragma mark DJIGimbalWorkMode
//-----------------------------------------------------------------
/**
 *  Gimbal work modes.
 */
typedef NS_ENUM (uint8_t, DJIGimbalWorkMode){
    /**
     *  The gimbal can move free of aircraft's yaw. This is only supported by the X3, X5 and X5R camera gimbals. In this mode, if the aircraft yaw changes, the camera will stay pointing in the same world direction.
     */
    DJIGimbalWorkModeFreeMode,
    /**
     *  The gimbal's work mode is FPV mode. In this mode, the gimbal yaw will follow the aircraft's heading, the gimbal roll will follow the RC's roll channel value. While the pitch will be available to move.
     *  Not supported by OSMO.
     *
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

//-----------------------------------------------------------------
#pragma mark DJIGimbalUserConfigType
//-----------------------------------------------------------------
/**
 *  Gimbal User Config. This is only supported by OSMO gimbal.
 *
 *  The gimbal has a feature called SmoothTrack
 *  SmoothTrack smooths out larger transitions in pitch and yaw (as opposed to keeping the camera pointed in the same direction at all times)
 *  SmoothTrack is used on two axes (yaw and pitch) and has three presets of fast, medium or slow which impact the tracking speed, deadband and acceleration settings. These settings can also be customized.
 */
typedef NS_ENUM (uint8_t, DJIGimbalUserConfigType){
    /**
     *  The gimbal's SmoothTrack will catch up with significant yaw and pitch changes with a fast speed.
     */
    DJIGimbalUserConfigTypeFastSmoothTrack = 3,
    /**
     *  The gimbal's SmoothTrack will catch up with significant yaw and pitch changes with a medium speed.
     */
    DJIGimbalUserConfigTypeMediumSmoothTrack = 4,
    /**
     *  The gimbal's SmoothTrack will catch up with significant yaw and pitch changes with a slow speed.
     */
    DJIGimbalUserConfigTypeSlowSmoothTrack = 5,
    /**
     *  The gimbal uses a custom configuration in memory slot 1 where the yaw and pitch speed, deadband and acceleration can be defined.
     */
    DJIGimbalUserConfigTypeCustom1 = 0,
    /**
     *  The gimbal uses a custom configuration in memory slot 2 where the yaw and pitch speed, deadband and acceleration can be defined.
     */
    DJIGimbalUserConfigTypeCustom2 = 1,
    /**
     *  The gimbal's user config type is unknown.
     */
    DJIGimbalUserConfigTypeUnknown = 0xFF,

};

//-----------------------------------------------------------------
#pragma mark DJIGimbalSmoothTrackSettings
//-----------------------------------------------------------------
/**
 *  Gimbal's SmoothTrack axis. This is only supported by the OSMO gimbal when using a Custom configuration in DJIGimbalUserConfigType.
 */
typedef NS_ENUM (uint8_t, DJIGimbalSmoothTrackAxis){
    /**
     *  The gimbal's SmoothTrack axis is yaw (also called pan for users).
     */
    DJIGimbalSmoothTrackAxisYaw,
    /**
     *  The gimbal's SmoothTrack axis is pitch (also called tilt for users).
     */
    DJIGimbalSmoothTrackAxisPitch,

};

//-----------------------------------------------------------------
#pragma mark DJIGimbalJoystick
//-----------------------------------------------------------------
/**
 *  Gimbal joystick axis. This is only supported by the OSMO gimbal when using a Custom configuration in DJIGimbalUserConfigType.
 */
typedef NS_ENUM (uint8_t, DJIGimbalJoystickAxis){
    /**
     *  The axis of gimbal's joystick direction is yaw.
     */
    DJIGimbalJoystickAxisYaw,
    /**
     *  The axis of gimbal's joystick direction is pitch.
     */
    DJIGimbalJoystickAxisPitch,

};

/*********************************************************************************/
#pragma mark - DJIGimbalConstraints
/*********************************************************************************/

/**
 *
 *  This class provides the constraints of the gimbal. These values
 *  are determined and change based on the aircraft and the type of
 *  gimbal on the aircraft.
 *
 */
@interface DJIGimbalConstraints : NSObject

/**
 *  Yes if pitch can be controlled.
 */
@property(nonatomic, readonly) BOOL isPitchAdjustable;

/**
 *  Yes if roll can be controlled.
 */
@property(nonatomic, readonly) BOOL isRollAdjustable;

/**
 *  Yes if yaw can be controlled.
 */
@property(nonatomic, readonly) BOOL isYawAdjustable;

/**
 *  Returns the maximum angle the pitch can be set to.
 */
@property(nonatomic, readonly) float pitchStopMax;

/**
 *  Returns the minimum angle the pitch can be set to.
 */
@property(nonatomic, readonly) float pitchStopMin;

/**
 *  Returns the maximum angle the roll can be set to.
 */
@property(nonatomic, readonly) float rollStopMax;

/**
 *  Returns the minimum angle the roll can be set to.
 */
@property(nonatomic, readonly) float rollStopMin;

/**
 *  Returns the maximum angle the yaw can be set to.
 */
@property(nonatomic, readonly) float yawStopMax;

/**
 *  Returns the minimum angle the yaw can be set to.
 */
@property(nonatomic, readonly) float yawStopMin;

@end

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
 *  Returns whether or not the attitude has been reset. If the gimbal is not in the
 *  original position, this value will return NO.
 */
@property(nonatomic, readonly) BOOL isAttitudeReset;

/**
 *  Returns whether or not the gimbal calibration success
 */
@property(nonatomic, readonly) BOOL isCalibrationSuccessful;

/**
 *  YES if the Gimbal is calibrating
 */
@property(nonatomic, readonly) BOOL isCalibrating;

/**
 *  Returns whether or not the gimbal's pitch value is at its maximum.
 */
@property(nonatomic, readonly) BOOL isPitchAtStop;

/**
 *  Returns whether or not the gimbal's roll value is at its maximum.
 */
@property(nonatomic, readonly) BOOL isRollAtStop;

/**
 *  Returns whether or not the gimbal's yaw value is at its maximum.
 */
@property(nonatomic, readonly) BOOL isYawAtStop;

@end

/*********************************************************************************/
#pragma mark - DJIGimbalUserConfigObject
/*********************************************************************************/

/**
 *
 *  This class provides advanced configuration of the gimbal. By changing the configuration, user can
 *  adjust the responsivity of the gimbal.
 *  Currently, the advanced configuration is only supported by OSMO.
 */
@interface DJIGimbalConfig : NSObject

/**
 *  Gimbal configuration type. There are three preset types: fast, medium and slow.
 *  When the configuration type to DJIGimbalUserConfigTypeCustom1 or DJIGimbalUserConfigTypeCustom2, user can change
 *  the configuration by calling methods related to smoothTracking.
 */
@property(nonatomic, readonly) DJIGimbalUserConfigType configType;

/**
 *  YES if gimbal SmoothTrack is enabled for the yaw axis.
 */
@property(nonatomic, readonly) BOOL isSmoothTrackYawEnabled;

/**
 *  YES if gimbal SmoothTrack is enabled for the pitch axis.
 */
@property(nonatomic, readonly) BOOL isSmoothTrackPitchEnabled;

/**
 *  SmoothTrack yaw axis speed determines how fast the gimbal will catch up with the translated yaw handle movement.
 *  Range is [0,100].
 */
@property(nonatomic, readonly) NSInteger smoothTrackYawSpeed;

/**
 *  SmoothTrack pitch axis speed determines how fast the gimbal will catch up with the translated pitch handle movement.
 *  Range is [0,100].
 */
@property(nonatomic, readonly) NSInteger smoothTrackPitchSpeed;

/**
 *   A larger SmoothTrack yaw axis deadband requires more yaw handle movement to translate into gimbal motion.
 *  Range is [0,90] degrees.
 */
@property(nonatomic, readonly) NSInteger smoothTrackYawDeadband;

/**
 *   A larger SmoothTrack pitch axis deadband requires more pitch handle movement to translate into gimbal motion.
 *  Range is [0,90] degrees.
 */
@property(nonatomic, readonly) NSInteger smoothTrackPitchDeadband;

/**
 *  SmoothTrack yaw axis acceleration determines how closely the camera will follow the translated yaw handle movement.
 *  Range is [0,30].
 */
@property(nonatomic, readonly) NSInteger smoothTrackYawAcceleration;

/**
 *  SmoothTrack pitch axis acceleration determines how closely the camera will follow the translated pitch handle movement.
 *  Range is [0,30].
 */
@property(nonatomic, readonly) NSInteger smoothTrackPitchAcceleration;

/**
 *  Joystick yaw axis smoothing controls the deceleration of the gimbal. A small value will cause the gimbal to stop abruptly.
 *  Range is [0,30].
 */
@property(nonatomic, readonly) NSInteger joystickYawSmoothing;

/**
 *  Joystick pitch axis smoothing controls the deceleration of the gimbal. A small value will cause the gimbal to stop abruptly.
 *  Range is [0,30].
 */
@property(nonatomic, readonly) NSInteger joystickPitchSmoothing;

/**
 *  Joystick yaw axis speed.
 *  Range is [0,100].
 */
@property(nonatomic, readonly) NSInteger joystickYawSpeed;

/**
 *  Joystick pitch axis speed.
 *  Range is [0,100].
 */
@property(nonatomic, readonly) NSInteger joystickPitchSpeed;

@end

/*********************************************************************************/
#pragma mark - GimbalAttitudeResultBlock
/*********************************************************************************/

/**
 *  Typedef block to be invoked when the remote attitude data is successfully changed.
 */
typedef void (^GimbalAttitudeResultBlock)(DJIGimbalAttitude attitudeInDegrees);

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
- (void)gimbalController:(DJIGimbal *)controller didUpdateGimbalState:(DJIGimbalState *)gimbalState;

/**
 *  Update the gimbal's user config data. Method only supported for OSMO.
 */
- (void)gimbalController:(DJIGimbal *)controller didUpdateGimbalConfig:(DJIGimbalConfig *)gimbalConfig;

@end

/*********************************************************************************/
#pragma mark - DJIGimbal
/*********************************************************************************/

/**
 *
 *  This class provides multiple methods to control gimbal, like set gimbal work mode, rotate gimbal with angle, start gimbal auto calibration, etc.
 */
@interface DJIGimbal : DJIBaseComponent

@property(nonatomic, weak) id<DJIGimbalDelegate> delegate;

/**
 *  Returns the latest gimbal attitude data and nil if none is available.
 */
@property(nonatomic, readonly) DJIGimbalAttitude attitudeInDegrees;

/**
 *  Sets the completion time, in seconds, to complete an action to control the gimbal. If
 *  the method rotateGimbalWithAngleMode:pitch:roll:yaw:withCompletion is used to control the gimbal's absolute
 *  angle，this property will be used to determine in what duration of time the gimbal should
 *  rotate to its new position. For example, if the value of this property is set to 2.0
 *  seconds, the gimbal will rotate to its target position in 2.0 seconds.
 *  Range is [0.1,25.5] seconds.
 *
 */
@property(nonatomic, assign) double completionTimeForControlAngleAction;

//-----------------------------------------------------------------
#pragma mark Set Gimbal Work Mode
//-----------------------------------------------------------------

/**
 *  Sets the gimbal's work mode. See enum DJIGimbalWorkMode for modes.
 *
 *  @param workMode Gimbal work mode to be set.
 *  @param block   Remote execution result error block.
 */
- (void)setGimbalWorkMode:(DJIGimbalWorkMode)workMode withCompletion:(DJICompletionBlock)block;

//-----------------------------------------------------------------
#pragma mark Gimbal Control
//-----------------------------------------------------------------

/**
 *  Gets the gimbal's constraints including which axes are adjustable, and what the axis stops are.
 *
 *  @return Gimbal's constraints. If the SDK and the aircraft have lost connection with each other, the
 *  method will return nil.
 */
- (nullable DJIGimbalConstraints *)getGimbalConstraints;

/**
 *  Rotate the gimbal's pitch, roll, and yaw in Angle Mode. The direction can either be set to clockwise or counter-clockwise.
 *
 *  For Phantom 3 Professional, Phantom 3 Advanced and Phantom 3 Standard, roll and yaw rotations are not available. For Inspire 1, Inspire Pro and M100, pitch, roll and yaw rotations are available. The range for roll rotation is [-15, 15]. For OSMO, roll rotation is not available.
 *
 *  @param pitch Gimbal's pitch rotation.
 *  @param roll Gimbal's roll rotation.
 *  @param yaw Gimbal's yaw rotation.
 *  @param block Execution result error block.
 */
- (void)rotateGimbalWithAngleMode:(DJIGimbalRotateAngleMode)angleMode pitch:(DJIGimbalAngleRotation)pitch roll:(DJIGimbalAngleRotation)roll yaw:(DJIGimbalAngleRotation)yaw withCompletion:(DJICompletionBlock)block;

/**
 *  Rotate the gimbal's pitch, roll, and yaw using speed. The direction can either be set to
 *  clockwise or counter-clockwise.
 *  For Phantom 3 Professional, Phantom 3 Advanced and Phantom 3 Standard, roll and yaw rotations are not available.
 *  For Inspire 1, Inspire Pro and M100, pitch, roll and yaw rotations are available.
 *  For OSMO, roll rotation is not available. The yaw angleVelocity of DJIGimbalSpeedRotation range is (0, 120).
 *
 *  @param pitch Gimbal's pitch rotation.
 *  @param roll Gimbal's roll rotation.
 *  @param yaw Gimbal's yaw rotation.
 *  @param block Execution result error block.
 */
- (void)rotateGimbalBySpeedWithPitch:(DJIGimbalSpeedRotation)pitch roll:(DJIGimbalSpeedRotation)roll yaw:(DJIGimbalSpeedRotation)yaw withCompletion:(DJICompletionBlock)block;

/**
 *  Resets the gimbal. The gimbal's pitch, roll, and yaw will be set to the origin, which is
 *  the standard position for the gimbal.
 *
 *  @param block Remote execution result error block.
 */
- (void)resetGimbalWithCompletion:(DJICompletionBlock)block;

//-----------------------------------------------------------------
#pragma mark Gimbal Calibration
//-----------------------------------------------------------------
/**
 *  Starts calibrating the gimbal.
 *
 *  @param block Remote execution result error block.
 */
- (void)startGimbalAutoCalibrationWithCompletion:(DJICompletionBlock)block;

/**
 *  The gimbal roll can be fine tuned with a custom offset. The range for the custom offset is
 *  [-10, 10] degrees. If the offset is negative, the gimbal will be fine tuned the specified
 *  number of degrees in the counterclockwise direction.
 *
 *  @param offset   Fine-tune offset in degrees to be tuned.
 *  @param block    Completion block.
 */
- (void)fineTuneGimbalRollInDegrees:(float)offset withCompletion:(DJICompletionBlock)block;

//-----------------------------------------------------------------
#pragma mark Gimbal User Config
//-----------------------------------------------------------------

/**
 *   YES if gimbal supports a user config (OSMO only).
 */
- (BOOL)isUserConfigSupported;

/**
 *  Sets gimbal user config type.
 *
 *  @param userConfigType Gimbal User Configure type.
 *  @param block Set Gimbal User Config result block.
 *
 */
- (void)setGimbalUserConfigType:(DJIGimbalUserConfigType)userConfigType withCompletion:(DJICompletionBlock)block;

/**
 *  Gets gimbal user config type.
 *
 *  @param block Get Gimbal User Config result block.
 *
 */
- (void)getGimbalUserConfigTypeWithCompletion:(void (^)(DJIGimbalUserConfigType userConfigType, BOOL success))block;
;

/**
 *  Enables a gimbal SmoothTrack axis.
 *
 *  @param axis Gimbal axis.
 *  @param enabled YES if SmoothTrack is to be enabled on axis.
 *  @param block set if Gimbal SmoothTrack Adjustment is available to be customized in the specific direction result block.
 *
 */
- (void)setGimbalSmoothTrackAxisEnabledOnAxis:(DJIGimbalSmoothTrackAxis)axis isEnabled:(BOOL)enabled withCompletion:(DJICompletionBlock)block;

/**
 *  Gets whether an axis has SmoothTrack enabled.
 *
 *  @param axis Gimbal axis.
 *  @param block get if Gimbal SmoothTrack Adjustment is available to be customized in the specific direction result block.
 */
- (void)getGimbalSmoothTrackAxisEnabledOnAxis:(DJIGimbalSmoothTrackAxis)axis withCompletion:(void (^)(BOOL isEnabled, BOOL success))block;

/**
 *  Sets gimbal SmoothTrack catch up speed on an axis. SmoothTrack speed determines how fast the gimbal will catch up with a large, translated handle movement and has a range [0,100].
 *
 *  @param axis Gimbal axis.
 *  @param speed SmoothTrack speed [0,100].
 *  @param block set Gimbal SmoothTrack Adjustment speed in specific direction result block.
 */
- (void)setGimbalSmoothTrackSpeedOnAxis:(DJIGimbalSmoothTrackAxis)axis speed:(NSInteger)speed withCompletion:(DJICompletionBlock)block;

/**
 *  Gets gimbal SmoothTrack speed on an axis. SmoothTrack speed determines how fast the gimbal will catch up with a large, translated handle movement and will have a range [0,100].
 *
 *  @param axis Gimbal axis.
 *  @param block get Gimbal SmoothTrack Adjustment speed in specific direction result block.
 */
- (void)getGimbalSmoothTrackSpeedOnAxis:(DJIGimbalSmoothTrackAxis)axis withCompletion:(void (^)(NSInteger speed, BOOL success))block;

/**
 *  Sets SmoothTrack deadband on an axis. A larger deadband requires more handle movement to translate into gimbal motion. Deadband has a range of [0,90] degrees.
 *
 *  @param axis Gimbal axis.
 *  @param deadband SmoothTrack deadband [0,90].
 *  @param block set Gimbal SmoothTrack Adjustment deadband in specific direction result block.
 */

- (void)setGimbalSmoothTrackDeadbandOnAxis:(DJIGimbalSmoothTrackAxis)axis deadband:(NSInteger)deadband withCompletion:(DJICompletionBlock)block;

/**
 *  Gets SmoothTrack deadband on an axis. A larger deadband requires more handle movement to translate into gimbal motion. Deadband has a range of [0,90] degrees.
 *
 *  @param axis Gimbal axis.
 *  @param block get Gimbal SmoothTrack Adjustment deadband in specific direction result block.
 */

- (void)getGimbalSmoothTrackDeadbandOnAxis:(DJIGimbalSmoothTrackAxis)axis withCompletion:(void (^)(NSInteger deadband, BOOL success))block;

/**
 *  Sets SmoothTrack acceleration on an axis. Acceleration determines how closely the camera will follow the translated yaw handle movement and has a range of [0,30].
 *
 *  @param axis Gimbal axis.
 *  @param acceleration SmoothTrack acceleration [0,30].
 *  @param block set Gimbal SmoothTrack Adjustment acceleration in specific direction result block.
 */

- (void)setGimbalSmoothTrackAccelerationOnAxis:(DJIGimbalSmoothTrackAxis)axis acceleration:(NSInteger)acceleration withCompletion:(DJICompletionBlock)block;

/**
 *  Gets SmoothTrack acceleration on an axis. Acceleration determines how closely the camera will follow the translated yaw handle movement and has a range of [0,30].
 *
 *  @param axis Gimbal axis.
 *  @param block get Gimbal SmoothTrack Adjustment acceleration in specific direction result block.
 */

- (void)getGimbalSmoothTrackAccelerationOnAxis:(DJIGimbalSmoothTrackAxis)axis withCompletion:(void (^)(NSInteger acceleration, BOOL success))block;

/**
 *  Sets joystick smoothing on an axis. Joystick smoothing controls the deceleration of the gimbal. A small value will cause the gimbal to stop abruptly. Smoothing has a range of [0,30].
 *
 *
 *  @param axis Gimbal axis.
 *  @param smoothing Joystick Smoothing [0,30].
 *  @param block set Gimbal Joystick Smoothing in specific direction result block.
 */

- (void)setGimbalJoystickSmoothingOnAxis:(DJIGimbalJoystickAxis)axis smoothing:(NSInteger)smoothing withCompletion:(DJICompletionBlock)block;

/**
 *  Gets joystick smoothing on an axis. Joystick smoothing controls the deceleration of the gimbal. A small value will cause the gimbal to stop abruptly. Smoothing has a range of [0,30].
 *
 *  @param axis Gimbal Joystick Direction.
 *  @param block get Gimbal Joystick Smoothing in specific direction result block.
 */

- (void)getGimbalJoystickSmoothingOnAxis:(DJIGimbalJoystickAxis)axis withCompletion:(void (^)(NSInteger smoothing, BOOL success))block;

/**
 *  Sets joystick speed on an axis. Speed has a range of [0,100].
 *
 *  @param axis Gimbal axis.
 *  @param speed Joystick speed [0,100].
 *  @param block set Gimbal Joystick Speed in specific direction result block.
 */

- (void)setGimbalJoystickSpeedOnAxis:(DJIGimbalJoystickAxis)axis speed:(NSInteger)speed withCompletion:(DJICompletionBlock)block;

/**
 *  Gets joystick speed on an axis. Speed has a range of [0,100].
 *
 *  @param axis Gimbal Joystick Direction.
 *  @param block get Gimbal Joystick Speed in specific direction result block.
 */

- (void)getGimbalJoystickSpeedOnAxis:(DJIGimbalJoystickAxis)axis withCompletion:(void (^)(NSInteger speed, BOOL success))block;

@end
NS_ASSUME_NONNULL_END
