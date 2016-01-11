//
//  DJIBaseProduct.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIBaseComponent.h>

#ifdef __cplusplus
#define DJI_API_EXTERN       extern "C" __attribute__((visibility("default")))
#else
#define DJI_API_EXTERN       extern __attribute__((visibility("default")))
#endif

#define DJI_API_DEPRECATED __attribute__((__deprecated__))

NS_ASSUME_NONNULL_BEGIN

//Keys for components dictionary
extern NSString *const DJIFlightControllerComponentKey;
extern NSString *const DJIRemoteControllerComponentKey;
extern NSString *const DJICameraComponentKey;
extern NSString *const DJIGimbalComponentKey;
extern NSString *const DJIAirLinkComponentKey;
extern NSString *const DJIBatteryComponentKey;
extern NSString *const DJIHandheldControllerComponentKey;

/**
 *  Completion block for asynchronous operations. This completion block is used for methods that return at an unknown future time.
 *
 *  @param error Error object if an error occured during async operation. nil if no error occurred.
 */
typedef void (^_Nullable DJICompletionBlock)(NSError *_Nullable error);

@class DJIBaseComponent;
@class DJIBaseProduct;

/**
 *
 *  This protocol provides delegate methods to get notified on component and product connectivity changes.
 *
 */
@protocol DJIBaseProductDelegate <NSObject>

@optional

/**
 *  Callback delegate method when a component object changed
 *
 */
- (void)componentWithKey:(NSString *)key changedFrom:(DJIBaseComponent *_Nullable)oldComponent to:(DJIBaseComponent *_Nullable)newComponent;

/**
 *  Called when connectivity status changed for the base product.
 *
 */
- (void)product:(DJIBaseProduct *)product connectivityChanged:(BOOL)isConnected;

@end

/**
 *
 *  Abstract class for all DJI Products
 */
@interface DJIBaseProduct : NSObject

/**
 *  Use this delegate to get notified on component changes and connectivity status changes.
 *
 */
@property (nonatomic, weak) id<DJIBaseProductDelegate> delegate;
/**
 *  Connectivity status. In case of aircraft, if the aircraft is out of range or turned off, then the connectivity status changes to NOT connected.
 *
 */
@property (assign, nonatomic, readonly, getter = isConnected) BOOL connected;

/**
 *  Contains a dictionary of all the available components
 *
 */
@property (nonatomic, readonly) NSDictionary<NSString *, NSArray<DJIBaseComponent *> *> *_Nullable components;

/**
 *  Get product's firmware package version
 *
 */
- (void)getFirmwarePackageVersionWithCompletion:(void (^)(NSString *_Nullable version, NSError *_Nullable error))block;

/**
 *  Returns the model of the product.
 */
@property (nonatomic, strong, readonly) NSString *_Nullable model;

@end
NS_ASSUME_NONNULL_END
