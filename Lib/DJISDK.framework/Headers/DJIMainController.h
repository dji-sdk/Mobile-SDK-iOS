//
//  DJIMainController.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIObject.h>
#import <DJISDK/DJIGroundStation.h>
#import <DJISDK/DJIMainControllerDef.h>
#import <DJISDK/DJIFoundation.h>

@class DJIMCSystemState;
@class DJIMCLandingGearState;
@class DJIMainController;

@protocol DJINavigation;
@protocol DJIFlightLimitation;
@protocol DJICompass;

@protocol DJIMainControllerDelegate <NSObject>

@optional

/**
 *  Main controller error callback.
 *
 */
-(void) mainController:(DJIMainController*)mc didMainControlError:(MCError)error;

/**
 *  Main controller system state update callback.
 *
 */
-(void) mainController:(DJIMainController*)mc didUpdateSystemState:(DJIMCSystemState*)state;

/**
 *  Landing gear state update callback.
 *
 */
-(void) mainController:(DJIMainController*)mc didUpdateLandingGearState:(DJIMCLandingGearState*)state;

/**
 *  Received data from external device callback. Supported on Matrice 100.
 *
 *  @param mc   Main controller instance.
 *  @param data Data received from external device.
 */
-(void) mainController:(DJIMainController *)mc didReceivedDataFromExternalDevice:(NSData*)data;

@end


@interface DJIMainController : DJIObject

/**
 *  Manin controller delegate
 */
@property(nonatomic, weak) id<DJIMainControllerDelegate> mcDelegate;

/**
 *  Compass of the aircraft.
 */
@property(nonatomic, readonly) NSObject<DJICompass>* compass;

/**
 *  The navigation manager
 */
@property(nonatomic, readonly) NSObject<DJINavigation>* navigationManager;

/**
 *  The flight limitation
 */
@property(nonatomic, readonly) NSObject<DJIFlightLimitation>* flightLimitation;

/**
 *  Main controller's firmware version.
 *
 */
-(NSString*) getMainControllerVersion DJI_API_DEPRECATED;

/**
 *  Get main controller's firmware version
 *
 *  @param block Remote execute result callback.
 */
-(void) getVersionWithResult:(void(^)(NSString* version, DJIError* error))block;

/**
 *  Get main controller's serial number
 *
 *  @param block Remote execute result callback
 */
-(void) getSerialNumberWithResult:(void(^)(NSString* sn, DJIError* error))block;

/**
 *  Start update main controller's system state
 */
-(void) startUpdateMCSystemState;

/**
 *  Stop update main controller's system state
 */
-(void) stopUpdateMCSystemState;

/**
 *  Start Takeoff. The aircraft will hover on 1.2M after takeoff.
 *
 *  @param block Remote execute result callback.
 */
-(void) startTakeoffWithResult:(DJIExecuteResultBlock)block;

/**
 *  Stop takeoff.
 *
 *  @param block Remote execute result callback.
 */
-(void) stopTakeoffWithResult:(DJIExecuteResultBlock)block;

/**
 *  Start auto landing.
 *
 *  @param block Remote execute result callback.
 */
-(void) startLandingWithResult:(DJIExecuteResultBlock)block;

/**
 *  Stop auto landing.
 *
 *  @param block Remote execute result callback.
 */
-(void) stopLandingWithResult:(DJIExecuteResultBlock)block;

/**
 *  Turn on the motor.
 *
 *  @param block Remote execute result callback.
 */
-(void) turnOnMotorWithResult:(DJIExecuteResultBlock)block;

/**
 *  Turn off the motor.
 *
 *  @param block Remote execute result callback.
 */
-(void) turnOffMotorWithResult:(DJIExecuteResultBlock)block;

/**
 *  Start go home.
 *
 *  @param block Remote execute result callback.
 */
-(void) startGoHomeWithResult:(DJIExecuteResultBlock)block;

/**
 *  Stop go home.
 *
 *  @param block Remote execute result callback.
 */
-(void) stopGoHomeWithResult:(DJIExecuteResultBlock)block;

/**
 *  Start compass calibration. API deprecated. please use - startCalibrationWithResult: in 'DJICompass' instead.
 *
 *  @param block Remote execute result callback.
 */
-(void) startCompassCalibrationWithResult:(DJIExecuteResultBlock)block DJI_API_DEPRECATED;

/**
 *  Stop compass calibration. API deprecated. please use - stopCalibrationWithResult: in 'DJICompass' instead.
 *
 *  @param block Remote execute result callback.
 */
-(void) stopCompassCalibrationWithResult:(DJIExecuteResultBlock)block DJI_API_DEPRECATED;

/**
 *  Set the fly limitation parameter. Phantom 2 Vision support only.
 *
 *  @param limitParam The maximum height and distance that the aircraft could be fly.
 *  @param block      Remote execute result callback
 */
-(void) setLimitFlyWithHeight:(float)height Distance:(float)distance withResult:(DJIExecuteResultBlock)block;

/**
 *  Get the fly limitation parameter. Phantom 2 Vision support only.
 *
 *  @param block Remote execute result
 */
-(void) getLimitFlyWithResultBlock:(void(^)(DJILimitFlyStatus limitStatus, DJIError*))block;

/**
 *  Set home point to drone. Home point is use for back home when the drone lost signal or other danger case.
 *  The drone will use current located location as default home point while it first start and get enough satellite( >= 6).
 *  User should be carefully to change the home point.
 *
 *  @param homePoint Home point in degree.
 *  @param block     Remote execute result callback
 */
-(void) setHomePoint:(CLLocationCoordinate2D)homePoint withResult:(DJIExecuteResultBlock)block;

/**
 *  Set home point use the aircraft's current location.
 *
 *  @param result Remote execute result.
 */
-(void) setHomePointUsingAircraftCurrentLocationWithResult:(DJIExecuteResultBlock)result;

/**
 *  Get home point of drone.
 *
 *  @param block Remote execute result callback.
 */
-(void) getHomePoint:(void(^)(CLLocationCoordinate2D homePoint, DJIError* error))block;

/**
 *  Set go home default altitude. The default altitude is used by the drone every time while going home.
 *
 *  @param altitude  Drone altitude in meter for going home.
 *  @param block     Remote execute result callback.
 */
-(void) setGoHomeDefaultAltitude:(float)altitude withResult:(DJIExecuteResultBlock)block;

/**
 *  Get the default altitude of go home.
 *
 *  @param block  Remote execute result callback.
 */
-(void) getGoHomeDefaultAltitude:(void(^)(float altitude, DJIError* error))block;

/**
 *  Set go home temporary altitude. The temporary altitude is used by the drone this time while going home.
 *
 *  @param block     Remote execute result callback.
 */
-(void) setGoHomeTemporaryAltitude:(float)tmpAltitude withResult:(DJIExecuteResultBlock)block;

/**
 *  Get go home default altitude.
 *
 *  @param block  Remote execute result callback.
 */
-(void) getGoHomeTemporaryAltitude:(void(^)(float altitude, DJIError* error))block;

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
