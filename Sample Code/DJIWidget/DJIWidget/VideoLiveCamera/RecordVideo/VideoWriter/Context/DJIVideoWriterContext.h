//
//  DJIVideoWriterContext.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIVideoPoolMp4Muxer.h"

@interface DJIVideoWriterContext : NSObject

-(instancetype) initWithNewFile:(NSString *)name;

@property(nonatomic, strong) DJIVideoPoolMp4Muxer* muxer;

/**
 *  counters
 */
@property(nonatomic, assign) int videoFrameCount;
@property(nonatomic, assign) int audioFrameCount;
@property(nonatomic, assign) int overAllFrameCount;

/**
 *  file size muxed.
 */
@property(nonatomic, readonly) uint32_t currentFileSize;

/**
 * 	`NO` file is closed
 */
@property(nonatomic, assign) BOOL isFileClosed;

/**
 *	current write file size.
 */
@property(nonatomic, strong) NSString* writeFilePath;

//Input Infos
@property(nonatomic, assign) int playbackFps;

+(NSString*) VideoCachePath;

-(void) closeFile;

-(BOOL) verifyContextForKeep;

-(void) deleteAllDiskFile;

-(BOOL) pushFrame:(VideoFrameH264Raw*)frame;

@end
