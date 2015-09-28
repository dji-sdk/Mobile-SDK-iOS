//
//  BatteryTestViewController.m
//  DJISdkDemo
//
//  Created by Ares on 14-7-16.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "PhantomBatteryTestViewController.h"
#import <DJISDK/DJISDK.h>
#import <DJISDK/DJIBattery.h>

@interface PhantomBatteryTestViewController ()

@end

@implementation PhantomBatteryTestViewController

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
    
    _connectionStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    _connectionStatusLabel.backgroundColor = [UIColor clearColor];
    _connectionStatusLabel.textAlignment = NSTextAlignmentCenter;
    _connectionStatusLabel.text = @"Disconnected";
    [self.navigationController.navigationBar addSubview:_connectionStatusLabel];
    
    _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom];
    _drone.delegate = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [_drone connectToDrone];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_connectionStatusLabel removeFromSuperview];
    if (_readBatteryInfoTimer) {
        [_readBatteryInfoTimer invalidate];
        _readBatteryInfoTimer = nil;
    }
    [_drone disconnectToDrone];
}

-(IBAction) onBatteryTestButtonClicked:(id)sender
{
    if (_readBatteryInfoTimer == nil) {
        [_batteryTestButton setTitle:@"Stop Battery Test" forState:UIControlStateNormal];
        _readBatteryInfoTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onReadBatteryInfoTimerTicked:) userInfo:nil repeats:YES];
    }
    else
    {
        [_batteryTestButton setTitle:@"Start Battery Test" forState:UIControlStateNormal];
        [_readBatteryInfoTimer invalidate];
        _readBatteryInfoTimer = nil;
    }
}

-(void) onReadBatteryInfoTimerTicked:(id)timer
{
    [_drone.smartBattery updateBatteryInfo:^(DJIError *error) {
        if (error.errorCode == ERR_Succeeded) {
            
            NSMutableString* batteryInfoString = [[NSMutableString alloc] init];
            [batteryInfoString appendFormat:@"designedVolume = %ld mAh\n", (long)_drone.smartBattery.designedVolume];
            [batteryInfoString appendFormat:@"fullChargeVolume = %ld mAh\n", (long)_drone.smartBattery.fullChargeVolume];
            [batteryInfoString appendFormat:@"currentElectricity = %ld mAh\n",(long)_drone.smartBattery.currentElectricity];
            [batteryInfoString appendFormat:@"currentVoltage = %ld mV\n",(long)_drone.smartBattery.currentVoltage];
            [batteryInfoString appendFormat:@"currentCurrent = %ld mA\n", (long)_drone.smartBattery.currentCurrent];
            [batteryInfoString appendFormat:@"remainLifePercent = %ld%%\n", (long)_drone.smartBattery.remainLifePercent];
            [batteryInfoString appendFormat:@"remainPowerPercent = %ld%%\n",(long)_drone.smartBattery.remainPowerPercent];
            [batteryInfoString appendFormat:@"batteryTemperature = %ld ℃\n",(long)_drone.smartBattery.batteryTemperature];
            [batteryInfoString appendFormat:@"chargeCount = %ld",(long)_drone.smartBattery.numberOfDischarge];
            
            _batteryStatusLabel.text = batteryInfoString;
        }
        else
        {
            NSLog(@"update BatteryInfo Failed");
        }
    }];
}

#pragma mark - DJIDroneDelegate

-(void) droneOnConnectionStatusChanged:(DJIConnectionStatus)status
{
    switch (status) {
        case ConnectionStartConnect:
        {
            NSLog(@"Start Reconnect...");
            break;
        }
        case ConnectionSucceeded:
        {
            NSLog(@"Connect Successed...");
            _connectionStatusLabel.text = @"Connected";
            break;
        }
        case ConnectionFailed:
        {
            NSLog(@"Connect Failed...");
             _connectionStatusLabel.text = @"Connect Failed";
            break;
        }
        case ConnectionBroken:
        {
            NSLog(@"Connect Broken...");
            _connectionStatusLabel.text = @"Disconnected";
            break;
        }
        default:
            break;
    }
}
@end
