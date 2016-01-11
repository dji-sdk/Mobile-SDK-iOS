//
//  CameraPushInfoViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates how to receive the updated state from DJICamera. 
 */
#import <DJISDK/DJISDK.h>
#import "DemoComponentHelper.h"
#import "CameraPushInfoViewController.h"

@interface CameraPushInfoViewController () <DJICameraDelegate>

@end

@implementation CameraPushInfoViewController

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set the delegate to receive the push data from camera
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        [camera setDelegate:self];
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Clean camera's delegate before exiting the view
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera && camera.delegate == self) {
        [camera setDelegate:nil];
    }
}

#pragma mark - DJICameraDelegate
-(void)camera:(DJICamera *)camera didUpdateSystemState:(DJICameraSystemState *)systemState {
    NSMutableString* cameraInfoString = [[NSMutableString alloc] init];
    [cameraInfoString appendString:@"Shooting single photo: "];
    [cameraInfoString appendString:systemState.isShootingSinglePhoto?@"YES\n" : @"NO\n"];
    [cameraInfoString appendString:@"Shooting single photo in RAW format: "];
    [cameraInfoString appendString:systemState.isShootingSinglePhotoInRAWFormat?@"YES\n" : @"NO\n"];
    [cameraInfoString appendString:@"Shooting burst photos: "];
    [cameraInfoString appendString:systemState.isShootingBurstPhoto?@"YES\n" : @"NO\n"];
    [cameraInfoString appendString:@"Recording: "];
    [cameraInfoString appendString:systemState.isRecording?@"YES\n" : @"NO\n"];
    [cameraInfoString appendString:@"Camera over-heated: "];
    [cameraInfoString appendString:systemState.isCameraOverHeated?@"YES\n" : @"NO\n"];
    [cameraInfoString appendString:@"Camera has error: "];
    [cameraInfoString appendString:systemState.isCameraError?@"YES\n" : @"NO\n"];
    [cameraInfoString appendString:@"In USB mode: "];
    [cameraInfoString appendString:systemState.isUSBMode?@"YES\n" : @"NO\n"];
    [cameraInfoString appendString:@"Camera Mode: "];
    switch (systemState.mode) {
        case DJICameraModeShootPhoto:
            [cameraInfoString appendString:@"Shoot Photo Mode\n"];
            break;
        case DJICameraModeRecordVideo:
            [cameraInfoString appendString:@"Record Video Mode\n"];
            break;
        case DJICameraModePlayback:
            [cameraInfoString appendString:@"Playback Mode\n"];
            break;
        case DJICameraModeMediaDownload:
            [cameraInfoString appendString:@"Media Download Mode\n"];
            break;
            
        default:
            break;
    }
    [cameraInfoString appendFormat:@"Current video recording time: %d\n", systemState.currentVideoRecordingTimeInSeconds];
    self.pushInfoLabel.text = cameraInfoString;
}

@end
