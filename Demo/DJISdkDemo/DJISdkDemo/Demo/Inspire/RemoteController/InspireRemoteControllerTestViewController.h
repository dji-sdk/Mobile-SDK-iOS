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
#import "DJILogerViewController.h"
#import "DJIBaseViewController.h"

@interface InspireRemoteControllerTestViewController : DJIBaseViewController<UITableViewDataSource, UITableViewDelegate, DJIRemoteControllerDelegate>
{
    NSMutableArray* mTestItems;
    NSMutableArray* mRCList;
    
    DJIDrone* mDrone;
    DJIInspireRemoteController* mRemoteController;
    
    DJIRCHardwareState mLastHardwareState;
    DJIRCWorkMode mCurrentWorkMode;
    
    DJIRCInfo* mCurrentRCInfo;
    DJIRCInfo* mControlPermissionRequester;
    
    DJIRCBatteryInfo mRCBatteryInfo;
    
    NSTimer* mFetchAvailableMasterTimer;
    
    int mWheelOffset;
}


@property(nonatomic, strong) IBOutlet UITableView* tableView;
@property(nonatomic, strong) IBOutlet UIView* subContentView;

@property(nonatomic, strong) IBOutlet UISegmentedControl* workModeSegmentedControl;
@property(nonatomic, strong) IBOutlet UISegmentedControl* controlModeSegmentedControl;
@property(nonatomic, strong) IBOutlet UILabel* rcNameLabel;
@property(nonatomic, strong) IBOutlet UILabel* rcPasswordLabel;

@property(nonatomic, strong) UILabel* topBarLabel;

-(IBAction) onSpeedControlSliderValueChanged:(UISlider*)sender;

-(IBAction) onSpeedControlSliderDragExit:(id)sender;

-(IBAction) onSensitivityControlSlicerValueChanged:(UISlider*)sender;

-(IBAction) onSensitivityControlSlicerDragExit:(id)sender;

-(IBAction) onWorkModeSegmentedControlValueChanged:(UISegmentedControl*)sender;

-(IBAction) onRCControlModeSegmentedControlValueChanged:(UISegmentedControl*)sender;

-(IBAction) onRequestControlPermissionButtonClicked:(id)sender;

-(IBAction) onEnterParingModeButtonClicked:(id)sender;

-(IBAction) onExitParingModeButtonClicked:(id)sender;

@end
