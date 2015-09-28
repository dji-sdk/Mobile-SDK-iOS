//
//  DJIPhantom3ProMainController.h
//  DJISDK
//
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <DJISDK/DJIMainController.h>

@interface DJIPhantom3ProMainController : DJIMainController

/**
 *  Main controller's firmware version.
 *
 */
-(NSString*) getMainControllerVersion;

/**
 *  Start update main controller's system state
 */
-(void) startUpdateMCSystemState;

/**
 *  Stop update main controller's system state
 */
-(void) stopUpdateMCSystemState;

/**
 *  Set multiple flight mode open. if set open, then the remote controller's mode switch will be available.
 *
 *  @param isOpen   Whether or not open the multiple flight mode.
 *  @param block    Remote execute result.
 */
-(void) setMultipleFlightModeOpen:(BOOL)isOpen withResult:(DJIExecuteResultBlock)block;

/*
 *  Set low battery waning data, percentage of voltage in range [25, 50].
 */
-(void) setLowBatteryWarning:(uint8_t)percent withResult:(DJIExecuteResultBlock)block;

/**
 *  Get low battery warning data.
 *
 *  @param result Remote execute result.
 */
-(void) getLowBatteryWarningWithResult:(void(^)(uint8_t percent, DJIError* error))result;

/**
 *  Set serious low battery waning data, percentage of voltage in range [10, 25]. 
 *
 *  @param percent Percentage of serious low battery
 *  @param block   Remote execute result.
 */
-(void) setSeriousLowBattery:(uint8_t)percent withResult:(DJIExecuteResultBlock)block;

/**
 *  Get serious low battery warning data.
 *
 *  @param result Remote execute result.
 */
-(void) getSeriousLowBatteryWarningwithResult:(void(^)(uint8_t percent, DJIError* error))result;

/**
 *  Set home point use the aircraft's current location.
 *
 *  @param result Remote execute result.
 */
-(void) setHomePointUsingAircraftCurrentLocationWithResult:(DJIExecuteResultBlock)result;

/**
 *  Set aircraft name. the length of aircraft name should be less than 32 characters
 *
 *  @param name   Name to be set to the aricraft.
 *  @param result Remote execute result.
 */
-(void) setAircraftName:(NSString*)name withResult:(DJIExecuteResultBlock)result;

/**
 *  Get aircraft name.
 *
 *  @param result Remote execute result.
 */
-(void) getAircraftNameWithResult:(void(^)(NSString* name, DJIError* error))result;

@end

