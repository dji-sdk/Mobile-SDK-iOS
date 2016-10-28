//
//  DJIHandheld.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIBaseProduct.h>

@class DJIFlightController;
@class DJIGimbal;
@class DJIBattery;
@class DJICamera;
@class DJIHandheldController;
@class DJIAirLink;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Handheld device model name unknown.
 */
extern NSString *const DJIHandheldModelNameUnknownHandheld;

/**
 *  Handheld device model name Osmo.
 */
extern NSString *const DJIHandheldModelNameOsmo;

/**
 *  Handheld device model name Osmo Pro.
 */
extern NSString *const DJIHandheldModelNameOsmoPro;

/**
 *  Handheld device model name Osmo RAW.
 */
extern NSString *const DJIHandheldModelNameOsmoRAW;

/**
 *  Handheld device model name Osmo Mobile.
 */
extern NSString *const DJIHandheldModelNameOsmoMobile;

/**
 *  Handheld device model name Osmo+.
 */
extern NSString *const DJIHandheldModelNameOsmoPlus;

/**
 *
 *  This class contains the components of a handheld device.
 */
@interface DJIHandheld : DJIBaseProduct

/**
 *  Returns an instance of the handheld device's camera.
 */
@property(nonatomic, readonly) DJICamera *_Nullable camera;

/**
 *  Returns an instance of the handheld device's gimbal.
 */
@property(nonatomic, readonly) DJIGimbal *_Nullable gimbal;

/**
 *  Returns an instance of the handheld device's battery.
 */
@property(nonatomic, readonly) DJIBattery *_Nullable battery;

/**
 *  Returns an instance of the handheld device's handheldController.
 */
@property(nonatomic, readonly) DJIHandheldController *_Nullable handheldController;

/**
 *  Returns an instance of the handheld's airLink.
 */
@property(nonatomic, readonly) DJIAirLink *_Nullable airLink;

/**
 *  Sets the handheld device's name (also the Bluetooth name). The name cannot
 *  be more than 20 characters.
 *  It is only supported by Osmo Mobile.
 *
 *  @param name         Name to be set to the device.
 *  @param completion   Completion block.
 */
- (void)setHandheldName:(NSString *)name withCompletion:(DJICompletionBlock)completion;

/**
 *  Returns the handheld device's name.
 *  It is only supported by Osmo Mobile.
 *
 *  @param completion Completion block that returns the getter result.
 */
- (void)getHandheldNameWithCompletion:(void (^)(NSString *name, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END