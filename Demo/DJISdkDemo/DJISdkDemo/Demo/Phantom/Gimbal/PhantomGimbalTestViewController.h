//
//  GimbalTestViewController.h
//  DJISdkDemo
//
//  Created by Ares on 14-7-16.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>


@interface PhantomGimbalTestViewController : UIViewController<DJIDroneDelegate, DJIGimbalDelegate>
{
    DJIDrone* _drone;
    UILabel* _connectionStatusLabel;
    BOOL _gimbalAttitudeUpdateFlag;
}

@property(nonatomic, strong) IBOutlet UILabel* attitudeLabel;
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

-(IBAction) onGimbalAttitudeUpdateTest:(id)sender;
@end
