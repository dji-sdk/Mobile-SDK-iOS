//
//  CameraRecordVideoViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

/**
 *  This file demonstrates:
 *  1. how to use the video previewer and connect it with camera's video feed.
 *  2. how to start recording video.
 *  3. how to stop recording video.
 */

#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"
#import <VideoPreviewer/VideoPreviewer.h>
#import "CameraRecordVideoViewController.h"
#import "VideoPreviewerSDKAdapter.h"

@interface CameraRecordVideoViewController () <DJICameraDelegate>

@property (nonatomic) BOOL isInRecordVideoMode;
@property (nonatomic) BOOL isRecordingVideo;
@property (nonatomic) int recordingTime;

@property (weak, nonatomic) IBOutlet UIView *videoFeedView;

@property (weak, nonatomic) IBOutlet UILabel *recordingTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *startRecordButton;
@property (weak, nonatomic) IBOutlet UIButton *stopRecordButton;

@property (nonatomic) VideoPreviewerSDKAdapter *previewerAdapter; 

@end

@implementation CameraRecordVideoViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setVideoPreview];
    
    // set delegate to render camera's video feed into the view
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        [camera setDelegate:self];
    }
    
    self.isInRecordVideoMode = NO;
    self.isRecordingVideo = NO;
    // disable the shoot photo button by default
    [self.startRecordButton setEnabled:NO];
    [self.stopRecordButton setEnabled:NO];
    
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
    
    [self cleanVideoPreview];
}

#pragma mark - Precondition
/**
 *  Check if the camera's mode is DJICameraModeRecordVideo.
 *  If the mode is not DJICameraModeRecordVideo, we need to set it to be DJICameraModeRecordVideo.
 *  If the mode is already DJICameraModeRecordVideo, we check the exposure mode.
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
            else if (mode == DJICameraModeRecordVideo) {
                target.isInRecordVideoMode = YES;
            }
            else {
                [target setCameraMode];
            }
        }];
    }
}

/**
 *  Set the camera's mode to DJICameraModeRecordVideo.
 *  If it succeeds, we can enable the take photo button.
 */
-(void) setCameraMode {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        WeakRef(target);
        [camera setCameraMode:DJICameraModeRecordVideo withCompletion:^(NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"ERROR: setCameraMode:withCompletion:. %@", error.description);
            }
            else {
                // Normally, once an operation is finished, the camera still needs some time to finish up
                // all the work. It is safe to delay the next operation after an operation is finished.
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    WeakReturn(target);
                    target.isInRecordVideoMode = YES;
                });
            }
        }];
    }
}

#pragma mark - Actions
/**
 *  When the pre-condition meets, the start record button should be enabled. Then the user can can record
 *  a video now.
 */
- (IBAction)onStartRecordButtonClicked:(id)sender {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        [self.startRecordButton setEnabled:NO];
        [camera startRecordVideoWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"ERROR: startRecordVideoWithCompletion:. %@", error.description);
            }
        }];
    }
}

/**
 *  When the camera is recording, the stop record button should be enabled. Then the user can stop recording
 *  the video.
 */
- (IBAction)onStopRecordButtonClicked:(id)sender {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        [self.stopRecordButton setEnabled:NO];
        [camera stopRecordVideoWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"ERROR: stopRecordVideoWithCompletion:. %@", error.description);
            }
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

-(void) setIsInRecordVideoMode:(BOOL)isInRecordVideoMode {
    _isInRecordVideoMode = isInRecordVideoMode;
    [self toggleRecordUI];
}

-(void) setIsRecordingVideo:(BOOL)isRecordingVideo {
    _isRecordingVideo = isRecordingVideo;
    [self toggleRecordUI];
}

-(void) toggleRecordUI {
    [self.startRecordButton setEnabled:(self.isInRecordVideoMode && !self.isRecordingVideo)];
    [self.stopRecordButton setEnabled:(self.isInRecordVideoMode && self.isRecordingVideo)];
    if (!self.isRecordingVideo) {
        self.recordingTimeLabel.text = @"00:00";
    }
    else {
        int hour = self.recordingTime / 3600;
        int minute = (self.recordingTime % 3600) / 60;
        int second = (self.recordingTime % 3600) % 60;
        self.recordingTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hour, minute, second];
    }
}

#pragma mark - DJICameraDelegate
-(void)camera:(DJICamera *)camera didReceiveVideoData:(uint8_t *)videoBuffer length:(size_t)size {
    [[VideoPreviewer instance] push:videoBuffer length:(int)size];
}

-(void)camera:(DJICamera *)camera didUpdateSystemState:(DJICameraSystemState *)systemState {
    self.isRecordingVideo = systemState.isRecording;
    
    self.recordingTime = systemState.currentVideoRecordingTimeInSeconds;
}

@end
