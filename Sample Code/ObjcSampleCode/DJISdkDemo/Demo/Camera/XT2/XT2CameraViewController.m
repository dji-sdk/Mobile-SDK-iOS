//
//  XT2CameraViewController.m
//  DJISdkDemo
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import "XT2CameraViewController.h"
#import "VideoPreviewerSDKAdapter.h"
#import <VideoPreviewer/VideoPreviewer.h>
#import "DemoUtility.h"

@interface XT2CameraViewController () <DJICameraDelegate>

@property (weak, nonatomic) IBOutlet UIView *fpvPreviewView;
@property (strong, nonatomic) VideoPreviewerSDKAdapter *adapter;
@property (strong, nonatomic) VideoPreviewer *videoPreviewer;
@property (weak, nonatomic) IBOutlet UIButton *shootPhotoButton;
@property (weak, nonatomic) IBOutlet UISwitch *fpvTemEnableSwitch;
@property (weak, nonatomic) IBOutlet UILabel *fpvTemperatureData;

@property (nonatomic) BOOL isInShootPhotoMode;
@property (nonatomic) BOOL isShootingPhoto;
@property (nonatomic) BOOL isStoringPhoto;

@end

@implementation XT2CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    //Set up as a delegate to the thermal camera to get Temperature updates
    __weak DJICamera *thermalCamera = [DemoXT2Helper connectedThermalCamera];
    if (thermalCamera) {
        thermalCamera.delegate = self;
    }

    //Set up the video previewer for the XT2.
    //NOTE: The same video previewer can access either camera depending on the video mode.
    //See the button's below to change the video mode.
    self.videoPreviewer = [[VideoPreviewer alloc] init];
    [self.videoPreviewer setView:self.fpvPreviewView];
    [self.videoPreviewer setType:VideoPreviewerTypeAutoAdapt];
    DJIVideoFeed *videoFeed;
    if (![DemoXT2Helper isXT2Camera] && [DemoXT2Helper connectedThermalCamera].index == 1) {
        videoFeed = [DJISDKManager videoFeeder].secondaryVideoFeed;
    } else {
        videoFeed = [DJISDKManager videoFeeder].primaryVideoFeed;
    }
    if (!self.adapter) {
        self.adapter = [VideoPreviewerSDKAdapter adapterWithVideoPreviewer:self.videoPreviewer andVideoFeed:videoFeed];
    }
    [self.videoPreviewer start];
    [self.adapter start];
    
    [self getCameraMode];
    [self updateThermalCameraUI];
}

//Change the XT2 Video mode to Thermal (IR) only
- (IBAction)irButtonPressed:(id)sender {
    [self updateVideoMode:DJICameraDisplayModeThermalOnly];
}

//Change the XT2 camera video mode to Visual only
- (IBAction)visibleButtonPressed:(id)sender {
    [self updateVideoMode:DJICameraDisplayModeVisualOnly];
}

//Change the XT2 camera video mode to MSX
- (IBAction)msxButtonPressed:(id)sender {
    [self updateVideoMode:DJICameraDisplayModeMSX];
}

//Change the XT2 camera video mode to PIP
- (IBAction)pipButtonPressed:(id)sender {
    [self updateVideoMode:DJICameraDisplayModePIP];
}

//Get count of photo's remaining on the XT2
//NOTE: use the Visual camera to get the correct count.
- (IBAction)getRemainingPhotoPressed:(id)sender {
    DJICamera *XT2VisualCamera = [DemoXT2Helper connectedXT2VisionCamera];
    DJICameraKey *remainingCountKey = [DJICameraKey keyWithIndex:XT2VisualCamera.index andParam:DJICameraParamSDCardAvailablePhotoCount];
    [[DJISDKManager keyManager] getValueForKey:remainingCountKey withCompletion:^(DJIKeyedValue * _Nullable value, NSError * _Nullable error) {
        ShowResult(@"There are %ld photos remaining", value.integerValue);
    }];
}

//Send the new video mode to the XT2 camera.
- (void) updateVideoMode:(DJICameraDisplayMode) mode {
    DJICameraKey *displayModeKey = [DemoXT2Helper thermalCameraKeyWithParam:DJICameraParamDisplayMode];
    [[DJISDKManager keyManager] setValue:@(mode) forKey:displayModeKey withCompletion:^(NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ShowResult(@"Failed to update video mode: %@", error.description);
            });
        }
    }];
}

/**
 *  Check if the camera's mode is DJICameraModeShootPhoto.
 *  If the mode is not DJICameraModeShootPhoto, we need to set it to be ShootPhoto.
 *  If the mode is already DJICameraModeShootPhoto, we check the exposure mode.
 */
-(void) getCameraMode {
    __weak DJICamera* camera = [DemoXT2Helper connectedThermalCamera];
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
    __weak DJICamera* camera = [DemoXT2Helper connectedThermalCamera];
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

- (IBAction)takePhotoButtonPressed:(id)sender {
    __weak DJICamera* camera = [DemoXT2Helper connectedThermalCamera];
    if (camera) {
        [self.shootPhotoButton setEnabled:NO];
        [camera startShootPhotoWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"ERROR: startShootPhoto:withCompletion:. %@", error.description);
            }
        }];
    }
}

//Enable temperature measurement on the thermal camera
- (IBAction)onThermalTemperatureDataSwitchValueChanged:(id)sender {
    DJICamera* camera = [DemoXT2Helper connectedThermalCamera];
    if (camera) {
        DJICameraThermalMeasurementMode mode = ((UISwitch*)sender).on ? DJICameraThermalMeasurementModeSpotMetering : DJICameraThermalMeasurementModeDisabled;
        [camera setThermalMeasurementMode:mode withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"Failed to set the measurement mode: %@", error.description);
            }
        }];
    }
}

- (void)updateThermalCameraUI {
    DJICamera* camera = [DemoXT2Helper connectedThermalCamera];
    if (camera && [camera isThermalCamera]) {
        WeakRef(target);
        [camera getThermalMeasurementModeWithCompletion:^(DJICameraThermalMeasurementMode mode, NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"Failed to get the measurement mode status: %@", error.description);
            }
            else {
                BOOL enabled = mode != DJICameraThermalMeasurementModeDisabled ? YES : NO;
                [target.fpvTemEnableSwitch setOn:enabled];
            }
        }];
    }
}

#pragma mark - DJICameraDelegate
-(void)camera:(DJICamera *)camera didUpdateSystemState:(DJICameraSystemState *)systemState {
    self.isShootingPhoto = systemState.isShootingSinglePhoto ||
    systemState.isShootingIntervalPhoto ||
    systemState.isShootingBurstPhoto;

    self.isStoringPhoto = systemState.isStoringPhoto;
}

-(void)camera:(DJICamera *)camera didUpdateTemperatureData:(float)temperature {
    self.fpvTemperatureData.text = [NSString stringWithFormat:@"%.1f", temperature];
}

@end
