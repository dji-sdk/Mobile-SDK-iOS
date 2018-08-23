//
//  DJIVideoFrameSyncPoint.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import "DJIVideoFrameSyncPoint.h"

@implementation DJIVideoFrameSyncPoint

-(instancetype) copyWithZone:(NSZone *)zone
{
	DJIVideoFrameSyncPoint* copy = [DJIVideoFrameSyncPoint pointWith:_localTimeMSec
														remote:_remoteTimeMSec];
	copy.caMediaTimeMS = self.caMediaTimeMS;
	return copy;
}

-(instancetype) initWith:(uint32_t)local remote:(uint32_t)remote
{
	if(self = [super init]){
		_localTimeMSec = local;
		_remoteTimeMSec = remote;
	}
	
	return self;
}

+(instancetype) pointWith:(uint32_t)local remote:(uint32_t)remote
{
	return [[DJIVideoFrameSyncPoint alloc] initWith:local remote:remote];
}

@end
