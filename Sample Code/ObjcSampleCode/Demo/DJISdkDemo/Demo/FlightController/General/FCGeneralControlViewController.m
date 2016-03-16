//
//  FCGeneralControlViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  DJIFlightController provides different sets of methods to control the movement of the aircraft. This file demonstrates the basic methods
 *  to make the aircraft take-off, go home and land. For more advanced methods, please refer to FCVirtualStickViewController.m.
 */
#import "FCGeneralControlViewController.h"
#import "DemoComponentHelper.h"
#import "DemoAlertView.h"
#import <DJISDK/DJISDK.h>

@interface FCGeneralControlViewController ()
- (IBAction)onTakeoffButtonClicked:(id)sender;
- (IBAction)onGoHomeButtonClicked:(id)sender;
- (IBAction)onLandButtonClicked:(id)sender;

@end

@implementation FCGeneralControlViewController

- (IBAction)onTakeoffButtonClicked:(id)sender {
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        [fc takeoffWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"Takeoff Error:%@", error.localizedDescription);
            }
            else
            {
                ShowResult(@"Takeoff Succeeded.");
            }
        }];
    }
    else
    {
        ShowResult(@"Component Not Exist");
    }
}

- (IBAction)onGoHomeButtonClicked:(id)sender {
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        [fc goHomeWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"GoHome Error:%@", error.localizedDescription);
            }
            else
            {
                ShowResult(@"GoHome Succeeded.");
            }
        }];
    }
    else
    {
        ShowResult(@"Component Not Exist");
    }
}

- (IBAction)onLandButtonClicked:(id)sender {
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        [fc autoLandingWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"Land Error:%@", error.localizedDescription);
            }
            else
            {
                ShowResult(@"Land Succeeded.");
            }
        }];
    }
    else
    {
        ShowResult(@"Component Not Exist");
    }
}
@end
