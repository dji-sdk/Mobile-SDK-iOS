//
//  GSFlyLimitCircleView.h
//  DJEye
//
//  Created by Ares on 14-4-29.
//  Copyright (c) 2014年 Sachsen & DJI. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "DJIFlyLimitCircle.h"

@interface DJIFlyLimitCircleView : MKCircleRenderer


- (id)initWithCircle:(DJIFlyLimitCircle *)circle;

@end
