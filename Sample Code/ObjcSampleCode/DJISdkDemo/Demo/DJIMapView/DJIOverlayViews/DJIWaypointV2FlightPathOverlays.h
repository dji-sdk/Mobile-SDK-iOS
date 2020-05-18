//
//  DJIWaypointV2FlightPathOverlays.h
//  SDK QA
//
//  Created by Tim Lee on 2018/12/4.
//  Copyright © 2018 DJI. All rights reserved.
//

#import "DJIMapOverlay.h"

@interface DJIWaypointV2FlightPathOverlays : DJIMapOverlay

- (instancetype)initWithWaypointFlightPath:(const CLLocationCoordinate2D *)coords count:(NSUInteger)count;

@end
