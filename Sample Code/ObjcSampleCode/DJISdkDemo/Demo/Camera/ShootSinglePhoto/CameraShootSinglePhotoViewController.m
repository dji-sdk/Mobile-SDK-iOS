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
#import "CameraShootSinglePhotoViewController.h"
#import "VideoPreviewerSDKAdapter.h"

@interface CameraShootSinglePhotoViewController () <DJICameraDelegate>

@property (nonatomic) BOOL isInShootPhotoMode;
@property (nonatomic) BOOL isShootingPhoto;
@property (nonatomic) BOOL isStoringPhoto;

@property (weak, nonatomic) IBOutlet UIView *videoFeedView;
@property (weak, nonatomic) IBOutlet UIButton *shootPhotoButton;

@property (nonatomic) VideoPreviewerSDKAdapter *previewerAdapter; 

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
	if (([camera.displayName isEqualToString:DJICameraDisplayNameMavic2ZoomCamera] ||
		 [camera.displayName isEqualToString:DJICameraDisplayNameMavic2ProCamera])) {
		[self.previewerAdapter setupFrameControlHandler];
	}
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
-(void)camera:(DJICamera *)camera didReceiveVideoData:(uint8_t *)videoBuffer length:(size_t)length {
    [[DJIVideoPreviewer instance] push:videoBuffer length:(int)length];
}

-(void)camera:(DJICamera *)camera didUpdateSystemState:(DJICameraSystemState *)systemState {
    self.isShootingPhoto = systemState.isShootingSinglePhoto ||
                           systemState.isShootingIntervalPhoto ||
                           systemState.isShootingBurstPhoto;
    
    self.isStoringPhoto = systemState.isStoringPhoto;
}

@end
