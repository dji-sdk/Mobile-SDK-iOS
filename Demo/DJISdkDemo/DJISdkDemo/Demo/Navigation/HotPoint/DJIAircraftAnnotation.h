//
//  DJIAircraftAnnotation.h
//  DJISdkDemo
//
//  Created by Ares on 15/4/27.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "DJIAircraftAnnotationView.h"

@interface DJIAircraftAnnotation : NSObject<MKAnnotation>

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;

-(id) initWithCoordiante:(CLLocationCoordinate2D)coordinate;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;


@end
