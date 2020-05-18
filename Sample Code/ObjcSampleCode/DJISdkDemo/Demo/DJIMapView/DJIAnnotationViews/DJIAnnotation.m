//
//  DJIAnnotation.m
//  Phantom3
//
//  Created by Jayce Yang on 14-4-10.
//  Copyright (c) 2014年 Jerome.zhang. All rights reserved.
//

#import "DJIAnnotation.h"
#import "DJIAnnotationView.h"

@interface DJIAnnotation ()

@end

@implementation DJIAnnotation

- (void)dealloc
{
    if (_backGroundAnnotation && _mapView) {
        if ([NSThread isMainThread]) {
           [self.mapView removeAnnotation:_backGroundAnnotation];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.mapView removeAnnotation:self.backGroundAnnotation];
            });
        }
        
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        
        self.index = 0;
    }
    return self;
}

//- (void)dealloc
//{
//    NSLog();
//}

+ (instancetype)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    DJIAnnotation *annotation = [[self alloc] init];
    annotation.coordinate = coordinate;
    return annotation;
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    _coordinate = coordinate;
    if (_backGroundAnnotation) {
        [_backGroundAnnotation setCoordinate:coordinate];
    }
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate animation:(bool)animation
{
    _coordinate = coordinate;
    if (_backGroundAnnotation) {
        [_backGroundAnnotation setCoordinate:coordinate animation:animation];
    }
}

- (void)createBackgroundAnnotation
{
    DJIAnnotation *annotation = [DJIAnnotation annotationWithCoordinate:_coordinate];
    annotation.isBackgroundAnnotation = YES;
    
    if (_mapView) {
        [_mapView addAnnotation:annotation];
    }
    
    _backGroundAnnotation = annotation;
}
@end
