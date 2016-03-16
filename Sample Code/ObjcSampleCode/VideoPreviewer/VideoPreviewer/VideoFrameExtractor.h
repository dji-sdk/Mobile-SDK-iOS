//
//  Video.h
//  iFrameExtractor
//
//  Created by lajos on 1/10/10.
//
//  Copyright 2010 Lajos Kamocsay
//
//  lajos at codza dot com
//
//  iFrameExtractor is free software; you can redistribute it and/or
//  modify it under the terms of the GNU Lesser General Public
//  License as published by the Free Software Foundation; either
//  version 2.1 of the License, or (at your option) any later version.
// 
//  iFrameExtractor is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//  Lesser General Public License for more details.
//


#import <Foundation/Foundation.h>
#import "MovieGLView.h"

@protocol VideoDataProcessDelegate <NSObject>

@optional

/**
 *  It is called after the video data is parsed
 *
 *  @param data   pointer to the parsed video data
 *  @param length length in byte
 */
- (void)processVideoData:(uint8_t *)data length:(int)length;
@end

/**
 *  Please init extractor before using it.
 *  
 */
@interface VideoFrameExtractor : NSObject {
    
	int _videoStream;
	int _sourceWidth, _sourceHeight;
	int _outputWidth, _outputHeight;
	double _duration;
    
    BOOL _shouldVerifyVideoStream;
}

@property (weak) id<VideoDataProcessDelegate> delegate;

@property(nonatomic, readonly) int frameRate;
@property(nonatomic, readonly) int outputWidth;
@property(nonatomic, readonly) int outputHeight;

/**
 *  init extractor
 *
 *  @return the extractor
 */
-(id)initExtractor;

/**
 *  clean extractor's buffer
 */
- (void)clearBuffer;

/**
 *  release the extractor
 */
-(void)freeExtractor;

-(void) setShouldVerifyVideoStream:(BOOL)shouldVerify;

-(void) parseVideo:(uint8_t*)buf length:(int)length withOutputBlock:(void (^)(uint8_t* frame, int size))block;
-(void) parseVideo:(uint8_t*)buf length:(int)length withFrame:(void (^)(VideoFrameH264Raw* frame))block;

-(void) decodeVideo:(uint8_t*)buf length:(int)length callback:(void(^)(BOOL b))callback;
-(void) decodeRawFrame:(VideoFrameH264Raw*)frame callback:(void(^)(BOOL b))callback;

/**
 *  decode the video data
 *
 *  @param buf      pointer to video data
 *  @param length   length in byte
 *  @param callback completion block to receive the decoding result
 *
 *  @return number of frames that is decoded
 */
-(int) __attribute__((deprecated)) decode:(uint8_t*)buf length:(int)length callback:(void(^)(BOOL b))callback;

/**
 *  Get yuv Frame
 *
 *  @param yuv YuvFrame
 */
-(void)getYuvFrame:(VideoFrameYUV *)yuv;

-(CVPixelBufferRef) __attribute__((deprecated)) getCVImage;

/**
 *  get the uuid for a frame
 *
 *  @return uuid of the next frame
 */
-(uint32_t) popNextFrameUUID;

/**
 *  Search the index of the I frame, SPS or PPS.
 *
 *  @param buffer pointer to the video data
 *  @param bufferSize length of the data in byte
 *  @return the index of the I frame. NULL when no I frame is found. 
 */
-(uint8_t*) getIFrameFromBuffer:(uint8_t*)buffer length:(int)bufferSize;

@end
