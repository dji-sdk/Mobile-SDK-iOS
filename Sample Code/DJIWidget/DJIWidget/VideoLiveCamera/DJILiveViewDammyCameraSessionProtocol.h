//
//  DJILiveViewDammyCameraProtocol.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJILiveViewDammyCameraStructs.h"

@protocol DJILiveViewDammyCameraSessionProtocol <NSObject>

-(BOOL) startSession;

-(BOOL) stopSession;

@optional
@property (nonatomic, readonly) DJILiveViewDammyCameraRecordingStatus recordingStatus;
@property (nonatomic, readonly) NSTimeInterval recordedTime;

@property (nonatomic, readonly) DJILiveViewDammyCameraCaptureStatus captureStatus;
@end
