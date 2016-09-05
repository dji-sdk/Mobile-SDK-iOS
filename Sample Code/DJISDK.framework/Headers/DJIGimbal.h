//
//  DJIGimbal.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIBaseComponent.h>
#import <DJISDK/DJIGimbalBaseTypes.h>
#import <DJISDK/DJIGimbalState.h>
#import <DJISDK/DJIGimbalAdvancedSettingsState.h>

@class DJIGimbal;

NS_ASSUME_NONNULL_BEGIN

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
 *  This class provides multiple methods to control the gimbal. These include
 *  setting the gimbal work mode, rotating the gimbal with angle, starting the
 *  gimbal auto calibration, etc.
 */
@interface DJIGimbal : DJIBaseComponent

/**
 *  Returns the delegate of DJIGimbal.
 */
@property(nonatomic, weak) id<DJIGimbalDelegate> delegate;

/**
 *  Returns the latest gimbal attitude data, or nil if none is available.
 *
 *  @deprecated Duplicated with the one in `DJIGimbalState`.
 */
@property(nonatomic, readonly) DJIGimbalAttitude attitudeInDegrees DEPRECATED_ATTRIBUTE;

/**
 *  Sets the completion time, in seconds, to complete an action to control the gimbal.
 *  If the method `rotateGimbalWithAngleMode:pitch:roll:yaw:withCompletion` is used
 *  to control the gimbal's absolute angle，this property will be used to determine
 *  in what duration of time the gimbal should rotate to its new position. For
 *  example, if the value of this property is set to 2.0 seconds, the gimbal will
 *  rotate to its target position in 2.0 seconds.
 *  Range is [0.1, 25.5] seconds.
 */
@property(nonatomic, assign) double completionTimeForControlAngleAction;

/**
 *  Returns the gimbal's features and possible range of settings.
 *  Each dictionary key is a possible gimbal feature and uses the DJIGimbalParam prefix.
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
- (void)setGimbalWorkMode:(DJIGimbalWorkMode)workMode
           withCompletion:(DJICompletionBlock)block;

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
- (void)rotateGimbalWithAngleMode:(DJIGimbalRotateAngleMode)angleMode
                            pitch:(DJIGimbalAngleRotation)pitch
                             roll:(DJIGimbalAngleRotation)roll
                              yaw:(DJIGimbalAngleRotation)yaw
                   withCompletion:(DJICompletionBlock)block;

/**
 *  Rotate the gimbal's pitch, roll, and yaw using speed. The direction can
 *  either be set to clockwise or counter-clockwise.
 *  See `gimbalCapability` for which axes can be moved for the gimbal being used.
 *
 *  @param pitch Gimbal's pitch rotation.
 *  @param roll Gimbal's roll rotation.
 *  @param yaw Gimbal's yaw rotation.
 *  @param block Execution result error block.
 */
- (void)rotateGimbalBySpeedWithPitch:(DJIGimbalSpeedRotation)pitch
                                roll:(DJIGimbalSpeedRotation)roll
                                 yaw:(DJIGimbalSpeedRotation)yaw
                      withCompletion:(DJICompletionBlock)block;

/**
 *  Resets the gimbal. The behaviours are product-dependent.
 *  Osmo series (e.g. Osmo, Osmo Pro): 
 *  The gimbal's pitch and yaw will be set to the origin, which is the standard
 *  position for the gimbal.
 *  Phantom series (e.g. Phantom 3 Professional, Phantom 4):
 *  The first call sets gimbal to point down vertically to the earth. The second
 *  call sets gimbal to the standard position.
 *  Other products (e.g. Inspire 1): 
 *  Only the gimbal's pitch will the set to the origin.
 *
 *  @param block Remote execution result error block.
 */
- (void)resetGimbalWithCompletion:(DJICompletionBlock)block;

/*********************************************************************************/
#pragma mark Gimbal Calibration
/*********************************************************************************/

/**
 *  Starts calibrating the gimbal. The product should be stationary (not flying,
 *  or being held) and horizontal during calibration.
 *  For gimbal's with adjustable payloads, the payload should be present and
 *  balanced before doing a calibration.
 *
 *  @param block Remote execution result error block.
 */
- (void)startGimbalAutoCalibrationWithCompletion:(DJICompletionBlock)block;

