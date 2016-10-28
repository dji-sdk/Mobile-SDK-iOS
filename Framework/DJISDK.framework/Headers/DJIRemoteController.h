//
//  DJIRemoteController.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <DJISDK/DJIBaseComponent.h>
#import <DJISDK/DJIRemoteControllerBaseTypes.h>

NS_ASSUME_NONNULL_BEGIN

/*********************************************************************************/
#pragma mark - DJIRemoteControllerDelegate
/*********************************************************************************/

@class DJIRemoteController;

/**
 *  This protocol provides delegate methods to receive the updated information
 *  related to the remote controller.
 */
@protocol DJIRemoteControllerDelegate <NSObject>

@optional

/**
 *  Callback function that updates the Remote Controller's current hardware
 *  state (e.g. the state of the physical buttons and joysticks).
 *
 *  @param rc    Instance of the Remote Controller for which the hardware state
 *               will be updated.
 *  @param state Current state of the Remote Controller's hardware state.
 */
- (void)remoteController:(DJIRemoteController *_Nonnull)rc didUpdateHardwareState:(DJIRCHardwareState)state;

/**
 *  Callback function that updates the Remote Controller's current GPS data.
 *
 *  @param rc    Instance of the Remote Controller for which the GPS data will be updated.
 *  @param state Current state of the Remote Controller's GPS data.
 */
- (void)remoteController:(DJIRemoteController *_Nonnull)rc didUpdateGpsData:(DJIRCGPSData)gpsData;

/**
 *  Callback function that updates the Remote Controller's current battery state.
 *
 *  @param rc    Instance of the Remote Controller for which the battery state will be updated.
 *  @param state Current state of the Remote Controller's battery state.
 */
- (void)remoteController:(DJIRemoteController *_Nonnull)rc didUpdateBatteryState:(DJIRCBatteryInfo)batteryInfo;

/**
 *  Callback function that gets called when a slave Remote Controller makes a request to a master
 *  Remote Controller to control the gimbal using the method requestGimbalControlRightWithCallbackBlock.
 *
 *  @param rc    Instance of the Remote Controller.
 *  @param state Information of the slave making the request to the master Remote Controller.
 */
- (void)remoteController:(DJIRemoteController *_Nonnull)rc didReceiveGimbalControlRequestFromSlave:(DJIRCInfo *_Nonnull)slave;

/**
 *  Callback function that updates the Remote Focus State, only support
 *  Focus product. If the isRCRemoteFocusCheckingSupported is YES, this delegate
 *  method will be called.
 *
 *  @param rc    Instance of the Remote Controller for which the battery state will be updated.
 *  @param state Current state of the Remote Focus state.
 */
- (void)remoteController:(DJIRemoteController *_Nonnull)rc didUpdateRemoteFocusState:(DJIRCRemoteFocusState)remoteFocusState;

@end

/*********************************************************************************/
#pragma mark - DJIRemoteController
/*********************************************************************************/

@class DJIWiFiLink;

/**
   This class represents the remote controller of the aircraft. It provides
 *  methods to change the settings of the physical remote controller. For some
 *  products (e.g. Inspire 1 and Matric 100), the class provides methods to
 *  manager the slave/master mode of the remote controllers.
 *
 * A remote controller is a device that can have a GPS, battery, radio, buttons,
 *  sticks, wheels, and output ports for video. The mobile device is connected
 *  to the remote controller, which is always sending out information about what
 *  everything is doing. The normal remote controller is called the master. A
 *  slave wirelessly connects to the master remote controller at 5 GHz, and the
 *  aircraft can also download information to the slave. The slave can send
 *  gimbal control commands to the master. This configuration allows one person
 *  to fly the aircraft while another person controls the gimbal.
 */
@interface DJIRemoteController : DJIBaseComponent

/**
 *  Returns the delegate of Remote Controller.
 */
@property(nonatomic, weak) id<DJIRemoteControllerDelegate> delegate;

/**
 *  Query method to check if the Remote Controller supports Remote Focus State Checking.
 */
- (BOOL)isRCRemoteFocusCheckingSupported;

