//
//  DJIVideoWriterContext.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import "DJIVideoWriterContext.h"
#import "DJIVideoFrameSyncPoint.h"

#define VIDEO_POOL_FILE_MUXED_EXTENSION (@"mp4")
#define VIDEO_POOL_PATH (@"videoCache")

@interface DJIVideoWriterContext()
/*
 * sync points
 */
@property (nonatomic, strong) DJIVideoFrameSyncPoint* lastSyncPoint;
@property (nonatomic, strong) DJIVideoFrameSyncPoint* currentSyncPoint;
@property (nonatomic, strong) NSMutableArray<DJIVideoFrameSyncPoint*>* syncPointList;
/**
 for subclass ovverride
 
 @param point <#point description#>
 */
-(void) pushSyncPoint:(DJIVideoFrameSyncPoint*)point;

@end

@implementation DJIVideoWriterContext

+(NSString*) MuxedFilePathByPoolPath:(NSString*)path
{
	return [path stringByAppendingPathExtension:VIDEO_POOL_FILE_MUXED_EXTENSION];
}

+(NSString*) VideoCachePath
{
	static NSString* path = nil;
	
	if(!path){
		NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		path = [docPath[0] stringByAppendingPathComponent:VIDEO_POOL_PATH];
	}
	
	return path;
};

-(instancetype) initWithNewFile:(NSString *)name
{

	if(self = [self init]){

		if (name.length == 0) {
			NSAssert(0, @"video pool writer context must have file name");
			return nil;
		}
		
		_writeFilePath = name;
		_isFileClosed =  NO;
		_currentFileSize = 0;

		_muxer = nil; //create later
		_syncPointList = [NSMutableArray array];
		_lastSyncPoint = [[DJIVideoFrameSyncPoint alloc] init];
		_currentSyncPoint = [[DJIVideoFrameSyncPoint alloc] init];
	}

	return self;
}

-(void) dealloc
{
	if (_muxer && !_muxer.muxerEnded) {
		[_muxer endFile];
	}
}

-(BOOL) verifyContextForKeep
{
	//check file valid.
	NSString* muxedPath = [DJIVideoWriterContext MuxedFilePathByPoolPath:_writeFilePath];
	NSFileManager* fm = [NSFileManager defaultManager];
	
	if(_currentFileSize == 0
	   || _videoFrameCount < 5
	   || NO == [fm fileExistsAtPath:muxedPath]){
		return NO;
	}
	return YES;
}

-(void) deleteAllDiskFile
{
	NSFileManager* fm = [NSFileManager defaultManager];
	[fm removeItemAtPath:_writeFilePath error:nil];
	[fm removeItemAtPath:[_writeFilePath stringByAppendingPathExtension:VIDEO_POOL_FILE_MUXED_EXTENSION] error:nil];
}

-(void) closeFile
{
	if(_isFileClosed)
		return;
	[_muxer endFile];
	NSLog(@"muxer end file, v:%d a:%d fps:%f", _muxer.muxedVideoFrameCount, _muxer.muxedAudioFrameCount, [_muxer requiredFPS]);
	_isFileClosed = YES;
}

-(double) playbackDuration
{
	if (self.playbackFps != 0) {
		return _muxer.muxedVideoFrameCount/(double)self.playbackFps;
	}
	return 0;
}

-(void) pushSyncPoint:(DJIVideoFrameSyncPoint*)point
{
	if (point) {
		[_syncPointList addObject:point];
	}
}

#pragma mark - raw frame data write

-(BOOL) pushFrame:(VideoFrameH264Raw*)frame
{
	if(!frame || _muxer.muxerEnded || _isFileClosed){
		return NO;
	}
	
	if(!_muxer){
		//create _muxer
		NSString* dstFile = [DJIVideoWriterContext MuxedFilePathByPoolPath:_writeFilePath];
		NSFileManager* fm = [NSFileManager defaultManager];
		[fm removeItemAtPath:dstFile error:nil];
		
		_muxer = [[DJIVideoPoolMp4Muxer alloc] initWithDstFile:dstFile streamInfo:&frame->frame_info];
		_muxer.enableAACAudio = NO;
		_muxer.skipPureAudio = YES;
	}
	
	if(!_muxer)
		return NO;
	
	if (!_muxer.headWrited) {
		//first frame must be a idr frame
		if (!frame->frame_info.frame_flag.has_idr) {
			return NO;
		}
		
		//push first frame
		[_muxer pushFrame:frame];
		if(_muxer.muxedVideoFrameCount == 0) //muxed failed
			return NO;
		else{
			
			//first frame, create syncPoint
			_lastSyncPoint = [DJIVideoFrameSyncPoint pointWith:0
													 remote:(uint32_t)frame->time_tag];
			_lastSyncPoint.caMediaTimeMS = frame->frame_info.ca_media_time_ms;
			[self pushSyncPoint:_lastSyncPoint];
			_currentFileSize = frame->frame_size;
			return YES;
		}
	}
	
	//frame successful muxed
	if (_muxer.muxedVideoFrameCount >= 1) {
		if([_muxer pushFrame:frame]){
			
			double lastSyncPointDelta = (_lastSyncPoint.remoteTimeMSec - _lastSyncPoint.localTimeMSec)/1000.0;
			double localDuration = [self playbackDuration];
			double localSyncDuration = localDuration + lastSyncPointDelta;
			double remoteDuration = frame->time_tag/1000.0;
			
			if (remoteDuration - localSyncDuration > 1.5) {
				//re sync
				_lastSyncPoint = [DJIVideoFrameSyncPoint pointWith:localDuration*1000
														 remote:remoteDuration*1000];
				_lastSyncPoint.caMediaTimeMS = frame->frame_info.ca_media_time_ms;
				[self pushSyncPoint:[_lastSyncPoint copyWithZone:nil]];
			}
			
			_overAllFrameCount = _muxer.muxedAllFrameCount;
			_videoFrameCount = _muxer.muxedVideoFrameCount;
			_currentFileSize += frame->frame_size;
			_currentSyncPoint = [DJIVideoFrameSyncPoint pointWith:localDuration*1000
														remote:(uint32_t)frame->time_tag];
		}
	}
	
	return YES;
}

@end
