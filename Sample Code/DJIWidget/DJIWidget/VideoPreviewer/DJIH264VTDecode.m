//
//  DJIH264VTDecode.m
//
//  Copyright (c) 2013 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJIH264VTDecode.h"
#import "DJIVideoHelper.h"
#import <CoreMedia/CoreMedia.h>

//#import "DJILogCenter.h"

#define INFO(fmt, ...) //DJILog(@"[VTDecoder]"fmt, ##__VA_ARGS__)
#define ERROR(fmt, ...) //DJILog(@"[VTDecoder]"fmt, ##__VA_ARGS__)

#define DEFAULT_STREAM_FPS (30)
#define FRAME_MAX_SLICE_COUNT (30)

uint8_t nalStartTag4Byte[] = {0, 0, 0, 1};
uint8_t nalStartTag3Byte[] = {0, 0, 1};

#pragma mark - VTDecode
@interface DJIH264VTDecode (){
    //264 context, for verification 246 stream.
    SPS _currentSPS;
    int _sps_w;
    int _sps_h;
    int _sps_fps;
    int _pic_slice_count;
    H264SliceHeaderSimpleInfo _pic_slices[FRAME_MAX_SLICE_COUNT];
    
    BOOL skip_current_frame;
    int last_decode_frame_index;
    int max_frame_index_plus_one;
    
    CMMemoryPoolRef _blockBufferMemoryPool;
    CMMemoryPoolRef _samplerBufferMemoryPool;
}


//the frame that currently working on
@property (nonatomic, assign) VideoFrameH264Raw* currentFrame;
@property (nonatomic, assign) VideoFrameH264Raw* frameInfoList;
@property (nonatomic, assign) int frameInfoListCount;

@end

#pragma mark - VideoToolBox Decompress Frame CallBack
/*
 This callback gets called everytime the decompresssion session decodes a frame
 */
void DJIHWDecoderDidDecompress( void *decompressionOutputRefCon, void *sourceFrameRefCon, OSStatus status, VTDecodeInfoFlags infoFlags, CVImageBufferRef imageBuffer, CMTime presentationTimeStamp, CMTime presentationDuration ){
    
    DJIH264VTDecode* decoder = (__bridge DJIH264VTDecode*)decompressionOutputRefCon;
    if(!decoder || !decoder.decoderInited)
        return;
    
    if (!status && imageBuffer) {
        decoder.decodeErrorCount = 0;
        if ([decoder.delegate respondsToSelector:@selector(decompressedFrame:frameInfo:)]) {
            
            VideoFrameH264Raw* rawFrame = nil;
            int frame_index = (int)sourceFrameRefCon;
            if (frame_index >=0 && (frame_index < decoder.frameInfoListCount)) {
                rawFrame = &decoder.frameInfoList[frame_index];
            }
            [decoder.delegate decompressedFrame:imageBuffer frameInfo:rawFrame];
        }
    }else{

        VideoFrameH264Raw* rawFrame = nil;
        int frame_index = (int)sourceFrameRefCon;
        if (frame_index >=0 && (frame_index < decoder.frameInfoListCount)) {
            rawFrame = &decoder.frameInfoList[frame_index];
        }
        
        if(decoder.currentFrame
           && rawFrame
           && rawFrame->frame_uuid == decoder.currentFrame->frame_uuid){
            //mark as incomplete frame
            rawFrame->frame_info.frame_flag.incomplete_frame_flag = 1;
            decoder.currentFrame->frame_info.frame_flag.incomplete_frame_flag = 1;
        }

        if ([decoder.delegate respondsToSelector:@selector(videoProcessFailedFrame:)]) {
            [decoder.delegate videoProcessFailedFrame:rawFrame];
        }
        
        INFO(@"decode callback status:%d, count:%d", (int)status, decoder.decodeErrorCount);
        decoder.decodeErrorCount ++;
        if (decoder.decodeErrorCount > 1) {
            ERROR(@"decode callback status:%d, count:%d", (int)status, decoder.decodeErrorCount);
            
            decoder.decodeErrorCount = 0;
            [decoder resetLater];
        }
    }
}

@implementation DJIH264VTDecode

