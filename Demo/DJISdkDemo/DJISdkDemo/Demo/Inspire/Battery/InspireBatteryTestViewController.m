//
//  BatteryTestViewController.m
//  DJISdkDemo
//
//  Created by Ares on 14-7-16.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "InspireBatteryTestViewController.h"

@interface InspireBatteryTestViewController ()

@end

@implementation InspireBatteryTestViewController

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
    
    if (self.connectedDrone) {
        _drone = self.connectedDrone;
    }
    else
    {
        _drone = [[DJIDrone alloc] initWithType:DJIDrone_Inspire];
    }
    
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
    
    [_drone connectToDrone];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self stopBatterUpdate];
    [_drone disconnectToDrone];
}

-(void) startBatteryUpdate
{
    if (_readBatteryInfoTimer == nil) {
        _readBatteryInfoTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onReadBatteryInfoTimerTicked:) userInfo:nil repeats:YES];
    }
}

-(void) stopBatterUpdate
{
    if (_readBatteryInfoTimer) {
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
            [batteryInfoString appendFormat:@"batteryTemperature = %d ℃\n",(int)_drone.smartBattery.batteryTemperature];
            [batteryInfoString appendFormat:@"dischargeCount = %ld",(long)_drone.smartBattery.numberOfDischarge];
            
            _batteryStatusLabel.text = batteryInfoString;
        }
        else
        {
            NSLog(@"update BatteryInfo Failed");
        }
    }];
}

-(void) getBatteryHistoryState
{
    if ([_drone.smartBattery isKindOfClass:[DJIInspireBattery class]]) {
        DJIInspireBattery* inspireBattery = (DJIInspireBattery*)_drone.smartBattery;
        [inspireBattery getBatteryHistoryState:^(NSArray *history, DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                for (int i = 0; i < history.count; i++) {
                    DJIBatteryState* batteryState = [history objectAtIndex:i];
                    NSString* info1 = [NSString stringWithFormat:@"dischargeOverCurrent:%d",batteryState.dischargeOverCurrent];

                    NSString* info2 = [NSString stringWithFormat:@"dischargeOverHeat:%d",batteryState.dischargeOverHeat];
                    NSString* info3 = [NSString stringWithFormat:@"dischargeLowTemperature:%d",batteryState.dischargeLowTemperature];

                    NSString* info4 = [NSString stringWithFormat:@"dischargeShortCut:%d",batteryState.dischargeShortCut];
                    NSString* info5 = [NSString stringWithFormat:@"underVoltageCellIndex:%d",batteryState.underVoltageCellIndex];
                    NSString* info6 = [NSString stringWithFormat:@"damagedCellIndex:%d",batteryState.damagedCellIndex];
                     NSString* info7 = [NSString stringWithFormat:@"selfDischarge:%d",batteryState.selfDischarge];
                    NSLog(@"History State:%d", i);
                    NSLog(@"%@",@"-------------------------");
                    NSLog(@"%@",info1);
                    NSLog(@"%@",info2);
                    NSLog(@"%@",info3);
                    NSLog(@"%@",info4);
                    NSLog(@"%@",info5);
                    NSLog(@"%@",info6);
                    NSLog(@"%@",info7);
                    NSLog(@"%@",@"-------------------------");
                }
                
            }
        }];
    }
    else
    {
        ShowResult(@"Not Inspire Battery!");
    }
}

#pragma mark - DJIDroneDelegate

-(void) droneOnConnectionStatusChanged:(DJIConnectionStatus)status
{
    if (status == ConnectionSucceeded) {
        [self startBatteryUpdate];
        [self getBatteryHistoryState];

    }
    else if(status == ConnectionFailed)
    {
    }
}
@end
