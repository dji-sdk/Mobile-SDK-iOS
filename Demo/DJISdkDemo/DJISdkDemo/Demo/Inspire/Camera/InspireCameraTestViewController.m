//
//  CameraTestViewController.m
//  DJISdkDemo
//
//  Created by Ares on 14-7-3.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "InspireCameraTestViewController.h"
#import "VideoPreviewer.h"
#import "DJIDemoHelper.h"
#import <DJISDK/DJISDK.h>

@interface InspireCameraTestViewController ()
- (IBAction)onSinglePreviewBackButtonClicked:(id)sender;
- (IBAction)onMultiPreviewButtonClicked:(id)sender;
- (IBAction)onSinglePreviewPreviousButtonClicked:(id)sender;
- (IBAction)onSinglePreviewNextButtonClicked:(id)sender;
- (IBAction)onSinglePreviewPlayButtonClicked:(id)sender;
- (IBAction)onSinglePreviewDeleteButtonClicked:(id)sender;
- (IBAction)onSinglePreviewDownloadButtonClicked:(id)sender;
- (IBAction)onMultiPreviewBackButtonClicked:(id)sender;
- (IBAction)onMultiPreviewPreviousButtonClicked:(id)sender;
- (IBAction)onMultiPreviewNextButtonClicked:(id)sender;
- (IBAction)onMultiPreviewSelectButtonClicked:(id)sender;
- (IBAction)onMultiPreviewPreviewButtonClicked:(id)sender;
- (IBAction)onEditBackButtonClicked:(id)sender;
- (IBAction)onEditPreviousButtonClicked:(id)sender;
- (IBAction)onEditNextButtonClicked:(id)sender;
- (IBAction)onEditSelectAllButtonClicked:(id)sender;
- (IBAction)onEditDeleteButtonClicked:(id)sender;
- (IBAction)onEditDownloadButtonClicked:(id)sender;

@end

@implementation InspireCameraTestViewController
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
        _drone = [[DJIDrone alloc] initWithType:DJIDrone_Inspire];
    }

    
    mInspireCamera = (DJIInspireCamera*)_drone.camera;
    
    mLastWorkMode = CameraWorkModeUnknown;
    
    videoPreviewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:videoPreviewView];
    [self.view sendSubviewToBack:videoPreviewView];
    videoPreviewView.backgroundColor = [UIColor grayColor];
    [[VideoPreviewer instance] start];
    [[VideoPreviewer instance] addObserver:self forKeyPath:@"isHardwareDecoding" options:NSKeyValueObservingOptionNew context:NULL];
    
    _settingsView = [[InspireCameraSettingsView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 320, 0, 320, 320)];
    [_settingsView setCamera:_drone.camera];
    _settingsView.alpha = 0;
    [self.view addSubview:_settingsView];
    
    self.recordingTimeLabel.hidden = YES;
    
    [self.contentView1 addSubview:self.singlePreviewView];
    [self.contentView1 addSubview:self.multiPreviewView];
    [self.contentView1 addSubview:self.multiEditView];
    self.singlePreviewView.hidden = YES;
    self.multiEditView.hidden = YES;
    self.multiPreviewView .hidden = YES;
    self.contentView1.hidden = YES;
}

-(void) dealloc
{
    [[VideoPreviewer instance] removeObserver:self forKeyPath:@"isHardwareDecoding"];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isHardwareDecoding"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* message = [VideoPreviewer instance].isHardwareDecoding ? @"Switched to hardware decoding" : @"Switched to software decoding";
            ShowResult(message);
        });
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[VideoPreviewer instance] setView:videoPreviewView];
    
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

