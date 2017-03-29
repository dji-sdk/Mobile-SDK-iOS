//
//  RCParingViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates how to start the pairing between the remote controller and the aircraft using SDK. 
 */
#import "RCParingViewController.h"
#import "DemoComponentHelper.h"
#import "DemoAlertView.h"
#import <DJISDK/DJISDK.h>

@interface RCParingViewController ()
- (IBAction)onStartParingButtonClicked:(id)sender;
- (IBAction)onStopParingButtonClicked:(id)sender;

@end

@implementation RCParingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onStartParingButtonClicked:(id)sender {
    DJIRemoteController* rc = [DemoComponentHelper fetchRemoteController];
    if (rc) {
        [rc startPairingWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"Start Failed:%@", error.localizedDescription);
            }
            else
            {
                ShowResult(@"Start Succeeded.");
            }
        }];
    }
    else
    {
        ShowResult(@"Component Not Exist");
    }
}

- (IBAction)onStopParingButtonClicked:(id)sender {
    DJIRemoteController* rc = [DemoComponentHelper fetchRemoteController];
    if (rc) {
        [rc stopPairingWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"Stop Failed:%@", error.localizedDescription);
            }
            else
            {
                ShowResult(@"Stop Succeeded.");
            }
        }];
    }
    else
    {
        ShowResult(@"Component Not Exist");
    }
}
@end
