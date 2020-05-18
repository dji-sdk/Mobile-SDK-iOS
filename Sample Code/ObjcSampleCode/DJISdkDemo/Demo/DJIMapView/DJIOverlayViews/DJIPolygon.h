//
//  DJIPolygon.h
//  Phantom3
//
//  Created by sunny.li on 15/12/12.
//  Copyright © 2015年 DJIDevelopers.com. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DJIPolygon : MKPolygon

/**
 *  根据level决定线条颜色
 */
/*
@property (copy, nonatomic) UIColor *strokeColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat lineDashPhase;
@property (nonatomic, assign) CGLineCap lineCap;
@property (nonatomic, assign) CGLineJoin lineJoin;
@property (nonatomic, strong) NSArray<NSNumber*> *lineDashPattern;
 */

@property (nonatomic, assign) uint8_t level;

@end
