//
//  DJIRangeExtender.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIObject.h>

#define INVALID_POWER_LEVEL -1

@class DJIRangeExtender;

@protocol DJIRangeExtenderDelegate <NSObject>

@optional
/**
 *  Update power level of range extender. The update frequency is 1Hz.
 *
 *  @param extender   Instance of DJIRangeExtender
 *  @param powerLevel Power level of range extender. If the connection to the range extender is borken, INVALID_POWER_LEVEL will be
 */
-(void) rangeExtender:(DJIRangeExtender*)extender didUpdatePowerLevel:(int)powerLevel;

@end


@interface DJIRangeExtender : DJIObject

/**
 *  Range extender power level update delegate
 */
@property(nonatomic, weak) id<DJIRangeExtenderDelegate> delegate;

/**
 *  Start power level update.
 */
-(void) startRangeExtenderPowerLevelUpdates;

/**
 *  Stop power level update.
 */
-(void) stopRangeExtenderPowerLevelUpdates;

/**
 *  Get the power level of the range extender.
 *
 *  @return Power level between [0, 10]. -1 is invalid power level.
 */
-(int) getRangeExtenderPowerLevel;

/**
 *  Bind mac address to the range extender.
 *
 *  @param macAddr The target bind camera's MAC address, get frome the QR code stick on the aircraft. the input MAC address should be this format:  60:60:1f:xx:xx:xx
 *
 *  @return Return bind result. if YES then bind Succeeded.
 *
 *  @attention If bind success, the range extender will reboot automatically.
 */
-(BOOL) bindRangeExtenderWithCameraMAC:(NSString*)macAddr;

/**
 *  Get the binding mac address of the range extender.
 *
 *  @return Return the binding MAC address. return nil if no binding.
 */
-(NSString*) getCurrentBindingMAC;

/**
 *  Get the binding ssid
 *
 *  @return Return the binding SSID, return nil if no binding.
 */
-(NSString*) getCurrentBindingSSID;

/**
 *  Get MAC Address of range extender.
 *
 *  @return MAC address of range extender.
 */
-(NSString*) getMacAddressOfRangeExtender;

/**
 *  Get SSID of range extender.
 *
 *  @return SSID of range extender.
 */
-(NSString*) getSsidOfRangeExtender;

/**
 *  Rename the range extender's ssid.
 *
 *  @param newName New ssid name of range extender, must has prefix "Phantom_"
 *  @attention If rename operation success, the range extender will reboot automatically.
 */
-(BOOL) renameSsidOfRangeExtender:(NSString*)newSsid;

/**
 *  Get wifi password
 *
 *  @return WIFI password or nil
 */
-(NSString*) getRangeExtenderWiFiPassword;

/**
 *  Set wifi password
 *
 *  @param password New wifi passwords that is made up of letters and numbers and should be 8 - 16 characters。
 *                  set nil to cancel setup password
 *  @attention Hard reset range extender will clean password
 */
-(BOOL) setRangeExtenderWiFiPassword:(NSString*)password;

@end
