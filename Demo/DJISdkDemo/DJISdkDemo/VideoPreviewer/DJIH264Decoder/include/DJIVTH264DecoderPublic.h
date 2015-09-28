//
//  DJIVTH264DecoderPublic.h
//  DJISDK
//
//  Copyright © 2015年 DJI. All rights reserved.
//

#ifndef DJIVTH264DecoderPublic_h
#define DJIVTH264DecoderPublic_h
#import <UIKit/UIKit.h>

#pragma pack (1)
/**
 *  A struct pass to decoder with the h264 frame data, this struct will return to user when the frame decode is complete
 */
typedef struct {
    uint32_t reserved:8; //0x00, do not use
    uint32_t frame_size:24; //length of the h264 frame data, set by user
    uint32_t frame_uuid;    //a unique id for this frame, set by user
    uint64_t userData;  //set by user
}DJIVTH264DecoderUserData;
#pragma pack ()

typedef enum : NSUInteger {
    DJIVTH264DecoderDataSourceNone = 0,
    DJIVTH264DecoderDataSourceInspire = 1,
    DJIVTH264DecoderDataSourcePhantom3Advanced = 4,
    DJIVTH264DecoderDataSourcePhantom3Standard = 4,
    DJIVTH264DecoderDataSourcePhantom3Professional = 5,
}DJIVTH264DecoderDataSource;

/**
 *  decoder callback
 */
@protocol DJIVTH264DecoderOutput <NSObject>

@required

-(void) decompressedFrame:(CVImageBufferRef)image frameInfo:(DJIVTH264DecoderUserData)frame;

@end

@protocol DJIVTH264DecoderProtocol <NSObject>

@required
/**
 *  Set data source for decoder
 *
 *  @param type DJIVTH264DecoderDataSource
 */

-(void) setDecoderDataSource:(DJIVTH264DecoderDataSource)dataSource;

/**
 *  Decode a complete h264 frame
 *
 *  @param data     input data must be a complete h264 frame
 *  @param size     size of input frame data
 *  @param userData user data will callback when decode complete
 *
 *  @return frame is use by decoder.
 */
-(BOOL) decodeFrame:(uint8_t*)data length:(NSUInteger)size userData:(DJIVTH264DecoderUserData)userData;

/**
 *  Set decoder output delegate
 *
 *  @param delegate
 */
-(void) setVTDecoderDelegate:(id<DJIVTH264DecoderOutput>)delegate;

/**
 *  sync decoder and pop out all frames, do not need to call when liveview decode
 */
-(void) dequeueAllFrames;

/**
 *  Reset the decoder.
 */
-(void) resetLater;

@end

@interface DJIVTH264DecoderPublic : NSObject

+(id<DJIVTH264DecoderProtocol>) createDecoderWithDataSource:(DJIVTH264DecoderDataSource)dataSource;

@end

#endif /* DJIVTH264DecoderPublic_h */