-(id) init{
    self = [super init];
    if (self) {
        
        _blockBufferMemoryPool = CMMemoryPoolCreate(NULL);
        _samplerBufferMemoryPool = CMMemoryPoolCreate(NULL);
        
        self.decoderInited = NO;
        self.dummyIPushed = NO;
        self.enabled = YES;
        
        _hardwareUnavailable = NO;
        _income_frame_count = 0;
        _decoder_create_count = 0;
        _pic_slice_count = 0;
        _sps_fps = 0;
        _sps_w = 0;
        _sps_h = 0;
        
        memset(sps_buffer, 0, sizeof(sps_buffer));
        memset(pps_buffer, 0, sizeof(pps_buffer));
        pps_size = 0;
        sps_size = 0;
        _fps = DEFAULT_STREAM_FPS;
        
        _sessionRef = nil;
        _formatDesc = nil;
        
        nalu_buf = malloc(NAL_MAX_SIZE);
        
        if (!nalu_buf) {
            ERROR(@"malloc failed");
            return nil;
        }
        
        au_buf = malloc(AU_MAX_SIZE);
        au_size = 0;
        au_nal_count = 0;
        _decodeErrorCount = 0;
        _videoSize = CGSizeZero;
        last_decode_frame_index = -1;
        skip_current_frame = NO;
        max_frame_index_plus_one = 0;
        
        _frameInfoList = NULL;
        _frameInfoListCount = 0;
        
        if(!au_buf){
            if (nalu_buf)
                free(nalu_buf);
            
            ERROR(@"malloc failed");
            return nil;
        }
        
       _blockBufferMemoryPool = CMMemoryPoolCreate(NULL);
       _samplerBufferMemoryPool = CMMemoryPoolCreate(NULL);
        
    }
    return self;
}

-(void)dealloc{
    
    ERROR(@"hardware decoder dealloc");
    [self safeReleaseDecodeSession];
    
    if (_blockBufferMemoryPool != NULL) {
        CMMemoryPoolInvalidate(_blockBufferMemoryPool);
        CFRelease(_blockBufferMemoryPool);
        _blockBufferMemoryPool = NULL;
    }
    
    if (_samplerBufferMemoryPool != NULL) {
        CMMemoryPoolInvalidate(_samplerBufferMemoryPool);
        CFRelease(_samplerBufferMemoryPool);
        _samplerBufferMemoryPool = NULL;
    }
    
    if(nalu_buf){
        free(nalu_buf);
        nalu_buf = NULL;
    }
    if(au_buf){
        free(au_buf);
        au_buf = NULL;
    }
    
    if (_frameInfoList) {
        free(_frameInfoList);
        _frameInfoList = NULL;
    }
    
    if (_blockBufferMemoryPool != NULL) {
        CMMemoryPoolInvalidate(_blockBufferMemoryPool);
        CFRelease(_blockBufferMemoryPool);
        _blockBufferMemoryPool = NULL;
    }
    
    if (_samplerBufferMemoryPool != NULL) {
        CMMemoryPoolInvalidate(_samplerBufferMemoryPool);
        CFRelease(_samplerBufferMemoryPool);
        _samplerBufferMemoryPool = NULL;
    }
}


-(void)resetInDecodeThread{
    //reset decoder
    ERROR(@"hardware decoder reset");
    self.decoderInited = NO;
    self.dummyIPushed = NO;
    self.decodeErrorCount = 0;
    
    pps_size = 0;
    sps_size = 0;
    
    au_size = 0;
    au_nal_count = 0;
    
    _frameInfoListCount = 0;
    if (_frameInfoList) {
        free(_frameInfoList);
        _frameInfoList = NULL;
    }
    
    [self safeReleaseDecodeSession];
}

-(void)resetLater{
    sps_size = 0;
    pps_size = 0;
    self.decoderInited = NO;
    self.dummyIPushed = NO;
}

