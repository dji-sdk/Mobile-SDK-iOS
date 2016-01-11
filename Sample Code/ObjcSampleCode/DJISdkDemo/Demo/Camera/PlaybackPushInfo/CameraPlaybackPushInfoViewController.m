//
//  CameraPlaybackPushInfoViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates how to receive the updated state from DJIPlaybackManager. 
 */
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"
#import "CameraPlaybackPushInfoViewController.h"

@interface CameraPlaybackPushInfoViewController () <DJIPlaybackDelegate>

@end

@implementation CameraPlaybackPushInfoViewController

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set the delegate to receive the push data from camera
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        if (![camera isPlaybackSupported]) {
            self.pushInfoLabel.text = @"The camera does not support Playback Mode. ";
        }
        else {
            [camera.playbackManager setDelegate:self];
        }
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Clean camera's delegate before exiting the view
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera && [camera isPlaybackSupported] && camera.playbackManager.delegate == self) {
        [camera.playbackManager setDelegate:nil];
    }
}

#pragma mark - DJIPlaybackDelegate
-(void) playbackManager:(DJIPlaybackManager *)playbackManager didUpdatePlaybackState:(DJICameraPlaybackState *)playbackState {
    NSMutableString* playbackString = [[NSMutableString alloc] init];
    [playbackString appendFormat:@"CurrentSelectedFileIndex: %d\n", playbackState.currentSelectedFileIndex];
    [playbackString appendFormat:@"MediaFileType: %d\n", (int)playbackState.mediaFileType];
    [playbackString appendFormat:@"NumberOfMediaFiles: %d\n", playbackState.numberOfMediaFiles];
    [playbackString appendFormat:@"PlaybackMode: %d\n", playbackState.playbackMode];
    [playbackString appendFormat:@"NumbersOfSelected: %d", playbackState.numberOfSelectedFiles];
    
    self.pushInfoLabel.text = playbackString;
}

@end