/**
 *  Sets the Remote Controller's name.
 *
 *  @param name  Remote controller name to be set. Six characters at most.
 *  @param completion Completion block.
 */
- (void)setRCName:(NSString *_Nonnull)name withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the Remote Controller's name.
 *
 */
- (void)getRCNameWithCompletion:(void (^_Nonnull)(NSString *_Nullable name, NSError *_Nullable error))completion;

/**
 *  Sets the Remote Controller's password.
 *
 *  @param password password Remote controller password to be set, using a string consisted by 4 digits.
 *  @param block    Completion block.
 */
- (void)setRCPassword:(NSString *_Nonnull)password withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the Remote Controller's password.
 *
 */
- (void)getRCPasswordWithCompletion:(void (^_Nonnull)(NSString *_Nullable password, NSError *_Nullable error))completion;

/**
 *  Sets the Remote Controller's control mode.
 *
 *  @param mode  Remote Controller control mode to be set.
 *  @param completion Completion block.
 */
- (void)setRCControlMode:(DJIRCControlMode)mode withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the master Remote Controller's control mode.
 *
 */
- (void)getRCControlModeWithCompletion:(void (^_Nonnull)(DJIRCControlMode mode, NSError *_Nullable error))completion;

/*********************************************************************************/
#pragma mark RC pairing
/*********************************************************************************/

/**
 *  Enters pairing mode, in which the Remote Controller starts pairing with the aircraft.
 *  This method is used when the Remote Controller no longer recognizes which aircraft
 *  it is paired with.
 */
- (void)enterRCToAircraftPairingModeWithCompletion:(DJICompletionBlock)completion;

/**
 *  Exits pairing mode.
 *
 */
- (void)exitRCToAircraftPairingModeWithCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the pairing status as the Remote Controller is pairing with the aircraft.
 *
 */
- (void)getRCToAircraftPairingStateWithCompletion:(void (^_Nonnull)(DJIRCToAircraftPairingState state, NSError *_Nullable error))completion;

/*********************************************************************************/
#pragma mark RC gimbal control
/*********************************************************************************/

/**
 *  Sets the gimbal's pitch speed for the Remote Controller's upper left wheel (Gimbal Dial).
 *
 *  @param speed Speed to be set for the gimbal's pitch, which should in the range of [0, 100],
 *  where 0 represents very slow and 100 represents very fast.
 *  @param completion Completion block.
 */
- (void)setRCWheelGimbalSpeed:(uint8_t)speed withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the gimbal's pitch speed for the Remote Controller's upper left wheel (Gimbal Dial).
 *
 */
- (void)getRCWheelGimbalSpeedWithCompletion:(void (^_Nonnull)(uint8_t speed, NSError *_Nullable error))completion;

/**
 *  Sets which of the gimbal directions the top left wheel (Gimbal Dial) on the
 *  Remote Controller will control. The three options (pitch, roll, and yaw) are
 *  outlined in the enum named DJIRCGimbalControlDirection in DJIRemoteControllerDef.h.
 *
 *  @param direction  Gimbal direction to be set that the top left wheel on the
 *                    Remote Controller will control.
 *  @param completion Completion block.
 */
- (void)setRCControlGimbalDirection:(DJIRCGimbalControlDirection)direction withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets which of the gimbal directions the top left wheel (Gimbal Dial) on the
 *  Remote Controller will control.
 *
 *  @param completion Completion block.
 */
- (void)getRCControlGimbalDirectionWithCompletion:(void (^_Nonnull)(DJIRCGimbalControlDirection direction, NSError *_Nullable error))completion;

/*********************************************************************************/
#pragma mark RC custom buttons
/*********************************************************************************/

/**
 *  Sets custom button's (Back Button's) tags, which can be used by the user to
 *  record user settings for a particular Remote Controller. Unlike all other
 *  buttons, switches and sticks on the Remote Controller, the custom buttons
 *  only send state to the Mobile Device and not the aircraft.
 *
 *  @param tag1       Button 1's custom tag.
 *  @param tag2       Button 2's custom tag.
 *  @param completion Completion block.
 */
