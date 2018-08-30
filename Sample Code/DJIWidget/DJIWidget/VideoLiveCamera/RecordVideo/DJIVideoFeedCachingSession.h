//
//  DJIVideoFeedCachingSession.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJILiveViewDammyCameraSessionProtocol.h"

@class DJIVideoPreviewer;

@interface DJIVideoFeedCachingSession : NSObject<DJILiveViewDammyCameraSessionProtocol>

- (instancetype)init OBJC_UNAVAILABLE("You must use the initWithVideoPreviewer");

- (instancetype) initWithVideoPreviewer:(DJIVideoPreviewer*)previewer;

@property (nonatomic, readonly) DJILiveViewDammyCameraRecordingStatus recordingStatus;
@property (nonatomic, readonly) NSTimeInterval recordedTime;

@end
