//
//  DJIBaseComponent.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIBaseProduct.h>

NS_ASSUME_NONNULL_BEGIN
@class DJIBaseComponent;
@class DJIBaseProduct;

/**
 *  The `DJIComponentConnectivityDelegate` defines methods that are called by the `DJIBaseComponent` object
 *  in response to a connectivity change.
 *  A component can be a camera, gimbal, remote controller, etc. A DJI product consists of several components.
 *
 */
@protocol DJIComponentConnectivityDelegate <NSObject>

@optional

/**
 *  Called when the connectivity status has changed for the component.
 */
- (void)component:(DJIBaseComponent *)component connectivityChanged:(BOOL)isConnected;

@end

/**
 *  Abstract class for components in a DJI Product.
 *  A component can be a camera, gimbal, remote controller, etc. A DJI product consists of several
 *  components.
 */
@interface DJIBaseComponent : NSObject

/**
 *  Use this delegate to be notified about connectivity status changes.
 */
@property (nonatomic, weak) id<DJIComponentConnectivityDelegate> connectivityDelegate;

/**
 *  The connectivity status of the component.
 */
@property (assign, nonatomic, readonly, getter = isConnected) BOOL connected;

/**
 *  The product to which this component is connected.
 */
@property (nonatomic, readonly, weak)  DJIBaseProduct *_Nullable product;

/**
 *  Get the component's firmware version.
 *
 */
- (void)getFirmwareVersionWithCompletion:(void (^)(NSString *_Nullable version, NSError *_Nullable error))block;

/**
 *  Get the serial number of the component. Note that this serial number does not match the serial number found on the physical component.
 *
 */
- (void)getSerialNumberWithCompletion:(void (^)(NSString *_Nullable serialNumber, NSError *_Nullable error))block;

@end

NS_ASSUME_NONNULL_END