//input a single nal
-(int)decodeInit:(uint8_t*)data Size:(int)size{
    
    if(!pps_size || !sps_size)
    {
        //find pps or sps
        if (size<=4
            || size > PPS_SPS_MAX_SIZS + 4) {
            return 0;
        }
        
        uint8_t nal_unit_header = data[4];
        uint8_t nal_header_forbiden_bit = 0x80&nal_unit_header;
        if (nal_header_forbiden_bit) {
            //Detect forbidden bit
            return 0;
        }
        
        uint8_t nal_unit_type = nal_unit_header&0x1f;
        switch (nal_unit_type) {
            case SPS_TAG:
                memcpy(sps_buffer, data+4, size-4);
                sps_size = size - 4;
                break;
            case PPS_TAG:
                memcpy(pps_buffer, data+4, size-4);
                pps_size = size - 4;
                break;
            case IDR_TAG:
                break;
            default:
                break;
        }
    }
    
    if(pps_size && sps_size){
        //got pps and sps data
        void* props[] = {sps_buffer, pps_buffer};
        size_t sizes[] = {sps_size, pps_size};
        [self safeReleaseDecodeSession];
        INFO(@"old session released\n");
        
        // Analyze sps and save information for the verification of slice header.
        if (-1 == h264_decode_seq_parameter_set_out(sps_buffer, sps_size, &_sps_w, &_sps_h, &_sps_fps, &_currentSPS)
            || _sps_w > 4000
            || _sps_h > 3000
            || _sps_fps > 100) {
            [self resetLater];
            return 0;
        }
        
        max_frame_index_plus_one = pow(2, _currentSPS.log2_max_frame_num);
        if (_frameInfoListCount != max_frame_index_plus_one) {
            //recreate frame info list
            if (_frameInfoList) {
                free(_frameInfoList);
                _frameInfoList = nil;
            }
            
            if (max_frame_index_plus_one) {
                _frameInfoList = malloc(sizeof(VideoFrameH264Raw)*max_frame_index_plus_one);
                memset(_frameInfoList, 0, max_frame_index_plus_one*sizeof(VideoFrameH264Raw));
            }
            _frameInfoListCount = max_frame_index_plus_one;
        }
        
        //create formatDesc
        OSStatus fmt_ret = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault, 2, (const void *)props, sizes, 4, &_formatDesc);
        if(fmt_ret){
            [self resetLater];
            return 0;
        }
        
        //get width and height of video
        CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions (_formatDesc);
        
        // Set the pixel attributes for the destination buffer
        CFMutableDictionaryRef destinationPixelBufferAttributes = CFDictionaryCreateMutable(
                                                                                            kCFAllocatorDefault,
                                                                                            0,
                                                                                            &kCFTypeDictionaryKeyCallBacks,
                                                                                            &kCFTypeDictionaryValueCallBacks);

        SInt32 destinationPixelType = kCVPixelFormatType_420YpCbCr8Planar;
        if (_enableFastUpload) {
            destinationPixelType = kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange;
            if (_currentSPS.full_range == 1) {
                destinationPixelType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
            }
        }
        else{
            destinationPixelType = kCVPixelFormatType_420YpCbCr8Planar;
            if (_currentSPS.full_range == 1) {
                destinationPixelType = kCVPixelFormatType_420YpCbCr8PlanarFullRange;
            }
        }
        
        CFNumberRef pixelType = CFNumberCreate(NULL, kCFNumberSInt32Type, &destinationPixelType);
        CFDictionarySetValue(destinationPixelBufferAttributes,kCVPixelBufferPixelFormatTypeKey, pixelType);
        CFRelease(pixelType);

        CFNumberRef width = CFNumberCreate(NULL, kCFNumberSInt32Type, &dimension.width);
        CFDictionarySetValue(destinationPixelBufferAttributes,kCVPixelBufferWidthKey, width);
        CFRelease(width);

        CFNumberRef height = CFNumberCreate(NULL, kCFNumberSInt32Type, &dimension.height);
        CFDictionarySetValue(destinationPixelBufferAttributes, kCVPixelBufferHeightKey, height);
        CFRelease(height);
        
        CFDictionarySetValue(destinationPixelBufferAttributes, kCVPixelBufferOpenGLCompatibilityKey, kCFBooleanTrue);
//        CFDictionarySetValue(destinationPixelBufferAttributes, kCVPixelBufferIOSurfacePropertiesKey, kCFBooleanFalse);
        
        //create decode section
        VTDecompressionOutputCallbackRecord callBackRecord;
        callBackRecord.decompressionOutputCallback = DJIHWDecoderDidDecompress;
        callBackRecord.decompressionOutputRefCon = (__bridge void *)self;
       
        INFO(@"begin create decompress session\n");
        NSDate* startCreateSession = [NSDate date];
        OSStatus session_ret = VTDecompressionSessionCreate(kCFAllocatorDefault, _formatDesc, NULL, destinationPixelBufferAttributes, &callBackRecord, &_sessionRef);
        double duration = -[startCreateSession timeIntervalSinceNow];
        
        //In some case on iOS 8.x, create hardware decoder may always return failed until restart the device, it may cost more than 10 seconds to get the failed result.
        if (destinationPixelBufferAttributes) {
            CFRelease(destinationPixelBufferAttributes);
            destinationPixelBufferAttributes = nil;
        }
        
        static int hw_decoder_create_fail_count = 0;
        if (session_ret) {
            [self safeReleaseDecodeSession];
            [self resetLater];
            hw_decoder_create_fail_count++;
            
            //if create hardware decoder failed too many times, we should fallback to software decoder
            if(hw_decoder_create_fail_count >= 5 || duration > 1){//too much error, use soft decoder
                if([self.delegate respondsToSelector:@selector(hardwareDecoderUnavailable)]){
                    ERROR(@"use software decode because failed count:%d duration:%.1f",
                          hw_decoder_create_fail_count, duration);
                    [self.delegate hardwareDecoderUnavailable];
                }
                _hardwareUnavailable = YES;
                hw_decoder_create_fail_count = 0;
            }
            
            return 0;
        }
        else{
            ERROR(@"create decode session %d", _decoder_create_count);
            hw_decoder_create_fail_count = 0;
            _decoder_create_count++;
        }
        
        if (false == VTDecompressionSessionCanAcceptFormatDescription(_sessionRef,_formatDesc)){
            //FIXME: always return false
            //ERROR(@"format not supported");
        }
        
        if (_sessionRef && _formatDesc)
        {
            self.videoSize = CGSizeMake(dimension.width, dimension.height);
            self.decoderInited = YES;
            
            self.dummyIPushed = NO;
            self.decodeErrorCount = 0;
            last_decode_frame_index = -1;
            skip_current_frame = NO;
            
            //try to load a dummy i frame, maybe failed at this time
            if(0 == [self loadDummyIframe]){
                self.dummyIPushed = YES;
            }
        }
    }
    
    return 0;
}

