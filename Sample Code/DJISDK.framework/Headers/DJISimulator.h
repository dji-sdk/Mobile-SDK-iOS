//
//  DJISimulator.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#import <DJISDK/DJIBaseProduct.h>
#import <CoreLocation/CLLocation.h>
#import <DJISDK/DJISimulatorState.h>

NS_ASSUME_NONNULL_BEGIN

@class DJISimulator;

/**
 *  This protocol provides the delegate method of the simulator.
 */
@protocol DJISimulatorDelegate <NSObject>
@optional

/**
 *  Updates the simulator's current state.
 */
- (void)simulator:(DJISimulator *_Nonnull)simulator updateSimulatorState:(DJISimulatorState *_Nonnull)state;

@end

/**
 *  DJI aircraft can be put into simulation mode using this class. Developers can start and stop the simulation, as well as monitor basic aircraft attitude and location information.
 */
@interface DJISimulator : NSObject

/**
 *  Returns the delegate of simulator.
 */
@property(nonatomic, weak) id<DJISimulatorDelegate> delegate;

/**
 *  `YES` if the simulator is started.
 */
@property(nonatomic, readonly) BOOL isSimulatorStarted;

/**
 *  Start simulator. Will result in error if simulation is already started.
 *
 *  @param location     Simulator coordinate latitude and longitude in degrees.
 *  @param frequency    Aircraft simulator state push frequency in Hz with range
 *                      [2, 150]. A setting of 10 Hz will result in delegate
 *                      method being called, 10 times per second.
 *  @param number       The initial number of GPS satellites with range [0, 20].
 *  @param block        The completion block.
 */
- (void)startSimulatorWithLocation:(CLLocationCoordinate2D)location
                   updateFrequency:(NSUInteger)frequency
               GPSSatellitesNumber:(NSUInteger)number
                    withCompletion:(DJICompletionBlock)block;

/**
 *  Stop the simulator.
 *
 *  @param block The Completion block.
 */
- (void)stopSimulatorWithCompletion:(DJICompletionBlock)block;

/**
 *  Enable/disable the fly zone system in the simulator. 
 *  By default, fly zone is disabled in the simulator. Rebooting the aircraft is
 *  required to make the setting take effect.
 *
 *  @param enabled  `YES` to enable the fly zone in the simulator.
 *  @param block    The execution block with the returned execution result.
 */
- (void)setFlyZoneEnabled:(BOOL)enabled withCompletion:(DJICompletionBlock)block;

/**
 *  Gets if the fly zone system is enabled in the simulator. By default, fly
 *  zone is disabled in the simulator.
 *
 *  @param block    The execution callback with the returned value.
 */
- (void)getFlyZoneEnabledWithCompletion:(void(^)(BOOL enabled, NSError *_Nullable error))block;

@end

NS_ASSUME_NONNULL_END

