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
 *  A feature is represented by a key with DJIGimbalParam prefix. The value in the gimbalCapability dictionary is an istance of
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

@property (assign, nonatomic) NSNumber *pitchRotation;
@property (assign, nonatomic) NSNumber *yawRotation;
@property (assign, nonatomic) NSNumber *rollRotation;

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
    [self.pitchMinButton setEnabled:[gimbal isFeatureSupported:DJIGimbalParamAdjustPitch]];
    [self.pitchMaxButton setEnabled:[gimbal isFeatureSupported:DJIGimbalParamAdjustPitch]];
    [self.yawMinButton setEnabled:[gimbal isFeatureSupported:DJIGimbalParamAdjustYaw]];
    [self.yawMaxButton setEnabled:[gimbal isFeatureSupported:DJIGimbalParamAdjustYaw]];
    [self.rollMinButton setEnabled:[gimbal isFeatureSupported:DJIGimbalParamAdjustRoll]];
    [self.rollMaxButton setEnabled:[gimbal isFeatureSupported:DJIGimbalParamAdjustRoll]];
}

-(void) setupRotationStructs {
    DJIGimbal* gimbal = [DemoComponentHelper fetchGimbal];
    self.pitchRotation = [gimbal isFeatureSupported:DJIGimbalParamAdjustPitch] ? @(0) : nil;
    self.yawRotation = [gimbal isFeatureSupported:DJIGimbalParamAdjustYaw] ? @(0) : nil;
    self.rollRotation = [gimbal isFeatureSupported:DJIGimbalParamAdjustRoll] ? @(0) : nil;
}

-(void) enablePitchExtensionIfPossible {
    DJIGimbal* gimbal = [DemoComponentHelper fetchGimbal];
    if (gimbal == nil) {
        return;
    }
    BOOL isPossible = [gimbal isFeatureSupported:DJIGimbalParamPitchRangeExtensionEnabled];
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
    NSInteger min = [[gimbal getParamMin:key] integerValue];
    
    if ([key isEqualToString:DJIGimbalParamAdjustPitch]) {
        self.pitchRotation = self.pitchRotation ? @(min) : nil;
    }
    else if ([key isEqualToString:DJIGimbalParamAdjustYaw]) {
        self.yawRotation = self.yawRotation ? @(min) : nil;
    }
    else if ([key isEqualToString:DJIGimbalParamAdjustRoll]) {
        self.rollRotation = self.rollRotation ? @(min) : nil;
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
    
    if ([key isEqualToString:DJIGimbalParamAdjustPitch]) {
        self.pitchRotation = self.pitchRotation ? @(max) : nil;
    }
    else if ([key isEqualToString:DJIGimbalParamAdjustYaw]) {
        self.yawRotation = self.yawRotation ? @(max) : nil;
    }
    else if ([key isEqualToString:DJIGimbalParamAdjustRoll]) {
        self.rollRotation = self.rollRotation ? @(max) : nil;
    }
    
    [self sendRotateGimbalCommand];
}

- (IBAction)resetGimbal:(id)sender {
    self.pitchRotation = self.pitchRotation ? @(0) : nil;
    self.yawRotation = self.yawRotation ? @(0) : nil;
    self.rollRotation = self.rollRotation ? @(0) : nil;

    [self sendRotateGimbalCommand];
}

-(void) sendRotateGimbalCommand {
    DJIGimbal* gimbal = [DemoComponentHelper fetchGimbal];
    if (gimbal == nil) {
        return;
    }

    DJIGimbalRotation *rotation = [DJIGimbalRotation gimbalRotationWithPitchValue:self.pitchRotation
                                                                        rollValue:self.rollRotation
                                                                         yawValue:self.yawRotation time:2
                                                                             mode:DJIGimbalRotationModeAbsoluteAngle];
    [gimbal rotateWithRotation:rotation completion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"rotateWithRotation failed: %@", error.description);
        }
    }];
}

-(NSString *) getCorrespondingKeyWithButton:(UIButton *)button {
    if (button == self.pitchMinButton || button == self.pitchMaxButton) {
        return DJIGimbalParamAdjustPitch;
    }
    else if (button == self.yawMinButton || button == self.yawMaxButton) {
        return DJIGimbalParamAdjustYaw;
    }
    else if (button == self.rollMinButton || button == self.rollMaxButton) {
        return DJIGimbalParamAdjustRoll;
    }
    return nil;
}

@end
