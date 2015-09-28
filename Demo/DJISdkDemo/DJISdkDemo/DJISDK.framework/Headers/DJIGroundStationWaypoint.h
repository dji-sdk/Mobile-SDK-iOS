//
//  DJIGroundStationWaypoint.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <DJISDK/DJIFoundation.h>


@interface DJIGroundStationWaypoint : NSObject

/**
 *  Coordinate of waypoint (degree)
 */
@property(nonatomic) CLLocationCoordinate2D coordinate;

/**
 *  Altitude of waypoint (meters)
 */
@property(nonatomic) float altitude;

/**
 *  Heading of aircraft when reached to this waypoint. range in [-180, 180].
 */
@property(nonatomic) float heading;

/**
 *  Horizontal velocity of aircraft when reached to this waypoint, in range [0, 7] (m/s)
 */
@property(nonatomic) float horizontalVelocity;

/**
 *  Time for aircraft staying at this waypoint (second).
 *  
 *  @attention Phantom 2 vision/Phantom 2 vision+ supported only.
 */
@property(nonatomic) int stayTime;

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
