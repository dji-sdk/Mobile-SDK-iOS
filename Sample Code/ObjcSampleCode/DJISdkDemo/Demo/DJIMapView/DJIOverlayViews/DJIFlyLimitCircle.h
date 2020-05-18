//
//  GSFlyLimitCircle.h
//  DJEye
//
//  Created by Ares on 14-4-28.
//  Copyright (c) 2014年 Sachsen & DJI. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DJIFlyLimitCircle : MKCircle



@property (nonatomic, assign) CLLocationCoordinate2D realCoordinate;

@property (nonatomic, assign) CGFloat outerRadius;
@property (nonatomic, assign) CGFloat innerRadius;
@property (nonatomic, assign) BOOL isClosed;
@property (nonatomic, assign) uint8_t category;
@property (nonatomic, assign) NSUInteger flyZoneID;
@property (nonatomic, copy  ) NSString* name;
//@property (nonatomic, assign) BOOL isWarning;
//@property (nonatomic, assign) BOOL canUnLock;

@end
