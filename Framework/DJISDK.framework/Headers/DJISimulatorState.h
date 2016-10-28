//
//  DJISimulatorState.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

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
 *  Simulated aircraft X (East-West) distance from initial simulator location
 *  where East is positive and North-East-Down coordinate system is used.
 */
@property(nonatomic, readonly) float positionX;

/**
 *  Simulated aircraft Y (North-South) distance from initial simulator location
 *  where North is positive and North-East-Down coordinate system is used.
 */
@property(nonatomic, readonly) float positionY;

/**
 *  Simulated aircraft Z (Vertical direction). The value should be negative if
 *  the height of aircraft is higher than initial home point's height.
 */
@property(nonatomic, readonly) float positionZ;

@end
