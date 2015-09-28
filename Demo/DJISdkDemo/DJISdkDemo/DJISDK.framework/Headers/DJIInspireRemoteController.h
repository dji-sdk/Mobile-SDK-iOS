//
//  DJIInspireRemoteController.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <DJISDK/DJIRemoteController.h>

@interface DJIInspireRemoteController : DJIRemoteController

/**
 *  Set Remote Controller's work mode.
 *
 *  @attention Master-Slave mode only support in Inspire's remote controller
 *  @param work  Work mode
 *  @param block Remote execute result.
 */
-(void) setRCWorkMode:(DJIRCWorkMode)work withResult:(DJIExecuteResultBlock)block;

/**
 *  Get Remote Controller's work mode
 *
 *  @param block Remote execute result.
 */
-(void) getRCWorkModeWithResult:(void(^)(DJIRCWorkMode workMode, BOOL isConnected, DJIError* error))block;


/**
 *  Used by a slave machine to request to join a master.
 *
 *  @param hostId   Master's identifier
 *  @param name     Master's name
 *  @param password Master's password
 *  @param block    Remote execute result.
 */
-(void) joinMasterWithID:(DJIRCID)hostId masterName:(DJIRCName)name masterPassword:(DJIRCPassword)password withResult:(void(^)(DJIRCJoinMasterResult result, DJIError* error))block;

/**
 *  Get master's info
 *
 *  @param block Remote execute result.
 */
-(void) getJoinedMasterNameAndPassword:(void(^)(DJIRCID masterId, DJIRCName masterName, DJIRCPassword masterPassword, DJIError* error))block;

/**
 *  Get searched available masters. User should call startSearchMasterWithResult to open search.
 *
 *  @param block Remote execute result. Array masters contain type of DJIRCInfo object
 */
-(void) getAvailableMastersWithResult:(void(^)(NSArray* masters, DJIError* error))block;

/**
 *  Used by a slave to start search masters from nearby. call getAvailableMastersWithResult to get search result.
 *
 *  @param block Remote execute result
 */
-(void) startSearchMasterWithResult:(DJIExecuteResultBlock)block;

/**
 *  Used by a slave to stop search masters from nearby.
 *
 *  @param block Remote execute result.
 */
-(void) stopSearchMasterWithResult:(DJIExecuteResultBlock)block;

/**
 *  Get if search master started.
 *
 *  @param block Remote execute result.
 */
-(void) getSearchMasterStateWithResult:(void(^)(BOOL isStarted, DJIError* error))block;

/**
 *  Used by a master to get the connected slaves.
 *
 *  @param block Remote execute result. Objects is slaveList is kind of class DJIRCInfo
 */
-(void) getSlaveListWithResult:(void(^)(NSArray* slaveList, DJIError* error))block;

/**
 *  Remove a slave form master.
 *
 *  @param slaveId Target slave to be remove.
 *  @param block   Remote execute result.
 */
-(void) removeSlave:(DJIRCID)slaveId withResult:(DJIExecuteResultBlock)block;

/**
 *  Disconnect to a master
 *
 *  @param masterId The connected master's identifier
 *  @param block    Remote execute result.
 */
-(void) removeMaster:(DJIRCID)masterId withResult:(DJIExecuteResultBlock)block;

/**
 *  Set slave's control permission.
 *
 *  @param slaveId    Target slave to be set
 *  @param permission Control permission
 *  @param block      Remote execute result.
 */
-(void) setSlave:(DJIRCID)slaveId controlPermission:(DJIRCControlPermission)permission withResult:(DJIExecuteResultBlock)block;

/**
 *  Get slave's control permission.
 *
 *  @param block Remote execute result. Objects is slaveList is kind of class DJIRCInfo
 */
-(void) getSlaveControlPermission:(void(^)(NSArray* slaveList, DJIError* error))block;

/**
 *  Set slave's control mode.
 *
 *  @param mode  Control mode to be set. the mode's style should be RCSlaveControlStyleXXX
 *  @param block Remote execute result.
 */
-(void) setSlaveControlMode:(DJIRCControlMode)mode withResult:(DJIExecuteResultBlock)block;

/**
 *  Get slave's control mode.
 *
 *  @param block Remote execute result.
 */
-(void) getSlaveControlModeWithResult:(void(^)(DJIRCControlMode mode, DJIError* error))block;

/**
 *  Set slave's joystick control the gimbal's pitch/roll/yaw speed.
 *
 *  @param speed Speed to be set for gimal's pitch/roll/yaw. speed value should be in range [0, 100].
 *  @param block Remote execute result.
 */
-(void) setSlaveJoystickControlGimbalSpeed:(DJIRCGimbalControlSpeed)speed withResult:(DJIExecuteResultBlock)block;

/**
 *  Get gimbal control speed.
 *
 *  @param block Remote execute result.
 */
-(void) getSlaveJoystickControlGimbalSpeedWithResult:(void(^)(DJIRCGimbalControlSpeed speed, DJIError* error))block;

/**
 *  Set RC's wheel control the gimbal's pitch speed
 *
 *  @param speed Speed of control gimbal. value should be in range [0, 100]
 *  @param block Remote execute result.
 */
-(void) setRCWheelControlGimbalSpeed:(uint8_t)speed withResult:(DJIExecuteResultBlock)block;

/**
 *  Get RC's wheel control gimbal's speed
 *
 *  @param block Remote execute result.
 */
-(void) getRCWheelControlGimbalSpeedWithResult:(void(^)(uint8_t speed, DJIError* error))block;

/**
 *  Used by a slave to rquest the gimbal's control right.
 *
 *  @param block Remote execute result.
 */
-(void) requestGimbalControlRightWithResult:(void(^)(DJIRCRequestGimbalControlResult result, DJIError* error))block;

/**
 *  Used by a master to response the slave's gimbal control request
 *
 *  @param requesterId The requester's identifier
 *  @param isAgree     Agree or not for the gimbal control right request.
 */
-(void) responseRequester:(DJIRCID)requesterId forGimbalControlRight:(BOOL)isAgree;

/**
 *  Set RC's wheel that on the top left will control which direction(pitch or roll or yaw) of gimbal.
 *
 *  @param direction Gimbal's direction control by the wheel
 *  @param block     Remote execute result.
 */
-(void) setRCControlGimbalDirection:(DJIRCGimbalControlDirection)direction withResult:(DJIExecuteResultBlock)block;

/**
 *  Get RC control gimbal's direction
 *
 *  @param block Remote execute.
 */
-(void) getRCControlGimbalDirectionWithResult:(void(^)(DJIRCGimbalControlDirection direction, DJIError* error))block;

/**
 *  Set custom button index. The index is used by user to record user settings
 *
 *  @param index1 Custom button1's index
 *  @param index2 Custom button2's index
 *  @param block  Remote execute result
 */
-(void) setRCCustomButton1Index:(uint8_t)index1 customButtonIndex2:(uint8_t)index2 withResult:(DJIExecuteResultBlock)block;

/**
 *  Get custom button's index settings
 *
 *  @param block Remote execute result
 */
-(void) getRCCustomButtonIndexWithResult:(void(^)(uint8_t index1, uint8_t index2, DJIError* error))block;

@end
