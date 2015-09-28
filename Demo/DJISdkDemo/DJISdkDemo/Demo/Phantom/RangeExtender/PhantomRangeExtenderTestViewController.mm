//
//  RangeExtenderTestViewController.m
//  DJISdkDemo
//
//  Created by Ares on 14-7-16.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "PhantomRangeExtenderTestViewController.h"
#import "MBProgressHUD.h"

@interface PhantomRangeExtenderTestViewController ()

@end

@implementation PhantomRangeExtenderTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom];
    _rangeExtender = _drone.rangeExtender;
    _rangeExtender.delegate = self;
    _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_progressHUD];
    
    _powerStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    _powerStatusLabel.backgroundColor = [UIColor clearColor];
    _powerStatusLabel.textAlignment = NSTextAlignmentCenter;
    _powerStatusLabel.text = @"0%";
    
    [self.navigationController.navigationBar addSubview:_powerStatusLabel];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];

    [_rangeExtender startRangeExtenderPowerLevelUpdates];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_powerStatusLabel removeFromSuperview];
    [_rangeExtender stopRangeExtenderPowerLevelUpdates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) readPowerLevel:(id)timer
{
    _powerStatusLabel.text = [NSString stringWithFormat:@"%d%%", [_rangeExtender getRangeExtenderPowerLevel]];
}

-(void) rangeExtender:(DJIRangeExtender *)extender didUpdatePowerLevel:(int)powerLevel
{
    if (powerLevel == INVALID_POWER_LEVEL) {
        _powerStatusLabel.text = @"N/A";
    }
    else
    {
        _powerStatusLabel.text = [NSString stringWithFormat:@"%d%%", powerLevel];
    }
}

-(IBAction) onGetButtonClicked:(id)sender
{
#define VALID_STRING(x) ((x == nil) ? @"N/A" : x)
    [_progressHUD show:YES];
    NSOperationQueue* operation = [[NSOperationQueue alloc] init];
    [operation addOperationWithBlock:^{
        NSString* bindingMacAddr =  [_rangeExtender getCurrentBindingMAC];
        NSString* bindingSSID = [_rangeExtender getCurrentBindingSSID];
        NSString* macAddr = [_rangeExtender getMacAddressOfRangeExtender];
        NSString* ssid = [_rangeExtender getSsidOfRangeExtender];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.cameraMACLabel.text =  VALID_STRING(bindingMacAddr);
            self.cameraSSIDLabel.text = VALID_STRING(bindingSSID);
            self.extenderMACLabel.text = VALID_STRING(macAddr);
            self.extenderSSIDLabel.text = VALID_STRING(ssid);
            [_progressHUD hide:YES];
        });
    }];
}

-(IBAction) onRenameButtonClicked:(id)sender
{
    if (self.extenderNewSsidTextField.text == nil) {
        return;
    }
    
    NSString* newSsid = self.extenderNewSsidTextField.text;
    if (![newSsid hasPrefix:@"Phantom_"]) {
        return;
    }
    
    [_progressHUD show:YES];
    NSOperationQueue* operation = [[NSOperationQueue alloc] init];
    [operation addOperationWithBlock:^{
        BOOL ret = [_rangeExtender renameSsidOfRangeExtender:newSsid];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_progressHUD hide:YES];
            NSString* message = @"Rename SSID Failed";
            if (ret) {
                message = @"Rename SSID Successed, Range Extender will Reboot";
            }

            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        });
    }];
    
}

-(IBAction) onBindNewButtonClicked:(id)sender
{
    NSString* macAddr = self.cameraNewMacTextField.text;
    if (macAddr == nil || macAddr.length == 0) {
        return;
    }

    [_progressHUD show:YES];
    NSOperationQueue* operation = [[NSOperationQueue alloc] init];
    [operation addOperationWithBlock:^{
        BOOL ret = [_rangeExtender bindRangeExtenderWithCameraMAC:macAddr];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_progressHUD hide:YES];
            NSString* message = @"Bind SSID Failed";
            if (ret) {
                message = @"Bind SSID Successed, Range Extender will Reboot";
            }
            
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        });
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    
    return YES;
}
@end