- (void)setRCCustomButton1Tag:(uint8_t)tag1 customButton2Tag:(uint8_t)tag2 withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the custom button's (Back Button's) tags.
 *
 */
- (void)getRCCustomButtonTagWithCompletion:(void (^_Nonnull)(uint8_t tag1, uint8_t tag2, NSError *_Nullable error))completion;

/**
 *  Set C1 button enable binding DJI GO app state. If it's enabled, when the
 *  user presses the C1 button, an alertView will pop up and ask if you want to
 *  open the DJI GO app. This feature only supports MFI certificated Remote
 *  Controller.

 *  @attention This feature will affect the user of DJI GO app, we suggest you
 *  to call this interface to enable the C1 binding feature when your
 *  application enter background. Otherwise, the C1 button will be unbound with
 *  DJI GO app forever.
 *
 *  @param enable Enable C1 button bind DJI GO app.
 *  @param completion Completion block.
 */
- (void)setRCC1ButtonBindingEnabled:(BOOL)enable withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the C1 button enable binding DJI Go app state. This feature only
 *  supports MFI certificated Remote Controller.
 *
 *  @param completion Completion block.
 */
- (void)getRCC1ButtonBindingEnabledWithCompletion:(void (^_Nonnull)(BOOL enable, NSError *_Nullable error))completion;

/*********************************************************************************/
#pragma mark RC master and slave mode
/*********************************************************************************/

/**
 *  Query method to check if the Remote Controller supports master/slave mode.
 */
- (BOOL)isMasterSlaveModeSupported;

/**
 *  Sets the Remote Controller's mode. See the `DJIRemoteControllerMode` enum
 *  for all possible Remote Controller modes.
 *  The master and slave modes are only supported for the Inspire 1, Inspire 1
 *  Pro and M100.
 *
 *  @param mode  Mode of type `DJIRemoteControllerMode` to be set for the Remote Controller.
 *  @param completion Completion block.
 */
- (void)setRemoteControllerMode:(DJIRemoteControllerMode)mode withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the Remote Controller's mode.
 *
 */
- (void)getRemoteControllerModeWithCompletion:(void (^_Nonnull)(DJIRemoteControllerMode mode, BOOL isConnected, NSError *_Nullable error))completion;

/*********************************************************************************/
#pragma mark RC master and slave mode - Slave RC methods
/*********************************************************************************/

/**
 *  Used by a slave Remote Controller to join a master Remote Controller. If the
 *  master Remote Controller accepts the request, the master Remote Controller
 *  will control the aircraft, and the slave Remote Controller will control the
 *  gimbal and/or be able to view the downlink video.
 *
 *  @param hostId     Master's unique identifier.
 *  @param name       Master's name.
 *  @param password   Master's password.
 *  @param completion Remote execution result callback block.
 */
- (void)joinMasterWithID:(DJIRCID)masterId
              masterName:(NSString *_Nonnull)masterName
          masterPassword:(NSString *_Nonnull)masterPassword
          withCompletion:(void (^_Nonnull)(DJIRCJoinMasterResult result, NSError *_Nullable error))completion;

/**
 *  Returns the master Remote Controller's information, which includes the
 *  unique identifier, name, and password.
 *
 *  @param completion Remote execution result callback block.
 */
- (void)getJoinedMasterNameAndPassword:(void (^_Nonnull)(DJIRCID masterId, NSString *_Nullable masterName, NSString *_Nullable masterPassword, NSError *_Nullable error))completion;

/**
 *  Starts a search by slave Remote Controller for nearby master Remote
 *  Controllers. To get the list of master Remote Controllers, first call
 *  `getAvailableMastersWithCallbackBlock`, then call
 *  `stopMasterRCSearchWithCompletion` to end the search.
 *
 *  @param completion Remote execution result callback block.
 */
- (void)startMasterRCSearchWithCompletion:(DJICompletionBlock)completion;

/**
 *  Returns all available master Remote Controllers that are located nearby.
 *  Before this method can be used, call `startMasterRCSearchWithCompletion` to
 *  start the search for master Remote Controllers. Once the list of masters is
 *  received, call `stopMasterRCSearchWithCompletion` to end the search.
 *
 *  @param completion Remote execution result callback block.
 */
