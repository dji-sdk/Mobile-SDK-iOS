//
//  BatteryTestViewController.h
//  DJISdkDemo
//
//  Created by Ares on 14-7-16.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import "DJIBaseViewController.h"
#import "DJIDemoHelper.h"

@interface Phantom3AdvancedBatteryTestViewController : DJIBaseViewController<DJIDroneDelegate>
{
    DJIDrone* _drone;
    NSTimer* _readBatteryInfoTimer;
}

@property(nonatomic, strong) IBOutlet UILabel* batteryStatusLabel;

@end
