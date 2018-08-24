//
//  DJIH264VTDecode.h
//
//  Copyright (c) 2014 DJI. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import <UIKit/UIKit.h>
#import "DJIStreamCommon.h"

#ifndef H264_VT_DECODE_H
#define H264_VT_DECODE_H
//interface for 264 decoder
@protocol H264DecoderOutput <NSObject>
@optional
// called when the frame decompression is finished
-(void) decompressedFrame:(CVImageBufferRef)image frameInfo:(VideoFrameH264Raw*)frame;
//decode failed frame
-(void) videoProcessFailedFrame:(VideoFrameH264Raw*)frame;
// called when hardware decoder encounters exception.
-(void) hardwareDecoderUnavailable;
@end

#define PPS_SPS_MAX_SIZS (256)
#define NAL_MAX_SIZE (1*1024*1024)
#define AU_MAX_SIZE (2*1024*1024)

@interface DJIH264VTDecode : NSObject <VideoStreamProcessor>{
    //decoder context
    VTDecompressionSessionRef _sessionRef;
    CMVideoFormatDescriptionRef _formatDesc;
    
    //pps and sps info
    uint8_t sps_buffer[PPS_SPS_MAX_SIZS];
    uint8_t pps_buffer[PPS_SPS_MAX_SIZS];
    int pps_size;
    int sps_size;
    NSInteger _fps;
    
    //buffer for nal unit
    void* nalu_buf;
    
    //buffer for complete access unit(1frame)
    void* au_buf;
    int au_size;
    int au_nal_count;
    
    //Decoded frame count
    int _income_frame_count;
    //Decoder to recreate the times
    int _decoder_create_count;
}

//CVImageBuffer output delegate
@property (nonatomic, weak) id<H264DecoderOutput> delegate;
//Enabled flag
@property (nonatomic, assign) BOOL enabled;
//YES if decoder is ready
@property (nonatomic, assign) BOOL decoderInited;
//need push a dummy iframe before decode
@property (nonatomic, assign) BOOL dummyIPushed;
//count decode error
@property (nonatomic, assign) int decodeErrorCount;
//hardware decode unavailable
@property (nonatomic, assign) BOOL hardwareUnavailable;
//frame rate
@property (nonatomic, assign) NSInteger fps;
//Encoder mode to select i-frame
@property (assign, nonatomic) NSInteger encoderType;
@property (assign, nonatomic) CGSize videoSize;
//In the case of hardware decoding enabled fastupload, hardware decode will the output in kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange or kCVPixelFormatType_420YpCbCr8BiPlanarFullRange format
@property (assign, nonatomic) BOOL enableFastUpload;

/**
 *  reset decode context. Can only be used in the decoder thread.
 */
-(void) resetInDecodeThread;

/**
 * Resets the video previewer, but it is not executed until it is safe to do so. It can be called in different thread.
 */
-(void) resetLater;

/**
 *  FLush all the frame in the video previewer's queue.
 */
-(void) dequeueAllFrames;
@end

#endif

