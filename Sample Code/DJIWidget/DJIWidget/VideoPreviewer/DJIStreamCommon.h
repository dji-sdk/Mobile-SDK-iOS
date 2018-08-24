//
//  DJIStreamCommon.h
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

#define H264_FRAME_INVALIED_UUID (0)

/**
 *  Color encoding format used by VideoPreviewer.
 */
typedef enum : NSUInteger {
    VPFrameTypeYUV420Planer = 0,
    VPFrameTypeYUV420SemiPlaner = 1,
    VPFrameTypeRGBA = 2,
} VPFrameType;

/*
 * the type of reverse lookup table for dlog filter
 */
typedef enum : NSUInteger {
    DLogReverseLookupTableTypeNone, //not use dlog reverse
    DLogReverseLookupTableP4POld, //old camera firmware, ask Luminis for detail
    DLogReverseLookupTableTypeDefault, //for p4p and in2
} DLogReverseLookupTableType;


/**
 *  Rotation of the video tream. VideoPreviewer is adaptive to the rotation of
 *  the stream.
 */
typedef NS_ENUM(NSUInteger, VideoStreamRotationType){
    VideoStreamRotationDefault,
    /**
     *  The live stream is rotated 90 degrees cw. VideoPreviewer will rotate 90
     *  degrees ccw when render it to screen.
     */
    VideoStreamRotationCW90,
    VideoStreamRotationCW180,
    VideoStreamRotationCW270,
};

/**
 *  fov state
 */
typedef enum : NSUInteger {
    DJISEIInfoLiveViewFOVState_Undefined = 0,
    DJISEIInfoLiveViewFOVState_Wide_Fov = 1,
    DJISEIInfoLiveViewFOVState_Narrow_Fov = 2,
    DJISEIInfoLiveViewFOVState_GDC_No_Needed = 3,
} DJISEIInfoLiveViewFOVState;


typedef struct{
    uint8_t has_lut_idx:1; // lut index
    uint8_t has_time_stamp:1; // the global time stamp
    uint8_t should_ignore:1;//render and processor ignore this frame after decoding
    uint8_t force_30_fps:1;//when liveview fps = 60，downsample to keep 30fps rendering and encoding
    uint8_t reserved:4;//unused
    
    uint8_t lut_idx; //has_lut_idx == 0,ignored
    uint8_t fov_state;//has_lut_idx == 0,ignored
    uint32_t timestamp; //has_time_stamp == 0,ignored
} DJIDecodingAssistInfo;


typedef struct{
    uint16_t width;
    uint16_t height;
    uint16_t fps;
    uint8_t  rotate; //0 - default, 1 - 90, 2 - 180, 3 - 270, VideoStreamRotationType
    uint8_t  reserved;
    uint16_t frame_index;
    uint16_t max_frame_index_plus_one;
    union{
        struct{
            int has_sps :1; //has sps info
            int has_pps :1; //has pps info
            int has_idr :1; //has idr frame
            int is_fullrange:1; //the luma is in fullrange
            int ignore_render:1; //render should ignore this frame
            int incomplete_frame_flag:1; //mark this frame as a incomplete or failed frame
            int reserved:2;
            
            uint8_t channelType:8; //DJIVideoDataDispatcherOutputChannel
        } frame_flag;
        uint32_t value;
    };
    DJIDecodingAssistInfo assistInfo;//assist info
    uint32_t frame_poc; //present order
    uint32_t ca_media_time_ms; //CACurrentMediaTime in ms
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
    /**
     *  The following three ptrs has different meanings when the encoding format
     *  is different.
     *  - YUV Planer: Y in `luma`, U in `chromaB` and V in `chromaR`
     *  - YUV Semi-Planer: y in `luma` and CrCb in `chromaB`
     *  - RGB: RGB value is stored in `luma`
     *
     *  When fastupload is enabled, `luma`, `chromaB` and `chromaR` may be nil
     *  and the pixel information can be accessed in `cv_pixelbuffer_fastupload`.
     */
    uint8_t *luma;
    uint8_t *chromaB;
    uint8_t *chromaR;
    
    uint8_t frameType; //VPFrameType
    
    int width, height;
    
    //slice data，`0` indicates the default value.
    int lumaSlice, chromaBSlice, chromaRSlice;
    
    pthread_rwlock_t mutex;
    // It is only valid when fastupload is enabled.
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
    uint64_t time_tag; //videoPool Internal relative time
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
    CGSize frameSize; //Persistence unused
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

// content fill mode
typedef NS_ENUM(NSUInteger, VideoPresentContentMode){
    VideoPresentContentModeAspectFit,
    VideoPresentContentModeAspectFill,
    VideoPresentContentModeNone,
};

/**
 *  stream processor to decode/save stream
 */
@protocol VideoStreamProcessor <NSObject>
@required
/**
 * Enables the stream processor.
 */
-(BOOL) streamProcessorEnabled;

-(DJIVideoStreamProcessorType) streamProcessorType;
;
-(BOOL) streamProcessorHandleFrameRaw:(VideoFrameH264Raw*)frame;
@optional

/**
 *  Stream basic information is changed (e.g. parameters of processor is re-configured)
 */
-(void) streamProcessorInfoChanged:(DJIVideoStreamBasicInfo*)info;
-(void) streamProcessorPause;
-(void) streamProcessorReset;
@end

/**
 *  frame processor to display video frame
 */
@protocol VideoFrameProcessor <NSObject>
@required
/**
 * Enables the frame processor
 */
-(BOOL) videoProcessorEnabled;
-(void) videoProcessFrame:(VideoFrameYUV*)frame;

@optional
/*
 * this output frame is not the same frame that input to the decoder
 * this frame only keeps some basic infomations from that input frame
 */
-(void) videoProcessFailedFrame:(VideoFrameH264Raw*)frame;
@end
