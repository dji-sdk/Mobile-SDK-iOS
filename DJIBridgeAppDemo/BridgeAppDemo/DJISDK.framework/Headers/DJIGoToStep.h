//
//  DJIGoToStep.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <DJISDK/DJISDK.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class represents a go-to step for a custom mission. By creating an object of this class and adding it into
 *  a custom mission, the aircraft will go to the specific location during the custom mission execution.
 */
@interface DJIGoToStep : DJIMissionStep

/**
 *  Flight speed of aircraft when going to the target location. Default is 8 m/s.
 */
@property(nonatomic, assign) float flightSpeed;

/**
 *  Go to coordinate from current aircraft position.
 *
 *  @param coorinate Target coorinate.
 *
 *  @return Instance of DJIGoToStep.
 */
- (instancetype _Nullable)initWithCoordinate:(CLLocationCoordinate2D)coorinate;

/**
 *  Go to altitude from current aircraft position.
 *
 *  @param altitude Target altitude in meters.
 *
 *  @return Instance of DJIGoToStep.
 */
- (instancetype _Nullable)initWithAltitude:(float)altitude;

/**
 *  Go to coordinate and alitude (in meters) from current aircraft position.
 *
 *  @param coorinate Target coordinate
 *  @param altitude  Target altitude in meters
 *
 *  @return Instance of DJIGoToStep.
 */
- (instancetype _Nullable)initWithCoordinate:(CLLocationCoordinate2D)coorinate altitude:(float)altitude;

@end

NS_ASSUME_NONNULL_END