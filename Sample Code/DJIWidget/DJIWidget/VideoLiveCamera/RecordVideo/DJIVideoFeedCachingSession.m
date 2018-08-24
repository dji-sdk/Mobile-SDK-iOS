//
//  DJIVideoFeedCachingSession.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import "DJIVideoFeedCachingSession.h"
#import "DJIVideoPreviewer.h"
#import "DJIVTH264Encoder.h"
#import "DJIWidgetMacros.h"
#import "DJIVideoWriter.h"

@interface DJIVideoFeedCachingSession()<VideoFrameProcessor, DJIVTH264EncoderOutput>

@property (nonatomic, strong) DJIVideoWriter* writer;
@property (nonatomic, strong) DJIVideoPreviewer* previewer;
@property (nonatomic, strong) DJIVTH264Encoder* encoder;
@property (nonatomic, assign) DJIVideoStreamBasicInfo streamInfo;

@property (nonatomic, readwrite) DJILiveViewDammyCameraRecordingStatus recordingStatus;
@property (nonatomic, assign) BOOL startUpdateRecordTime;
@property (nonatomic, assign) NSTimeInterval recordedTime;
@property (nonatomic, assign) NSUInteger recordFrameCounter;
@property (nonatomic, assign) double recordStartTime;

@end

@implementation DJIVideoFeedCachingSession

- (instancetype) _init {
	self = [super init];
	return self;
}

- (instancetype) initWithVideoPreviewer:(DJIVideoPreviewer*)previewer {
	self = [self _init];
	if (self) {
		_previewer = previewer;
	}
	return self;
}

- (BOOL)startSession {
	if(self.recordingStatus == DJILiveViewDammyCameraRecordingStatusRecording ||
	   self.recordingStatus == DJILiveViewDammyCameraRecordingStatusPrepear){
		return NO;
	}
	
	self.writer = [DJIVideoWriter instance];
    
    DJIVideoStreamBasicInfo streamInfo = self.previewer.currentStreamInfo;
    if (self.previewer.detectRealtimeFrameRate) {
        streamInfo.frameRate = (int)self.previewer.realTimeFrameRate;
    }
	self.streamInfo = streamInfo;

    
	//encoder
    DJIVTH264CompressConfiguration* config = [[DJIVTH264CompressConfiguration alloc] initWithUsageType:DJIVTH264CompressConfigurationUsageTypeLocalRecord];
    _encoder = [[DJIVTH264Encoder alloc] initWithConfig:config delegate:self];
    _encoder.streamInfo = self.streamInfo;
	_encoder.enabled = YES;
	[self.previewer registFrameProcessor:self];
	
	self.recordingStatus = DJILiveViewDammyCameraRecordingStatusPrepear;
	[self startRecording];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopSession) name:VIDEO_POOL_LOW_DISK_STOP_NOTIFICATION object:nil];
	self.recordStartTime = CFAbsoluteTimeGetCurrent();
	return YES;
}

-(void) startRecording{
	if (self.recordingStatus != DJILiveViewDammyCameraRecordingStatusPrepear) {
		return;
	}

	[self.writer updateStreamInfo:self.streamInfo];
	if (![self.writer beginVideoWriter]) {
		NSLog(@"Please check disk available space");
	}
}

- (BOOL)stopSession {
	if(self.recordingStatus != DJILiveViewDammyCameraRecordingStatusRecording){
		return NO;
	}
	
	[_writer endVideoWriter];
	[_encoder setEnabled:NO];
	[_encoder invalidate];
	
	[self.previewer unregistFrameProcessor:self];
	[self.previewer unregistStreamProcessor:self];
	
	_writer = nil;
	_encoder = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.recordingStatus = DJILiveViewDammyCameraRecordingStatusEnded;
	return YES;
}

#pragma mark - frame processor

-(BOOL) videoProcessorEnabled{
	return YES;
}

-(void) videoProcessFrame:(VideoFrameYUV*)frame{
	
    [_encoder pushVideoFrame:frame];
	
	if (_encoder.outputVideoFrameNum != 0) {
		weakSelf(target);
		if (self.recordingStatus == DJILiveViewDammyCameraRecordingStatusPrepear) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (target.recordingStatus == DJILiveViewDammyCameraRecordingStatusPrepear) {
					target.recordingStatus = DJILiveViewDammyCameraRecordingStatusRecording;
				}
			});
		}
	}
	
	if(self.recordingStatus != DJILiveViewDammyCameraRecordingStatusEnded
	   && self.startUpdateRecordTime){
		_recordFrameCounter++;
		if (self.streamInfo.frameRate != 0) {
			NSTimeInterval duration = _recordFrameCounter/(double)self.streamInfo.frameRate;
			
			if ((NSUInteger)duration - (NSUInteger)self.recordedTime != 0) {
				weakSelf(target);
				dispatch_async(dispatch_get_main_queue(), ^{
					target.recordedTime = duration;
				});
			}
		}
	}
}

#pragma mark - live encoder

- (BOOL)vtH264Encoder:(DJIVTH264Encoder *)encoder output:(VideoFrameH264Raw *)packet {
	if (packet->type_tag == TYPE_TAG_VideoFrameH264Raw) {
		[_writer writeAsync:packet];
		if (_writer.currentFileSize != 0) {
			self.startUpdateRecordTime = YES;
		}
	}
	return YES;
}

-(uint64_t) currentTimeTag{
	return (CFAbsoluteTimeGetCurrent() - self.recordStartTime) *1000;
}

@end
