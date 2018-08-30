//
//  DJIVTH264Compressor.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJIWidget/DJIStreamCommon.h>
#import "DJIVTH264CompressConfiguration.h"


typedef NS_ENUM(NSUInteger, DJIVTH264CompressorStatus) {
    DJIVTH264CompressorStatusIdel,
    DJIVTH264CompressorStatusReady,
    DJIVTH264CompressorStatusFailed,
};


@interface DJIVTH264Compressor : NSObject

@property (nonatomic, strong, readonly) NSData* sps;
@property (nonatomic, strong, readonly) NSData* pps;


@property (nonatomic, readonly) DJIVTH264CompressorStatus status;

@property (nonatomic, assign) NSTimeInterval configFrameRate;

@property (nonatomic, copy) void (^encodeOutput)(VideoFrameH264Raw* frame, NSError* error);

// setup vtCompressSession
- (BOOL)setupCompressSessionWithWidth:(int)width height:(int)height rotate:(int)rotate compressConfig:(DJIVTH264CompressConfiguration *)config;

- (BOOL)encodePixelBuffer:(CVPixelBufferRef)pixelBuffer shouldReleased:(BOOL)released;

// complete all frames and reset to idel status
- (void)reset;

@end
