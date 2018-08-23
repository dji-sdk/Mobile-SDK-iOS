//
//  DJIVideoFrameSyncPoint.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DJIVideoFrameSyncPoint : NSObject <NSCopying>

@property (nonatomic, readonly) uint32_t localTimeMSec;
@property (nonatomic, readonly) uint32_t remoteTimeMSec;
@property (nonatomic, assign) uint32_t caMediaTimeMS;

-(id) initWith:(uint32_t)local remote:(uint32_t)remote;
+(id) pointWith:(uint32_t)local remote:(uint32_t)remote;

@end
