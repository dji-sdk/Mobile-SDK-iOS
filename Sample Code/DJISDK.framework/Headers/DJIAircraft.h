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

NS_ASSUME_NONNULL_BEGIN

/**
 *  The Aircraft's model name is unknown.
 */
extern NSString *const DJIAircraftModelNameUnknownAircraft;
/**
 *  The Aircraft's model name is Inspire 1.
 */
extern NSString *const DJIAircraftModelNameInspire1;
/**
 *  The Aircraft's model name is Inspire 1 Pro.
 */
extern NSString *const DJIAircraftModelNameInspire1Pro;
/**
 *  The Aircraft's model name is Inspire 1 Raw.
 */
extern NSString *const DJIAircraftModelNameInspire1RAW;
/**
 *  The Aircraft's model name is Phantom 3 Professional.
 */
extern NSString *const DJIAircraftModelNamePhantom3Professional;
/**
 *  The Aircraft's model name is Phantom 3 Advanced.
 */
extern NSString *const DJIAircraftModelNamePhantom3Advanced;
/**
 *  The Aircraft's model name is Phantom 3 Standard.
 */
extern NSString *const DJIAircraftModelNamePhantom3Standard;
/**
 *  The Aircraft's model name is Phantom 3 4K.
 */
extern NSString *const DJIAircraftModelNamePhantom34K;
/**
 *  The Aircraft's model name is Matrice 100.
 */
extern NSString *const DJIAircraftModelNameMatrice100;
/**
 *  The Aircraft's model name is Phantom 4.
 */
extern NSString *const DJIAircraftModelNamePhantom4;
/**
 *  The Aircraft's model name is Matrice 600.
 */
extern NSString *const DJIAircraftModelNameMatrice600;
/**
 *  The Aircraft's model name is A3.
 */
extern NSString *const DJIAircraftModelNameA3;

/**
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
 *  Returns an array of aircraft's batteries.
 *  It is used when the aircraft has multiple batteries, e.g. Matrice 600.
 *
 *  @see DJIBattery
 */
@property(nonatomic, readonly) NSArray<DJIBattery *> *_Nullable batteries;

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
