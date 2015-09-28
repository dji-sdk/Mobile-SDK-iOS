//
//  GimbalTestViewController.h
//  DJISdkDemo
//
//  Created by Ares on 14-7-16.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import "DJIBaseViewController.h"
#import "DJIDemoHelper.h"

@interface Phantom3AdvancedGimbalTestViewController : DJIBaseViewController<DJIDroneDelegate, DJIGimbalDelegate>
{
    DJIDrone* mDrone;
    DJIPhantom3AdvancedGimbal* mGimbal;

    int mLastStepValue;
    BOOL _gimbalAttitudeUpdateFlag;
}

@property(nonatomic, strong) UILabel* attitudeLabel;
/**
 *  Gimbal
 *
 */
-(IBAction) onGimbalScrollUpTouchDown:(id)sender;

-(IBAction) onGimbalScrollUpTouchUp:(id)sender;

-(IBAction) onGimbalScroollDownTouchDown:(id)sender;

-(IBAction) onGimbalScroollDownTouchUp:(id)sender;

@end
