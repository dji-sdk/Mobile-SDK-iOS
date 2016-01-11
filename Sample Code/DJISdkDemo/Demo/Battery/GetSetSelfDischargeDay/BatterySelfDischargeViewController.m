//
//  BatterySelfDischargeViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates how to change setting through DJIBattery.
 */
#import "BatterySelfDischargeViewController.h"
#import "DemoUtility.h"
#import <DJISDK/DJISDK.h>

@interface BatterySelfDischargeViewController ()

@end

@implementation BatterySelfDischargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Self Discharge Days";
    self.rangeLabel.text = @"The input should be an integer. The range is [1, 10]. ";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onGetButtonClicked:(id)sender {
    [self updateSelfDischargeDay];
}

-(void) updateSelfDischargeDay {
    DJIBattery* battery = [DemoComponentHelper fetchBattery];
    if (battery) {
        WeakRef(target);
        [battery getSelfDischargeDayWithCompletion:^(uint8_t day, NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"ERROR: getBatterySelfDischargeDay. %@", error.description);
            }
            else {
                NSString* getTextString = [NSString stringWithFormat:@"%u", day];
                target.getValueTextField.text = getTextString;
            }
        }];
    }
}

- (IBAction)onSetButtonClicked:(id)sender {
    DJIBattery* battery = [DemoComponentHelper fetchBattery];
    if (battery) {
        int selDischargeDay = [self.setValueTextField.text intValue];

        [battery setSelfDischargeDay:selDischargeDay withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"ERROR: setBatterySelfDischargeDay. %@. ", error.description);
            }
            else {
                ShowResult(@"Succeed. ");
            }
        }];
    }
}

@end
