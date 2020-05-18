//
//  DJILimitSpaceOverlay.h
//  Phantom3
//
//  Created by DJISoft on 2017/1/19.
//  Copyright © 2017年 DJIDevelopers.com. All rights reserved.
//

#import "DJIMapOverlay.h"
#import "DJISDK/DJISDK.h"

@interface DJILimitSpaceOverlay : DJIMapOverlay

@property (nonatomic, readonly) DJIFlyZoneInformation *limitSpaceInfo;

- (id)initWithLimitSpace:(DJIFlyZoneInformation *)limitSpaceInfo;

@end