-(int) loadDummyIframe{
    //load dummy_i frame
    
    //if we dont know the encoder type, do not use prebuild IDR frame
    if (_encoderType == H264EncoderType_unknown) {
        return 0;
    }
    
    int frame_rate = DEFAULT_STREAM_FPS;
    CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions (_formatDesc);
    if(_fps >0 && _fps<=60){
        frame_rate = (int)_fps;
    }
    
    PrebuildIframeInfo info;
    info.fps = frame_rate;
    info.frame_width = dimension.width;
    info.frame_height = dimension.height;
    info.encoder_type = (int)_encoderType;
    int prebuildFrameSize = loadPrebuildIframe(au_buf, AU_MAX_SIZE, info);
    if (prebuildFrameSize <= 0) {
        ERROR(@"prebuild iframe not found:%d %dx%d p%d" ,
              info.encoder_type, info.frame_width, info.frame_height, info.fps);
        _hardwareUnavailable = YES;
        return -1;
    }
    
    //push i frame
    au_size = prebuildFrameSize;
    int push_ret = [self pushSampleBuffer:au_buf Size:au_size frameInfo:nil];
    au_size = 0;
    au_nal_count = 0;
    if (push_ret == 0) {
        ERROR(@"push iframe success");
        
        if (_encoderType == H264EncoderType_A9_phantom3c
            || _encoderType == H264EncoderType_A9_phantom3s) {
            //skip frame num 0 then start
            skip_current_frame = YES;
        }
    }else{
        ERROR(@"prebuild decode failed:%d %dx%d p%d" ,
              info.encoder_type, info.frame_width, info.frame_height, info.fps);
    }
    return  push_ret;
}

