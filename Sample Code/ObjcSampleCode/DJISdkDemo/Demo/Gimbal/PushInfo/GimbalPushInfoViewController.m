//
//  GimbalPushInfoViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates how to receive the updated state from DJIGimbal. 
 */

#import <DJISDK/DJISDK.h>
#import "DemoComponentHelper.h"
#import "GimbalPushInfoViewController.h"

@interface GimbalPushInfoViewController () <DJIGimbalDelegate>

@end

@implementation GimbalPushInfoViewController

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set the delegate to receive the push data from gimbal
    __weak DJIGimbal* gimbal = [DemoComponentHelper fetchGimbal];
    if (gimbal) {
        [gimbal setDelegate:self]; 
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // Clean gimbal's delegate before exiting the view
    __weak DJIGimbal* gimbal = [DemoComponentHelper fetchGimbal];
    if (gimbal && gimbal.delegate == self) {
        [gimbal setDelegate:nil];
    }
}

#pragma mark - DJIGimbalDelegate
// Override method in DJIGimbalDelegate to receive the pushed data
-(void)gimbal:(DJIGimbal *)gimbal didUpdateState:(DJIGimbalState *)state {
    NSMutableString* gimbalInfoString = [[NSMutableString alloc] init];
    [gimbalInfoString appendFormat:@"Gimbal attitude in degree: (%f, %f, %f)\n", state.attitudeInDegrees.pitch,
     state.attitudeInDegrees.roll,
     state.attitudeInDegrees.yaw];
    [gimbalInfoString appendFormat:@"Roll fine tune in degree: %d\n", (int)state.rollFineTuneInDegrees];
    [gimbalInfoString appendString:@"Gimbal work mode: "];
    switch (state.mode) {
        case DJIGimbalModeFPV:
            [gimbalInfoString appendString:@"FPV\n"];
            break;
        case DJIGimbalModeFree:
            [gimbalInfoString appendString:@"Free\n"];
            break;
        case DJIGimbalModeYawFollow:
            [gimbalInfoString appendString:@"Yaw-follow\n"];
            break;
            
        default:
            break;
    }
    [gimbalInfoString appendString:@"Is attitude reset: "];
    [gimbalInfoString appendString:state.isAttitudeReset?@"YES\n" : @"NO\n"];
    [gimbalInfoString appendString:@"Is calibrating: "];
    [gimbalInfoString appendString:state.isCalibrating?@"YES\n" : @"NO\n"];
    [gimbalInfoString appendString:@"Is pitch at stop: "];
    [gimbalInfoString appendString:state.isPitchAtStop?@"YES\n" : @"NO\n"];
    [gimbalInfoString appendString:@"Is roll at stop: "];
    [gimbalInfoString appendString:state.isRollAtStop?@"YES\n" : @"NO\n"];
    [gimbalInfoString appendString:@"Is yaw at stop: "];
    [gimbalInfoString appendString:state.isYawAtStop?@"YES\n" : @"NO\n"];
    
    self.pushInfoLabel.text = gimbalInfoString; 
}

@end
