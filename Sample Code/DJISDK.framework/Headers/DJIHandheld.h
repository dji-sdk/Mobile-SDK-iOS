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

@end

NS_ASSUME_NONNULL_END