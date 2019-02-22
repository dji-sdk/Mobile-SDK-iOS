//
//  CameraShootSinglePhotoViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

/**
 *  This file demonstrates: 
 *  1. how to use the video previewer and connect it with camera's video feed. 
 *  2. how to take a photo.
 */

#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"
#import <DJIWidget/DJIVideoPreviewer.h>
#import <DJIWidget/DJILiveViewDammyCameraTakePhotoSession.h>
#import "CameraShootSinglePhotoViewController.h"
#import "VideoPreviewerSDKAdapter.h"

@interface CameraShootSinglePhotoViewController () <DJICameraDelegate>

@property (nonatomic) BOOL isInShootPhotoMode;
@property (nonatomic) BOOL isShootingPhoto;
@property (nonatomic) BOOL isStoringPhoto;

@property (weak, nonatomic) IBOutlet UIView *videoFeedView;
@property (weak, nonatomic) IBOutlet UIButton *shootPhotoButton;

@property (nonatomic) VideoPreviewerSDKAdapter *previewerAdapter; 
@property (nonatomic, strong) DJILiveViewDammyCameraTakePhotoSession* captureSession;

@property (nonatomic, assign) BOOL isSDCardInserted;
@property (nonatomic, assign) BOOL isUsingInternalStorage;
@property (nonatomic, assign) BOOL isSingleSinglePhotoMode;
@property (nonatomic, assign) DJICameraStorageLocation activeStorageLocation;
@end

@implementation CameraShootSinglePhotoViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setVideoPreview];
    
    // set delegate to render camera's video feed into the view
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        [camera setDelegate:self];
    }
    
    // disable the shoot photo button by default
    [self.shootPhotoButton setEnabled:NO];
    
    // start to check the pre-condition
    [self getCameraMode];
	[self bindDatas];
	[self setupCaptureSession];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // clean the delegate
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera && camera.delegate == self) {
        [camera setDelegate:nil];
    }
    
    [self cleanVideoPreview];
	[self cleanupCaptureSession];
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
	
	DJIKey *shootPhotoModeKey = [DJICameraKey keyWithParam:DJICameraParamShootPhotoMode];
	[[DJISDKManager keyManager] startListeningForChangesOnKey:shootPhotoModeKey withListener:self andUpdateBlock:^(DJIKeyedValue * _Nullable oldValue, DJIKeyedValue * _Nullable newValue) {
		WeakReturn(target);
		if (newValue) {
			target.isSingleSinglePhotoMode = [storageValue integerValue] == DJICameraShootPhotoModeSingle;
		}
	}];
	DJIKeyedValue *shootPhotoModeValue = [[DJISDKManager keyManager] getValueForKey:storageKey];
	if (shootPhotoModeValue) {
		self.isSingleSinglePhotoMode = [storageValue integerValue] == DJICameraShootPhotoModeSingle;
	}
}

#pragma mark - Capture Session

- (void)setupCaptureSession {
	self.captureSession = [[DJILiveViewDammyCameraTakePhotoSession alloc] initWithVideoPreviewer:[DJIVideoPreviewer instance]];
	[self.captureSession addObserver:self forKeyPath:@"captureStatus" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)cleanupCaptureSession {
	[self.captureSession removeObserver:self forKeyPath:@"captureStatus"];
	[self.captureSession stopSession];
	self.captureSession = nil;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"captureStatus"]) {
		[self onSessionCaptureStatusChanged:change];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:nil];
	}
}

-(void) onSessionCaptureStatusChanged:(id)value
{
	if (self.captureSession.captureStatus == DJILiveViewDammyCameraCaptureStatusCapturing) {
		[self.shootPhotoButton setEnabled:NO];
	} else {
		[self.shootPhotoButton setEnabled:YES];
	}
}


