//
//  GSFlyLimitCircle.m
//  DJEye
//
//  Created by Ares on 14-4-28.
//  Copyright (c) 2014年 Sachsen & DJI. All rights reserved.
//

#import "DJIFlyLimitCircle.h"

@implementation DJIFlyLimitCircle

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%f, %f), innerRadius: %f, outterRadius: %f, level: %d", [super description], _realCoordinate.latitude, _realCoordinate.longitude, _innerRadius, _outerRadius, _category];
}
@end
