//
//  DJICircle.h
//  Phantom3
//
//  Created by sunny.li on 15/7/24.
//  Copyright (c) 2015年 DJIDevelopers.com. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DJICircle : MKCircle

@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, assign) CGFloat lineWidth;

@end
