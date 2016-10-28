//
//  CameraPlaybackDownloadViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates how to download files in playback manager. It includes:
 *  1. How to show the video feed on the view. Commands in playback manager highly depend on the user interaction,
 *     so it is important to show the video feed to the user why using playback manager.
 *  2. How to set delegate to the playback manager. It is important to check current playback state before executing
 *     the commands.
 *  3. How to select the files to download. 
 *  4. How to download the selected files in the playback manager.
 *  The basic workflow is as follows:
 *  1. Check if the current camera mode is DJICameraModePlayback. If it is not, change it to DJICameraModePlayback. 
 *  2. If current playback mode is already in multiple edit, we can start to select files and jump to step 3. 
 *     a. In order to switch to multiple edit, the playback manager need to switch to multiple preview first. Therefore,
 *        we check if the mode is already in multiple preview. If that is the case, we enter multiple edit mode. Otherwise, 
 *        we enter multiple preview first and then enter multiple edit. 
 *  3. Select the files with index 1 and index 2. （CAUTION: please ensure that there are at least two files in SD Card.)
 *  4. Start downloading the selected files.
 */
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"
#import <VideoPreviewer/VideoPreviewer.h>
#import "CameraPlaybackDownloadViewController.h"
#import "VideoPreviewerSDKAdapter.h"

@interface CameraPlaybackDownloadViewController () <DJICameraDelegate, DJIPlaybackDelegate>

@property (nonatomic) BOOL isFinished;
@property (nonatomic) BOOL isInMultipleEditMode;
@property (nonatomic) BOOL isSelectedFilesEnough;

@property (weak, nonatomic) IBOutlet UIView *videoFeedView;
@property (weak, nonatomic) IBOutlet UIButton *selectFirstButton;
@property (weak, nonatomic) IBOutlet UIButton *selectSecondButton;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (nonatomic) VideoPreviewerSDKAdapter *previewerAdapter; 

@end

@implementation CameraPlaybackDownloadViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.isFinished = NO;
    self.isInMultipleEditMode = NO;
    self.isSelectedFilesEnough = NO;
    
    self.statusLabel.text = @"";

    [self setVideoPreview];
    
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (!camera) {
        ShowResult(@"Cannot detect the camera. ");
        return;
    }
    
    if (![camera isPlaybackSupported]) {
        ShowResult(@"Playback is not supported. ");
        return;
    }
    
    // set delegate to render camera's video feed into the view
    [camera setDelegate:self];
    // set playback manager delegate to check playback state
    [camera.playbackManager setDelegate:self];
    
    // start to check the pre-condition
    [self getCameraMode];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // clean the delegate
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera && camera.delegate == self) {
        [camera setDelegate:nil];
    }
    if (camera && camera.playbackManager.delegate == self) {
        [camera.playbackManager setDelegate:nil];
    }
    
    [self cleanVideoPreview];
}

#pragma mark - Precondition
/**
 *  Check if the camera's mode is DJICameraModePlayback.
 *  If the mode is not DJICameraModePlayback, we need to set it to be DJICameraModePlayback.
 */
-(void) getCameraMode {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        WeakRef(target);
        [camera getCameraModeWithCompletion:^(DJICameraMode mode, NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"ERROR: getCameraModeWithCompletion:. %@", error.description);
            }
            else if (mode != DJICameraModePlayback) {
                [target setCameraMode];
            }
        }];
    }
}

/**
 *  Set the camera's mode to DJICameraModePlayback.
 */
-(void) setCameraMode {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        WeakRef(target);
        [camera setCameraMode:DJICameraModePlayback withCompletion:^(NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"ERROR: setCameraMode:withCompletion:. %@", error.description);
            }
        }];
    }
}

#pragma mark - Actions
- (IBAction)onSelectFirstClicked:(id)sender {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        [camera.playbackManager toggleFileSelectionAtIndex:0];
    }
}

