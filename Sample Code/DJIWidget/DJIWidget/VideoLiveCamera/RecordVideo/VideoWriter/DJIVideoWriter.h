//
//  DJIVideoWriter.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJIWidget/DJIStreamCommon.h>

#define VIDEO_POOL_LOW_DISK_STOP_NOTIFICATION (@"VIDEO_POOL_LOW_DISK_STOP_NOTIFICATION")

@interface DJIVideoWriter : NSObject

+(DJIVideoWriter*) instance;
/**
 *	Current write file size byte.
 */
@property(nonatomic, readonly) uint64_t currentFileSize;
/*
 *	`YES` is recording.
 */
@property(nonatomic, readonly) BOOL inRecording;

-(void) updateStreamInfo:(DJIVideoStreamBasicInfo)info;

-(BOOL) beginVideoWriter;

-(BOOL) endVideoWriter;

-(void) writeAsync:(VideoFrameH264Raw*)frame;

@end