#pragma mark - Precondition
/**
 *  Check if the camera's mode is DJICameraModeShootPhoto.
 *  If the mode is not DJICameraModeShootPhoto, we need to set it to be ShootPhoto.
 *  If the mode is already DJICameraModeShootPhoto, we check the exposure mode.
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
            else if (mode == DJICameraModeShootPhoto) {
                target.isInShootPhotoMode = YES;
            }
            else {
                [target setCameraMode];
            }
        }];
    }
}

/**
 *  Set the camera's mode to DJICameraModeShootPhoto.
 *  If it succeeds, we can enable the take photo button.
 */
-(void) setCameraMode {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        WeakRef(target);
        [camera setMode:DJICameraModeShootPhoto withCompletion:^(NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"ERROR: setMode:withCompletion:. %@", error.description);
            }
            else {
                // Normally, once an operation is finished, the camera still needs some time to finish up
                // all the work. It is safe to delay the next operation after an operation is finished.
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    WeakReturn(target);
                    [camera setShootPhotoMode:DJICameraShootPhotoModeSingle withCompletion:^(NSError * _Nullable error) {
                        WeakReturn(target);
                        if (error) {
                            ShowResult(@"ERROR: setShootPhotoMode:withCompletion:. %@", error.description);
                        }
                        else {
                            target.isInShootPhotoMode = YES;
                        }
                    }];
                });
            }
        }];
    }
}

#pragma mark - Actions
/**
 *  When the pre-condition meets, the shoot photo button should be enabled. Then the user can can shoot
 *  a photo now.
 */
- (IBAction)onShootPhotoButtonClicked:(id)sender {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
		if (self.activeStorageLocation == DJICameraStorageLocationSDCard &&
			!self.isSDCardInserted &&
			!self.isUsingInternalStorage &&
			self.isSingleSinglePhotoMode) {
			if (self.captureSession.captureStatus == DJILiveViewDammyCameraCaptureStatusCapturing) {
				[self.captureSession stopSession];
			} else {
				WeakRef(target);
				[DemoAlertView showAlertViewWithMessage:@"ShotPhoto Without SD card, Save on Photo Library" titles:@[@"Cancel", @"OK"] action:^(NSUInteger buttonIndex) {
					if (buttonIndex == 1) {
						[target.captureSession startSession];
					}
				}];
			}
			return;
		}
		
		[self.shootPhotoButton setEnabled:NO];
        [camera startShootPhotoWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"ERROR: startShootPhoto:withCompletion:. %@", error.description);
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

-(void) setIsInShootPhotoMode:(BOOL)isInShootPhotoMode {
    _isInShootPhotoMode = isInShootPhotoMode;
    [self toggleShootPhotoButton];
}

-(void) setIsShootingPhoto:(BOOL)isShootingPhoto {
    _isShootingPhoto = isShootingPhoto;
    [self toggleShootPhotoButton];
}

-(void) setIsStoringPhoto:(BOOL)isStoringPhoto {
    _isStoringPhoto = isStoringPhoto;
    [self toggleShootPhotoButton]; 
}

-(void) toggleShootPhotoButton {
    [self.shootPhotoButton setEnabled:(self.isInShootPhotoMode && !self.isShootingPhoto && !self.isStoringPhoto)];
}

#pragma mark - DJICameraDelegate

-(void)camera:(DJICamera *)camera didUpdateSystemState:(DJICameraSystemState *)systemState {
    self.isShootingPhoto = systemState.isShootingSinglePhoto ||
                           systemState.isShootingIntervalPhoto ||
                           systemState.isShootingBurstPhoto;
    
    self.isStoringPhoto = systemState.isStoringPhoto;
}

-(void)camera:(DJICamera *)camera didUpdateStorageState:(DJICameraStorageState *)sdCardState {
	self.isSDCardInserted = sdCardState.isInserted;
	if (self.activeStorageLocation == DJICameraStorageLocationSDCard) {
		self.isSDCardInserted = sdCardState.isInserted;
	}
	else {
		self.isUsingInternalStorage = sdCardState.isInserted;
	}
}

@end
