//
//  H264VTDecode.h
//
//  Copyright (c) 2014 DJI. All rights reserved.
//
#ifndef H264_VT_DECODE_H
#define H264_VT_DECODE_H
#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import <Foundation/Foundation.h>
#import "DJIStreamCommon.h"

//interface for 264 decoder
@protocol H264DecoderOutput <NSObject>
@optional
// called when the frame decompression is finished
-(void) decompressedFrame:(CVImageBufferRef)image frameInfo:(VideoFrameH264Raw*)frame;
// called when hardware decoder encounters exception.
-(void) hardwareDecoderUnavailable;
@end

#define PPS_SPS_MAX_SIZS (256)
#define NAL_MAX_SIZE (1*1024*1024)
#define AU_MAX_SIZE (2*1024*1024)

@interface H264VTDecode : NSObject <VideoStreamProcessor>{
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
    
    int _income_frame_count;
    int _decoder_create_count;
}

//CVImageBuffer output delegate
@property (nonatomic, weak) id<H264DecoderOutput> delegate;
@property (nonatomic, assign) BOOL enabled;
@property (assign, nonatomic) NSInteger encoderType;
@property (nonatomic, assign) BOOL hardware_unavailable;

/***
 reset decode context. Can only be used in the decoder thread.
 ***/
-(void) resetInDecodeThread;

/**
 * Resets the video previewer, but it is not executed until it is safe to do so. It can be called in different thread.
 **/
-(void) resetLater;

/***
 convert imagebuffer to uiimage for test
 in: CVImagePixelBuffer
 ***/
-(UIImage *) convertFromCVImageBuffer:(CVImageBufferRef)imageBuffer savePath:(NSString*)path;

/**
 *  FLush all the frame in the video previewer's queue. 
 */
-(void) dequeueAllFrames;
@end
#endif

