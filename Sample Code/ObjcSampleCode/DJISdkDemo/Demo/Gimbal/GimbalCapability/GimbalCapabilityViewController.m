//
//  GimbalCapabilityViewController.m
//  DJISdkDemo
//
//  Copyright © 2016 DJI. All rights reserved.
//
/**
 *  This file demonstrates how to use gimbal capability to check if a feature is supported by the connected gimbal and the valid range for 
 *  the feature. This demo will do the following steps: 
 *  1. Enable/disable buttons according to the supported features. 
 *  2. For products that support pitch range extension, the program will enable this feature. 
 *  3. When a button is pressed, this demo will get the min or max valid value and rotate the gimbal to the value. 
 *
 *  A feature is represented by a key with DJIGimbalKey prefix. The value in the gimbalCapability dictionary is an istance of
 *  DJIParamCapability or its subclass. A category, capabilityCheck, of DJIGimbal is provided in this demo.
 */
#import <DJISDK/DJISDK.h>
#import "DJIGimbal+CapabilityCheck.h"
#import "GimbalCapabilityViewController.h"
#import "DemoUtility.h"

@interface GimbalCapabilityViewController ()

@property (weak, nonatomic) IBOutlet UIButton *pitchMinButton;
@property (weak, nonatomic) IBOutlet UIButton *pitchMaxButton;
@property (weak, nonatomic) IBOutlet UIButton *yawMinButton;
@property (weak, nonatomic) IBOutlet UIButton *yawMaxButton;
@property (weak, nonatomic) IBOutlet UIButton *rollMinButton;
@property (weak, nonatomic) IBOutlet UIButton *rollMaxButton;

@property (assign, nonatomic) DJIGimbalAngleRotation pitchRotation;
@property (assign, nonatomic) DJIGimbalAngleRotation yawRotation;
@property (assign, nonatomic) DJIGimbalAngleRotation rollRotation;

- (IBAction)rotateGimbalToMin:(id)sender;
- (IBAction)rotateGimbalToMax:(id)sender;
- (IBAction)resetGimbal:(id)sender;

@end

@implementation GimbalCapabilityViewController

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupButtons];
    [self setupRotationStructs];
    [self enablePitchExtensionIfPossible];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void) setupButtons {
    DJIGimbal* gimbal = [DemoComponentHelper fetchGimbal];
    [self.pitchMinButton setEnabled:[gimbal isFeatureSupported:DJIGimbalKeyAdjustPitch]];
    [self.pitchMaxButton setEnabled:[gimbal isFeatureSupported:DJIGimbalKeyAdjustPitch]];
    [self.yawMinButton setEnabled:[gimbal isFeatureSupported:DJIGimbalKeyAdjustYaw]];
    [self.yawMaxButton setEnabled:[gimbal isFeatureSupported:DJIGimbalKeyAdjustYaw]];
    [self.rollMinButton setEnabled:[gimbal isFeatureSupported:DJIGimbalKeyAdjustRoll]];
    [self.rollMaxButton setEnabled:[gimbal isFeatureSupported:DJIGimbalKeyAdjustRoll]];
}

-(void) setupRotationStructs {
    DJIGimbal* gimbal = [DemoComponentHelper fetchGimbal];
    _pitchRotation.enabled = [gimbal isFeatureSupported:DJIGimbalKeyAdjustPitch];
    _yawRotation.enabled = [gimbal isFeatureSupported:DJIGimbalKeyAdjustYaw];
    _rollRotation.enabled = [gimbal isFeatureSupported:DJIGimbalKeyAdjustRoll];
}

-(void) enablePitchExtensionIfPossible {
    DJIGimbal* gimbal = [DemoComponentHelper fetchGimbal];
    if (gimbal == nil) {
        return;
    }
    BOOL isPossible = [gimbal isFeatureSupported:DJIGimbalKeyPitchRangeExtension];
    if (isPossible) {
        [gimbal setPitchRangeExtensionEnabled:YES withCompletion:nil];
    }
}


- (IBAction)rotateGimbalToMin:(id)sender {
    DJIGimbal* gimbal = [DemoComponentHelper fetchGimbal];
    if (gimbal == nil) {
        return;
    }
    
    NSString *key = [self getCorrespondingKeyWithButton:(UIButton *)sender];
    NSInteger min = -[[gimbal getParamMin:key] integerValue];
    
    if ([key isEqualToString:DJIGimbalKeyAdjustPitch]) {
        _pitchRotation.direction = DJIGimbalRotateDirectionCounterClockwise;
        _pitchRotation.angle = (float)min;
    }
    else if ([key isEqualToString:DJIGimbalKeyAdjustYaw]) {
        _yawRotation.direction = DJIGimbalRotateDirectionCounterClockwise;
        _yawRotation.angle = (float)min;
    }
    else if ([key isEqualToString:DJIGimbalKeyAdjustRoll]) {
        _rollRotation.direction = DJIGimbalRotateDirectionCounterClockwise;
        _rollRotation.angle = (float)min;
    }
    
    [self sendRotateGimbalCommand];
}

- (IBAction)rotateGimbalToMax:(id)sender {
    DJIGimbal* gimbal = [DemoComponentHelper fetchGimbal];
    if (gimbal == nil) {
        return;
    }
    
    NSString *key = [self getCorrespondingKeyWithButton:(UIButton *)sender];
    NSInteger max = [[gimbal getParamMax:key] integerValue];
    
    if ([key isEqualToString:DJIGimbalKeyAdjustPitch]) {
        _pitchRotation.direction = DJIGimbalRotateDirectionClockwise;
        _pitchRotation.angle = (float)max;
    }
    else if ([key isEqualToString:DJIGimbalKeyAdjustYaw]) {
        _yawRotation.direction = DJIGimbalRotateDirectionClockwise;
        _yawRotation.angle = (float)max;
    }
    else if ([key isEqualToString:DJIGimbalKeyAdjustRoll]) {
        _rollRotation.direction = DJIGimbalRotateDirectionClockwise;
        _rollRotation.angle = (float)max;
    }
    
    [self sendRotateGimbalCommand];
}

- (IBAction)resetGimbal:(id)sender {
    _pitchRotation.angle = 0;
    _yawRotation.angle = 0;
    _rollRotation.angle = 0;
    
    [self sendRotateGimbalCommand];
}

-(void) sendRotateGimbalCommand {
    DJIGimbal* gimbal = [DemoComponentHelper fetchGimbal];
    if (gimbal == nil) {
        return;
    }
    
    [gimbal rotateGimbalWithAngleMode:DJIGimbalAngleModeAbsoluteAngle pitch:self.pitchRotation roll:self.rollRotation yaw:self.yawRotation withCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"rotateGimbalWithAngleMode failed: %@", error.description);
        }
    }];
}

-(NSString *) getCorrespondingKeyWithButton:(UIButton *)button {
    if (button == self.pitchMinButton || button == self.pitchMaxButton) {
        return DJIGimbalKeyAdjustPitch;
    }
    else if (button == self.yawMinButton || button == self.yawMaxButton) {
        return DJIGimbalKeyAdjustYaw;
    }
    else if (button == self.rollMinButton || button == self.rollMaxButton) {
        return DJIGimbalKeyAdjustRoll;
    }
    return nil;
}

@end