/**
 *  The gimbal roll can be fine tuned with a custom offset. The range for the
 *  custom offset is [-2.0, 2.0] degrees. If the offset is negative, the gimbal
 *  will be fine tuned the specified number of degrees in the counterclockwise
 *  direction.
 *
 *  @param offset   Fine-tuned offset, in degrees, to be tuned.
 *  @param block    Completion block.
 */
- (void)fineTuneGimbalRollInDegrees:(float)offset withCompletion:(DJICompletionBlock)block;

/**
 *  Starts testing the balance of the gimbal payload.
 *  For gimbals that allow payloads to be changed, a balance test should be
 *  performed to ensure the camera is mounted correctly. The product should be
 *  stationary (not flying, or being held) and horizontal during testing. See
 *  `DJIGimbalState` for the test result.
 *  Only supported by Ronin-MX.
 *
 *  @param block    Completion block that receives the execution result. The
 *                  completion block will return when the balance test is
 *                  successfully started.
 */
- (void)startGimbalBalanceTestWithCompletion:(DJICompletionBlock)block;

/*********************************************************************************/
#pragma mark - Gimbal Advanced Setting
/*********************************************************************************/

/**
 *  Sets the advanced settings profile. The advanced settings profile has
 *  options for both preset and custom profiles for SmoothTrack and Controller
 *  settings. Settings for SmoothTrack and Controller can only be set manually
 *  when using a custom profile.
 *  Use `DJIGimbalParamAdvancedSettingsProfile` in `gimbalCapability` to check if
 *  it is supported by the gimbal.
 *  Only supported by Osmo.
 *
 *  @param profile Profile to set.
 *  @param block Completion block that receives the execution result.
 */
- (void)setAdvancedSettingsProfile:(DJIGimbalAdvancedSettingsProfile)profile
                    withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the advanced settings profile.
 *  Use `DJIGimbalParamAdvancedSettingsProfile` to check if it is supported by
 *  the gimbal.
 *  Only supported by Osmo.
 *
 *  @param block Completion block that receives the execution result.
 */
- (void)getAdvancedSettingsProfileWithCompletion:(void (^_Nonnull)(DJIGimbalAdvancedSettingsProfile profile,
                                                                   NSError *_Nullable error))block;

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
 *  Extends the pitch range of gimbal. Currently, it is only supported by
 *  Phantom 3 Series and Phantom 4. If extended, the gimbal's pitch control
 *  range can be [-30, 90], otherwise, it's [0, 90].
 *  Use `DJIGimbalParamPitchRangeExtension` to check if it is supported by the
 *  gimbal.
 *
 *  @param shouldExtend Whether the pitch range should be extended
 *  @param block The completion block that receives execution result.
 */
- (void)setPitchRangeExtensionEnabled:(BOOL)shouldExtend
                       withCompletion:(DJICompletionBlock)block;

/**
 *  Get the extend gimbal pitch range state.
 *  Use `DJIGimbalParamPitchRangeExtension` to check if it is supported by the gimbal.
 *
 *  @param shouldExtend Whether the pitch range should be extended
 *  @param block        The completion block that receives execution result.
 */
- (void)getPitchRangeExtensionEnabledWithCompletion:(void (^_Nonnull)(BOOL isExtended,
                                                                      NSError *_Nullable error))block;

/*********************************************************************************/
#pragma mark Gimbal Motor Control Configuration
/*********************************************************************************/

/**
 *  Configures gimbal's motor control with a preset configuration applicable for
 *  most popular cameras.
 *  In order to the optimize the performance, motor control tuning is still required.
 *
 *  @param preset   The preset configuration to set.
 *  @param block    The completion block that receives execution result.
 */
- (void)configureMotorControlWithPreset:(DJIGimbalMotorControlPreset)preset
                         withCompletion:(DJICompletionBlock)block;

/**
 *  Sets the coefficient of speed error control. It can be seen as the
 *  coefficient for the proportional term in the PID controller.
 *  Use `DJIGimbalParamMotorControlStiffnessPitch`,
 *  `DJIGimbalParamMotorControlStiffnessYaw` and
 *  `DJIGimbalParamMotorControlStiffnessRoll` with `gimbalCapability` to check if
 *  the gimbal supports this feature and the range of possible values (unitless).
 *  Only supported by Ronin-MX.
 *
 *   @param stiffness   The stiffness value to set.
 *   @param axis        The axis that the setting is applied to.
 *   @param block       The completion block that receives execution result.
 */
