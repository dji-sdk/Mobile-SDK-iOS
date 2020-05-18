//
//  DJIWaypointAnnotation.m
//  DJISdkDemo
//
//  Created by DJI on 15/7/2.
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import "DJIWaypointAnnotation.h"

@implementation DJIWaypointAnnotation

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if (self) {
        _coordinate = coordinate;
    }
    return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
}

@end
