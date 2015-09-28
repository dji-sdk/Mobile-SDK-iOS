//
//  DJIInspireMainController.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <DJISDK/DJIMainController.h>
#import <DJISDK/DJIHotPointMission.h>
#import <DJISDK/DJIGroundStation.h>
#import <DJISDK/DJIFollowMeMission.h>
#import <DJISDK/DJIIOCMission.h>

@interface DJIInspireMainController : DJIMainController

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
 *  Open landing gear protection. If opened, the landing gear will drop down automatically while the drone landing
 *
 *  @param block Remote execute reult
 */
-(void) openLandingGearProtectionWithResult:(DJIExecuteResultBlock)block;

/**
 *  Close landing gear protection
 *
 *  @param block Remote execute reult
 */
-(void) closeLandingGearProtectionWithResult:(DJIExecuteResultBlock)block;

/**
 *  Set dynamic home point enable
 *
 *  @param enable Dynamic home point enable
 *  @param block  Remote execute result.
 */
-(void) setDynamicHomePointEnable:(BOOL)enable withResult:(DJIExecuteResultBlock)block DJI_API_DEPRECATED;

/**
 *  Enter transport mode. if receive ERR_CommandExecuteFailed error, that maybe the gimbal is not dismount or the ground is not flattening.
 *
 *  @param block Remote execute result.
 */
-(void) enterTransportModeWithResult:(DJIExecuteResultBlock)block;

/**
 *  Exit transport mode.
 *
 *  @param block Remote execute result.
 */
-(void) exitTransportModeWithResult:(DJIExecuteResultBlock)block;

/**
 *  Set multiple flight mode open. if set open, then the remote controller's mode switch will be available.
 *
 *  @param isOpen   Whether or not open the multiple flight mode.
 *  @param block    Remote execute result.
 */
-(void) setMultipleFlightModeOpen:(BOOL)isOpen withResult:(DJIExecuteResultBlock)block;

/*
 *  Set low battery waning data.
 *
 *  @param percent Percentage of low battery in range [25, 50].
 *  @param block   Remote execute result.
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

/**
 *  Send data to external device. Only support in product Matrice100.
 *
 *  @param data  Data to be sent to external device, the size of data should not large then 100 byte.
 *  @param block Remote execute result.
 */
-(void) sendDataToExternalDevice:(NSData*)data withResult:(DJIExecuteResultBlock)block;

@end
