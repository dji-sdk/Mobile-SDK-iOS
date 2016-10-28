//
//  CameraPlaybackCommandViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates how to use the commands in playback manager. It includes:
 *  1. How to show the video feed on the view. Commands in playback manager highly depend on the user interaction, 
 *     so it is important to show the video feed to the user while using playback manager. 
 *  2. How to set delegate to the playback manager. It is important to check current playback state before executing
 *     the commands. 
 *  3. How to execute a command in the playback manager.
 */
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"
#import <VideoPreviewer/VideoPreviewer.h>
#import "CameraPlaybackCommandViewController.h"
#import "VideoPreviewerSDKAdapter.h"

@interface CameraPlaybackCommandViewController () <DJICameraDelegate, DJIPlaybackDelegate>

@property (nonatomic) BOOL isInPlaybackMode;
@property (nonatomic) BOOL isInMultipleMode;

@property (weak, nonatomic) IBOutlet UIView *videoFeedView;

@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *multipleButton;
@property (weak, nonatomic) IBOutlet UIButton *singleButton;

@property (nonatomic) VideoPreviewerSDKAdapter *previewerAdapter;

@end

@implementation CameraPlaybackCommandViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setVideoPreview];
    
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (!camera) {
        ShowResult(@"Cannot detect the camera. ");
        return;
    }
    
    self.isInPlaybackMode = NO;
    
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
            else if (mode == DJICameraModePlayback) {
                target.isInPlaybackMode = YES;
            }
            else {
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
            else {
                // Normally, once an operation is finished, the camera still needs some time to finish up
                // all the work. It is safe to delay the next operation after an operation is finished.
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    WeakReturn(target);
                    target.isInPlaybackMode = YES;
                });
            }
        }];
    }
}

#pragma mark - Actions
- (IBAction)onPreviousButtonClicked:(id)sender {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        if (self.isInMultipleMode) {
            [camera.playbackManager goToPreviousMultiplePreviewPage];
        }
        else {
            [camera.playbackManager goToPreviousSinglePreviewPage];
        }
    }
}

- (IBAction)onNextButtonClicked:(id)sender {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        if (self.isInMultipleMode) {
            [camera.playbackManager goToNextMultiplePreviewPage];
        }
        else {
            [camera.playbackManager goToNextSinglePreviewPage];
        }
    }
}

- (IBAction)onMultipleButtonClicked:(id)sender {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        [camera.playbackManager enterMultiplePreviewMode];
    }
}

- (IBAction)onSingleButtonClicked:(id)sender {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        [camera.playbackManager enterSinglePreviewModeWithIndex:0];
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

-(void) setIsInMultipleMode:(BOOL)isInMultipleMode {
    _isInMultipleMode = isInMultipleMode;
    [self.multipleButton setEnabled:!_isInMultipleMode];
    [self.singleButton setEnabled:_isInMultipleMode];
}

#pragma mark - DJICameraDelegate
-(void)camera:(DJICamera *)camera didReceiveVideoData:(uint8_t *)videoBuffer length:(size_t)size {
    [[VideoPreviewer instance] push:videoBuffer length:(int)size];
}
  
#pragma mark - DJIPlaybackDelegate
-(void)playbackManager:(DJIPlaybackManager *)playbackManager didUpdatePlaybackState:(DJICameraPlaybackState *)playbackState {
    self.isInMultipleMode = playbackState.playbackMode == DJICameraPlaybackModeMultipleFilesPreview ||
                            playbackState.playbackMode == DJICameraPlaybackModeMultipleFilesEdit;
}

@end
