//
//  DJIVideoWriterDiskHelper.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import "DJIVideoWriterDiskHelper.h"

#define PRINT_DISK_STATE  (1)

@interface DJIVideoWriterDiskHelper ()
@property (nonatomic, readwrite) uint64_t freeDiskSpace;
@property (nonatomic, readwrite) uint64_t availableSpace;
@property (nonatomic, strong) dispatch_source_t updateFreeDiskSpaceTimer;
@end

@implementation DJIVideoWriterDiskHelper

-(instancetype) init
{
    if (self = [super init]) {
        _freeDiskSpace = [self updateFreeDiskspace];
		_updateFreeDiskSpaceTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
		dispatch_source_set_timer(_updateFreeDiskSpaceTimer, DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
		dispatch_source_set_event_handler(_updateFreeDiskSpaceTimer, ^{
			[self updateFreeDiskspace];
		});
		dispatch_resume(_updateFreeDiskSpaceTimer);
	}
    
    return self;
}

-(void) dealloc
{
	dispatch_cancel(_updateFreeDiskSpaceTimer);
}


-(BOOL) isLowerThanLimitSpace
{
    if (self.freeDiskSpace < VIDEO_POOL_LOW_DISK_SPACE_THRESHOLD) {
        return YES;
    }
    return NO;
}

-(uint64_t) updateFreeDiskspace
{
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    
    static NSString* path = nil;
    if(!path) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        path = [paths lastObject];
    }
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:path error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
    } else {
        totalFreeSpace = UINT32_MAX;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.freeDiskSpace = totalFreeSpace;
        if (totalFreeSpace > VIDEO_POOL_LOW_DISK_SPACE_THRESHOLD) {
            self.availableSpace = totalFreeSpace - VIDEO_POOL_LOW_DISK_SPACE_THRESHOLD;
        }else{
            self.availableSpace = 0;
        }
#if PRINT_DISK_STATE
		NSLog(@"freeDiskSpace = %tuM", self.freeDiskSpace / 1024 / 1024);
		NSLog(@"availableSpace = %tuM", self.availableSpace / 1024 / 1024);
#endif
    });
    return totalFreeSpace;
}

@end
