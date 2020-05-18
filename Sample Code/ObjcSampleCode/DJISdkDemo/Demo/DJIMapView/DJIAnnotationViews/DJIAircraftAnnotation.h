//
//  DJIAircraftAnnotation.h
//  Phantom3
//
//  Created by Ares on 14-8-21.
//  Copyright (c) 2014年 Jerome.zhang. All rights reserved.
//

#import "DJIAnnotation.h"
#import <DJISDK/DJISDK.h>

@interface DJIAircraftAnnotation : DJIAnnotation

@property (nonatomic, assign) CGFloat heading;

@property (nonatomic) DJIAirSenseAirplaneState *state; 

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate;

-(void) setAnnotationTitle:(NSString*)title;
+ (instancetype)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate heading:(CGFloat)heading;
@end
