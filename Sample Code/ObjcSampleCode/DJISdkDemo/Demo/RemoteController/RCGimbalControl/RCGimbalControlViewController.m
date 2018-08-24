//
//  RCGimbalControlViewController.m
//  DJISdkDemo
//
//  Copyright © 2018 DJI. All rights reserved.
//
/**
 *  This file demonstrates how to read and set the gimbal controlled by the RC in aircrafts which have the capability for multiple gimbals,
 *  i.e. M210 and M210RTK.
 */

#import "RCGimbalControlViewController.h"
#import <DJISDK/DJISDK.h>

@interface RCGimbalControlViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *gimbalSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;

@end

@implementation RCGimbalControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    __weak __typeof__(self) weakSelf = self;
    DJIRemoteControllerKey *key = [DJIRemoteControllerKey keyWithIndex:0 andParam:DJIRemoteControllerParamControllingGimbalIndex];
    [[DJISDKManager keyManager] startListeningForChangesOnKey:key withListener:self andUpdateBlock:^(DJIKeyedValue * _Nullable oldValue, DJIKeyedValue * _Nullable newValue) {
        if (newValue) {
            weakSelf.gimbalSegmentedControl.selectedSegmentIndex = newValue.integerValue;
        }
    }];
    [[DJISDKManager keyManager] getValueForKey:key withCompletion:^(DJIKeyedValue * _Nullable value, NSError * _Nullable error) {
        if (error) {
            weakSelf.errorMessageLabel.text = [NSString stringWithFormat:@"Error messge: %@",error.description];
        } else {
            if (value) {
                weakSelf.gimbalSegmentedControl.selectedSegmentIndex = value.integerValue;
            }
        }
    }];
}

- (IBAction)gimbalSegmentedControlValueChanged:(id)sender {
    __weak __typeof__(self) weakSelf = self;
    DJIRemoteControllerKey *key = [DJIRemoteControllerKey keyWithIndex:0 andParam:DJIRemoteControllerParamControllingGimbalIndex];
    [[DJISDKManager keyManager] setValue:@(self.gimbalSegmentedControl.selectedSegmentIndex) forKey:key withCompletion:^(NSError * _Nullable error) {
        if (error) {
            weakSelf.errorMessageLabel.text = [NSString stringWithFormat:@"Error messge: %@",error.description];
            [[DJISDKManager keyManager] getValueForKey:key withCompletion:^(DJIKeyedValue * _Nullable value, NSError * _Nullable error) {
                if (error) {
                    weakSelf.errorMessageLabel.text = [NSString stringWithFormat:@"Error messge: %@",error.description];
                } else {
                    if (value) {
                        weakSelf.gimbalSegmentedControl.selectedSegmentIndex = value.integerValue;
                    }
                }
            }];
        }
    }];
}

@end
