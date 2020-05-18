//
//  DJIWaypointV2FlightPathOverlays.m
//  SDK QA
//
//  Created by Tim Lee on 2018/12/4.
//  Copyright © 2018 DJI. All rights reserved.
//

#import "DJIWaypointV2FlightPathOverlays.h"

@implementation DJIWaypointV2FlightPathOverlays

- (instancetype)initWithWaypointFlightPath:(const CLLocationCoordinate2D *)coords count:(NSUInteger)count {
	self = [super init];
	if (self) {
		self.subOverlays = [NSMutableArray array];
		MKPolyline* line = [MKPolyline polylineWithCoordinates:coords count:count];
		[self.subOverlays addObject:line];
	}
	return self;
}

@end
