//
//  DJIStreamCommon.h
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#ifndef DJI_STREAM_COMMON_H
#define DJI_STREAM_COMMON_H
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define H264_FRAME_INVALIED_UUID (0)

typedef enum : NSUInteger {
    VPFrameTypeYUV420Planer = 0,
    VPFrameTypeYUV420SemiPlaner = 1,
    VPFrameTypeRGBA = 2,
} VPFrameType;

typedef struct{
    uint16_t width;
    uint16_t height;
    
    uint16_t fps;
    uint16_t reserved;
    
    uint16_t frame_index;
    uint16_t max_frame_index_plus_one;
    
    union{
        struct{
            int has_sps :1;
            int has_pps :1;
            int has_idr :1;
        } frame_flag;
        uint32_t value;
    };
    
} VideoFrameH264BasicInfo;

typedef struct{
    uint32_t sampleRate;
    uint8_t channelCount;
    uint16_t sampleCount;
    uint8_t reserved;
} AudioFrameAACBasicInfo;

#ifndef YUV_FRAME_
#define YUV_FRAME_

typedef struct
{
    uint8_t *luma;
    uint8_t *chromaB;
    uint8_t *chromaR;
    
    uint8_t frameType; //VPFrameType
    
    int width, height;
    
    int lumaSlice, chromaBSlice, chromaRSlice;
    
    pthread_rwlock_t mutex;
    void* cv_pixelbuffer_fastupload;
    

    uint32_t frame_uuid; //frame id from decoder
    VideoFrameH264BasicInfo frame_info;
} VideoFrameYUV;
#endif

typedef enum : NSUInteger {
    TYPE_TAG_VideoFrameH264Raw = 0,
    TYPE_TAG_AudioFrameAACRaw = 1,
    TYPE_TAG_VideoFrameJPEG = 2,
} TYPE_TAG_VPFrame;

#pragma pack (1)
typedef struct{
    uint32_t type_tag:8;//TYPE_TAG_VideoFrameH264Raw
    uint32_t frame_size:24;
    uint32_t frame_uuid;
    uint64_t time_tag; //videoPool 内部相对时间
    VideoFrameH264BasicInfo frame_info;
    
    uint8_t frame_data[0]; //followd by frame data;
}VideoFrameH264Raw;

typedef struct{
    uint32_t type_tag:8;//TYPE_TAG_AudioFrameAACRaw
    uint32_t frame_size:24;
    uint64_t time_tag;
    AudioFrameAACBasicInfo frame_info;
    uint8_t frame_data[0];
}AudioFrameAACRaw;
#pragma pack()

typedef struct {
    CGSize frameSize;
    int frameRate;
    int encoderType;
} DJIVideoStreamBasicInfo;

typedef enum{
    DJIVideoStreamProcessorType_Unknown = 0,
    DJIVideoStreamProcessorType_Decoder, //decoder same as passthrough
    DJIVideoStreamProcessorType_Passthrough, //passthrough data
    DJIVideoStreamProcessorType_Consume, //consume data
    DJIVideoStreamProcessorType_Modify, //modify data
} DJIVideoStreamProcessorType;

typedef NS_ENUM(NSUInteger, H264EncoderType){
    H264EncoderType_unknown = 0,
    H264EncoderType_DM368_inspire = 1,
    H264EncoderType_DM368_longan = 2,
    H264EncoderType_A9_phantom3c = 4,
    H264EncoderType_A9_phantom3s = 4,
    H264EncoderType_DM365_phamtom3x = 5,
    H264EncoderType_1860_phantom4x = 6,
    H264EncoderType_LightBridge2 = 7,
    H264EncoderType_A9_P3_W = 8,
    H264EncoderType_A9_OSMO_NO_368 = 9,
};

/**
 *  stream processor to decode/save stream
 */
@protocol VideoStreamProcessor <NSObject>
@required
/**
 *  Enables the stream processor.
 */
-(BOOL) streamProcessorEnabled;

-(DJIVideoStreamProcessorType) streamProcessorType;

-(BOOL) streamProcessorHandleFrameRaw:(VideoFrameH264Raw*)frame;

@optional
-(BOOL) streamProcessorHandleFrame:(uint8_t*)data size:(int)size __attribute__((deprecated("VideoPreview will ignore this method. ")));
-(void) streamProcessorInfoChanged:(DJIVideoStreamBasicInfo*)info;
-(void) streamProcessorPause;
-(void) streamProcessorReset;
@end

/**
 *  frame processor to display video frame
 */
@protocol VideoFrameProcessor <NSObject>
@required

-(BOOL) videoProcessorEnabled;
-(void) videoProcessFrame:(VideoFrameYUV*)frame;
-(void) videoProcessFailedFrame;
@end

#endif /* DJIVTH264DecoderPublic_h */
