//
//  PanoramaMissionViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates the process to start a panorama mission. 
 *  Currently, the panorama mission is only supported by Osmo.
 */
#import <DJISDK/DJISDK.h>
#import "PanoramaMissionViewController.h"

@interface PanoramaMissionViewController ()

@end

@implementation PanoramaMissionViewController

/**
 *  Initialize the panorama mission. Currently, the mission supports two types: full circle and half circle. User need specifies the
 *  type when creating the mission. 
 */
-(DJIMission*) initializeMission {
    DJIPanoramaMission* mission = [[DJIPanoramaMission alloc] initWithPanoramaMode:DJIPanoramaModeFullCircle];
    return mission;
}

#pragma mark - Override Methods
-(void)missionManager:(DJIMissionManager *)manager missionProgressStatus:(DJIMissionProgressStatus *)missionProgress {
    if ([missionProgress isKindOfClass:[DJIPanoramaMissionStatus class]]) {
        DJIPanoramaMissionStatus* panoStatus = (DJIPanoramaMissionStatus*)missionProgress;
        
        [self showPanoramaMissionStatus:panoStatus];
    }
}

-(void) showPanoramaMissionStatus:(DJIPanoramaMissionStatus*)panoStatus {
    NSMutableString* statusStr = [NSMutableString stringWithFormat:@"Total Photo Num: %tu\n", panoStatus.totalNumber];
    [statusStr appendFormat:@"Current Shot Num: %tu\n", panoStatus.currentShotNumber];
    [statusStr appendFormat:@"Current Saved Num: %tu\n", panoStatus.currentSavedNumber];
    [self.statusLabel setText:statusStr];
}

@end