- (void)getAvailableMastersWithCompletion:(void (^_Nonnull)(NSArray<DJIRCInfo *> *_Nullable masters, NSError *_Nullable error))completion;

/**
 *  Used by a slave Remote Controller to stop the search for nearby master Remote Controllers.
 *
 *  @param completion Remote execution result callback block.
 */
- (void)stopMasterRCSearchWithCompletion:(DJICompletionBlock)completion;

/**
 *  Returns the state of the master Remote Controller search. The search is
 *  initiated by the Mobile Device, but performed by the Remote Controller.
 *  Therefore, if the Mobile Device's application crashes while a search is
 *  ongoing, this method can be used to let the new instance of the application
 *  understand the Remote Controller state.
 *
 *  @param completion Remote execution result callback block.
 */
- (void)getMasterRCSearchStateWithCompletion:(void (^_Nonnull)(BOOL isStarted, NSError *_Nullable error))completion;

/**
 *  Removes a master Remote Controller from the current slave Remote Controller.
 *
 *  @param masterId The connected master's identifier.
 *  @param completion Completion block.
 */
- (void)removeMaster:(DJIRCID)masterId withCompletion:(DJICompletionBlock)completion;

/**
 *  Called by the slave Remote Controller to request gimbal control from the master Remote Controller.
 *
 *  @param completion Remote execution result callback block.
 */
- (void)requestGimbalControlRightWithCompletion:(void (^_Nonnull)(DJIRCRequestGimbalControlResult result, NSError *_Nullable error))completion;

/**
 *  Sets the Remote Contoller's slave control mode.
 *
 *  @param mode  Control mode to be set. the mode's style should be `RCSlaveControlStyleXXX`.
 *  @param completion Completion block
 */
- (void)setSlaveControlMode:(DJIRCControlMode)mode withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the Remote Controller's slave control mode.
 *
 *  @param completion Remote execution result callback block.
 */
- (void)getSlaveControlModeWithCompletion:(void (^_Nonnull)(DJIRCControlMode mode, NSError *_Nullable error))completion;

/**
 *  Called by the slave Remote Controller to set the gimbal's pitch, roll, and yaw speed with a range of [0, 100].
 *
 *  @param speed Gimal's pitch, roll, and yaw speed with a range of [0, 100].
 *  @param completion Completion block
 */
- (void)setSlaveJoystickControlGimbalSpeed:(DJIRCGimbalControlSpeed)speed withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the current slave's gimbal's pitch, roll, and yaw speed with a range of [0, 100].
 *
 *  @param completion Remote execution result callback block.
 */
- (void)getSlaveJoystickControlGimbalSpeedWithCompletion:(void (^_Nonnull)(DJIRCGimbalControlSpeed speed, NSError *_Nullable error))completion;

/*********************************************************************************/
#pragma mark RC master and slave mode - Master RC methods
/*********************************************************************************/

/**
 *  Used by the current master Remote Controller to get all the slaves connected to it.
 *
 *  @param block Remote execution result callback block. The arrray of slaves contains objects
 *  of type `DJIRCInfo`.
 */
- (void)getSlaveListWithCompletion:(void (^_Nonnull)(NSArray<DJIRCInfo *> *_Nullable slaveList, NSError *_Nullable error))block;

/**
 *  Removes a slave Remote Controller from the current master Remote Controller.
 *
 *  @param slaveId Target slave to be removed.
 *  @param completion Completion block.
 */
- (void)removeSlave:(DJIRCID)slaveId withCompletion:(DJICompletionBlock)completion;

/**
 *  When a slave Remote Controller requests a master Remote Controller to control the gimbal, this
 *  method is used by a master Remote Controller to respond to the slave Remote Controller's request.
 *
 *  @param requesterId The slave Remote Controller's identifier.
 *  @param isAgree     YES if the master Remote Controller agrees to give the slave Remote Controller the right to control the gimbal.
 */
- (void)responseRequester:(DJIRCID)requesterId forGimbalControlRight:(BOOL)isAgree;

@end
NS_ASSUME_NONNULL_END
