//
//  CameraTestViewController.h
//  DJISdkDemo
//
//  Created by Ares on 14-7-3.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import "Phantom3AdvancedCameraSettingsView.h"
#import "DJIBaseViewController.h"
#import "DJIDemoHelper.h"

@interface Phantom3AdvancedCameraTestViewController : DJIBaseViewController<DJIDroneDelegate, DJICameraDelegate, DJIMainControllerDelegate>
{
    DJIDrone* _drone;
    DJIPhantom3AdvancedCamera* mPhantom3AdvancedCamera;
    UIView* videoPreviewView;
    
    Phantom3AdvancedCameraSettingsView* _settingsView;
    DJICameraSystemState* mCameraSystemState;
    DJICameraPlaybackState* mCameraPlaybackState;
    CameraWorkMode mLastWorkMode;
}

@property(nonatomic, strong) IBOutlet UIButton* captureButton;
@property(nonatomic, strong) IBOutlet UIButton* recordingButton;
@property(nonatomic, strong) IBOutlet UILabel* recordingTimeLabel;
@property(nonatomic, strong) IBOutlet UIView* contentView1;
@property(nonatomic, strong) IBOutlet UIView* contentView2;

-(IBAction) onStartTakePhotoClicked:(id)sender;

-(IBAction) onStartRecordingClicked:(id)sender;

-(IBAction) onSetSettingsClicked:(id)sender;

-(IBAction) onBack:(id)sender;

@end
