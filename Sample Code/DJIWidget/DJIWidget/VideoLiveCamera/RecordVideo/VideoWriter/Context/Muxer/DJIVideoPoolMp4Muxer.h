//
//  DJIVideoPoolMp4Muxer.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "DJIStreamCommon.h"
// The h264 stream mux to mp4 file

@interface DJIVideoPoolMp4Muxer : NSObject

//mp4 file address
@property (nonatomic, strong, readonly) NSString* dstFilePath;
//mp4 header has been written
@property (nonatomic, readonly) BOOL headWrited;
//The file has ended and cannot be written
@property (nonatomic, readonly) BOOL muxerEnded;
// Support aac audio, default NO
@property (nonatomic, assign) BOOL enableAACAudio;
// Skip the video with no video, default NO;
@property (nonatomic, assign) BOOL skipPureAudio;

//The total number of frames written
@property (nonatomic, readonly) uint32_t muxedAllFrameCount;
@property (nonatomic, readonly) uint32_t muxedVideoFrameCount;
@property (nonatomic, readonly) uint32_t muxedAudioFrameCount;

-(id) initWithDstFile:(NSString*)path streamInfo:(VideoFrameH264BasicInfo*)info;

// Write the frame, the first frame written to mp4 must be an idr with sps, pps, otherwise the frame will be discarded
-(BOOL) pushFrame:(VideoFrameH264Raw*)frame;
-(BOOL) pushAudio:(AudioFrameAACRaw*)frame;

/**
 *  The specified frame rate in the video stream
 */
-(double) requiredFPS;
-(void) endFile;
@end
