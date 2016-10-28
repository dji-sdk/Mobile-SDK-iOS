//
//  DJIGimbalAdvancedSettingsState.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIGimbalBaseTypes.h"

/**
 *  The current advanced settings of the gimbal. These include settings for
 *  SmoothTrack and the Controller.
 *  Only supported by Osmo.
 */
@interface DJIGimbalAdvancedSettingsState : NSObject

/**
 *  Advanced settings profile. `DJIGimbalAdvancedSettingsProfileFast`,
 *  `DJIGimbalAdvancedSettingsProfileMedium` and `DJIGimbalAdvancedSettingsProfileSlow`
 *  are preset profiles. In these profiles, SmoothTrack and Controller settings
 *  cannot be manually changed. When the profile is
 *  `DJIGimbalAdvancedSettingsProfileCustom1` or
 *  `DJIGimbalAdvancedSettingsProfileCustom2`, the SmoothTrack and Controller
 *  settings can be manually changed. When a profile is changed from a custom
 *  setting, the current settings will be saved in that custom setting.
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
 *  SmoothTrack yaw axis speed determines how fast the gimbal will catch up with
 *  the translated yaw handle movement.
 *  Range is [0,100].
 */
@property(nonatomic, readonly) NSInteger smoothTrackSpeedYaw;

/**
 *  SmoothTrack pitch axis speed determines how fast the gimbal will catch up
 *  with the translated pitch handle movement.
 *  Range is [0,100].
 */
@property(nonatomic, readonly) NSInteger smoothTrackSpeedPitch;

/**
 *  A larger SmoothTrack yaw axis deadband requires more yaw handle movement to
 *  translate into gimbal motion.
 *  Range is [0,90] degrees.
 */
@property(nonatomic, readonly) NSInteger smoothTrackDeadbandYaw;

/**
 *  A larger SmoothTrack pitch axis deadband requires more pitch handle movement
 *  to translate into gimbal motion.
 *  Range is [0,90] degrees.
 */
@property(nonatomic, readonly) NSInteger smoothTrackDeadbandPitch;

/**
 *  SmoothTrack yaw axis acceleration determines how closely the gimbal's yaw
 *  axis will follow the translated controller movement.
 *  Range is [0,30].
 */
@property(nonatomic, readonly) NSInteger smoothTrackAccelerationYaw;

/**
 *  SmoothTrack pitch axis acceleration determines how closely the gimbal's yaw
 *  axis will follow the translated controller movement.
 *  Range is [0,30].
 */
@property(nonatomic, readonly) NSInteger smoothTrackAccelerationPitch;

/**
 *  Controller yaw axis smoothing controls the deceleration of the gimbal. A
 *  small value will cause the gimbal to stop abruptly.
 *  Range is [0,30].
 */
@property(nonatomic, readonly) NSInteger controllerSmoothingYaw;

/**
 *  Controller pitch axis smoothing controls the deceleration of the gimbal. A
 *  small value will cause the gimbal to stop abruptly.
 *  Range is [0,30].
 */
@property(nonatomic, readonly) NSInteger controllerSmoothingPitch;

/**
 *  Controller yaw axis speed determines how sensitively the gimbal's yaw axis
 *  will follow the controller movement.
 *  Range is [0,100].
 */
@property(nonatomic, readonly) NSInteger controllerSpeedYaw;

/**
 *  Controller pitch axis speed determines how sensitively the gimbal's pitch
 *  axis will follow the controller movement.
 *  Range is [0,100].
 */
@property(nonatomic, readonly) NSInteger controllerSpeedPitch;

@end