- (IBAction)onSelectSecondClicked:(id)sender {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        [camera.playbackManager toggleFileSelectionAtIndex:1];
    }
}
- (IBAction)onDownloadClicked:(id)sender {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        self.isFinished = YES;
        __block NSUInteger currentFileTotalSize;
        __block NSUInteger currentFileRecievedSize = 0;
        __block NSString* currentFileName;
        
        WeakRef(target);
        [camera.playbackManager downloadSelectedFilesWithPreparation:^(NSString * _Nullable fileName, DJIDownloadFileType fileType, NSUInteger fileSize, BOOL * _Nonnull skip) {
            WeakReturn(target);
            currentFileName = fileName;
            self.statusLabel.text = [NSString stringWithFormat:@"Start to download file: %@", fileName];
            currentFileTotalSize = fileSize;
            currentFileRecievedSize = 0;
        } process:^(NSData * _Nullable data, NSError * _Nullable error) {
            WeakReturn(target);
            dispatch_async(dispatch_get_main_queue(), ^{
                WeakReturn(target);
                if (error) {
                    ShowResult(@"ERROR occurs while downloading file: %@", currentFileName);
                }
                else {
                    currentFileRecievedSize += data.length;
                    self.statusLabel.text = [NSString stringWithFormat:@"Downloaded: %f%%", (float)currentFileRecievedSize*100.0/(float)currentFileTotalSize];
                }
            });
        } fileCompletion:^{
            WeakReturn(target);
            target.statusLabel.text = @"A file is downloaded";
        } overallCompletion:^(NSError * _Nullable error) {
            WeakReturn(target); 
            if (error)
                ShowResult(@"ERROR: downloadSelectedFiles. %@", error.description);
            else
                ShowResult(@"All files are downloaded. ");
        }];
    }
}

#pragma mark - UI related
- (void)setVideoPreview {
    [[VideoPreviewer instance] start];
    [[VideoPreviewer instance] setView:self.videoFeedView];
    self.previewerAdapter = [VideoPreviewerSDKAdapter adapterWithVideoPreviewer:[VideoPreviewer instance]];
    [self.previewerAdapter start];
}

- (void)cleanVideoPreview {
    [[VideoPreviewer instance] unSetView];
    [self.previewerAdapter stop];
    self.previewerAdapter = nil;
}

-(void) setIsFinished:(BOOL)isFinished {
    _isFinished = isFinished;
    [self updateButtons];
}

-(void) setIsInMultipleEditMode:(BOOL)isInMultipleEditMode {
    _isInMultipleEditMode = isInMultipleEditMode;
    [self updateButtons];
}

-(void) setIsSelectedFilesEnough:(BOOL)isSelectedFilesEnough {
    _isSelectedFilesEnough = isSelectedFilesEnough;
    [self updateButtons];
}

-(void) updateButtons {
    if (self.isFinished || !self.isInMultipleEditMode) {
        [self.selectFirstButton setEnabled:NO];
        [self.selectSecondButton setEnabled:NO];
        [self.downloadButton setEnabled:NO];
        return;
    }
    
    [self.selectFirstButton setEnabled:YES];
    [self.selectSecondButton setEnabled:YES];
    [self.downloadButton setEnabled:self.isSelectedFilesEnough];
}

#pragma mark - DJICameraDelegate
-(void)camera:(DJICamera *)camera didReceiveVideoData:(uint8_t *)videoBuffer length:(size_t)size {
    [[VideoPreviewer instance] push:videoBuffer length:(int)size];
}

#pragma mark - DJIPlaybackDelegate
-(void)playbackManager:(DJIPlaybackManager *)playbackManager didUpdatePlaybackState:(DJICameraPlaybackState *)playbackState {
    if (self.isFinished) {
        return;
    }
    
    self.isSelectedFilesEnough = playbackState.numberOfSelectedFiles > 0;
    
    switch (playbackState.playbackMode) {
        case DJICameraPlaybackModeMultipleFilesEdit:
            // already in multiple edit. Then select files.
            self.isInMultipleEditMode = YES;
            break;
            
        case DJICameraPlaybackModeMultipleFilesPreview:
            [playbackManager enterMultipleEditMode];
            break;
        
        case DJICameraPlaybackModeDownload:
            break;
            
        default:
            [playbackManager enterMultiplePreviewMode];
            break;
    }
}

@end
