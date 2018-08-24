//
//  DJIVideoWriterDiskHelper.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

//200m
#define VIDEO_POOL_LOW_DISK_SPACE_THRESHOLD (200*1024*1024)

//a disk helper to mointor the disk remain size
@interface DJIVideoWriterDiskHelper : NSObject

//this space will auto update every 10sec
@property (nonatomic, readonly) uint64_t freeDiskSpace;
@property (nonatomic, readonly) uint64_t availableSpace;

-(BOOL) isLowerThanLimitSpace;

@end
