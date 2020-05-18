//
//  DJIAircraftAnnotation.m
//  Phantom3
//
//  Created by Ares on 14-8-21.
//  Copyright (c) 2014年 Jerome.zhang. All rights reserved.
//

#import "DJIAircraftAnnotation.h"

@implementation DJIAircraftAnnotation
{
    NSString* _annotationTitle;
}

+ (instancetype)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate heading:(CGFloat)heading
{
    DJIAircraftAnnotation *instance = [self annotationWithCoordinate:coordinate];
    if (instance) {
        instance.heading = heading;
    }
    
    return instance;
}

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
    }
    
    return self;
}

-(id) init
{
    self = [super init];
    if (self) {
        _annotationTitle = nil;
    }
    
    return self;
}

-(void) setAnnotationTitle:(NSString*)title
{
    _annotationTitle = title;
}

-(NSString*) title
{
    return _annotationTitle;
}

@end
