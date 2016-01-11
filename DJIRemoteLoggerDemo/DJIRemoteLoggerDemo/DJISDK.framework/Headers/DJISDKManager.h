/*
 *  DJI iOS Mobile SDK Framework
 *  DJIAppManager.h
 *
 *  Copyright (c) 2015, DJI.
 *  All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class DJIAircraft;
@class DJIBaseProduct;

@protocol DJISDKManagerDelegate <NSObject>

@required

/**
 *  Callback delegate method after the application attempts to register.
 *
 *  @param error nil if registration is successful. Otherwise it contains NSError object with error codes from DJISDKRegistrationError.
 *
 */
-(void) sdkManagerDidRegisterAppWithError:(NSError* _Nullable) error;

@optional
/**
 *  Called when the `product` property changed.
 *
 *  @param oldProduct Old product object. Nil if starting up.
 *  @param newProduct New product object. Nil if the link USB or Wifi link between the product and phone is disconnected.
 *
 */
-(void) sdkManagerProductDidChangeFrom:(DJIBaseProduct* _Nullable) oldProduct to:(DJIBaseProduct* _Nullable) newProduct;

@end

@interface DJISDKManager : NSObject

/**
 *  Product connected to the mobile device.
 *
 *  @return available DJIBaseProduct object. nil if no product is available.
 */
+(__kindof DJIBaseProduct* _Nullable) product;


/**
 *  The first time the app is initialized after installation, the app connects to a DJI Server through the internet to verify the Application Key. Subsequent app starts will use locally cached verification information to register the app.
 *
 *  @param appKey   Application key that was provided by DJI after the application was registered.
 *  @param delegate Registration result callback delegate
 */
+(void) registerApp:(NSString*)appKey withDelegate:(id<DJISDKManagerDelegate>)delegate;


/**
 *  Queue in which completion blocks are called. if left unset, completion blocks are called in main queue.
 *
 *  @param completionBlockQueue dispatch queue.
 */
+ (void)setCompletionBlockQueue:(dispatch_queue_t)completionBlockQueue;

/**
 *  Start a connection to the DJI product. This method should be called after successful registration of the app. `sdkManagerProductDidChangeFrom:to:` delegate method will be called if the connection succeeded.
 */
+ (void)startConnectionToProduct;

/**
 * Disconnect the existing connection to the DJI product
 */
+ (void)stopConnectionToProduct;

/**
 *  Set SDK close the connection automatically when app enter background and resume connection automatically when app enter foreground. Default is YES.
 *
 *  @param isClose Close connection or not when app enter background.
 */
+(void) closeConnectionWhenEnterBackground:(BOOL)isClose;

/**
 *  Gets the DJI Mobile SDK Version
 *
 *  @return SDK version as a string.
 */
+(NSString*) getSDKVersion;

/**
 *  Enter debug mode with debug id.
 *
 *  @param debugId Debug id from the DJI Bridge App
 */
+(void) enterDebugModeWithDebugId:(NSString*)debugId;

/**
 *  Enter enable remote logging with log server URL.
 *
 *  @param deviceID Optional device id to uniquely identify logs from an installation.
 *  @param url URL of the remote log server
 */
+(void) enableRemoteLoggingWithDeviceID: (NSString * _Nullable) deviceID logServerURLString: (NSString*) url;

@end

NS_ASSUME_NONNULL_END