- (void)setMotorControlStiffness:(NSInteger)stiffness
                          onAxis:(DJIGimbalAxis)axis
                  withCompletion:(DJICompletionBlock)block;
/**
 *  Gets the coefficient of speed error control. It can be seen as the
 *  coefficient for the proportional term in the PID controller.
 *  Use `DJIGimbalParamMotorControlStiffnessPitch`,
 *  `DJIGimbalParamMotorControlStiffnessYaw` and
 *  `DJIGimbalParamMotorControlStiffnessRoll` with `gimbalCapability` to check if
 *  the gimbal supports this feature and the range of possible values (unitless).
 *  Only supported by Ronin-MX.
 *
 *  @param axis     The axis to query.
 *  @param block    The completion block that receives execution result.
 */
- (void)getMotorControlStiffnessOnAxis:(DJIGimbalAxis)axis
                        withCompletion:(void (^_Nonnull)(NSInteger stiffness,
                                                         NSError *_Nullable error))block;

/**
 *  Sets the coefficient of attitude accuracy control. It can be seen as the
 *  coefficient for the integral term in the PID controller.
 *  Use `DJIGimbalParamMotorControlStrengthPitch`,
 *  `DJIGimbalParamMotorControlStrengthYaw` and
 *  `DJIGimbalParamMotorControlStrengthRoll` with `gimbalCapability` to check if
 *  the gimbal supports this feature and the range of possible values (unitless).
 *  Only supported by Ronin-MX.
 *
 *   @param strength    The strength value to set.
 *   @param axis        The axis that the setting is applied to.
 *   @param block       The completion block that receives execution result.
 */
- (void)setMotorControlStrength:(NSInteger)strength
                         onAxis:(DJIGimbalAxis)axis
                 withCompletion:(DJICompletionBlock)block;
/**
 *  Gets the coefficient of attitude accuracy control. It can be seen as the
 *  coefficient for the integral term in the PID controller.
 *  Use `DJIGimbalParamMotorControlStrengthPitch`,
 *  `DJIGimbalParamMotorControlStrengthYaw` and
 *  `DJIGimbalParamMotorControlStrengthRoll` with `gimbalCapability` to check if
 *  the gimbal supports this feature and the range of possible values (unitless).
 *  Only supported by Ronin-MX.
 *
 *  @param axis     The axis to query.
 *  @param block    The completion block that receives execution result.
 */
- (void)getMotorControlStrengthOnAxis:(DJIGimbalAxis)axis
                       withCompletion:(void (^_Nonnull)(NSInteger strength,
                                                        NSError *_Nullable error))block;

/**
 *  Sets the coefficient of denoising the output.
 *  Use `DJIGimbalParamMotorControlGyroFilteringPitch`,
 *  `DJIGimbalParamMotorControlGyroFilteringYaw` and
 *  `DJIGimbalParamMotorControlGyroFilteringRoll` with `gimbalCapability` to check
 *  if the gimbal supports this feature and the range of possible values (unitless).
 *  Only supported by Ronin-MX.
 *
 *   @param filtering   The gyro filtering value to set.
 *   @param axis        The axis that the setting is applied to.
 *   @param block       The completion block that receives execution result.
 */
- (void)setMotorControlGyroFiltering:(NSInteger)filtering
                              onAxis:(DJIGimbalAxis)axis
                      withCompletion:(DJICompletionBlock)block;
/**
 *  Gets the coefficient of denoising the output.
 *  Use `DJIGimbalParamMotorControlGyroFilteringPitch`,
 *  `DJIGimbalParamMotorControlGyroFilteringYaw` and
 *  `DJIGimbalParamMotorControlGyroFilteringRoll` with `gimbalCapability` to check
 *  if the gimbal supports this feature and the range of possible values (unitless).
 *  Only supported by Ronin-MX.
 *
 *  @param axis     The axis to query.
 *  @param block    The completion block that receives execution result.
 */
- (void)getMotorControlGyroFilteringOnAxis:(DJIGimbalAxis)axis
                            withCompletion:(void (^_Nonnull)(NSInteger filtering,
                                                             NSError *_Nullable error))block;

/**
 *  Sets the value for pre-adjust. It can be seen as the coefficient for the
 *  derivative term in the PID controller. Only supported by Ronin-MX.
 *  Use `DJIGimbalParamMotorControlPrecontrolPitch`,
 *  `DJIGimbalParamMotorControlPrecontrolYaw` and
 *  `DJIGimbalParamMotorControlPrecontrolRoll` with `gimbalCapability` to check if
 *  the gimbal supports this feature and the range of possible values (unitless).
 *
 *   @param precontrol  The Precontrol value to set.
 *   @param axis        The axis that the setting is applied to.
 *   @param block       The completion block that receives execution result.
 */
