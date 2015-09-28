//
//  BatteryTestViewController.h
//  DJISdkDemo
//
//  Created by Ares on 14-7-16.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJIDrone.h>

@interface PhantomBatteryTestViewController : UIViewController<DJIDroneDelegate>
{
    DJIDrone* _drone;
    NSTimer* _readBatteryInfoTimer;
}

@property(nonatomic, strong) IBOutlet UILabel* connectionStatusLabel;
@property(nonatomic, strong) IBOutlet UILabel* batteryStatusLabel;
@property(nonatomic, strong) IBOutlet UIButton* batteryTestButton;

-(IBAction) onBatteryTestButtonClicked:(id)sender;

@end
