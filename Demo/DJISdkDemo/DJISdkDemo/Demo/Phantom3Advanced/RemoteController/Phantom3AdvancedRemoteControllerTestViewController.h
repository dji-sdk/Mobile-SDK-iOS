//
//  InspireRemoteControllerTestViewController.h
//  DJISdkDemo
//
//  Created by Ares on 15/4/9.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import "DJIDemoHelper.h"
#import "DJIBaseViewController.h"

@interface Phantom3AdvancedRemoteControllerTestViewController : DJIBaseViewController<UITableViewDataSource, UITableViewDelegate, DJIRemoteControllerDelegate>
{
    NSMutableArray* mTestItems;
    NSMutableArray* mRCList;
    
    DJIDrone* mDrone;
    DJIPhantom3AdvancedRemoteController * mRemoteController;
    DJIRCHardwareState mLastHardwareState;
    DJIRCBatteryInfo mRCBatteryInfo;
    int mWheelOffset;
}


@property(nonatomic, strong) IBOutlet UITableView* tableView;
@property(nonatomic, strong) IBOutlet UIView* subContentView;
@property(nonatomic, strong) IBOutlet UISegmentedControl* controlModeSegmentedControl;

@property(nonatomic, strong) UILabel* topBarLabel;

-(IBAction) onRCControlModeSegmentedControlValueChanged:(UISegmentedControl*)sender;

-(IBAction) onEnterParingModeButtonClicked:(id)sender;

-(IBAction) onExitParingModeButtonClicked:(id)sender;

@end
