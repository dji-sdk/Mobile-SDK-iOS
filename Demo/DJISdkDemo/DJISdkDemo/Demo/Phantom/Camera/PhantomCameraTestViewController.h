//
//  CameraTestViewController.h
//  DJISdkDemo
//
//  Created by Ares on 14-7-3.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import "PhantomCameraSettingsView.h"

@interface PhantomCameraTestViewController : UIViewController<DJIDroneDelegate, DJICameraDelegate, DJIMainControllerDelegate>
{
    DJIDrone* _drone;
    UIView* videoPreviewView;
    PhantomCameraSettingsView* _settingsView;

    BOOL _isTimeSynced;
    BOOL _isRecording;
}

@property(nonatomic, strong) IBOutlet UIButton* captureButton;
@property(nonatomic, strong) IBOutlet UIButton* recordingButton;

-(IBAction) onStartTakePhotoClicked:(id)sender;

-(IBAction) onStopTakePhotoClicked:(id)sender;

-(IBAction) onStartRecordingClicked:(id)sender;

-(IBAction) onSetSettingsClicked:(id)sender;

-(IBAction) onSetRecordingResolutionClicked:(id)sender;

-(IBAction) onStartUpdateSystemState:(id)sender;

-(IBAction) onSyncTimeClicked:(id)sender;



-(IBAction) onBack:(id)sender;

@end
