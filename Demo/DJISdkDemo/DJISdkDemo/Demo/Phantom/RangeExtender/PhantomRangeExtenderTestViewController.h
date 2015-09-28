//
//  RangeExtenderTestViewController.h
//  DJISdkDemo
//
//  Created by Ares on 14-7-16.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import "MBProgressHUD.h"

@interface PhantomRangeExtenderTestViewController : UIViewController<UITextFieldDelegate, DJIRangeExtenderDelegate>
{
    DJIDrone* _drone;
    DJIRangeExtender* _rangeExtender;
    UILabel* _powerStatusLabel;
    MBProgressHUD* _progressHUD;
    
    NSTimer* _updatePowerLevelTimer;
}

@property(nonatomic, strong) IBOutlet UILabel* extenderMACLabel;
@property(nonatomic, strong) IBOutlet UILabel* extenderSSIDLabel;
@property(nonatomic, strong) IBOutlet UILabel* cameraMACLabel;
@property(nonatomic, strong) IBOutlet UILabel* cameraSSIDLabel;
@property(nonatomic, strong) IBOutlet UITextField* extenderNewSsidTextField;
@property(nonatomic, strong) IBOutlet UITextField* cameraNewMacTextField;
@property(nonatomic, strong) IBOutlet UITextField* cameraNewSsidTextField;


-(IBAction) onGetButtonClicked:(id)sender;

-(IBAction) onRenameButtonClicked:(id)sender;

-(IBAction) onBindNewButtonClicked:(id)sender;
@end
