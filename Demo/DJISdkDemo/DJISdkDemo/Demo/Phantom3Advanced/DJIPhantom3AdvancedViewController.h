//
//  DJIRootViewController.h
//  DJISdkDemo
//
//  Created by Ares on 14-6-27.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJIBaseViewController.h"

@interface DJIPhantom3AdvancedViewController : DJIBaseViewController

@property(nonatomic, weak) IBOutlet UILabel* versionLabel;

-(IBAction) onCameraButtonClicked:(id)sender;

-(IBAction) onManinControllerButtonClicked:(id)sender;

-(IBAction) onNavigationButtonClicked:(id)sender;

-(IBAction) onGimbalButtonClicked:(id)sender;

-(IBAction) onBatteryButtonClicked:(id)sender;

-(IBAction) onMediaButtonClicked:(id)sender;

-(IBAction) onRemoteControllerButtonClicked:(id)sender;

-(IBAction) onImageTransmitterButtonClicked:(id)sender;

@end
