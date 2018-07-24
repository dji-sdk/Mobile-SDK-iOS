//
//  DJICustomVideoFrameExtractor.h
//
//  Copyright (c) 2018 DJI. All rights reserved.
//


#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import "MovieGLView.h"

@protocol DJIVideoDataProcessDelegate <NSObject>

@optional
/**
 *  It is called after the video data is parsed
 *
 *  @param data   pointer to the parsed video data
 *  @param length length in byte
 */
- (void)processVideoData:(uint8_t *)data length:(int)length;
@end

@interface DJICustomVideoFrameExtractor : NSObject

@property (weak) id<DJIVideoDataProcessDelegate> delegate;

@property (nonatomic, assign) BOOL usingDJIAircraftEncoder;
@property (nonatomic, assign) BOOL shouldVerifyVideoStream;

@property(nonatomic, readonly) int frameRate;
@property(nonatomic, readonly) int outputWidth;
@property(nonatomic, readonly) int outputHeight;
@property(nonatomic, readonly) double duration;


/**
 *  init extractor
 *
 *  @return the extractor
 */
-(instancetype) initExtractor;

/**
 *  clean extractor's buffer
 */
-(void) clearExtractorBuffer;

/**
 *  release the extractor
 */
-(void) freeExtractor;

-(void) parseVideo:(uint8_t*)buf length:(int)length withOutputBlock:(void (^)(uint8_t* frame, int size))block;

/**
 *  the frame in block should be released by user
 */
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
-(void) getYuvFrame:(VideoFrameYUV *)yuv;

/**
 *
 */
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
