//
//  DJIWhitelistOverlay.h
//  DJISdkDemo
//
//  Created by Tim Lee on 2017/4/18.
//  Copyright © 2017年 DJI. All rights reserved.
//

#import "DJIMapOverlay.h"
#import "DJISDK/DJISDK.h"

@interface DJIWhitelistOverlay : DJIMapOverlay

@property(nonatomic, strong) DJICustomUnlockZone *whitelistInformation;

- (instancetype)initWithWhitelistInformation:(DJICustomUnlockZone *)information andEnabled:(BOOL)enabled;

@end
