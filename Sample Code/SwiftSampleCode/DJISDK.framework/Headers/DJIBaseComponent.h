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
 *  The DJIComponentConnectivityDelegate defines methods that are called by DJIBaseComponent object
 *  in response to the connectivity change.
 *
 */
@protocol DJIComponentConnectivityDelegate <NSObject>

@optional

/**
 *  Called when connectivity status changed for the component.
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
 *  Use this delegate to get notified on connectivity status changes.
 */
@property (nonatomic, weak) id<DJIComponentConnectivityDelegate> connectivityDelegate;

/**
 *  The connectivity of the component.
 */
@property (assign, nonatomic, readonly, getter = isConnected) BOOL connected;

/**
 *  The name of the component. Different types of components will have different names.
 */
@property (copy, nonatomic, readonly)  NSString *_Nonnull name;

/**
 *  Product to which this component is connected
 */
@property (nonatomic, readonly, weak)  DJIBaseProduct *_Nullable product;

/**
 *  Get component's firmware version
 *
 */
- (void)getFirmwareVersionWithCompletion:(void (^)(NSString *_Nullable version, NSError *_Nullable error))block;

/**
 *  Get serial number of the component. Please note this serial number does not match with the serial number found in the physical component.
 *
 */
- (void)getSerialNumberWithCompletion:(void (^)(NSString *_Nullable serialNumber, NSError *_Nullable error))block;

@end

NS_ASSUME_NONNULL_END