-(void) saveDummyIframe{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *file_name = [(NSString*)[paths objectAtIndex:0] stringByAppendingFormat:@"/%@", @"dummy_i.h264"];

    FILE* out = fopen([file_name cStringUsingEncoding:NSUTF8StringEncoding], "wb");
    fwrite(au_buf, au_size, 1, out);
    fclose(out);
}

-(int) pushSampleBuffer:(uint8_t*)data Size:(int)size frameInfo:(VideoFrameH264Raw*)frame{
    
    if (size <= 4 || (self.decoderInited != YES)){
        return -1;
    }
    
    CMSampleBufferRef sampleBuffer = NULL;
    CMBlockBufferRef newBBufOut = NULL;
    
    //fill size in nal head
    size_t in_block_size = size;
    uint8_t* block_data = data;
    
    
    //create memory block
    /*
     All of its allocations are on the granularity of page sizes; it does not suballocate
     memory within pages, so it is a poor choice for allocating tiny blocks.
     For example, it's appropriate to use as the blockAllocator argument to
     CMBlockBufferCreateWithMemoryBlock, but not the structureAllocator argument --
     use kCFAllocatorDefault instead.
     */
    CFAllocatorRef blockAllocator = CMMemoryPoolGetAllocator(_blockBufferMemoryPool);

    OSStatus block_status = CMBlockBufferCreateWithMemoryBlock(
                               kCFAllocatorDefault, // CFAllocatorRef structureAllocator
                               block_data,          // void *memoryBlock
                               in_block_size,       // size_t blockLengt
                               blockAllocator,      // CFAllocatorRef blockAllocator
                               NULL,                // const CMBlockBufferCustomBlockSource *customBlockSource
                               0,                   // size_t offsetToData
                               in_block_size,       // size_t dataLength
                               0,                   // CMBlockBufferFlags flags
                               &newBBufOut);        // CMBlockBufferRef *newBBufOut
    if (block_status || !newBBufOut) {
        return -1;
    }
    
    
    //create sample buffer
    int sample_count = 1;
    size_t* sample_size_array = &in_block_size;
    
    CMSampleTimingInfo timming;
    timming.decodeTimeStamp = CMTimeMake(1, 30000);
    timming.presentationTimeStamp = CMTimeMake(1, 30000);
    timming.duration = CMTimeMake(1, 30000);
    

    CFAllocatorRef samplerAlloctor = CMMemoryPoolGetAllocator(_samplerBufferMemoryPool);
    OSStatus sample_status = CMSampleBufferCreateReady(
               samplerAlloctor,     // CFAllocatorRef allocator
               newBBufOut,          // CMBlockBufferRef dataBuffer
               _formatDesc,         // CMFormatDescriptionRef formatDescription
               sample_count,        // CMItemCount numSamples
               1,                   // CMItemCount numSampleTimingEntries
               &timming,            // const CMSampleTimingInfo *sampleTimingArray
               sample_count,        // CMItemCount numSampleSizeEntries
               sample_size_array,   // const size_t *sampleSizeArray
               &sampleBuffer);      // CMSampleBufferRef *sBufOut

    if (sample_status || !sampleBuffer) {
        CFRelease(newBBufOut);
        return -1;
    }
    
    int frame_index = -1;
    if (frame && frame->frame_info.frame_index < _frameInfoListCount) {
        frame_index = frame->frame_info.frame_index;
        _frameInfoList[frame_index] = *frame;
    }
    
    //decompress
    VTDecodeFrameFlags flags = 0;
    //VTDecodeFrameFlags flags = kVTDecodeFrame_EnableAsynchronousDecompression;
    //VTDecodeFrameFlags flags = kVTDecodeFrame_1xRealTimePlayback;
    VTDecodeInfoFlags flagOut = 0;
    //pass uuid as a pointer
    //Warning, this is a sync operation, but the decoded frame will return from a different thread
    OSStatus decode_status = VTDecompressionSessionDecodeFrame(_sessionRef, sampleBuffer, flags, (void*)(long)frame_index, &flagOut);
    
    if(0 != decode_status){
        ERROR(@"decode status:%d, flagout:%d", (int)decode_status, (unsigned int)flagOut);
    }
    else{
        //INFO(@"decode!");
    }

    //release block and sample
    if(sampleBuffer)
        CFRelease(sampleBuffer);
    if(newBBufOut)
        CFRelease(newBBufOut);
    return decode_status;

}

