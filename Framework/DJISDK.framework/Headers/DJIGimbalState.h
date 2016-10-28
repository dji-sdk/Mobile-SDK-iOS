//
//  DJIGimbalState.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIGimbalBaseTypes.h"

/**
 *  This class provides the current state of the gimbal.
 *
 */
@interface DJIGimbalState : NSObject
/**
 *  The current gimbal attitude in degrees. Roll, pitch and yaw are 0 if the gimbal
 *  is level with the aircraft and points in the forward direction of the aircraft.
 */
@property(nonatomic, readonly) DJIGimbalAttitude attitudeInDegrees;

/**
 *  Returns the gimbal's roll fine-tune value. The range for the fine-tune value is
 *  [-10, 10] degrees. If the fine-tune value is negative, the gimbal will be fine
 *  tuned the specified number of degrees in the counterclockwise direction.
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

/**
 *  `YES` if the mobile device is mounted on the gimbal. Only used by Osmo 
 *  Mobile.
 */
@property(nonatomic, readonly) BOOL isMobileDeviceMounted;

/**
 *  `YES` if one of the gimbal motors is overloaded. Only used by Osmo Mobile.
 */
@property(nonatomic, readonly) BOOL isMotorOverloaded;

/**
 *  Returns the balance status of the gimbal. Only used by Osmo Mobile.
 */
@property(nonatomic, readonly) DJIGimbalLoadingBalanceStatus balanceState;

@end
