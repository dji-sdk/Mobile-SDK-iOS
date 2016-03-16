//
//  DJISDKManager.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class DJIAircraft;
@class DJIBaseProduct;

/**
 *  This protocol provides delegate methods to receive the updated registration status and the change of the connected product.
 *
 */
@protocol DJISDKManagerDelegate <NSObject>

@required

/**
 *  Callback delegate method after the application attempts to register.
 *
 *  @param error nil if registration is successful. Otherwise it contains an `NSError` object with error codes from `DJISDKRegistrationError`.
 *
 */
- (void)sdkManagerDidRegisterAppWithError:(NSError *_Nullable)error;

@optional
/**
 *  Called when the `product` property changed.
 *
 *  @param oldProduct Old product object. Nil if starting up.
 *  @param newProduct New product object. Nil if the USB link or WiFi link between the product and phone is disconnected.
 *
 */
- (void)sdkManagerProductDidChangeFrom:(DJIBaseProduct *_Nullable)oldProduct to:(DJIBaseProduct *_Nullable)newProduct;

@end

/**
 *  This protocol provides delegate methods to receive the updated connection status between the debug server, remote controller and debug client.
 */
@protocol DJISDKDebugServerDelegate <NSObject>

@optional
/**
 *  Callback delegate method after the Debug server is started.
 *
 *  @param isRCConnected is true if the RC is connected with the Debug server.
 *  @param isWifiConnected is true if the debug client is connected with the Debug server based on WiFi.
 *
 */
- (void)sdkDebugServerWithRCConnectionStatus:(BOOL)isRCConnected andDebugClientConnectionStatus:(BOOL)isWifiConnected;

@end

/**
 *  This class contains methods to register the app, start or stop connections with the product, and use the DJI Bridge app and Remote Logger tools, etc. After registration, the user can access the connected product through `DJISDKManager`. Then the user can start to control the components of the product.
 */
@interface DJISDKManager : NSObject

/**
 *  Product connected to the mobile device. The product is accessible only after successful registration of the app.
 *
 *  @return The available `DJIBaseProduct object`, or nil if no product is available.
 */
+ (__kindof DJIBaseProduct *_Nullable)product;

/**
 *  The first time the app is initialized after installation, the app connects to a DJI Server through the internet to verify the Application Key. Subsequent app starts will use locally cached verification information to register the app.
 *
 *  @param appKey   Application key that was provided by DJI after the application was registered.
 *  @param delegate Registration result callback delegate
 */
+ (void)registerApp:(NSString *)appKey withDelegate:(id<DJISDKManagerDelegate>)delegate;

/**
 *  Queue in which completion blocks are called. If left unset, completion blocks are called in main queue.
 *
 *  @param completionBlockQueue Dispatch queue.
 */
+ (void)setCompletionBlockQueue:(dispatch_queue_t)completionBlockQueue;

/**
 *  Start a connection to the DJI product. Call this method after successful registration of the app. `sdkManagerProductDidChangeFrom:to:` delegate method will be called if the connection succeeded.
 *
 *  @return YES if the connection has started successfully.
 */
+ (BOOL)startConnectionToProduct;

/**
 * Disconnect the existing connection to the DJI product.
 */
+ (void)stopConnectionToProduct;

/**
 *  Set the SDK to close the connection automatically when the app enters the background, and resume connection automatically when the app enters the foreground. Default is YES.
 *
 *  @param isClose Determines whether to close the connection when the app enters the background.
 */
+ (void)closeConnectionWhenEnterBackground:(BOOL)isClose;

/**
 *  Gets the DJI Mobile SDK Version.
 *
 *  @return SDK version as a string.
 */
+ (NSString *)getSDKVersion;

/**
 *  Enter debug mode with debug ID.
 *
 *  @param debugId Debug ID from the DJI Bridge App.
 */
+ (void)enterDebugModeWithDebugId:(NSString *)debugId;

/**
 *  Enter enable remote logging with log server URL.
 *
 *  @param deviceID Optional device ID to uniquely identify logs from an installation.
 *  @param url URL of the remote log server.
 */
+ (void)enableRemoteLoggingWithDeviceID:(NSString *_Nullable)deviceID logServerURLString:(NSString *)url;

@end

/*********************************************************************************/
#pragma mark - DJISDKManager (DebugServer)
/*********************************************************************************/

/**
 *  This class provides methods for you to start and stop the SDK debug server. You can use them with the DJI Bridge App for remote debugging.
 */
@interface DJISDKManager (DebugServer)
/**
 *  Start the debug server.
 *
 *  @param completion block returns the IP address of the server.
 */
+ (void)startSDKDebugServerWithCompletion:(void (^)(NSString *ipaddress))block;

/**
 * Register the delegate object to get the connection status of the debug server with the Remote controller and the debug client.
 */
+ (void)setDebugServerDelegate:(id<DJISDKDebugServerDelegate>)delegate;

/**
 * Stop the debug server and release the service objects used by the server.
 */
+ (void)stopSDKDebugServer;

@end

NS_ASSUME_NONNULL_END
