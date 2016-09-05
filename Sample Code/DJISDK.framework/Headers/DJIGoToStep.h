//
//  DJIGoToStep.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <DJISDK/DJIMissionStep.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class represents a go-to step for a custom mission. By creating an object of this class and adding it to
 *  a custom mission, the aircraft will go to the specified location during the custom mission execution.
 */
@interface DJIGoToStep : DJIMissionStep

/**
 *  Flight speed of the aircraft when going to the target location. Default is 8 m/s.
 */
@property(nonatomic, assign) float flightSpeed;

/**
 *  Go to the specified coordinate from the current aircraft position.
 *
 *  @param coordinate Target coordinate.
 *
 *  @return Instance of `DJIGoToStep`.
 */
- (instancetype _Nullable)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 *  Go to the specified altitude from the current aircraft position.
 *
 *  @param altitude Target altitude in meters.
 *
 *  @return Instance of `DJIGoToStep`.
 */
- (instancetype _Nullable)initWithAltitude:(float)altitude;

/**
 *  Go to the specified coordinate and altitude (in meters) from the current aircraft position.
 *
 *  @param coordinate Target coordinate.
 *  @param altitude  Target altitude in meters.
 *
 *  @return Instance of `DJIGoToStep`.
 */
- (instancetype _Nullable)initWithCoordinate:(CLLocationCoordinate2D)coordinate altitude:(float)altitude;

@end

NS_ASSUME_NONNULL_END