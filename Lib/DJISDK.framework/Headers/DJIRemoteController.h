//
//  DJIRemoteController.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import "DJIObject.h"
#import <CoreLocation/CoreLocation.h>
#import <DJISDK/DJIRemoteControllerDef.h>

@class DJIRemoteController;

@protocol DJIRemoteControllerDelegate <NSObject>

@optional

/**
 *  Update Remote Controller's hardware state
 *
 *  @param rc    Remote Controller Instance
 *  @param state Hardware state
 */
-(void) remoteController:(DJIRemoteController*)rc didUpdateHardwareState:(DJIRCHardwareState)state;

/**
 *  Update Remote Controller's GPS data.
 *
 *  @param rc      Remote Controller Instance
 *  @param gpsData Gps data
 */
-(void) remoteController:(DJIRemoteController*)rc didUpdateGpsData:(DJIRCGPSData)gpsData;

/**
 *  Update Remote Controller's battery state.
 *
 *  @param rc          Remote Controller Instance
 *  @param batteryInfo Battery Info
 */
-(void) remoteController:(DJIRemoteController *)rc didUpdateBatteryState:(DJIRCBatteryInfo)batteryInfo;

/**
 *  Receive gimbal control request from a slave.
 *
 *  @param rc    Remote Controller Instance
 *  @param slave Slave who request for gimbal control permission
 */
-(void) remoteController:(DJIRemoteController *)rc didReceivedGimbalControlRequestFormSlave:(DJIRCInfo*)slave;

@end

@interface DJIRemoteController : DJIObject

@property(nonatomic, weak) id<DJIRemoteControllerDelegate> delegate;

/**
 *  Get remote controller's firmware version.
 *
 *  @param block Remote execute result callback.
 */
-(void)getVersionWithResult:(void(^)(NSString* version, DJIError* error))block;

/**
 *  Set RC Name
 *
 *  @param name  RC name to be set
 *  @param block Remote execute result.
 */
-(void) setRCName:(DJIRCName)name withResult:(DJIExecuteResultBlock)block;

/**
 *  Get RC Name
 *
 *  @param block Remote execute result.
 */
-(void) getRCNameWithResult:(void(^)(DJIRCName name, DJIError* error))block;

/**
 *  Set RC Password
 *
 *  @param password RC Password to be set
 *  @param block    Remote execute result.
 */
-(void) setRCPassword:(DJIRCPassword)password withResult:(DJIExecuteResultBlock)block;

/**
 *  Get RC Password
 *
 *  @param block Remote execute result.
 */
-(void) getRCPasswordWithResult:(void(^)(DJIRCPassword password, DJIError* error))block;

/**
 *  Set RC's control mode.
 *
 *  @param mode  Control mode to be set. the mode's style should be RCMasterControlStyleXXX.
 *  @param block Remote execute result.
 */
-(void) setRCControlMode:(DJIRCControlMode)mode withResult:(DJIExecuteResultBlock)block;

/**
 *  Get master's control mode
 *
 *  @param block Remote execute result.
 */
-(void) getRCControlModeWithResult:(void(^)(DJIRCControlMode mode, DJIError* error))block;

/**
 *  Enter frequency pairing mode.
 *
 *  @param block Remote execute result.
 */
-(void) enterRCPairingModeWithResult:(DJIExecuteResultBlock)block;

/**
 *  Exit frequency pairing mode.
 *
 *  @param block Remote execute result.
 */
-(void) exitRCParingModeWithResult:(DJIExecuteResultBlock)block;

/**
 *  Get RC Calibration state
 *
 *  @param block Remote execute result
 */
-(void) getRCCalibrationStateWithResult:(void(^)(DJIRCCalibrationState state, DJIError* error))block;

/**
 *  Record RC Calibration middle value
 *
 *  @param block Remote execute result
 */
-(void) recordRCCalibrationMiddleValueWithResult:(void(^)(DJIRCCalibrationState state, DJIError* error))block;

/**
 *  Record RC Calibration extreme value
 *
 *  @param block Remote execute result
 */
-(void) recordRCCalibrationExtremeValueWithResult:(void(^)(DJIRCCalibrationState state, DJIError* error))block;

/**
 *  Exit RC Calibration
 *
 *  @param block Remote execute result
 */
-(void) exitRCCalibrationWithResult:(void(^)(DJIRCCalibrationState state, DJIError* error))block;

/**
 *  Get frequency pairing status.
 *
 *  @param block Remote execute result.
 */
-(void) getRCParingStateWithResult:(void(^)(DJIRCParingState state, DJIError* error))block;

@end