- (void)setMotorControlPrecontrol:(NSInteger)precontrol
                           onAxis:(DJIGimbalAxis)axis
                   withCompletion:(DJICompletionBlock)block;
/**
 *  Gets the value for pre-adjust. It can be seen as the coefficient for the
 *  derivative term in the PID controller. Only supported by Ronin-MX.
 *  Use `DJIGimbalParamMotorControlPrecontrolPitch`,
 *  `DJIGimbalParamMotorControlPrecontrolYaw` and
 *  `DJIGimbalParamMotorControlPrecontrolRoll` with `gimbalCapability` to check if
 *  the gimbal supports this feature and the range of possible values (unitless).
 *
 *  @param axis     The axis to query.
 *  @param block    The completion block that receives execution result.
 */
- (void)getMotorControlPrecontrolOnAxis:(DJIGimbalAxis)axis
                         withCompletion:(void (^_Nonnull)(NSInteger precontrol,
                                                          NSError *_Nullable error))block;

/*********************************************************************************/
#pragma mark Gimbal Controller Setting
/*********************************************************************************/

/**
 *  Sets physical controller (e.g. the joystick on Osmo or the remote controller
 *  of the aircraft) deadband on an axis. A larger deadband requires more
 *  controller movement to start gimbal motion.
 *  Use `DJIGimbalParamControllerDeadbandYaw` and
 *  `DJIGimbalParamControllerDeadbandPitch` with `gimbalCapability` to check if
 *  the gimbal supports this feature and the range of possible values (unitless).
 *
 *  @param deadband The deadband value to be set.
 *  @param axis     The axis that the setting will be applied to.
 *  @param block    The completion block that receives execution result.
 */
- (void)setControllerDeadband:(NSInteger)deadband
                       onAxis:(DJIGimbalAxis)axis
               withCompletion:(DJICompletionBlock)block;
/**
 *  Gets physical controller deadband value on an axis. A larger deadband
 *  requires more controller movement to start gimbal motion.
 *  Use `DJIGimbalParamControllerDeadbandYaw` and
 *  `DJIGimbalParamControllerDeadbandPitch` with `gimbalCapability` to check if
 *  the gimbal supports this feature and the range of possible values (unitless).
 *
 *  @param axis     The axis to query.
 *  @param block    The completion block that receives execution result.
 */
- (void)getControllerDeadbandOnAxis:(DJIGimbalAxis)axis
                     withCompletion:(void (^_Nonnull)(NSInteger deadband,
                                                      NSError *_Nullable error))block;

/**
 *  Sets physical controller (e.g. the joystick on Osmo or the remote controller
 *  of the aircraft) speed on an axis. Speed setting controls the mapping
 *  between the movement of the controller and the gimbal speed.
 *  Use `DJIGimbalParamControllerSpeedYaw` and `DJIGimbalParamControllerSpeedPitch`
 *  with `gimbalCapability` to check if the gimbal supports this feature and the
 *  range of possible values (unitless).
 *
 *  @param speed    The speed value to be set.
 *  @param axis     The axis that the setting will be applied to.
 *  @param block    The completion block that receives execution result.
 */
- (void)setControllerSpeed:(NSInteger)speed
                    onAxis:(DJIGimbalAxis)axis
            withCompletion:(DJICompletionBlock)block;
/**
 *  Gets physical controller speed value on an axis. Speed setting controls the
 *  mapping between the movement of the controller and the gimbal speed.
 *  Use `DJIGimbalParamControllerSpeedYaw` and `DJIGimbalParamControllerSpeedPitch`
 *  with `gimbalCapability` to check if the gimbal supports this feature and the
 *  range of possible values (unitless).

 *  @param axis     The axis to query.
 *  @param block    The completion block that receives execution result.
 */
- (void)getControllerSpeedOnAxis:(DJIGimbalAxis)axis
                  withCompletion:(void (^_Nonnull)(NSInteger speed,
                                                   NSError *_Nullable error))block;

