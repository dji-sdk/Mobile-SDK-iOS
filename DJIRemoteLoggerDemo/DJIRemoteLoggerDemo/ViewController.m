//
//  ViewController.m
//  DJIRemoteLoggerDemo
//
//  Created by DJI on 2/12/15.
//  Copyright © 2015 DJI. All rights reserved.
//

#import "ViewController.h"
#import <DJISDK/DJISDK.h>

#define ENTER_DEBUG_MODE 1

@interface ViewController ()<DJISDKManagerDelegate>
- (IBAction)logSDKVersionButtonAction:(id)sender;

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self registerApp];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerApp
{
    NSString *appKey = @"Enter Your App Key Here";
    [DJISDKManager registerApp:appKey withDelegate:self];
}

- (void)showAlertViewWithTitle:(NSString *)title withMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - DJISDKManager Delegate Method
- (void)sdkManagerDidRegisterAppWithError:(NSError *)error
{
    NSString* message = @"Register App Successed!";
    if (error) {
        message = @"Register App Failed! Please enter your App Key and check the network.";
    }else
    {
        [DJISDKManager enableRemoteLoggingWithDeviceID:@"Enter Device ID Here" logServerURLString:@"Enter URL Here"];
    }
    
    [self showAlertViewWithTitle:@"Register App" withMessage:message];
}

#pragma mark - IBAction Method

- (IBAction)logSDKVersionButtonAction:(id)sender {
    
    DJILogDebug(@"SDK Version: %@", [DJISDKManager getSDKVersion]);
}

@end
