//
//  GimbalRotationInSpeedViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates how to control the gimbal's rotation speed.
 */
#import <DJISDK/DJISDK.h>
#import "DemoComponentHelper.h"
#import "GimbalRotationInSpeedViewController.h"

@interface GimbalRotationInSpeedViewController ()

@property(strong,nonatomic) NSTimer* gimbalSpeedTimer;

@property(atomic) float rotationAngleVelocity;

@end

@implementation GimbalRotationInSpeedViewController

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self resetRotation];
    
    /*
     *  The proper way to use rotateGimbalInSpeedWithPitch:Roll:Yaw:withCompletion: is to keep sending the command in a 
     *  frequency. The suggested time interval is 40ms.
     */
    if (self.gimbalSpeedTimer == nil) {
        self.gimbalSpeedTimer = [NSTimer scheduledTimerWithTimeInterval:0.04 target:self selector:@selector(onUpdateGimbalSpeedTick:) userInfo:nil repeats:YES];
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.gimbalSpeedTimer) {
        [self.gimbalSpeedTimer invalidate];
        self.gimbalSpeedTimer = nil;
    }
}

- (IBAction)onUpButtonClicked:(id)sender {
    self.rotationAngleVelocity = 5.0;
}

- (IBAction)onDownButtonClicked:(id)sender {
    self.rotationAngleVelocity = -5.0;
}

- (IBAction)onStopButtonClicked:(id)sender {
    self.rotationAngleVelocity = 0.0; 
}

-(void) onUpdateGimbalSpeedTick:(id)timer {
    __weak DJIGimbal* gimbal = [DemoComponentHelper fetchGimbal];
    if (gimbal) {
        DJIGimbalRotation *rotation = [DJIGimbalRotation gimbalRotationWithPitchValue:@(self.rotationAngleVelocity)
                                                                            rollValue:nil
                                                                             yawValue:nil
                                                                                 time:0
                                                                                 mode:DJIGimbalRotationModeSpeed];

        [gimbal rotateWithRotation:rotation completion:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"ERROR: rotateGimbalInSpeed. %@", error.description);
            }
        }];
    }
}

-(void) resetRotation {
    self.rotationAngleVelocity = 0.0;
}

@end