/**
 *  Sets physical controller (e.g. the joystick on Osmo or the remote controller
 *  of the aircraft) smoothing on an axis. Smoothing controls the deceleration of
 *  the gimbal.
 *  Use `DJIGimbalParamControllerSmoothingYaw` and
 *  `DJIGimbalParamControllerSmoothingPitch` with `gimbalCapability` to check if
 *  the gimbal supports this feature and the range of possible values (unitless).
 *
 *  @param smoothing    The smoothing value to be set.
 *  @param axis         The axis that the setting will be applied to.
 *  @param block        The completion block that receives execution result.
 */
- (void)setControllerSmoothing:(NSInteger)smoothing
                        onAxis:(DJIGimbalAxis)axis
                withCompletion:(DJICompletionBlock)block;
/**
 *  Gets physical controller smoothing value on an axis. Smoothing controls the
 *  deceleration of the gimbal.
 *  Use `DJIGimbalParamControllerSmoothingYaw` and
 *  `DJIGimbalParamControllerSmoothingPitch` with `gimbalCapability` to check if
 *  the gimbal supports this feature and the range of possible values (unitless).
 *
 *  @param axis     The axis to query.
 *  @param block    The completion block that receives execution result.
 */
- (void)getControllerSmoothingOnAxis:(DJIGimbalAxis)axis
                      withCompletion:(void (^_Nonnull)(NSInteger smoothing,
                                                       NSError *_Nullable error))block;
/*********************************************************************************/
#pragma mark Gimbal Smooth Track Setting
/*********************************************************************************/

/**
 *  Enables SmoothTrack for the axis. Only supported by Osmo. Ronin-MX supports
 *  SmoothTrack but it is always enabled for both pitch axis and yaw axis.
 *  Use `DJIGimbalParamSmoothTrackEnabledPitch` and
 *  `DJIGimbalParamSmoothTrackEnabledYaw` with `gimbalCapability` to check if
 *  the gimbal supports this feature.
 *
 *  @param enabled  `YES` to enable SmoothTrack on the axis.
 *  @param axis     The axis that the setting will be applied to.
 *  @param block    The completion block that receives execution result.
 */
- (void)setSmoothTrackEnabled:(BOOL)enabled
                       onAxis:(DJIGimbalAxis)axis
               withCompletion:(DJICompletionBlock)block;

/**
 *  Gets whether an axis has SmoothTrack enabled. Only supported by Osmo.
 *  Ronin-MX supports SmoothTrack but it is always enabled for both pitch axis
 *  and yaw axis.
 *  Use `DJIGimbalParamSmoothTrackEnabledPitch` and
 *  `DJIGimbalParamSmoothTrackEnabledYaw` with `gimbalCapability` to check if the
 *  gimbal supports this feature.
 *
 *  @param axis     The axis to query.
 *  @param block    The completion block that receives execution result.
 */
- (void)getSmoothTrackEnabledOnAxis:(DJIGimbalAxis)axis
                     withCompletion:(void (^_Nonnull)(BOOL isEnabled,
                                                      NSError *_Nullable error))block;

/**
 *  Sets gimbal SmoothTrack catch up speed on an axis. SmoothTrack speed
 *  determines how fast the gimbal will catch up with a large, translated handle
 *  movement.
 *  Use `DJIGimbalParamSmoothTrackSpeedPitch` and `DJIGimbalParamSmoothTrackSpeedYaw`
 *  with `gimbalCapability` to check if the gimbal supports this feature and the
 *  range of possible values (unitless).
 *
 *  @param speed    SmoothTrack speed [0,100].
 *  @param axis     The axis that the setting will be applied to.
 *  @param block    The completion block that receives execution result.
 */
- (void)setSmoothTrackSpeed:(NSInteger)speed
                     onAxis:(DJIGimbalAxis)axis
             withCompletion:(DJICompletionBlock)block;

/**
 *  Gets gimbal SmoothTrack speed on an axis. SmoothTrack speed determines how
 *  fast the gimbal will catch up with a large, translated handle movement.
 *  Use `DJIGimbalParamSmoothTrackSpeedPitch` and `DJIGimbalParamSmoothTrackSpeedYaw`
 *  with `gimbalCapability` to check if the gimbal supports this feature and the
 *  range of possible values (unitless).
 *
 *  @param axis     The axis to query.
 *  @param block    The completion block that receives execution result.
 */
- (void)getSmoothTrackSpeedOnAxis:(DJIGimbalAxis)axis
                   withCompletion:(void (^_Nonnull)(NSInteger speed,
                                                    NSError *_Nullable error))block;

