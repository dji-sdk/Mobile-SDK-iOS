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
#import <DJIWidget/DJIVideoPreviewer.h>
#import "CameraRecordVideoViewController.h"
#import "VideoPreviewerSDKAdapter.h"
#import <DJIWidget/DJIVideoFeedCachingSession.h>

@interface CameraRecordVideoViewController () <DJICameraDelegate>

@property (nonatomic) BOOL isInRecordVideoMode;
@property (nonatomic) BOOL isRecordingVideo;
@property (nonatomic) NSUInteger recordingTime;

@property (weak, nonatomic) IBOutlet UIView *videoFeedView;

@property (weak, nonatomic) IBOutlet UILabel *recordingTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *startRecordButton;
@property (weak, nonatomic) IBOutlet UIButton *stopRecordButton;

@property (nonatomic) VideoPreviewerSDKAdapter *previewerAdapter; 

@property (nonatomic) BOOL isSDCardInserted;
@property (nonatomic) BOOL isUsingInternalStorage;
@property (nonatomic) DJIVideoFeedCachingSession* recordVideoSession;
@property (nonatomic) DJICameraStorageLocation activeStorageLocation;

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
	[[DJISDKManager keyManager] stopAllListeningOfListeners:self];
}

- (void)bindDatas {
	WeakRef(target);
	DJIKey *storageKey = [DJICameraKey keyWithParam:DJICameraParamStorageLocation];
	[[DJISDKManager keyManager] startListeningForChangesOnKey:storageKey withListener:self andUpdateBlock:^(DJIKeyedValue * _Nullable oldValue, DJIKeyedValue * _Nullable newValue) {
		WeakReturn(target);
		if (newValue) {
			target.activeStorageLocation = [newValue integerValue];
		}
	}];
	DJIKeyedValue *storageValue = [[DJISDKManager keyManager] getValueForKey:storageKey];
	if (storageValue) {
		self.activeStorageLocation = [storageValue integerValue];
	}
}

#pragma mark - Record Video Session

