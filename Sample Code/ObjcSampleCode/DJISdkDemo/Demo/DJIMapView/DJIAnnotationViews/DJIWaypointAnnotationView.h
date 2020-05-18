//
//  DJIWaypointAnnotationView.h
//  DJISdkDemo
//
//  Created by DJI on 15/7/2.
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DJIWaypointAnnotationView : MKAnnotationView

@property(nonatomic, strong) UILabel* titleLabel;

- (instancetype)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;
@end
