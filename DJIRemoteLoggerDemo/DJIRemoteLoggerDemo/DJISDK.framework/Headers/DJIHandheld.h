//
//  DJIHandheld.h
//  DJISDK
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIBaseProduct.h>

@class DJIFlightController;
@class DJIGimbal;
@class DJIBattery;
@class DJICamera;
@class DJIHandheldController;

NS_ASSUME_NONNULL_BEGIN

@interface DJIHandheld : DJIBaseProduct

/**
 *  Returns an instance of the handheld device's camera.
 */
@property(nonatomic, readonly) DJICamera* _Nullable camera;

/**
 *  Returns an instance of the handheld device's gimbal.
 */
@property(nonatomic, readonly) DJIGimbal* _Nullable gimbal;

/**
 *  Returns an instance of the handheld device's battery.
 */
@property(nonatomic, readonly) DJIBattery* _Nullable battery;

/**
 *  Returns an instance of the handheld device's handheldController.
 */
@property(nonatomic, readonly) DJIHandheldController* _Nullable handheldController;

@end

NS_ASSUME_NONNULL_END