- (void)setupRecordVideoSession {
	self.recordVideoSession = [[DJIVideoFeedCachingSession alloc] initWithVideoPreviewer:[DJIVideoPreviewer instance]];
	[self.recordVideoSession addObserver:self forKeyPath:@"recordingStatus" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)cleanupRecordVideoSession {
	[self.recordVideoSession removeObserver:self forKeyPath:@"recordingStatus"];
	[self.recordVideoSession stopSession];
	self.recordVideoSession = nil;
}

-(void) onSessionRecordStatusChanged:(id)value
{
	if (self.recordVideoSession.recordingStatus == DJILiveViewDammyCameraRecordingStatusRecording) {
		[self.startRecordButton setEnabled:NO];
		[self.stopRecordButton setEnabled:YES];
	} else {
		[self.startRecordButton setEnabled:YES];
		[self.stopRecordButton setEnabled:NO];
	}
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"recordingStatus"]) {
		[self onSessionRecordStatusChanged:change];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:nil];
	}
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
        [camera getModeWithCompletion:^(DJICameraMode mode, NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"ERROR: getModeWithCompletion:. %@", error.description);
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
        if ([camera.displayName isEqualToString:DJICameraDisplayNameZenmuseP1]) {
            [camera setFlatMode:DJIFlatCameraModeVideoNormal withCompletion:^(NSError * _Nullable error) {
                WeakReturn(target);
                if (error) {
                    ShowResult(@"ERROR: setFlatMode:withCompletion:. %@", error.description);
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
        } else {
            [camera setMode:DJICameraModeRecordVideo withCompletion:^(NSError * _Nullable error) {
                WeakReturn(target);
                if (error) {
                    ShowResult(@"ERROR: setMode:withCompletion:. %@", error.description);
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
}

#pragma mark - Actions
/**
 *  When the pre-condition meets, the start record button should be enabled. Then the user can can record
 *  a video now.
 */
- (IBAction)onStartRecordButtonClicked:(id)sender {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
		
		if (!self.isSDCardInserted &&
			!self.isUsingInternalStorage &&
			self.isInRecordVideoMode) {
			if (self.recordVideoSession.recordingStatus == DJILiveViewDammyCameraRecordingStatusRecording) {
				ShowResult(@"Current in record video mode");
			} else {
				WeakRef(target);
				[DemoAlertView showAlertViewWithMessage:@"Record Without SD card, Save on SandBox" titles:@[@"Cancel", @"OK"] action:^(NSUInteger buttonIndex) {
					if (buttonIndex == 1) {
						[target setupRecordVideoSession];
						[target.recordVideoSession startSession];
					}
				}];
			}
			return;
		}
		
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
		
		if (!self.isSDCardInserted &&
			!self.isUsingInternalStorage &&
			self.isInRecordVideoMode) {
			if (self.recordVideoSession.recordingStatus != DJILiveViewDammyCameraRecordingStatusRecording) {
				ShowResult(@"Current not in record video mode");
			} else {
				[self.recordVideoSession stopSession];
				[self cleanupRecordVideoSession];
			}
			return;
		}
		
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
    [[DJIVideoPreviewer instance] start];
    [[DJIVideoPreviewer instance] setView:self.videoFeedView];
    self.previewerAdapter = [VideoPreviewerSDKAdapter adapterWithDefaultSettings];
    [self.previewerAdapter start];
	DJICamera* camera = [DemoComponentHelper fetchCamera];
	[self.previewerAdapter setupFrameControlHandler];
}

- (void)cleanVideoPreview {
    [[DJIVideoPreviewer instance] unSetView];
    if (self.previewerAdapter) {
    	[self.previewerAdapter stop];
    	self.previewerAdapter = nil;
    }
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
	BOOL isUsedNoSDCardRecordVideo = !self.isSDCardInserted && !self.isUsingInternalStorage && self.isInRecordVideoMode;
	BOOL isNoSDCardRecordingVideo = self.recordVideoSession.recordingStatus == DJILiveViewDammyCameraRecordingStatusRecording;
	if (isUsedNoSDCardRecordVideo) {
		[self.startRecordButton setEnabled:(self.isInRecordVideoMode && !isNoSDCardRecordingVideo)];
		[self.stopRecordButton setEnabled:(self.isInRecordVideoMode && isNoSDCardRecordingVideo)];
	} else {
		[self.startRecordButton setEnabled:(self.isInRecordVideoMode && !self.isRecordingVideo)];
		[self.stopRecordButton setEnabled:(self.isInRecordVideoMode && self.isRecordingVideo)];
	}
	
	if (isUsedNoSDCardRecordVideo) {
		if (isNoSDCardRecordingVideo) {
			
		}
	} else {
		
	}
	BOOL isRecordingVideo = self.isRecordingVideo || isNoSDCardRecordingVideo;
    if (!isRecordingVideo) {
        self.recordingTimeLabel.text = @"00:00";
    }
    else {
		NSUInteger recordTime = self.recordingTime;
		if (isUsedNoSDCardRecordVideo) {
			recordTime = self.recordVideoSession.recordedTime;
		}
		int hour = (int)recordTime / 3600;
		int minute = (recordTime % 3600) / 60;
		int second = (recordTime % 3600) % 60;
		self.recordingTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hour, minute, second];
    }
}

#pragma mark - DJICameraDelegate

-(void)camera:(DJICamera *)camera didUpdateSystemState:(DJICameraSystemState *)systemState {
    self.isRecordingVideo = systemState.isRecording;
    
    self.recordingTime = systemState.currentVideoRecordingTimeInSeconds;
}

-(void)camera:(DJICamera *)camera didUpdateStorageState:(DJICameraStorageState *)sdCardState {
    if (sdCardState.location == DJICameraStorageLocationSDCard) {
        self.isSDCardInserted = sdCardState.isInserted;
    }
	if (self.activeStorageLocation == DJICameraStorageLocationSDCard) {
        if (sdCardState.location == DJICameraStorageLocationSDCard) {
            self.isSDCardInserted = sdCardState.isInserted;
        }
	}
	else {
		self.isUsingInternalStorage = sdCardState.isInserted;
	}
}
@end
