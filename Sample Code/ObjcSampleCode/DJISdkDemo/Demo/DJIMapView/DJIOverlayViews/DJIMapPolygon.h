//
//  DJIMapPolygon.h
//  Phantom3
//
//  Created by sunny.li on 17/2/9.
//  Copyright © 2017年 DJIDevelopers.com. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DJIMapPolygon : MKPolygon

@property (copy, nonatomic) UIColor *strokeColor;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat lineDashPhase;
@property (nonatomic, assign) CGLineCap lineCap;
@property (nonatomic, assign) CGLineJoin lineJoin;
@property (nonatomic, strong) NSArray<NSNumber*> *lineDashPattern;

@end