// Expect a complete nal with 0 0 0 1 start code as input.
-(int)decodeWork:(uint8_t*)data Size:(int)size{
    
    if (size <= 4 || (self.decoderInited != YES)
        ) {
        return -1;
    }
    
    uint8_t nal_unit_header = data[4];
    uint8_t nal_header_forbiden_bit = 0x80&nal_unit_header;
    if (nal_header_forbiden_bit) {
        //Detect forbidden bit
        return -1;
    }

    uint8_t nal_unit_type = nal_unit_header&0x1f;
    switch (nal_unit_type) {
        //drop aud, pps, sps... dont need them in stream
        case IDR_TAG:
        case SLICE_TAG:
        case SLICE_A_TAG:
        case SLICE_B_TAG:
        case SLICE_C_TAG:
            break;
        default:
            return 0;
            break;
    }
    
    if (nal_unit_type > 12) {
        //unknown data
        return -1;
    }
    
    //fill size in nal head
    size_t in_block_size = size;
    uint32_t nal_size = (int)in_block_size-4;
    uint8_t* nal_size_ptr = (uint8_t*)&nal_size;

    //save nal into au buffer
    if (au_size + size <= AU_MAX_SIZE) {
        
        //conver the size to big-endian mode
        uint8_t* nal_start_code = au_buf + au_size;
        nal_start_code[0] = nal_size_ptr[3];
        nal_start_code[1] = nal_size_ptr[2];
        nal_start_code[2] = nal_size_ptr[1];
        nal_start_code[3] = nal_size_ptr[0];
        
        memcpy(au_buf + au_size +4, data+4, size-4);
        au_size += size;
        au_nal_count++;
        
        //analyze slice_header
        [self sliceDecodeAdd:data+5 size:size-5];
    }
    else{
        ERROR(@"error: au size:%d append:%d", au_size, size);
    }
    
    return 0;
}

/***
 in: a complete h264 frame from ffmpeg av_parser_parse2
 out: decode frame image
 ***/
