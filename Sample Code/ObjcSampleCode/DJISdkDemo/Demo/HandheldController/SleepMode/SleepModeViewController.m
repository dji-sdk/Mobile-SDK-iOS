//
//  SleepModeViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates how to set the power mode of a handheld controller. For more information
 *  about the power mode, please refer to the inline documentation for DJIHandheldPowerMode. 
 *
 *  CAUTION: user can turn off the handheld device through SDK. However, once the device is turned 
 *  off, user need to turn on the device using the physical button. 
 */
#import "DemoUtility.h"
#import "SleepModeViewController.h"

@interface SleepModeViewController () <DJIHandheldControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *sleepButton;
@property (weak, nonatomic) IBOutlet UIButton *awakeButton;
@property (weak, nonatomic) IBOutlet UIButton *shutdownButton;

@end

@implementation SleepModeViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    DJIHandheldController* handheld = [DemoComponentHelper fetchHandheldController];
    if (handheld) {
        [handheld setDelegate:self];
    }
    else {
        ShowResult(@"There is no handheld controller. ");
        [self.sleepButton setEnabled:NO];
        [self.awakeButton setEnabled:NO];
        [self.shutdownButton setEnabled:NO];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    DJIHandheldController* handheld = [DemoComponentHelper fetchHandheldController];
    if (handheld && handheld.delegate == self) {
        [handheld setDelegate:nil];
    }
}

- (IBAction)onSleepButtonClicked:(id)sender {
    DJIHandheldController* handheld = [DemoComponentHelper fetchHandheldController];
    if (handheld) {
        [self.sleepButton setEnabled:NO];
        [self sendPowerMode:DJIHandheldPowerModeSleeping];
    }
}

- (IBAction)onAwakeButtonClicked:(id)sender {
    DJIHandheldController* handheld = [DemoComponentHelper fetchHandheldController];
    if (handheld) {
        [self.awakeButton setEnabled:NO];
        [self sendPowerMode:DJIHandheldPowerModeOn];
    }
}

- (IBAction)onShutdownButtonClicked:(id)sender {
    DJIHandheldController* handheld = [DemoComponentHelper fetchHandheldController];
    if (handheld) {
        [self.shutdownButton setEnabled:NO];
        [self sendPowerMode:DJIHandheldPowerModeOff];
    }
}

-(void) sendPowerMode:(DJIHandheldPowerMode)mode {
    DJIHandheldController* handheld = [DemoComponentHelper fetchHandheldController];
    if (handheld) {
        [handheld setPowerMode:mode withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"ERROR: setHandheldPowerMode failed. %@", error.description);
            }
            else {
                ShowResult(@"SUCCESS: setHandheldPowerMode. ");
            }
        }];
    }
}

#pragma mark - DJIHandheldControllerDelegate
-(void)handheldController:(DJIHandheldController *)controller didUpdatePowerMode:(DJIHandheldPowerMode)powerMode {
    switch (powerMode) {
        case DJIHandheldPowerModeSleeping:
            [self.sleepButton setEnabled:NO];
            [self.awakeButton setEnabled:YES];
            [self.shutdownButton setEnabled:YES];
            break;

        case DJIHandheldPowerModeOn:
            [self.sleepButton setEnabled:YES];
            [self.awakeButton setEnabled:NO];
            [self.shutdownButton setEnabled:YES];
            break;
            
        case DJIHandheldPowerModeOff:
            [self.sleepButton setEnabled:NO];
            [self.awakeButton setEnabled:NO];
            [self.shutdownButton setEnabled:NO];
            break;
            
        default:
            break;
    }
}


@end
