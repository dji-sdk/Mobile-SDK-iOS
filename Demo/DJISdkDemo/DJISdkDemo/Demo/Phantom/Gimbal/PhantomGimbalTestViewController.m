//
//  GimbalTestViewController.m
//  DJISdkDemo
//
//  Created by Ares on 14-7-16.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "PhantomGimbalTestViewController.h"

@interface PhantomGimbalTestViewController ()

@end

@implementation PhantomGimbalTestViewController

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
    _drone.delegate = self;
    _drone.gimbal.delegate = self;
    
    [self.navigationController.navigationBar setHidden:NO];
    
    _connectionStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    _connectionStatusLabel.backgroundColor = [UIColor clearColor];
    _connectionStatusLabel.textAlignment = NSTextAlignmentCenter;
    _connectionStatusLabel.text = @"Disconnected";
    
    [self.navigationController.navigationBar addSubview:_connectionStatusLabel];
    
    self.attitudeLabel.text = @"Pitch = 0\nRoll = 0\nYaw = 0\n";
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
    [_drone disconnectToDrone];
}

-(void) onGimbalAttitudeYawRotationForward
{
    DJIGimbalRotation pitch = {YES, 0, RelativeAngle, RotationForward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationForward};
    DJIGimbalRotation yaw = {YES, 16, RelativeAngle, RotationForward};
    while (_gimbalAttitudeUpdateFlag) {
        [_drone.gimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                
            }
        }];
        usleep(40000);
    }
    // stop rotation.
    pitch.angle = 0;
    roll.angle = 0;
    yaw.angle = 0;
    [_drone.gimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
    }];
}

-(void) onGimbalAttitudeYawRotationBackward
{
    DJIGimbalRotation pitch = {YES, 0, RelativeAngle, RotationBackward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationBackward};
    DJIGimbalRotation yaw = {YES, 16, RelativeAngle, RotationBackward};
    while (_gimbalAttitudeUpdateFlag) {
        [_drone.gimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                
            }
        }];
        usleep(40000);
    }
    // stop rotation.
    pitch.angle = 0;
    roll.angle = 0;
    yaw.angle = 0;
    [_drone.gimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
    }];
}

-(void) onGimbalAttitudeScrollUp
{
    DJIGimbalRotation pitch = {YES, 150, RelativeAngle, RotationForward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationForward};
    DJIGimbalRotation yaw = {YES, 0, RelativeAngle, RotationForward};
    while (_gimbalAttitudeUpdateFlag) {
        [_drone.gimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                
            }
        }];
        usleep(40000);
    }
    // stop rotation.
    pitch.angle = 0;
    roll.angle = 0;
    yaw.angle = 0;
    [_drone.gimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
    }];
}

-(void) onGimbalAttitudeScrollDown
{
    DJIGimbalRotation pitch = {YES, 150, RelativeAngle, RotationBackward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationBackward};
    DJIGimbalRotation yaw = {YES, 0, RelativeAngle, RotationBackward};
    while (_gimbalAttitudeUpdateFlag) {
        [_drone.gimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                
            }
        }];
        usleep(40000);
    }
    
    // stop rotation.
    pitch.angle = 0;
    roll.angle = 0;
    yaw.angle = 0;
    [_drone.gimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
        if (error.errorCode == ERR_Succeeded) {
            
        }
        else
        {
            NSLog(@"Set GimbalAttitude Failed");
        }
    }];
}

-(IBAction) onGimbalAttitudeUpdateTest:(id)sender
{
    static BOOL s_startUpdate = NO;
    if (s_startUpdate == NO) {
        s_startUpdate = YES;
        NSOperationQueue* asyncQueue = [NSOperationQueue mainQueue];
        asyncQueue.maxConcurrentOperationCount = 1;
        [_drone.gimbal startGimbalAttitudeUpdateToQueue:asyncQueue withResultBlock:^(DJIGimbalAttitude attitude) {
            NSString* attiString = [NSString stringWithFormat:@"Pitch = %0.1f\nRoll = %0.1f\nYaw = %0.1f\n", attitude.pitch, attitude.roll, attitude.yaw];
            self.attitudeLabel.text = attiString;
        }];
        //        [_drone.gimbalManager startGimbalAttitudeUpdates];
        //        [NSThread detachNewThreadSelector:@selector(readGimbalAttitude) toTarget:self withObject:Nil];
    }
    else
    {
        [_drone.gimbal stopGimbalAttitudeUpdates];
        s_startUpdate = NO;
    }
}

-(void) readGimbalAttitude
{
    while (true) {
        DJIGimbalAttitude attitude = _drone.gimbal.gimbalAttitude;
        NSLog(@"Gimbal Atti Pitch:%f, Roll:%f, Yaw:%f", attitude.pitch, attitude.roll, attitude.yaw);
        
        [NSThread sleepForTimeInterval:0.2];
    }
}

