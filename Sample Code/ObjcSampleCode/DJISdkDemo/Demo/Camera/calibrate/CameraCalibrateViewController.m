//
//  CameraCalibrateViewController.m
//  DJISdkDemo
//
//  Created by neo.xu on 2021/8/4.
//  Copyright © 2021 DJI. All rights reserved.
//

#import "CameraCalibrateViewController.h"
#import "DemoUtility.h"
#import "VideoPreviewerSDKAdapter.h"
#import <DJIWidget/DJIVideoPreviewer.h>
#import <DJISDK/DJISDK.h>

@interface CameraCalibrateViewController () <DJICameraDelegate>

@property (nonatomic, weak) IBOutlet UIView *fpvView;
@property (weak, nonatomic) IBOutlet UILabel *calibrateStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *calibrateResultLabel;
@property (weak, nonatomic) IBOutlet UIButton *startCalibrate;
@property (weak, nonatomic) IBOutlet UIButton *setFocusTarget;

@property (nonatomic) VideoPreviewerSDKAdapter *previewerAdapter;

@end

@implementation CameraCalibrateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //    DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (self.camera) {
        self.camera.delegate = self;
    }
    DJIBaseProduct *product = [DemoComponentHelper fetchProduct];
    if ([product.model isEqualToString:DJIAircraftModelNameMatrice300RTK] && self.camera && self.camera.index == 0) {
        [[self ocuSyncLink] assignSourceToPrimaryChannel:DJIVideoFeedPhysicalSourceLeftCamera
                                        secondaryChannel:DJIVideoFeedPhysicalSourceFPVCamera
                                          withCompletion:^(NSError *_Nullable error) {
                                            if (error) {
                                                ShowResult(@"allocation error: %@", error.description);
                                            } else {
                                                ShowResult(@"success");
                                            }
                                          }];
    }

    [[DJIVideoPreviewer instance] start];
    self.previewerAdapter = [VideoPreviewerSDKAdapter adapterWithDefaultSettings];
    [self.previewerAdapter start];
    [self.previewerAdapter setupFrameControlHandler];

    [self.camera setFocusMode:DJICameraFocusModeAuto
               withCompletion:^(NSError *_Nullable error) {
                 if (error) {
                     NSLog(@"setFocusMode error: %@", error.description);
                     ShowResult(@"setFocusMode error: %@", error.description);
                 }
               }];
}

- (DJIOcuSyncLink *)ocuSyncLink {
    return [DemoComponentHelper fetchAirLink].ocuSyncLink;
}

- (DJICamera *)camera {
    return [DemoComponentHelper fetchCamera];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[DJIVideoPreviewer instance] setView:self.fpvView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // Call unSetView during exiting to release the memory.
    [[DJIVideoPreviewer instance] unSetView];

    if (self.previewerAdapter) {
        [self.previewerAdapter stop];
        self.previewerAdapter = nil;
    }
}

- (IBAction)onStartCalibrateButtonClicked:(id)sender {
    [self.camera startCalibrationWithCompletion:^(NSError *_Nullable error) {
      if (error) {
          ShowResult(@"ERROR: start calibration failed because %@", error.description);
      } else {
          ShowResult(@"Success! Please choose the object distance more than 102m as focus target to auto focus");
      }
    }];
}

- (IBAction)onSetFocusTargetButtonClicked:(id)sender {
    [DemoAlertView showAlertViewWithMessage:@"Set focus target"
                                     titles:@[ @"Cancle", @"OK" ]
                                 textFields:@[ @"X", @"Y" ]
                                     action:^(NSArray<UITextField *> *_Nullable textFields, NSUInteger buttonIndex) {
                                       if (buttonIndex == 0) {
                                           return;
                                       }
                                       float targetX = textFields[0].text.floatValue;
                                       float targetY = textFields[1].text.floatValue;
                                       CGPoint targetPoint = {targetX, targetY};
                                       [self.camera setFocusTarget:targetPoint
                                                    withCompletion:^(NSError *_Nullable error) {
                                                      if (error != nil) {
                                                          ShowResult(@"setFocusTarget failed: %@", error.description);
                                                      } else {
                                                          ShowResult(@"setFocusTarget success");
                                                      }
                                                    }];
                                     }];
}

- (void)camera:(DJICamera *_Nonnull)camera didUpdateCalibrationState:(DJICameraCalibrateState)calibrationState {
    NSString *calibrationStateString = @"";
    switch (calibrationState) {
        case DJICameraCalibrateState_NotCalibrate:
            calibrationStateString = @"CalibrateState_NotCalibrate";
            break;
        case DJICameraCalibrateState_Calibrated:
            calibrationStateString = @"CalibrateState_Calibrated";
            break;
        case DJICameraCalibrateState_Calibrating:
            calibrationStateString = @"CalibrateState_Calibrating";
            break;
        case DJICameraCalibrateState_WaitingForCalibrate:
            calibrationStateString = @"CalibrateState_WaitingForCalibrate";
            break;

        default:
            break;
    }
    [self.calibrateStateLabel setText:calibrationStateString];
}

- (void)camera:(DJICamera *_Nonnull)camera didUpdateCalibrationResult:(DJICameraCalibrateResult)calibrationResult {
    NSString *calibrationResultString = @"";
    switch (calibrationResult) {
        case DJICameraCalibrateResult_Idle:
            calibrationResultString = @"CalibrateResult_Idle";
            break;
        case DJICameraCalibrateResult_Completed:
            calibrationResultString = @"CalibrateResult_Completed";
            break;
        case DJICameraCalibrateResult_FailNormal:
            calibrationResultString = @"CalibrateResult_FailNormal";
            break;
        case DJICameraCalibrateResult_DataError:
            calibrationResultString = @"CalibrateResult_DataError";
            break;

        default:
            break;
    }
    [self.calibrateResultLabel setText:calibrationResultString];
}

@end
