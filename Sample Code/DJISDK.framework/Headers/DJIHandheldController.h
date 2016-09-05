//
//  DJIHandheldController.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIBaseComponent.h>
#import <DJISDK/DJIHandheldControllerBaseTypes.h>

@class DJIWiFiLink;

NS_ASSUME_NONNULL_BEGIN

@class DJIHandheldController;

/*********************************************************************************/
#pragma mark - DJIHandheldControllerDelegate
/*********************************************************************************/

/**
 *
 *  This protocol provides a delegate method to receive the updated power mode of the handheld controller.
 *
 */
@protocol DJIHandheldControllerDelegate <NSObject>

@optional

/**
 *  Tells the delegate that a handheld controller's power mode has been updated.
 *
 *  @param controller   The handheld controller that updates the power mode.
 *  @param powerMode    The handheld controller's current power mode.
 *
 */
- (void)handheldController:(DJIHandheldController *_Nonnull)controller didUpdatePowerMode:(DJIHandheldPowerMode)powerMode;

/**
 *  Delegate for the handheld controller's current hardware state (e.g. the
 *  state of the physical buttons and joysticks).
 *  Supported only by Osmo Mobile. 
 *
 *  @param controller   The handheld controller that updates the hardware state.
 *  @param powerMode    The handheld controller's current hardware state.
 *
 */
- (void)handheldController:(DJIHandheldController *_Nonnull)controller didUpdateHardwareState:(DJIHandheldControllerHardwareState *)state;

@end


/*********************************************************************************/
#pragma mark - DJIHandheldController
/*********************************************************************************/

/**
 *
 *  This class contains interfaces to control a handheld device. You can make the handheld device enter sleep mode, awake from sleep mode or shut it down.
 */
@interface DJIHandheldController : DJIBaseComponent

/**
 *  Returns the `DJIHandheldController` delegate.
 */
@property(nonatomic, weak) id <DJIHandheldControllerDelegate> delegate;

/**
 *  Set the power mode for the handheld.
 *
 *  @param mode     The power mode to set.
 *                  CAUTION: When the mode is `DJIHandheldPowerModePowerOff`, the handheld device will be shut down and
 *                  the connection will be broken. The user must then power on the device manually.
 *  @param block    Remote execution result callback block.
 */
- (void)setHandheldPowerMode:(DJIHandheldPowerMode)mode withCompletion:(DJICompletionBlock)block;

@end

NS_ASSUME_NONNULL_END
