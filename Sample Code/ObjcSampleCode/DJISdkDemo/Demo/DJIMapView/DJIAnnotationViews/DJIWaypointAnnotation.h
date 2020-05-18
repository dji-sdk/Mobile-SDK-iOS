//
//  DJIWaypointAnnotation.h
//  DJISdkDemo
//
//  Created by DJI on 15/7/2.
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DJIWaypointAnnotation : NSObject<MKAnnotation>

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, strong) NSString* text;

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
