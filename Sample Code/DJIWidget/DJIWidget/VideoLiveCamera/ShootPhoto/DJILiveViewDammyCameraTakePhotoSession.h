//
//  DJILiveViewDammyCameraTakePhotoSession.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJILiveViewDammyCameraSessionProtocol.h"

@class DJIVideoPreviewer;
/*
 * section for taking signle photo from live stream
 */
@interface DJILiveViewDammyCameraTakePhotoSession : NSObject<DJILiveViewDammyCameraSessionProtocol>

- (instancetype)init OBJC_UNAVAILABLE("You must use the initWithVideoPreviewer");

-(instancetype) initWithVideoPreviewer:(DJIVideoPreviewer*)previewer;

@end
