//
//  DJIBaseProduct.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/**
 *  Completion block for asynchronous operations. This completion block is used
 *  for methods that return at an unknown future time.
 *
 *  @param error An error object if an error occurred during async operation, or
 *  nil if no error occurred.
 */
typedef void (^_Nullable DJICompletionBlock)(NSError *_Nullable error);

@class DJIBaseComponent;
@class DJIBaseProduct;
@class DJIDiagnostics;

/**
 *  This protocol provides delegate methods to be notified about component and
 *  product connectivity changes.
 */
@protocol DJIBaseProductDelegate <NSObject>

@optional

/**
 *  Callback delegate method when a component object changes.
 *
 */
- (void)componentWithKey:(NSString *)key
             changedFrom:(DJIBaseComponent *_Nullable)oldComponent
                      to:(DJIBaseComponent *_Nullable)newComponent;

/**
 *  Called when the connectivity status changes for the base product.
 *
 */
- (void)product:(DJIBaseProduct *)product connectivityChanged:(BOOL)isConnected;

/**
 *  Callback function that updates the product's current diagnostics information.
 *
 */
- (void)product:(DJIBaseProduct *_Nonnull)product didUpdateDiagnosticsInformation:(NSArray *_Nonnull)info;

@end

/**
 *
 *  Abstract class for all DJI Products.
 */
@interface DJIBaseProduct : NSObject

/**
 *  Use this delegate to be notified of component changes and connectivity 
 *  status changes.
 */
@property (nonatomic, weak) id<DJIBaseProductDelegate> delegate;
/**
 *  Connectivity status. In case of aircraft, if the aircraft is out of range or
 *  turned off, the connectivity status changes to NOT connected.
 */
@property (nonatomic, readonly, getter = isConnected) BOOL connected;

/**
 *  Contains a dictionary of all the available components.
 *
 */
@property (nonatomic, readonly) NSDictionary<NSString *, NSArray<DJIBaseComponent *> *> *_Nullable components;

/**
 *  Get the product's firmware package version. For Products except Phantom 4,
 *  Internet connection is required and the execution time for this method
 *  highly depends on the Internet status.
 *
 *  @param block Completion block to receive the result.
 *
 */
- (void)getFirmwarePackageVersionWithCompletion:(void (^)(NSString *_Nullable version, NSError *_Nullable error))block;

/**
 *  Returns the model of the product.
 */
@property (nonatomic, strong, readonly) NSString *_Nullable model;

@end
NS_ASSUME_NONNULL_END
