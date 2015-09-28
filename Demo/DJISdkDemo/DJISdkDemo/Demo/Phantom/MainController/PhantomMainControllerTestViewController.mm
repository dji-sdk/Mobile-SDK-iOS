//
//  MainControllerTestViewController.m
//  DJISdkDemo
//
//  Created by Ares on 14-7-16.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "PhantomMainControllerTestViewController.h"
#import <DJISDK/DJISDK.h>

@interface PhantomMainControllerTestViewController ()

@end

@implementation PhantomMainControllerTestViewController

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
    
    self.statusTextView.editable = NO;
    
    _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom];
    _drone.delegate = self;
    _drone.mainController.mcDelegate = self;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [_drone connectToDrone];
    [_drone.mainController startUpdateMCSystemState];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_connectionStatusLabel removeFromSuperview];
    [_drone.mainController stopUpdateMCSystemState];
    [_drone disconnectToDrone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) mainController:(DJIMainController*)mc didMainControlError:(MCError)error
{
    switch (error) {
        case MC_NO_ERROR:
        {
            self.errorLabel.text = @"NO Error";
            break;
        }
        case MC_CONFIG_ERROR:
        {
            self.errorLabel.text = @"Config Error";
            break;
        }
        case MC_SERIALNUM_ERROR:
        {
            self.errorLabel.text = @"SERIALNUM_ERROR";
            break;
        }
        case MC_IMU_ERROR:
        {
            self.errorLabel.text = @"IMU_ERROR";
            break;
        }
        case MC_X1_ERROR:
        {
            self.errorLabel.text = @"X1_ERROR";
            break;
        }
        case MC_X2_ERROR:
        {
            self.errorLabel.text = @"X2_ERROR";
            break;
        }
        case MC_PMU_ERROR:
        {
            self.errorLabel.text = @"PMU_ERROR";
            break;
        }
        case MC_TRANSMITTER_ERROR:
        {
            self.errorLabel.text = @"TRANSMITTER_ERROR";
            break;
        }
        case MC_SENSOR_ERROR:
        {
            self.errorLabel.text = @"SENSOR_ERROR";
            break;
        }
        case MC_COMPASS_ERROR:
        {
            self.errorLabel.text = @"COMPASS_ERROR";
            break;
        }
        case MC_IMU_CALIBRATION_ERROR:
        {
            self.errorLabel.text = @"IMU_CALIBRATION_ERROR";
            break;
        }
        case MC_COMPASS_CALIBRATION_ERROR:
        {
            self.errorLabel.text = @"COMPASS_CALIBRATION_ERROR";
            break;
        }
        case MC_TRANSMITTER_CALIBRATION_ERROR:
        {
            self.errorLabel.text = @"TRANSMITTER_CALIBRATION_ERROR";
            break;
        }
        case MC_INVALID_BATTERY_ERROR:
        {
            self.errorLabel.text = @"INVALID_BATTERY_ERROR";
            break;
        }
        case MC_INVALID_BATTERY_COMMUNICATION_ERROR:
        {
            self.errorLabel.text = @"INVALID_BATTERY_COMMUNICATION_ERROR";
            break;
        }
            
        default:
            break;
    }
}

-(void) mainController:(DJIMainController*)mc didUpdateSystemState:(DJIMCSystemState*)state
{
    NSMutableString* MCSystemStateString = [[NSMutableString alloc] init];
    
    [MCSystemStateString appendFormat:@"satelliteCount = %d\n", state.satelliteCount];
    [MCSystemStateString appendFormat:@"homeLocation = {%f, %f}\n", state.homeLocation.latitude, state.homeLocation.longitude];
    [MCSystemStateString appendFormat:@"droneLocation = {%f, %f}\n", state.droneLocation.latitude, state.droneLocation.longitude];
    [MCSystemStateString appendFormat:@"velocityX = %f\n", state.velocityX];
    [MCSystemStateString appendFormat:@"velocityY = %f\n", state.velocityY];
    [MCSystemStateString appendFormat:@"velocityZ = %f\n", state.velocityZ];
    [MCSystemStateString appendFormat:@"altitude = %f\n", state.altitude];
    [MCSystemStateString appendFormat:@"DJIaltitude  = {%f, %f , %f}\n", state.attitude.pitch ,state.attitude.roll , state.attitude.yaw];
    [MCSystemStateString appendFormat:@"powerLevel = %d\n", state.powerLevel];
    [MCSystemStateString appendFormat:@"isFlying = %d\n", state.isFlying];
    [MCSystemStateString appendFormat:@"noFlyStatus = %d\n", (int)state.noFlyStatus];
    [MCSystemStateString appendFormat:@"noFlyZoneCenter = {%f,%f}\n", state.noFlyZoneCenter.latitude,state.noFlyZoneCenter.longitude];
    [MCSystemStateString appendFormat:@"noFlyZoneRadius = %d\n", state.noFlyZoneRadius];
    
    _statusTextView.text = MCSystemStateString;
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
