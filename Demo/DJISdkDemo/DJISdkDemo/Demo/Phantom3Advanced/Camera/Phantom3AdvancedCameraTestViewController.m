//
//  CameraTestViewController.m
//  DJISdkDemo
//
//  Created by Ares on 14-7-3.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "Phantom3AdvancedCameraTestViewController.h"
#import "VideoPreviewer.h"
#import "DJIDemoHelper.h"
#import <DJISDK/DJISDK.h>

@interface Phantom3AdvancedCameraTestViewController ()

@end

@implementation Phantom3AdvancedCameraTestViewController
{
    BOOL isUpdating;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.connectedDrone) {
        _drone = self.connectedDrone;
    }
    else
    {
        _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom3Advanced];
    }
    mPhantom3AdvancedCamera = (DJIPhantom3AdvancedCamera*)_drone.camera;
    
    mLastWorkMode = CameraWorkModeUnknown;
    
    videoPreviewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:videoPreviewView];
    [self.view sendSubviewToBack:videoPreviewView];
    videoPreviewView.backgroundColor = [UIColor grayColor];
    [[VideoPreviewer instance] start];
    
    _settingsView = [[Phantom3AdvancedCameraSettingsView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 320, 0, 320, 320)];
    [_settingsView setCamera:_drone.camera];
    _settingsView.alpha = 0;
    [self.view addSubview:_settingsView];
    
    self.recordingTimeLabel.hidden = YES;
    
    self.contentView1.hidden = YES;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[VideoPreviewer instance] setView:videoPreviewView];
    [[VideoPreviewer instance] setDecoderDataSource:[self dataSourceFromDroneType:_drone.droneType]];
    
    _drone.delegate = self;
    _drone.camera.delegate = self;
    _drone.mainController.mcDelegate = self;
    [_drone connectToDrone];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_drone.camera startCameraSystemStateUpdates];
    [_drone.mainController startUpdateMCSystemState];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[VideoPreviewer instance] unSetView];
    
    [_drone.camera stopCameraSystemStateUpdates];
    [_drone.mainController stopUpdateMCSystemState];
    
    [_drone disconnectToDrone];

    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) onStartTakePhotoClicked:(UIButton*)sender
{
    if (mCameraSystemState) {
        if (mCameraSystemState.isTakingContinusCapture ||
            mCameraSystemState.isTakingMultiCapture) {
            [_drone.camera stopTakePhotoWithResult:^(DJIError *error) {
                ShowResult(@"Stop Take photo:%@", error.errorDescription);
            }];
        }
        else
        {
            if (!mCameraSystemState.isSDCardExist) {
                ShowResult(@"Please insert a SD Card...");
                return;
            }
            if (mCameraSystemState.workMode != CameraWorkModeCapture) {
                ShowResult(@"Camera work mode error, please switch to Capture mode.");
                return;
            }
            if (mCameraSystemState.isTakingSingleCapture ||
                mCameraSystemState.isTakingRawCapture) {
                ShowResult(@"Camera is Busy...");
                return;
            }
            if (mCameraSystemState.isSeriousError || mCameraSystemState.isCameraSensorError) {
                ShowResult(@"Camera system error...");
                return;
            }
            
            CameraCaptureMode mode = _settingsView.captureMode;
            [_drone.camera startTakePhoto:mode withResult:^(DJIError *error) {
                ShowResult(@"Take photo:%@", error.errorDescription);
            }];
        }
    }
    else
    {
        CameraCaptureMode mode = _settingsView.captureMode;
        [_drone.camera startTakePhoto:mode withResult:^(DJIError *error) {
            ShowResult(@"Try Take photo:%@", error.errorDescription);
        }];
    }
}

