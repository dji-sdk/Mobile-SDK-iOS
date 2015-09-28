//
//  DJIInspireGimbal.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <DJISDK/DJIGimbal.h>

@interface DJIInspireGimbal : DJIGimbal

/**
 *  Set completion time for control gimbal angle action. If user use API setGimbalPitch:Roll:Yaw:withResult: to control the gimbal's angle (AbsoluteAngle)， this property will be used. the precision is 0.1s. for example, the property value is set as 2.0, then the gimbal will rotate to the target position in 2.0s
 */
@property(nonatomic, assign) double completionTimeForControlAngleAction;

/**
 *  Start gimbal calibration
 *
 *  @param result Remote execute result.
 */
-(void) startGimbalAutoCalibrationWithResult:(DJIExecuteResultBlock)result;

/**
 *  Set gimbal's work mode
 *
 *  @param workMode Work mode
 *  @param result   Remote execute result.
 */
-(void) setGimbalWorkMode:(DJIGimbalWorkMode)workMode withResult:(DJIExecuteResultBlock)result;

/**
 *  Reset gimbal. the gimbal's pitch roll yaw will back to origin.
 *
 *  @param result Remote execute result.
 */
-(void) resetGimbalWithResult:(DJIExecuteResultBlock)result;

/**
 *  Gimbal's roll fine-tune. if fineTune is negative number, then the roll will adjust specificed angle anticlockwise. 1fineTune = 0.1degree
 *
 *  @param angle  Fine-tune angle
 *  @param result Remote execute result
 */
-(void) setGimbalRollFineTune:(int8_t)fineTune withResult:(DJIExecuteResultBlock)result;

/**
 *  Control gimbal rotate
 *
 *  @param pitch Pitch rotation parameters. Inspire is in range [-90, 30] and Phantom3 Pression is in range [-90, 0]. the input angle precision is 0.1 degree
 *  @param roll  Roll rotation parameters. angel is in range [-180, +180]. the input angle precision is 0.1 degree
 *  @param yaw   Yaw rotation parameters. angel is in range [-180, +180]. the input angle precision is 0.1 degree
 *  @param block Remote execute result
 */
-(void) setGimbalPitch:(DJIGimbalRotation)pitch Roll:(DJIGimbalRotation)roll Yaw:(DJIGimbalRotation)yaw withResult:(DJIExecuteResultBlock)block;

@end
