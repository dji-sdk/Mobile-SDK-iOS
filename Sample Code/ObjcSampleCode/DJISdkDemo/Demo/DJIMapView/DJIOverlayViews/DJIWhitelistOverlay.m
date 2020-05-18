//
//  DJIWhitelistOverlay.m
//  DJISdkDemo
//
//  Created by Tim Lee on 2017/4/18.
//  Copyright © 2017年 DJI. All rights reserved.
//

#import "DJIWhitelistOverlay.h"
#import "DJICircle.h"

@implementation DJIWhitelistOverlay

- (instancetype)initWithWhitelistInformation:(DJICustomUnlockZone *)information andEnabled:(BOOL)enabled
{
    self = [self init];
    if (self) {
        _whitelistInformation = information;
        [self createOverlaysWithEnabled:enabled];
    }
    return self;
}

- (void)createOverlaysWithEnabled:(BOOL)enabled
{
    CLLocationCoordinate2D coordinateInMap = _whitelistInformation.center;
    DJICircle *circle = [DJICircle circleWithCenterCoordinate:coordinateInMap
                                                       radius:_whitelistInformation.radius];
    circle.lineWidth = 1;
    circle.fillColor = enabled ? [UIColor colorWithRed:0 green:1 blue:0 alpha:0.2] : [UIColor colorWithRed:0 green:0 blue:1 alpha:.2];
    circle.strokeColor = enabled ? [UIColor colorWithRed:0 green:1 blue:0 alpha:0.2] : [UIColor colorWithRed:0 green:0 blue:1 alpha:.2];
    self.subOverlays = [NSMutableArray array];
    [self.subOverlays addObject:circle];
}

@end
