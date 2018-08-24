//
//  DJICustomVideoFrameExtractor.h
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import "DJIMovieGLView.h"

@class DJICustomVideoFrameExtractor;

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

/**
 * check frame state
 */
@protocol DJIVideoDataFrameControlDelegate <NSObject>

@required

- (BOOL)parseDecodingAssistInfoWithBuffer:(uint8_t *)buffer length:(int)length assistInfo:(DJIDecodingAssistInfo *)assistInfo;

- (BOOL)isNeedFitFrameWidth;

- (void)frameExtractorDidFailToParseFrames:(DJICustomVideoFrameExtractor *)extractor;

@end


@interface DJICustomVideoFrameExtractor : NSObject

@property (weak) id<DJIVideoDataProcessDelegate> processDelegate;
@property (weak) id<DJIVideoDataFrameControlDelegate> delegate;

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
-(id)initExtractor;

/**
 *  clean extractor's buffer
 */
- (void)clearExtractorBuffer;

/**
 *  release the extractor
 */
-(void)freeExtractor;

/**
 *  the frame in block should be released by user
 */
-(void) parseVideo:(uint8_t*)buf length:(int)length withFrame:(void (^)(VideoFrameH264Raw* frame))block;


-(void) decodeRawFrame:(VideoFrameH264Raw*)frame callback:(void(^)(BOOL b))callback;


/**
 *  Get yuv Frame
 *
 *  @param yuv YuvFrame
 */
-(void)getYuvFrame:(VideoFrameYUV *)yuv;

/**
 *  get the uuid for a frame
 *
 *  @return uuid of the next frame
 */
-(uint32_t) popNextFrameUUID;

@end
