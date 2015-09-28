//
//  DJIWaypointAnnotation.h
//  DJISdkDemo
//
//  Created by Ares on 15/7/2.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DJIWaypointAnnotation : NSObject<MKAnnotation>

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, strong) NSString* text;

-(id) initWithCoordiante:(CLLocationCoordinate2D)coordinate;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