-(BOOL) decodeCompleteFrame:(VideoFrameH264Raw*)frame frameData:(uint8_t*)frameData{
    uint8_t* data = frameData;
    int size = frame->frame_size;
    
    if(!data || _hardwareUnavailable){
        ERROR(@"data:%p ua:%d", data, _hardwareUnavailable);
        return NO;
    }
    
    //INFO(@"income:%d", _income_frame_count);
    _income_frame_count++;
    [self clear264VerifyContext];
    
    
    int remain_size = size;
    uint8_t* buffer = (uint8_t*)data;
    
    while (remain_size > 0) {
        
        if(_hardwareUnavailable)
            return NO;
        
        //find a nal start code
        int start_code_offset = findNextNALStartCodeEndPos(buffer, remain_size);
        if (start_code_offset <= 0) {
            //at least need a start code
            break;
        }
        
        int next_start_code_offset = findNextNALStartCodePos(buffer + start_code_offset, remain_size - start_code_offset);
        if (next_start_code_offset < 0) {
            //end of buffer
            next_start_code_offset = remain_size - start_code_offset;
        }
        
        int nal_payload_size = next_start_code_offset;
        if(nal_payload_size > NAL_MAX_SIZE || 0 >= nal_payload_size){
            ERROR(@"error rbsp size:%d", nal_payload_size);
            return NO;
        }
        
        //get nal payload, add 00 00 00 01 start code in front of rbsp
        uint8_t* process_nal = nil;
        if ((buffer + start_code_offset) - data >= 4) { //do not copy if have enough head space
            process_nal = buffer + start_code_offset - 4;
        }else{
            memcpy((uint8_t*)nalu_buf + 4, buffer+start_code_offset, nal_payload_size);
            memcpy(nalu_buf, nalStartTag4Byte, 4);
            process_nal = nalu_buf;
        }
        //INFO(@"nal payload size:%d", nal_payload_size);
        
        if (self.decoderInited) {
            //do decode
            if([self decodeWork:process_nal Size:nal_payload_size+4] < 0){
                //it have detected error data.
                frame->frame_info.frame_flag.incomplete_frame_flag = 1;
                return 0;
            };
        }
        else{
            //do init
            [self decodeInit:process_nal Size:nal_payload_size+4];
        }
        
        remain_size = remain_size - next_start_code_offset - start_code_offset;
        buffer = buffer + next_start_code_offset + start_code_offset;
    }
    
    int decode_ret = -1;
    if (au_size && au_nal_count) {
        //need at least dummy iframe before decode other p frames
        if (self.dummyIPushed == NO) {
            if(0 == [self loadDummyIframe]){
                if (_encoderType == H264EncoderType_A9_phantom3c
                    || _encoderType == H264EncoderType_A9_phantom3s) {
                    //skip frame num 0 then start.
                    skip_current_frame = YES;
                }
                self.dummyIPushed = YES;
            }
        }
        
        if (self.dummyIPushed) {
            //decode
            int frameIndex = -1;
            if ([self verifyCurrentFrame:&frameIndex]) {
                
                if (skip_current_frame) {
                    //use prebuild IDR frame to replace the frame that FrameNum is 0
                    if (frameIndex == 0) {
                        skip_current_frame = NO;
                        last_decode_frame_index = 0;
                    }
                    frame->frame_info.frame_flag.incomplete_frame_flag = 1;
                    decode_ret = 0;
                }else{
                    //decode
                    frame->frame_info.frame_index = frameIndex;
                    frame->frame_info.frame_flag.is_fullrange = (_currentSPS.full_range == 1);
                    decode_ret = [self pushSampleBuffer:au_buf Size:au_size frameInfo:frame];
                    last_decode_frame_index = frameIndex;
                    if (decode_ret !=0) {
                        ERROR(@"decode out imm:%d", decode_ret);
                    }
                }
            }else{
                //frame error, but decoder should continue
                frame->frame_info.frame_flag.incomplete_frame_flag = 1;
                decode_ret = 0;
            }
        }
    }else{
        //ERROR(@"no au found");
        //no data can put into decoder in this frame, this is not a exception
        frame->frame_info.frame_flag.incomplete_frame_flag = 1;
        decode_ret = 0;
    }
    
    au_size = 0;
    au_nal_count = 0;
    
    if (0 == decode_ret) {
        return YES;
    }
    
    return NO;
}

/**
 *  Force decoder export all frame.
 */
-(void) dequeueAllFrames{
    if (_sessionRef) {
        OSStatus wait_status = VTDecompressionSessionWaitForAsynchronousFrames(_sessionRef);
        if (wait_status) {
            INFO(@"wait asynchronous failed:%d", (int)wait_status);
        }
    }
}

-(void) safeReleaseDecodeSession{    
    if(_sessionRef){
        //make sure the session isn't decoding when release, otherwise may cause the device blue screen (display driver exception) on iOS8.x
        [self dequeueAllFrames];
        //disable session before release,otherwise the device might blue screen
        VTDecompressionSessionInvalidate(_sessionRef);
        CFRelease(_sessionRef);
        _sessionRef = NULL;
    }
    
    if(_formatDesc){
        CFRelease(_formatDesc);
        _formatDesc = NULL;
    }
}

-(void) setFps:(NSInteger)fps{
    if (_fps == fps) {
        return;
    }
    _fps = fps;
    _hardwareUnavailable = NO;
    [self resetLater];
}

-(void) setVideoSize:(CGSize)videoSize{
    if (CGSizeEqualToSize(videoSize, _videoSize)) {
        return;
    }
    _videoSize = videoSize;
    _hardwareUnavailable = NO;
    [self resetLater];
}

-(void) setEncoderType:(NSInteger)encoderType{
    if (_encoderType == encoderType) {
        return;
    }
    _encoderType = encoderType;
    _hardwareUnavailable = NO;
    [self resetLater];
}

