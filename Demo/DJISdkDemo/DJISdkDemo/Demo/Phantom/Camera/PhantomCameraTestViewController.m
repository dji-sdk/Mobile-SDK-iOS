//
//  CameraTestViewController.m
//  DJISdkDemo
//
//  Created by Ares on 14-7-3.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "PhantomCameraTestViewController.h"
#import <DJISDK/DJISDK.h>
#import "VideoPreviewer.h"
#import "DJIDemoHelper.h"

@interface PhantomCameraTestViewController ()

@end

@implementation PhantomCameraTestViewController
{
    BOOL isUpdating;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom];
    _drone.delegate = self;
    _drone.camera.delegate = self;
    
    videoPreviewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:videoPreviewView];
    [self.view sendSubviewToBack:videoPreviewView];
    videoPreviewView.backgroundColor = [UIColor grayColor];
    [[VideoPreviewer instance] start];
    
    _settingsView = [[PhantomCameraSettingsView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 320, 0, 320, 320)];
    [_settingsView setCamera:_drone.camera];
    _settingsView.alpha = 0;
    [self.view addSubview:_settingsView];
    isUpdating = NO;
    _isRecording = NO;
    _isTimeSynced = NO;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[VideoPreviewer instance] setView:videoPreviewView];

    [_drone connectToDrone];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_drone.camera startCameraSystemStateUpdates];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_drone disconnectToDrone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) onStartTakePhotoClicked:(id)sender
{
    if (_isTimeSynced) {
        CameraCaptureMode mode = _settingsView.captureMode;
        [_drone.camera startTakePhoto:mode withResult:^(DJIError *error) {
            if (error) {
                NSLog(@"onStartTakePhotoClicked:%@", [error errorDescription]);
            }
        }];
    }
    else
    {
        [_drone.camera syncTime:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                [_drone.camera startTakePhoto:CameraSingleCapture withResult:^(DJIError *error) {
                    if (error) {
                        NSLog(@"onStartTakePhotoClicked:%@", [error errorDescription]);
                    }
                }];
            }
            else
            {
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Sync Time Failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        }];
    }

}

-(IBAction) onStopTakePhotoClicked:(id)sender
{
    [_drone.camera stopTakePhotoWithResult:^(DJIError *error) {
        if (error) {
            NSLog(@"onStopTakePhotoClicked:%@", [error errorDescription]);
        }
    }];
}

-(IBAction) onStartRecordingClicked:(id)sender
{
    if (_isRecording) {
        [_drone.camera stopRecord:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                [self.recordingButton setTitle:@"Start Record" forState:UIControlStateNormal];
            }
            else
            {
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:Nil message:@"Stop Record Failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            }
        }];
    }
    else
    {
        [_drone.camera startRecord:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                [self.recordingButton setTitle:@"Stop Record" forState:UIControlStateNormal];
            }
            else
            {
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:Nil message:@"Start Record Failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            }
        }];
    }
}

-(IBAction) onSetSettingsClicked:(id)sender
{
    if (_settingsView.alpha == 0.0) {
        _settingsView.alpha = 1.0;
    }
    else
    {
        _settingsView.alpha = 0.0;
    }
}

-(IBAction) onSetRecordingResolutionClicked:(id)sender
{
    
}

-(IBAction) onStartUpdateSystemState:(id)sender
{
    if (isUpdating) {
        [_drone.camera stopCameraSystemStateUpdates];
        [_drone.mainController stopUpdateMCSystemState];
    }
    else
    {
        [_drone.camera startCameraSystemStateUpdates];
        [_drone.mainController startUpdateMCSystemState];
    }
    
    isUpdating = !isUpdating;
}

-(IBAction) onSyncTimeClicked:(id)sender
{
    [_drone.camera syncTime:^(DJIError *error) {
        if (error.errorCode != ERR_Succeeded) {
            NSLog(@"Time Sync Failed");
        }
    }];
}


-(IBAction) onBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
            [_drone.camera setCamerMode:CameraCameraMode withResultBlock:^(DJIError *error) {
                if (error.errorCode == ERR_Succeeded) {
                    
                }
            }];
            break;
        }
        case ConnectionFailed:
        {
            NSLog(@"Connect Failed...");
            break;
        }
        case ConnectionBroken:
        {
            NSLog(@"Connect Broken...");
            break;
        }
        default:
            break;
    }
}

#pragma mark - DJICameraDelegate

-(void) camera:(DJICamera*)camera didReceivedVideoData:(uint8_t*)videoBuffer length:(int)length
{
    uint8_t* pBuffer = (uint8_t*)malloc(length);
    memcpy(pBuffer, videoBuffer, length);
    [[[VideoPreviewer instance] dataQueue] push:pBuffer length:length];
}

-(void) camera:(DJICamera*)camera didUpdateSystemState:(DJICameraSystemState*)systemState
{
    NSLog(@"Camera System Updates...");
    if (systemState.isUSBMode) {
        [_drone.camera setCamerMode:CameraCameraMode withResultBlock:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                
            }
        }];
    }
    if (_isRecording != systemState.isRecording) {
        _isRecording = systemState.isRecording;
        if (_isRecording) {
            [self.recordingButton setTitle:@"Stop Record" forState:UIControlStateNormal];
        }
        else
        {
            [self.recordingButton setTitle:@"Start Record" forState:UIControlStateNormal];
        }
    }
    
    _isTimeSynced = systemState.isTimeSynced;
}

-(void) mainController:(DJIMainController*)mc didMainControlError:(MCError)error
{
    
}

-(void) mainController:(DJIMainController*)mc didUpdateSystemState:(DJIMCSystemState*)state
{
    
}



@end
