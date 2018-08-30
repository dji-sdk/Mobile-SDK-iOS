//
//  DJIVideoWriter.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import "DJIVideoWriter.h"
#import "DJIVideoWriterContext.h"
#import "DJIVideoWriterDiskHelper.h"
#import "DJIWidgetMacros.h"
#include <Foundation/NSDateFormatter.h>

@interface DJIVideoWriter ()

/*Check current write disk state*/
@property(nonatomic, strong) DJIVideoWriterDiskHelper* diskHelper;

//a working queue
@property(nonatomic, strong) dispatch_queue_t workingQueue;

@property(nonatomic, assign) DJIVideoStreamBasicInfo videoStremInfo;

@property(nonatomic, strong) DJIVideoWriterContext* currentCtx;

@property(nonatomic, assign) uint64_t currentFileSize;

@end

@implementation DJIVideoWriter

-(instancetype) init
{
	self = [super init];
	if (self) {
		_workingQueue = dispatch_queue_create("com.dji.video.create.queue", DISPATCH_QUEUE_SERIAL);
		_videoStremInfo.frameRate = 30;
		_videoStremInfo.frameSize = CGSizeMake(1280, 720);
		_diskHelper = [[DJIVideoWriterDiskHelper alloc] init];
		[self createVideoCacheFolder];
	}
	return self;
}

+(DJIVideoWriter*) instance
{
	static DJIVideoWriter* writer = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		writer = [[DJIVideoWriter alloc] init];
	});
	return writer;
}

+(NSString *)stringFromDate:(NSDate *)date{
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
	NSString *destDateString = [dateFormatter stringFromDate:date];
	return destDateString;
}

-(BOOL) inRecording{
	if (_currentCtx) {
		return YES;
	}
	return NO;
}

-(void) updateStreamInfo:(DJIVideoStreamBasicInfo)info{
	if (0 == memcmp(&info, &_videoStremInfo, sizeof(DJIVideoStreamBasicInfo))) {
		return;
	}
	
	_videoStremInfo = info;
}

-(void) createVideoCacheFolder{
	NSString* path = [DJIVideoWriterContext VideoCachePath];
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	if(![fileManager fileExistsAtPath:path]){
		[fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
	}
}

-(BOOL) beginVideoWriter{
	
	if (![self checkDiskFreeSpaceCanContinueWork]) {
		return NO;
	}
	NSDate* createDate = [NSDate date];
	NSString* poolFileName = [[self class] stringFromDate:createDate];
	NSString* path = [DJIVideoWriterContext VideoCachePath];
	path = [path stringByAppendingPathComponent:poolFileName];
	
	if (_currentCtx) {
		[self endVideoWriter];
	}
	
	weakSelf(target);
	dispatch_sync(_workingQueue, ^
				  {
					  weakReturn(target);
					  @synchronized(target){
						  target.currentCtx = [[DJIVideoWriterContext alloc] initWithNewFile:path];
					  }
				  });
	_currentFileSize = 0;
	return YES;
}

-(BOOL) endVideoWriter
{
	if (!self.currentCtx)
		return NO;
	
	//wait for end complete
	weakSelf(target);
	//this sync may block main thread, maybe 10ms in some case,
	dispatch_sync(_workingQueue, ^{
		weakReturn(target);
		DJIVideoWriterContext* context = target.currentCtx;
		if (!context) {
			return;
		}
		
		[context closeFile];
		if(NO == [context verifyContextForKeep]){
			[context deleteAllDiskFile];
			target.currentCtx = nil;
			return;
		}
		target.currentCtx = nil;
	});
	return YES;
}

#pragma mark - Write Frame

-(void) writeAsync:(VideoFrameH264Raw*)frame{
	
	if(!frame)
		return;
	
	if (!_currentCtx) {
		free(frame);
		return;
	}
	
	if (NO == [self checkDiskFreeSpaceCanContinueWork]) {
		free(frame);
		return;
	}
	
	weakSelf(target);
	dispatch_async(_workingQueue, ^{
		if (target == nil) {
			free(frame);
			return;
		}
		
		DJIVideoWriterContext* ctx = target.currentCtx;
		if (ctx){
			[ctx pushFrame:frame];
			target.currentFileSize = ctx.currentFileSize;
		}
		
		free(frame);
	});
}

#pragma mark - State Check

-(BOOL) checkDiskFreeSpaceCanContinueWork
{
	if ([_diskHelper isLowerThanLimitSpace]) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter] postNotificationName:VIDEO_POOL_LOW_DISK_STOP_NOTIFICATION object:nil];
		});
		[self endVideoWriter];
		return NO;
	}
	return YES;
}

@end