-(IBAction) onStartRecordingClicked:(id)sender
{
    if (mCameraSystemState.workMode != CameraWorkModeRecord) {
        ShowResult(@"Camera work mode error, please switch to Record mode.");
        return;
    }
    
    if (mCameraSystemState.isRecording) {
        [_drone.camera stopRecord:^(DJIError *error) {
            ShowResult(@"Stop Recording:%@", error.errorDescription);
        }];
    }
    else
    {
        [_drone.camera startRecord:^(DJIError *error) {
            ShowResult(@"Start Recording:%@", error.errorDescription);
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

-(IBAction) onBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DJIDroneDelegate

-(void) droneOnConnectionStatusChanged:(DJIConnectionStatus)status
{
    if (status == ConnectionSucceeded) {
        [mPhantom3AdvancedCamera setCameraWorkMode:CameraWorkModeCapture withResult:nil];
    }
}

-(void) setRecordingButtonTitle:(BOOL)isRecord
{
    if (isRecord) {
        [self.recordingButton setTitle:@"Stop Record" forState:UIControlStateNormal];
        [self.recordingButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        self.recordingTimeLabel.hidden = NO;
    }
    else
    {
        [self.recordingButton setTitle:@"Start Record" forState:UIControlStateNormal];
        [self.recordingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.recordingTimeLabel.hidden = YES;
    }
}

-(void) setCaptureButtonTitle:(BOOL)isStopCapture
{
    if (isStopCapture) {
        [self.captureButton setTitle:@"Stop Capture" forState:UIControlStateNormal];
        [self.captureButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    else
    {
        [self.captureButton setTitle:@"Start Capture" forState:UIControlStateNormal];
        [self.captureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

#pragma mark - DJICameraDelegate

-(void) camera:(DJICamera*)camera didReceivedVideoData:(uint8_t*)videoBuffer length:(int)length
{
    uint8_t* pBuffer = (uint8_t*)malloc(length);
    memcpy(pBuffer, videoBuffer, length);
    [[VideoPreviewer instance].dataQueue push:pBuffer length:length];
}

-(void) camera:(DJICamera*)camera didUpdateSystemState:(DJICameraSystemState*)systemState
{
    if (systemState.workMode == CameraWorkModePlayback ||
        systemState.workMode == CameraWorkModeDownload) {
        [mPhantom3AdvancedCamera setCameraWorkMode:CameraWorkModeCapture withResult:nil];
    }
    if (mCameraSystemState) {
        if (mCameraSystemState.isRecording != systemState.isRecording) {
            [self setRecordingButtonTitle:systemState.isRecording];
        }
        if (( mCameraSystemState.isTakingMultiCapture != systemState.isTakingMultiCapture) ||
            (mCameraSystemState.isTakingContinusCapture != systemState.isTakingContinusCapture)) {
            BOOL isStop = systemState.isTakingContinusCapture || systemState.isTakingMultiCapture;
            [self setCaptureButtonTitle:isStop];
        }
        
        if (systemState.isUSBMode) {
            [_drone.camera setCamerMode:CameraCameraMode withResultBlock:nil];
        }
        
        if (systemState.isRecording) {
            if (mCameraSystemState.currentRecordingTime != systemState.currentRecordingTime) {
                int hour = systemState.currentRecordingTime / 3600;
                int minute = (systemState.currentRecordingTime % 3600) / 60;
                int second = (systemState.currentRecordingTime % 3600) % 60;
                self.recordingTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hour, minute, second];
            }
        }
    }
    else
    {
        [self setRecordingButtonTitle:systemState.isRecording];
        BOOL isStop = systemState.isTakingContinusCapture || systemState.isTakingMultiCapture;
        [self setCaptureButtonTitle:isStop];
    }

    mCameraSystemState = systemState;
}

-(void) camera:(DJICamera *)camera didGeneratedNewMedia:(DJIMedia *)newMedia
{
    NSLog(@"GenerateNewMedia:%@",newMedia.mediaURL);
}

-(void) mainController:(DJIMainController*)mc didMainControlError:(MCError)error
{
    
}

-(void) mainController:(DJIMainController*)mc didUpdateSystemState:(DJIMCSystemState*)state
{
    
}
@end
