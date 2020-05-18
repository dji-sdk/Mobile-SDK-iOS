//
//  DJIAircraftAnnotationView.h
//  DJISdkDemo
//
//  Created by DJI on 15/4/27.
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DJIAircraftAnnotationView : MKAnnotationView

- (instancetype)initWithAnnotation:(id <MKAnnotation>)annotation alpha:(CGFloat)alpha reuseIdentifier:(NSString *)reuseIdentifier;
-(void) updateHeading:(float)heading;

@end