#pragma mark - h264 stream simple verification
-(void) clear264VerifyContext{
    //clear on every frame
    _pic_slice_count = 0;
//    _sps_fps = 0;
//    _sps_w = 0;
//    _sps_h = 0;
}

enum AVPictureType {
    AV_PICTURE_TYPE_NONE = 0, ///< Undefined
    AV_PICTURE_TYPE_I,     ///< Intra
    AV_PICTURE_TYPE_P,     ///< Predicted
    AV_PICTURE_TYPE_B,     ///< Bi-dir predicted
    AV_PICTURE_TYPE_S,     ///< S(GMC)-VOP MPEG4
    AV_PICTURE_TYPE_SI,    ///< Switching Intra
    AV_PICTURE_TYPE_SP,    ///< Switching Predicted
    AV_PICTURE_TYPE_BI,    ///< BI type
};

//Add the slice containing mb added to the list.
-(void) sliceDecodeAdd:(uint8_t*)buf size:(int)size{
    H264SliceHeaderSimpleInfo info;
    info.frame_num = -1;
    info.slice_type = -1;
    info.first_mb_in_slice = -1;
    
    if(0 == h264_decode_slice_header(buf, size, &_currentSPS, &info)){
        //sliceheader analyse succeed
        if (info.slice_type == AV_PICTURE_TYPE_P
            || info.slice_type == AV_PICTURE_TYPE_B
            || info.slice_type == AV_PICTURE_TYPE_I) {
            //processing only i frame and p frame
            if (_pic_slice_count < FRAME_MAX_SLICE_COUNT) {
                _pic_slices[_pic_slice_count] = info;
                _pic_slice_count++;
            }
        }
    }
    else{
        //Also placed in the wrong slice, will check it out later
        if (_pic_slice_count < FRAME_MAX_SLICE_COUNT) {
            _pic_slices[_pic_slice_count] = info;
            _pic_slice_count++;
        }
    }
}

//try verify frame complete.
-(BOOL) verifyCurrentFrame:(int*)currentFrameIndex{
    //at least has one slice
    if (_pic_slice_count <= 0 || _pic_slice_count == FRAME_MAX_SLICE_COUNT) {
        //ERROR(@"error 0");
        return NO;
    }
    
    if (!_sps_w || !_sps_h ) {
        //ERROR(@"error 1");
        return NO;
    }
    
    int current_frame_index = _pic_slices[0].frame_num;
    int last_slice_first_mb = 0;
    *currentFrameIndex = current_frame_index;
    
    if (_pic_slices[0].first_mb_in_slice != 0) {
        return NO;
    }
    
    for (int i=0; i<_pic_slice_count; i++) {
        H264SliceHeaderSimpleInfo* info = &_pic_slices[i];
        if (info->frame_num != current_frame_index) {
            //aud lost，slice isn't belong this frame.
            //ERROR(@"error 3");
            return NO;
        }
        
        if (i>0 && info->first_mb_in_slice <= last_slice_first_mb) {
            //ERROR(@"error 4");
            return NO;
        }
        
        last_slice_first_mb = info->first_mb_in_slice;
    }
    return YES;
}

#pragma mark - stream processor protocol

-(DJIVideoStreamProcessorType) streamProcessorType{
    return DJIVideoStreamProcessorType_Decoder;
}

-(BOOL) streamProcessorHandleFrameRaw:(VideoFrameH264Raw *)frame{
    _currentFrame = frame;
    BOOL ret = [self decodeCompleteFrame:frame frameData:frame->frame_data];
    _currentFrame = nil;
    return ret;
}

/**
 *  Stream basic information is changed, the decoder ... etc need to reconfigure the interior
 */
-(void) streamProcessorInfoChanged:(DJIVideoStreamBasicInfo*)info{
    
    NSLog(@"[vs]stream info changed : %@",[NSThread currentThread]);
    
    self.fps = info->frameRate;
    self.encoderType = info->encoderType;
    self.videoSize = info->frameSize;
}

-(BOOL) streamProcessorEnabled{
    return self.enabled;
}

@end
