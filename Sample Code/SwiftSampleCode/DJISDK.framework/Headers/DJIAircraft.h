//
//  DJIAircraft.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIBaseProduct.h>

@class DJIFlightController;
@class DJIGimbal;
@class DJIBattery;
@class DJIRemoteController;
@class DJICamera;
@class DJIAirLink;
@protocol DJIAircraftDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 *
 *  This class contains the components of an aircraft.
 */
@interface DJIAircraft : DJIBaseProduct

/**
 *  Returns an instance of the aircraft's camera.
 *
 *  @see DJICamera
 */
@property(nonatomic, readonly) DJICamera *_Nullable camera;

/**
 *  Returns an instance of the aircraft's flight controller.
 *
 *  @see DJIFlightController
 */
@property(nonatomic, readonly) DJIFlightController *_Nullable flightController;

/**
 *  Returns an instance of the aircraft's gimbal.
 *
 *  @see DJIGimbal
 */
@property(nonatomic, readonly) DJIGimbal *_Nullable gimbal;

/**
 *  Returns an instance of the aircraft's smart battery.
 *
 *  @see DJIBattery
 */
@property(nonatomic, readonly) DJIBattery *_Nullable battery;

/**
 *  Returns an instance of the aircraft's remote controller.
 *
 *  @see DJIRemoteController
 */
@property(nonatomic, readonly) DJIRemoteController *_Nullable remoteController;

/**
 *  Returns an instance of the aircraft's airLink.
 *
 *  @see DJIAirLink
 */
@property(nonatomic, readonly) DJIAirLink *_Nullable airLink;

/**
 *  Sets the aircraft's name. The aircraft's name should be less than 32 characters.
 *
 *  @param name   Name to be set to the aircraft.
 *  @param completion  Completion block
 */
- (void)setAircraftName:(NSString *)name withCompletion:(DJICompletionBlock)completion;

/**
 *  Returns the aircraft's name.
 *
 *  @param completion Remote execution result callback block.
 */
- (void)getAircraftNameWithCompletion:(void (^)(NSString *name, NSError *_Nullable error))completion;

@end
NS_ASSUME_NONNULL_END