-(IBAction) onGimbalScrollUpTouchDown:(id)sender
{
    _gimbalAttitudeUpdateFlag = YES;
    [NSThread detachNewThreadSelector:@selector(onGimbalAttitudeScrollUp) toTarget:self withObject:nil];
    NSOperationQueue* asyncQueue = [NSOperationQueue mainQueue];
    asyncQueue.maxConcurrentOperationCount = 1;
    [_drone.gimbal startGimbalAttitudeUpdateToQueue:asyncQueue withResultBlock:^(DJIGimbalAttitude attitude) {
        NSString* attiString = [NSString stringWithFormat:@"Pitch = %0.1f\nRoll = %0.1f\nYaw = %0.1f\n", attitude.pitch, attitude.roll, attitude.yaw];
        self.attitudeLabel.text = attiString;
    }];
}

-(IBAction) onGimbalScrollUpTouchUp:(id)sender
{
    _gimbalAttitudeUpdateFlag = NO;
    [_drone.gimbal stopGimbalAttitudeUpdates];
}

-(IBAction) onGimbalScroollDownTouchDown:(id)sender
{
    _gimbalAttitudeUpdateFlag = YES;
    [NSThread detachNewThreadSelector:@selector(onGimbalAttitudeScrollDown) toTarget:self withObject:nil];
    NSOperationQueue* asyncQueue = [NSOperationQueue mainQueue];
    asyncQueue.maxConcurrentOperationCount = 1;
    [_drone.gimbal startGimbalAttitudeUpdateToQueue:asyncQueue withResultBlock:^(DJIGimbalAttitude attitude) {
        NSString* attiString = [NSString stringWithFormat:@"Pitch = %0.1f\nRoll = %0.1f\nYaw = %0.1f\n", attitude.pitch, attitude.roll, attitude.yaw];
        self.attitudeLabel.text = attiString;
    }];
}

-(IBAction) onGimbalScroollDownTouchUp:(id)sender
{
    _gimbalAttitudeUpdateFlag = NO;
    [_drone.gimbal stopGimbalAttitudeUpdates];
}

-(IBAction) onGimbalYawRotationForwardTouchDown:(id)sender
{
    _gimbalAttitudeUpdateFlag = YES;
    [NSThread detachNewThreadSelector:@selector(onGimbalAttitudeYawRotationForward) toTarget:self withObject:nil];
    NSOperationQueue* asyncQueue = [NSOperationQueue mainQueue];
    asyncQueue.maxConcurrentOperationCount = 1;
    [_drone.gimbal startGimbalAttitudeUpdateToQueue:asyncQueue withResultBlock:^(DJIGimbalAttitude attitude) {
        NSString* attiString = [NSString stringWithFormat:@"Pitch = %0.1f\nRoll = %0.1f\nYaw = %0.1f\n", attitude.pitch, attitude.roll, attitude.yaw];
        self.attitudeLabel.text = attiString;
    }];
}

-(IBAction) onGimbalYawRotationForwardTouchUp:(id)sender
{
    _gimbalAttitudeUpdateFlag = NO;
    [_drone.gimbal stopGimbalAttitudeUpdates];
}

-(IBAction) onGimbalYawRotationBackwardTouchDown:(id)sender
{
    _gimbalAttitudeUpdateFlag = YES;
    [NSThread detachNewThreadSelector:@selector(onGimbalAttitudeYawRotationBackward) toTarget:self withObject:nil];
    NSOperationQueue* asyncQueue = [NSOperationQueue mainQueue];
    asyncQueue.maxConcurrentOperationCount = 1;
    [_drone.gimbal startGimbalAttitudeUpdateToQueue:asyncQueue withResultBlock:^(DJIGimbalAttitude attitude) {
        NSString* attiString = [NSString stringWithFormat:@"Pitch = %0.1f\nRoll = %0.1f\nYaw = %0.1f\n", attitude.pitch, attitude.roll, attitude.yaw];
        self.attitudeLabel.text = attiString;
    }];
}

-(IBAction) onGimbalYawRotationBackwardTouchUp:(id)sender
{
    _gimbalAttitudeUpdateFlag = NO;
    [_drone.gimbal stopGimbalAttitudeUpdates];
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

#pragma mark - DJIGimbalDelegate

-(void) gimbalController:(DJIGimbal*)controller didGimbalError:(DJIGimbalError)error
{
    if (error == GimbalClamped) {
        NSLog(@"Gimbal Clamped");
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Gimbal Clamped" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    if (error == GimbalErrorNone) {
        NSLog(@"Gimbal Error None");
        
    }
    if (error == GimbalMotorAbnormal) {
        NSLog(@"Gimbal Motor Abnormal");
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Gimbal Motor Abnormal" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

@end