-(IBAction) onHardwareDecodeSwitchValueChanged:(UISwitch*)sender
{
    if (sender.on) {
        [[VideoPreviewer instance] setDecoderDataSource:[self dataSourceFromDroneType:_drone.droneType]];
    }
    else
    {
        [[VideoPreviewer instance] setDecoderDataSource:kDJIDecoderDataSoureNone];
    }
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

-(IBAction) onPlaybackButtonClicked:(id)sender
{
    mLastWorkMode = mCameraSystemState.workMode;
    [mInspireCamera setCameraWorkMode:CameraWorkModePlayback withResult:^(DJIError *error) {
        ShowResult(@"Enter Playback:%@", error.errorDescription);
    }];
}

-(IBAction) onBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DJIDroneDelegate

-(void) droneOnConnectionStatusChanged:(DJIConnectionStatus)status
{
    if (status == ConnectionSucceeded) {
        //Enter the FPV, set work mode to CameraWorkModeCapture
        [mInspireCamera setCameraWorkMode:CameraWorkModeCapture withResult:nil];
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
    [[[VideoPreviewer instance] dataQueue] push:pBuffer length:length];
}

-(void) camera:(DJICamera*)camera didUpdateSystemState:(DJICameraSystemState*)systemState
{
    if (mCameraSystemState) {
        if (mCameraSystemState.isRecording != systemState.isRecording) {
            [self setRecordingButtonTitle:systemState.isRecording];
        }
        if (( mCameraSystemState.isTakingMultiCapture != systemState.isTakingMultiCapture) ||
            (mCameraSystemState.isTakingContinusCapture != systemState.isTakingContinusCapture)) {
            BOOL isStop = systemState.isTakingContinusCapture || systemState.isTakingMultiCapture;
            [self setCaptureButtonTitle:isStop];
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
    
    BOOL isPlayback = (mCameraSystemState.workMode == CameraWorkModePlayback) || (mCameraSystemState.workMode == CameraWorkModeDownload);
    self.contentView2.hidden = isPlayback;
    self.contentView1.hidden = !isPlayback;
}

-(void) onPlaybackModeChanged:(CameraPlaybackMode)mode
{
    self.singlePreviewView.hidden = !(mode == SingleFilePreview);
    self.multiEditView.hidden = !(mode == MultipleFilesEdit);
    self.multiPreviewView.hidden = !(mode == MultipleFilesPreview);
}

#pragma mark -

-(void) camera:(DJICamera *)camera didUpdatePlaybackState:(DJICameraPlaybackState *)playbackState
{
    if (mCameraSystemState.workMode == CameraWorkModePlayback ||
        mCameraSystemState.workMode == CameraWorkModeDownload) {
        if (mCameraPlaybackState) {
            if (mCameraPlaybackState.playbackMode != playbackState.playbackMode) {
                [self onPlaybackModeChanged:playbackState.playbackMode];
            }
        }
        else
        {
            [self onPlaybackModeChanged:playbackState.playbackMode];
        }
        
        mCameraPlaybackState = playbackState;
    }
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

#pragma mark -

- (IBAction)onSinglePreviewBackButtonClicked:(id)sender {
    if (mLastWorkMode == CameraWorkModeUnknown) {
        mLastWorkMode = CameraWorkModeCapture;
    }
    
    [mInspireCamera setCameraWorkMode:mLastWorkMode withResult:^(DJIError *error) {
        ShowResult(@"Exit Playback:%@", error.errorDescription);
    }];
}

- (IBAction)onMultiPreviewButtonClicked:(id)sender {
    [mInspireCamera enterMultiplePreviewMode];
}

- (IBAction)onSinglePreviewPreviousButtonClicked:(id)sender {
    [mInspireCamera singlePreviewPreviousPage];
}

- (IBAction)onSinglePreviewNextButtonClicked:(id)sender {
    [mInspireCamera singlePreviewNextPage];
}

- (IBAction)onSinglePreviewPlayButtonClicked:(id)sender {
    if (mCameraPlaybackState.mediaFileType == MediaFileVIDEO) {
        if (mCameraPlaybackState.videoPlayProgress > 0) {
            [mInspireCamera stopVideoPlayback];
        }
        else
        {
            [mInspireCamera startVideoPlayback];
        }
    }
}

- (IBAction)onSinglePreviewDeleteButtonClicked:(id)sender {
    [mInspireCamera deleteCurrentPreviewFile];
}

- (IBAction)onSinglePreviewDownloadButtonClicked:(id)sender {
    [self downloadFiles];
}

- (IBAction)onMultiPreviewBackButtonClicked:(id)sender {
    if (mLastWorkMode == CameraWorkModeUnknown) {
        mLastWorkMode = CameraWorkModeCapture;
    }
    
    [mInspireCamera setCameraWorkMode:mLastWorkMode withResult:^(DJIError *error) {
        ShowResult(@"Exit Playback:%@", error.errorDescription);
    }];
}

- (IBAction)onMultiPreviewPreviousButtonClicked:(id)sender {
    [mInspireCamera multiplePreviewPreviousPage];
}

- (IBAction)onMultiPreviewNextButtonClicked:(id)sender {
    [mInspireCamera multiplePreviewNextPage];
}

- (IBAction)onMultiPreviewSelectButtonClicked:(id)sender {
    [mInspireCamera enterMultipleEditMode];
}

- (IBAction)onMultiPreviewPreviewButtonClicked:(id)sender {
    [mInspireCamera enterSinglePreviewModeWithIndex:0];
}

- (IBAction)onEditBackButtonClicked:(id)sender {
    [mInspireCamera exitMultipleEditMode];
}

- (IBAction)onEditPreviousButtonClicked:(id)sender {
    [mInspireCamera multiplePreviewPreviousPage];
}

- (IBAction)onEditNextButtonClicked:(id)sender {
    [mInspireCamera multiplePreviewNextPage];
}

- (IBAction)onEditSelectAllButtonClicked:(UIButton*)sender {

    if (mCameraPlaybackState.isAllFilesInPageSelected) {
        [mInspireCamera unselectAllFilesInPage];
    }
    else
    {
        [mInspireCamera selectAllFilesInPage];
    }
}

- (IBAction)onEditDeleteButtonClicked:(id)sender {
    [mInspireCamera deleteAllSelectedFiles];
}

- (IBAction)onEditDownloadButtonClicked:(id)sender {
    [self downloadFiles];
}

-(void) downloadFiles
{
    __block long totalFileSize;
    __block NSString* targetFileName;
    __block int downloadedFileCount = 0;
    __block NSMutableData* fileData = nil;
    int totalFileCount = mCameraPlaybackState.numbersOfSelected;
    if (mCameraPlaybackState.playbackMode == SingleFilePreview) {
        totalFileCount = 1;
    }
    WeakRef(obj);
    [mInspireCamera downloadAllSelectedFilesWithPreparingBlock:^(NSString *fileName, DJIDownloadFileType fileType, NSUInteger fileSize, BOOL *skip) {
        
        fileData = [[NSMutableData alloc] init];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            WeakReturn(obj);
            totalFileSize = fileSize;
            targetFileName = fileName;
            [obj showDownloadProgressAlert];
            [obj.downloadProgressAlert setTitle:[NSString stringWithFormat:@"Download (%d/%d)", downloadedFileCount + 1, totalFileCount]];
            [obj.downloadProgressAlert setMessage:[NSString stringWithFormat:@"FileName:%@ FileSize:%0.1fKB Downloaded:0.0KB", fileName, fileSize / 1024.0]];
        }];
    } dataBlock:^(NSData *data, NSError *error) {
        [fileData appendData:data];
        uint32_t val = arc4random() % 200;
        if (error) {
            val = 0;
        }
        if (val == 0) {
            float percent = fileData.length*100.0 / totalFileSize;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                WeakReturn(obj);
                [obj showDownloadProgressAlert];
                if (error) {
                    [obj.downloadProgressAlert setTitle:@"Download Error"];
                    [obj.downloadProgressAlert setMessage:[NSString stringWithFormat:@"%@", error]];
                    [obj performSelector:@selector(dismissDownloadProgressAlert) withObject:nil afterDelay:3.0];
                }
                else
                {
                    [obj.downloadProgressAlert setMessage:[NSString stringWithFormat:@"FileName:%@ FileSize:%0.1fKB Downloaded:%0.1f%%", targetFileName, totalFileSize / 1024.0, percent]];
                }
                NSLog(@"Received Data:%d Error:%@", data.length, error);
            }];
        }
    } completionBlock:^{
        NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        filePath = [filePath stringByAppendingPathComponent:targetFileName];
        NSFileManager* fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:filePath]) {
            [fileData writeToFile:filePath atomically:YES];
        }
        
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"Completed Download");
            WeakReturn(obj);
            if (obj.downloadProgressAlert) {
                [obj.downloadProgressAlert setTitle:[NSString stringWithFormat:@"Download (%d/%d)", downloadedFileCount + 1, totalFileCount]];
                [obj.downloadProgressAlert setMessage:@"Completed"];
            }
            downloadedFileCount++;
            if (downloadedFileCount == totalFileCount) {
                [obj performSelector:@selector(dismissDownloadProgressAlert) withObject:nil afterDelay:2.0];
            }
        }];
    }];
}

-(NSString*) fileType:(DJIDownloadFileType)type
{
    if (type == DJIDownloadFilePhoto) {
        return @"Photo";
    }
    else if (type == DJIDownloadFileDNG) {
        return @"DNG";
    }
    else if (type == DJIDownloadFileVideo720P) {
        return @"Video 720P";
    }
    else if (type == DJIDownloadFileVideo1080P) {
        return @"Video 1080P";
    }
    else if (type == DJIDownloadFileVideo4K) {
        return @"Video 4K";
    }
    else {
        return @"";
    }
}
-(void) showDownloadProgressAlert
{
    if (self.downloadProgressAlert == nil) {
        self.downloadProgressAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [self.downloadProgressAlert show];
    }
}

-(void) dismissDownloadProgressAlert
{
    if (self.downloadProgressAlert) {
        [self.downloadProgressAlert dismissWithClickedButtonIndex:0 animated:YES];
        self.downloadProgressAlert = nil;
    }
}
@end
