//
//  GimbalTestViewController.h
//  DJISdkDemo
//
//  Created by Ares on 14-7-16.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import "DJILogerViewController.h"
#import "DJIBaseViewController.h"
#import "DJIDemoHelper.h"

@interface InspireGimbalTestViewController : DJIBaseViewController<DJIDroneDelegate, DJIGimbalDelegate, UITextFieldDelegate>
{
    DJIDrone* mDrone;
    DJIInspireGimbal* mGimbal;

    int mLastStepValue;
    BOOL _gimbalAttitudeUpdateFlag;
}

@property(nonatomic, strong) UILabel* attitudeLabel;
@property(nonatomic, strong) IBOutlet UITextField* pitchInputBox;
@property(nonatomic, strong) IBOutlet UITextField* yawInputBox;
/**
 *  Gimbal
 *
 */
-(IBAction) onGimbalScrollUpTouchDown:(id)sender;

-(IBAction) onGimbalScrollUpTouchUp:(id)sender;

-(IBAction) onGimbalScroollDownTouchDown:(id)sender;

-(IBAction) onGimbalScroollDownTouchUp:(id)sender;

-(IBAction) onGimbalYawRotationForwardTouchDown:(id)sender;

-(IBAction) onGimbalYawRotationForwardTouchUp:(id)sender;

-(IBAction) onGimbalYawRotationBackwardTouchDown:(id)sender;

-(IBAction) onGimbalYawRotationBackwardTouchUp:(id)sender;

-(IBAction) onSetGimbalAngleButtonClicked:(id)sender;

@end
