//
//  DJIAppManager.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIFoundation.h>
#import <DJISDK/DJIDrone.h>

//Error code for regist App
#define RegisterSuccess                   0

// The first time regist app should connect the internet.
#define RegisterErrorConnectInternet     -1

// The input app key is invalid. please check your app key is correct.
#define RegisterErrorInvalidAppKey       -2

// May be the network is bussy or the server is unreachable.
#define RegisterErrorGetMetaDataTimeout  -3

// Attempt to copy meta data from other registered device is not allow.
#define RegisterErrorDeviceNotMatch      -4

// The bundle identifier of your app should be identical to the one you regist from the website.
#define RegisterErrorBundleIdNotMatch    -5

// The app key is prohibited, please contact to the dji for help.
#define RegisterErrorAppKeyProhibited    -6

// Maximum number of active count is exceed, please contact to the dji for help.
#define RegisterErrorActivationExceed    -7

// The app key is apply for other platform.
#define RegisterErrorAppKeyPlatformError -8

// The app key is not exist. please check your app key is correct.
#define RegisterErrorAppKeyNotExist      -9

// The app key is no permission.
#define RegisterErrorAppKeyNoPermission  -10

// Server error, please contact to the dji for help.
#define RegisterErrorServerParseFailure  -11

// Server error, please contact to the dji for help.
#define RegisterErrorServerWriteError    -12

// Server error, please contact to the dji for help.
#define RegisterErrorServerDataAbnormal  -13

// The meta data is damaged, please connect to the internet and retry.
#define RegisterErrorInvalidMetaData     -14

// The input app key is empty.
#define RegisterErrorEmptyAppKey         -15

// Unknown error
#define RegisterErrorUnknown             -1000

@protocol DJIAppManagerDelegate <NSObject>

@required
/**
 *  Regist result callback
 */
-(void) appManagerDidRegisterWithError:(int)errorCode;

@optional
/**
 *  The connected drone changed callback. If the app regist succeed, the app will start to detect the connected drone automatically and the delegate will be call when detected a new connected drone. The auto detection supported for Inspire1/Phantom 3 PRO/ Phantom 3 Advanced
 *
 *  @param newDrone The new drone object that connected
 */
-(void) appManagerDidConnectedDroneChanged:(DJIDrone*)newDrone;

@end

@interface DJIAppManager : NSObject

/**
 *  Get the connected drone.
 *
 *  @return Connected drone object in currently.
 */
+(DJIDrone*) connectedDrone;

/**
 *  Regist app. User should call once while the app first used and should connect to the internet at the first time registration.
 *
 *  @param appKey   App key that applied from dji's developer website.
 *  @param delegate Regist result callback
 */
+(void) registerApp:(NSString*)appKey withDelegate:(id<DJIAppManagerDelegate>)delegate;

/**
 *  Get error descryption with error code.
 *
 *  @param errorCode Error code return from regist callback
 *
 *  @return The error descryption
 */
+(NSString*) getErrorDescryption:(int)errorCode;

/**
 *  Get DJI SDK framework version
 *
 *  @return Version of framework.
 */
+(NSString*) getFrameworkVersion;

@end