/**
 *  Sets SmoothTrack deadband on an axis. A larger deadband requires more handle
 *  movement to translate into gimbal motion.
 *  Use `DJIGimbalParamSmoothTrackDeadbandPitch` and
 *  `DJIGimbalParamSmoothTrackDeadbandYaw` with `gimbalCapability` to check if
 *  the gimbal supports this feature and the range of possible values in degrees.
 *
 *  @param deadband SmoothTrack deadband [0,90].
 *  @param axis     The axis that the setting will be applied to.
 *  @param block    The completion block that receives execution result.
 */

- (void)setSmoothTrackDeadband:(NSInteger)deadband
                        onAxis:(DJIGimbalAxis)axis
                withCompletion:(DJICompletionBlock)block;

/**
 *  Gets SmoothTrack deadband on an axis. A larger deadband requires more handle
 *  movement to translate into gimbal motion.
 *  Use `DJIGimbalParamSmoothTrackDeadbandPitch` and
 *  `DJIGimbalParamSmoothTrackDeadbandYaw` with `gimbalCapability` to check if
 *  the gimbal supports this feature and the range of possible values in degrees.
 *
 *  @param axis     The axis to query.
 *  @param block    The completion block that receives execution result.
 */

- (void)getSmoothTrackDeadbandOnAxis:(DJIGimbalAxis)axis
                      withCompletion:(void (^_Nonnull)(NSInteger deadband,
                                                       NSError *_Nullable error))block;

/**
 *  Sets SmoothTrack acceleration on an axis. Acceleration determines how
 *  closely the camera will follow the translated yaw handle movement.
 *  Use `DJIGimbalParamSmoothTrackAccelerationPitch` and
 *  `DJIGimbalParamSmoothTrackAccelerationYaw` with `gimbalCapability` to check if
 *  the gimbal supports this feature and the range of possible values (unitless).
 *
 *  @param acceleration SmoothTrack acceleration [0,30].
 *  @param axis         The axis that the setting will be applied to.
 *  @param block        The completion block that receives execution result.
 */

- (void)setSmoothTrackAcceleration:(NSInteger)acceleration
                            onAxis:(DJIGimbalAxis)axis
                    withCompletion:(DJICompletionBlock)block;

/**
 *  Gets SmoothTrack acceleration on an axis. Acceleration determines how
 *  closely the camera will follow the translated yaw handle movement.
 *  Use `DJIGimbalParamSmoothTrackAccelerationPitch` and
 *  `DJIGimbalParamSmoothTrackAccelerationYaw` with `gimbalCapability` to check if
 *  the gimbal supports this feature and the range of possible values (unitless).
 *
 *  @param axis     The axis to query.
 *  @param block    The completion block that receives execution result.
 */
- (void)getSmoothTrackAccelerationOnAxis:(DJIGimbalAxis)axis
                          withCompletion:(void (^_Nonnull)(NSInteger acceleration,
                                                           NSError *_Nullable error))block;

/*********************************************************************************/
#pragma mark Gimbal Endpoint Setting
/*********************************************************************************/

/**
 *  Endpoint settings determine the farthest points to which the gimbal will
 *  rotate during manual controller input.
 *  Only supported by Ronin-MX.
 *  Use `DJIGimbalParamEndpointPitchUp`, `DJIGimbalParamEndpointPitchDown`,
 *  `DJIGimbalParamEndpointYawLeft` and `DJIGimbalParamEndpointYawRight` in
 *  `gimbalCapability` to check if the gimbal supports this feature and what the
 *  valid range of enpoints are.
 *
 *  @param endpoint     The endpoint value to set.
 *  @param direction    The endpoint direction.
 *  @param block        The completion block that receives execution result.
 */
- (void)setEndpoint:(NSInteger)endpoint
        inDirection:(DJIGimbalEndpointDirection)direction
     withCompletion:(DJICompletionBlock)block;
/**
 *  Gets the farthest points to which the gimbal will rotate during manual
 *  controller input.
 *  Only supported by Ronin-MX.
 *  Use `DJIGimbalParamEndpointPitchUp`, `DJIGimbalParamEndpointPitchDown`,
 *  `DJIGimbalParamEndpointYawLeft` and `DJIGimbalParamEndpointYawRight` with
 *  `gimbalCapability` to check if the gimbal supports this feature.
 *
 *  @param direction    The endpoint direction.
 *  @param block        The completion block that receives execution result.
 */- (void)getEndpointInDirection:(DJIGimbalEndpointDirection)direction
                   withCompletion:(void (^_Nonnull)(NSInteger endpoint,
                                                    NSError *_Nullable error))block;

