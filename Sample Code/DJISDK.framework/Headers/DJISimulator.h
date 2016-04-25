//
//  DJISimulator.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#import <DJISDK/DJIBaseProduct.h>
#import <CoreLocation/CLLocation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Aircraft's state during the simulation.
 */
@interface DJISimulatorState : NSObject

/**
 *  `YES` if motors are on in simulator.
 */
@property(nonatomic, readonly) BOOL areMotorsOn;

/**
 *  `YES` if aircraft is flying in simulator.
 */
@property(nonatomic, readonly) BOOL isFlying;

/**
 *  Simulated latitude of the aircraft.
 */
@property(nonatomic, readonly) double latitude;

/**
 *  Simulated longitude of the aircraft.
 */
@property(nonatomic, readonly) double longitude;

/**
 *  Simulated aircraft pitch with range [-30, 30].
 */
@property(nonatomic, readonly) float pitch;

/**
 *  Simulated aircraft roll with range [-30, 30].
 */
@property(nonatomic, readonly) float roll;

/**
 *  Simulated aircraft yaw with range [-180, 180].
 */
@property(nonatomic, readonly) float yaw;

/**
 *  Simulated aircraft X (East-West) distance from initial simulator location where East is positive and North-East-Down coordinate system is used.
 */
@property(nonatomic, readonly) float positionX;

/**
 *  Simulated aircraft Y (North-South) distance from initial simulator location where North is positive and North-East-Down coordinate system is used.
 */
@property(nonatomic, readonly) float positionY;

/**
 *  Simulated aircraft Z (Vertical direction). The value should be negative if the height of aircraft is higher
 *  than initial home point's height.
 */
@property(nonatomic, readonly) float positionZ;

@end

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
 *  @param frequency    Aircraft simulator state push frequency in Hz with range [2, 150]. A setting of 10 Hz will result in delegate method being called, 10 times per second.
 *  @param number       The initial number of GPS satellites with range [0, 20].
 *  @param block        The Completion block.
 */
- (void)startSimulatorWithLocation:(CLLocationCoordinate2D)location updateFrequency:(NSUInteger)frequency GPSSatellitesNumber:(NSUInteger)number withCompletion:(DJICompletionBlock)block;

/**
 *  Stop the simulator.
 *
 *  @param block The Completion block.
 */
- (void)stopSimulatorWithCompletion:(DJICompletionBlock)block;

@end

NS_ASSUME_NONNULL_END

