//
//  CameraTestViewController.h
//  DJISdkDemo
//
//  Created by Ares on 14-7-3.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import "InspireCameraSettingsView.h"
#import "DJILogerViewController.h"
#import "DJIBaseViewController.h"
#import "DJIDemoHelper.h"

@interface InspireCameraTestViewController : DJIBaseViewController<DJIDroneDelegate, DJICameraDelegate, DJIMainControllerDelegate>
{
    DJIDrone* _drone;
    DJIInspireCamera* mInspireCamera;
    UIView* videoPreviewView;
    
    InspireCameraSettingsView* _settingsView;
    DJICameraSystemState* mCameraSystemState;
    DJICameraPlaybackState* mCameraPlaybackState;
    CameraWorkMode mLastWorkMode;
}

@property(nonatomic, strong) IBOutlet UIButton* captureButton;
@property(nonatomic, strong) IBOutlet UIButton* recordingButton;
@property(nonatomic, strong) IBOutlet UILabel* recordingTimeLabel;
@property(nonatomic, strong) IBOutlet UIView* contentView1;
@property(nonatomic, strong) IBOutlet UIView* contentView2;
@property(nonatomic, strong) IBOutlet UIView* singlePreviewView;
@property(nonatomic, strong) IBOutlet UIView* multiPreviewView;
@property(nonatomic, strong) IBOutlet UIView* multiEditView;

@property(nonatomic, strong) UIAlertView* downloadProgressAlert;

-(IBAction) onStartTakePhotoClicked:(id)sender;

-(IBAction) onStartRecordingClicked:(id)sender;

-(IBAction) onSetSettingsClicked:(id)sender;

-(IBAction) onPlaybackButtonClicked:(id)sender;

-(IBAction) onHardwareDecodeSwitchValueChanged:(id)sender;

-(IBAction) onBack:(id)sender;

@end