/*********************************************************************************/
#pragma mark Others
/*********************************************************************************/

/**
 *  Allows the camera to be mounted in the upright position (on top of the
 *  aircraft instead of underneath).
 *  Only supported by Ronin-MX.
 *
 *  @param enabled  `YES` to allow the camera to be upright.
 *  @param block    The completion block that receives execution result.
 */
- (void)setCameraUprightEnabled:(BOOL)enabled
                 withCompletion:(DJICompletionBlock)block;
/**
 *  Gets if the camera is allowed to be in the upright position.
 *  Only supported by Ronin-MX.
 *
 *  @param block    The completion block that receives execution result.
 */
- (void)getCameraUprightEnabledWithCompletion:(void (^_Nonnull)(BOOL enabled,
                                                                NSError *_Nullable error))block;

/**
 *  Turns on and off the gimbal motors. `NO` means the gimbal power remains on,
 *  however the motors will not work.
 *  Only supported by Ronin-MX.
 *
 *  @param enabled  `YES` to enable the motor.
 *  @param block    The completion block that receives execution result.
 */
- (void)setMotorEnabled:(BOOL)enabled withCompletion:(DJICompletionBlock)block;
/**
 *  Gets if the gimbal motors are enabled to work or not.
 *  Only supported by Ronin-MX.
 *
 *  @param block    The completion block that receives execution result.
 */
- (void)getMotorEnabledWithCompletion:(void (^_Nonnull)(BOOL enabled,
                                                        NSError *_Nullable error))block;

/**
 *  Resets gimbal position to selfie setup. If the gimbal yaw is not at 180
 *  degrees, then calling this method will rotate the gimbal yaw to 180 degrees
 *  (effectively pointing the camera to the person holding the gimbal). If the
 *  gimbal yaw is at 180 degrees, then the gimbal will rotate in yaw to 0 degrees.
 *  Only supported by Osmo.
 *
 *  @param block    The completion block that receives execution result.
 */
- (void)toggleGimbalSelfieWithCompletion:(DJICompletionBlock)block;

/**
 *  Sets the gimbal's controller mode.
 *  The control mode for the gimbal controller (joystick for Osmo). The total
 *  controller deflection is a combination of horizontal and vertical deflection.
 *  This translates to gimbal movement around the yaw and pitch axes.
 *  The gimbal can be set to either move in both yaw and pitch simultaneously
 *  based on horizontal and vertical deflection of the controller, or move in
 *  only yaw or pitch exclusively based on whether horizontal or vertical
 *  deflection is larger.
 *  Only supported by Osmo.
 *
 *  @param controlMode  The stick control mode to set.
 *  @param block        The completion block that receives execution result.
 */
- (void)setGimbalControllerMode:(DJIGimbalControllerMode)controlMode
                 withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the gimbal's controller mode.
 *  Only supported by Osmo.
 *
 *  @param block    The completion block that receives execution result.
 */
- (void)getGimbalControllerModeWithCompletion:(void (^_Nonnull)(DJIGimbalControllerMode controlMode,
                                                                NSError *_Nullable error))block;

/**
 *  Inverts the physical control for gimbal movement on an axis.
 *  It is only supported by Osmo Mobile. The setting can only be applied to the
 *  pitch or yaw axis.
 *
 *  @param enabled  `YES` to enable inverted control.
 *  @param axis     The axis that the setting will be applied to.
 *  @param block    The completion block that receives execution result.
 */
- (void)setInvertControlEnabled:(BOOL)enabled
                         onAxis:(DJIGimbalAxis)axis
                 withCompletion:(DJICompletionBlock)block;

/**
 *  Gets if the physical control is inverted for gimbal movement on an axis.
 *  It is only supported by Osmo Mobile. The setting can only be applied to the
 *  pitch or yaw axis.
 *
 *  @param axis     The axis to query.
 *  @param block    The completion block that receives execution result.
 */
-(void)getInvertControlEnabledOnAxis:(DJIGimbalAxis)axis
                      withCompletion:(void (^_Nonnull)(BOOL enabled,
                                                       NSError *_Nullable error))block;

@end

NS_ASSUME_NONNULL_END
