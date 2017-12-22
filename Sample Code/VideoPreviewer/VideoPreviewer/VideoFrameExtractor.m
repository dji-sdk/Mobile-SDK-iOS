//
//  Video.m
//  iFrameExtractor
//
//  Created by lajos on 1/10/10.
//  Copyright 2010 www.codza.com. All rights reserved.
//

#import "VideoFrameExtractor.h"
#import "DJIVideoHelper.h"
#import <sys/time.h>

#include "libavformat/avformat.h"
#include "libavcodec/avcodec.h"
#include "libswscale/swscale.h"

@interface VideoFrameExtractor (){
    AVCodecContext *_pCodecCtx; //decode
    AVFrame *_pFrame;   //frame
    AVCodecParserContext *_pCodecPaser;
    
    uint32_t s_frameUuidCounter;
    VideoFrameH264Raw* _frameInfoList;
    int _frameInfoListCount;
}

@end

@implementation VideoFrameExtractor

#define _CP_YUV_FRAME_(dst, src, linesize, width, height) \
do{ \
if(dst == NULL || src == NULL || linesize < width || width <= 0)\
break;\
uint8_t * dd = (uint8_t* ) dst; \
uint8_t * ss = (uint8_t* ) src; \
int ll = linesize; \
int ww = width; \
int hh = height; \
for(int i = 0 ; i < hh ; ++i) \
{ \
memcpy(dd, ss, width); \
dd += ww; \
ss += ll; \
} \
}while(0)

-(void)getYuvFrame:(VideoFrameYUV *)yuv
{
    @synchronized (self) {
        if(!_pFrame) return ;
        
        //get info from current avframe
        int input_width = _pFrame->width, input_height = _pFrame->height;
        int line_size[3] = {0};
        line_size[0] = _pFrame->linesize[0];
        line_size[1] = _pFrame->linesize[1];
        line_size[2] = _pFrame->linesize[2];
        
        if(yuv->luma != NULL && ((yuv->width != input_width) || (yuv->height != (input_height))))
        {
            free(yuv->luma);
            free(yuv->chromaB);
            free(yuv->chromaR);
            
            yuv->luma = NULL;
            yuv->chromaB = NULL;
            yuv->chromaR = NULL;
        }
        
        if(yuv->luma == NULL)
        {
            yuv->luma = (uint8_t*) malloc(input_width * input_height);
            yuv->chromaB = (uint8_t*) malloc(input_width * input_height/4);
            yuv->chromaR = (uint8_t*) malloc(input_width * input_height/4);
        }
        
        _CP_YUV_FRAME_(yuv->luma, _pFrame->data[0], _pFrame->linesize[0], input_width, input_height);
        
        _CP_YUV_FRAME_(yuv->chromaB, _pFrame->data[1], _pFrame->linesize[1], input_width/2, input_height/2);
        _CP_YUV_FRAME_(yuv->chromaR, _pFrame->data[2], _pFrame->linesize[2], input_width/2, input_height/2);
        
        yuv->width = input_width;
        yuv->height = input_height;
        yuv->frame_uuid = H264_FRAME_INVALIED_UUID;
        memset(&yuv->frame_info, 0, sizeof(VideoFrameH264BasicInfo));
        
        if (_pFrame->poc < _frameInfoListCount) {
            yuv->frame_uuid = _frameInfoList[_pFrame->poc].frame_uuid;
            yuv->frame_info = _frameInfoList[_pFrame->poc].frame_info;
        }
    }
}

-(CVImageBufferRef)getCVImage{
    @synchronized (self) {
        if(!_pFrame) return nil;
        
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                                 [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
        CVPixelBufferRef pixbuffer = NULL;
        CVReturn create_status = CVPixelBufferCreate(kCFAllocatorDefault, _pFrame->width, _pFrame->height, kCVPixelFormatType_420YpCbCr8Planar, (__bridge CFDictionaryRef) options, &pixbuffer);
        
        if (kCVReturnSuccess != create_status) {
            return nil;
        }
        
        if( kCVReturnSuccess != CVPixelBufferLockBaseAddress(pixbuffer, 0)){
            CFRelease(pixbuffer);
            return nil;
        }
        
        uint8_t* luma = (uint8_t*)CVPixelBufferGetBaseAddressOfPlane(pixbuffer, 0);
        uint8_t* chromaB = (uint8_t*)CVPixelBufferGetBaseAddressOfPlane(pixbuffer, 1);
        uint8_t* chromaR = (uint8_t*)CVPixelBufferGetBaseAddressOfPlane(pixbuffer, 2);
        
        if (!luma || !chromaB || !chromaR) {
            CFRelease(pixbuffer);
            return nil;
        }
        
        //copy yuv data
        _CP_YUV_FRAME_(luma, _pFrame->data[0], _pFrame->linesize[0], _pCodecCtx->width, _pCodecCtx->height);
        _CP_YUV_FRAME_(chromaB, _pFrame->data[1], _pFrame->linesize[1], _pCodecCtx->width/2, _pCodecCtx->height/2);
        _CP_YUV_FRAME_(chromaR, _pFrame->data[2], _pFrame->linesize[2], _pCodecCtx->width/2, _pCodecCtx->height/2);
        
        CVPixelBufferUnlockBaseAddress(pixbuffer, 0);
        return pixbuffer;
    }
    return nil;
}

#undef _CP_YUV_FRAME_

-(uint8_t*) getIFrameFromBuffer:(uint8_t*)buffer length:(int)bufferSize;
{
    if (buffer == NULL || bufferSize < 5) {
        return NULL;
    }
    
    uint8_t* pIter = buffer;
    uint8_t* pIterEnd = buffer + (bufferSize - 5);
    while (pIter <= pIterEnd) {
        if ((*pIter == 0x00 && *(pIter + 1) == 0x00 && *(pIter + 2) == 0x00 && *(pIter + 3) == 0x01)) {
            uint8_t flag = *(pIter + 4);
            if (flag == 0x65 || flag == 0x67 || flag == 0x68) {
                return pIter;
            }
        }
        pIter++;
    }
    
    return NULL;
}

-(void) setShouldVerifyVideoStream:(BOOL)shouldVerify
{
    _shouldVerifyVideoStream = shouldVerify;
}

-(void) privateParseVideo:(uint8_t*)buf length:(int)length withOutputBlock:(void (^)(AVPacket* frame))block
{
    if(_pCodecCtx == NULL) return;

    // Need padding for FFMpeg. Otherwise Address Sanitizer will complain heap overflow.
    size_t lengthWithPadding = length + FF_INPUT_BUFFER_PADDING_SIZE;
    uint8_t *bufWithPadding = malloc(lengthWithPadding);
    memset(bufWithPadding, 0, lengthWithPadding);
    memcpy(bufWithPadding, buf, length);

    uint8_t *paserBuffer_In = bufWithPadding;
    int paserLength_In = (int)length;
    int paserLen;

    while (paserLength_In > 0) {
        AVPacket packet;
        av_init_packet(&packet);
        paserLen = av_parser_parse2(_pCodecPaser, _pCodecCtx, &packet.data, &packet.size, paserBuffer_In, paserLength_In, AV_NOPTS_VALUE, AV_NOPTS_VALUE, AV_NOPTS_VALUE);
        paserLength_In -= paserLen;
        paserBuffer_In += paserLen;
        
        if (packet.size > 0) {
            bool isSpsPpsFound = false;
            //int rate = getVideFrameRateWH(packet.data, packet.size, &isSpsPpsFound, &_outputWidth, &_outputHeight);
            
            if(_pCodecPaser->height_in_pixel == 1088){
                //1080p hack
                _pCodecPaser->height_in_pixel = 1080;
            }
            
            _outputWidth = _pCodecPaser->width_in_pixel;
            _outputHeight = _pCodecPaser->height_in_pixel;
            isSpsPpsFound = _pCodecPaser->frame_has_sps?YES:NO;
            
            if (isSpsPpsFound) {
                if (_frameInfoListCount != _pCodecPaser->max_frame_num_plus1) {
                    //recreate frame info list
                    if (_frameInfoList) {
                        free(_frameInfoList);
                        _frameInfoList = nil;
                    }
                    
                    if (_pCodecPaser->max_frame_num_plus1) {
                        _frameInfoListCount = _pCodecPaser->max_frame_num_plus1;
                        _frameInfoList = malloc(sizeof(VideoFrameH264Raw)*_frameInfoListCount);
                        memset(_frameInfoList, 0, _frameInfoListCount*sizeof(VideoFrameH264Raw));
                    }
                }
            }
            
            int rate = 0;
            if (_pCodecPaser->frame_rate_den) {
                // If the stream is encoded by DJI's encoder, the frame rate
                // should be double of the value from the parser.
                double scale = _usingDJIAircraftEncoder?2.0:1.0;
                rate = (int)(0.5+_pCodecPaser->frame_rate_num/(scale*_pCodecPaser->frame_rate_den));
                _frameRate = rate;
            }
            
            if (_shouldVerifyVideoStream) {
                if (isSpsPpsFound) {
                    _shouldVerifyVideoStream = NO;
                }
                else{
                    continue;
                }
            }
            
            if (!_shouldVerifyVideoStream){
                if (block) {
                    block(&packet);
                }
            }
            
        }
        else{
            av_free_packet(&packet);
            break;
        }
        
        av_free_packet(&packet);
    }

    if (bufWithPadding) {
        free(bufWithPadding);
    }

}

-(void) parseVideo:(uint8_t*)buf length:(int)length withOutputBlock:(void (^)(uint8_t* frame, int size))block{
    [self privateParseVideo:buf length:length withOutputBlock:^(AVPacket* frame) {
        if (!block || !frame->data) {
            return;
        }
        
        uint8_t* pVideoBuffer = (uint8_t*)malloc(frame->size);
        if (pVideoBuffer) {
            memcpy(pVideoBuffer, frame->data, frame->size);
            block(pVideoBuffer, frame->size);
            
            if(_delegate!=nil && [_delegate respondsToSelector:@selector(processVideoData:length:)]){
                [_delegate processVideoData:frame->data length:frame->size];
            }
        }
    }];
}

-(void) parseVideo:(uint8_t *)buf length:(int)length withFrame:(void (^)(VideoFrameH264Raw *))block{
    [self privateParseVideo:buf length:length withOutputBlock:^(AVPacket* frame) {
        if (!block || !frame->data) {
            return;
        }
        
        VideoFrameH264Raw* outputFrame = (VideoFrameH264Raw*)malloc(sizeof(VideoFrameH264Raw) + frame->size);
        outputFrame->type_tag = TYPE_TAG_VideoFrameH264Raw;
        memset(outputFrame, 0, sizeof(VideoFrameH264Raw));
        memcpy(outputFrame+1, frame->data, frame->size);
        
        [self popNextFrameUUID];
        
        outputFrame->frame_uuid = s_frameUuidCounter;
        outputFrame->frame_size = frame->size;
        
        { //patch by amanda
            outputFrame->frame_info.frame_index = _pCodecPaser->frame_num;
            outputFrame->frame_info.max_frame_index_plus_one = _pCodecPaser->max_frame_num_plus1;
            
            if (outputFrame->frame_info.frame_index >= outputFrame->frame_info.max_frame_index_plus_one) {
                // something wrong;
            }
            
            if(_pCodecPaser->height_in_pixel == 1088){
                //1080p hack
                _pCodecPaser->height_in_pixel = 1080;
            }
            
            outputFrame->frame_info.width = _pCodecPaser->width_in_pixel;
            outputFrame->frame_info.height = _pCodecPaser->height_in_pixel;
            
            if (_pCodecPaser->frame_rate_den) {
                // If the stream is encoded by DJI's encoder, the frame rate
                // should be double of the value from the parser. 
                double scale = _usingDJIAircraftEncoder?2.0:1.0;
                outputFrame->frame_info.fps = ceil(_pCodecPaser->frame_rate_num/(scale*_pCodecPaser->frame_rate_den));
            }
            outputFrame->frame_info.frame_flag.has_sps = _pCodecPaser->frame_has_sps;
            outputFrame->frame_info.frame_flag.has_pps = _pCodecPaser->frame_has_pps;
            outputFrame->frame_info.frame_flag.has_idr = (_pCodecPaser->key_frame ==1)?1:0;
            outputFrame->frame_info.frame_flag.is_fullrange = NO; //we can only get this in sps, set this bit later
        }
        
        block(outputFrame);
    }];
}

-(void) decodeRawFrame:(VideoFrameH264Raw*)frame callback:(void(^)(BOOL b))callback{
    if (!frame) {
        if (callback) {
            callback(NO);
        }
        
        return;
    }
    
    @synchronized (self)
    {
        AVPacket packet;
        av_init_packet(&packet);
        packet.data = frame->frame_data;
        packet.size = frame->frame_size;
        
        if (_frameInfoListCount > frame->frame_info.frame_index) {
            _frameInfoList[frame->frame_info.frame_index] = *frame;
        }else{
        }
        
        int got_picture;
        avcodec_decode_video2(_pCodecCtx, _pFrame, &got_picture, &packet);
        
        if (_pCodecCtx->height == 1088) {
            _pCodecCtx->height = 1080;
        }
        
        _outputWidth = _pCodecCtx->width;
        _outputHeight = _pCodecCtx->height;
        
        if (callback) {
            callback(got_picture);
        }

        av_free_packet(&packet);
    }
}

-(void) decodeVideo:(uint8_t*)buf length:(int)length callback:(void(^)(BOOL b))callback
{
    @synchronized (self)
    {
        AVPacket packet;
        av_init_packet(&packet);
        packet.data = buf;
        packet.size = length;
        
        int got_picture;
        avcodec_decode_video2(_pCodecCtx, _pFrame, &got_picture, &packet);
        
        if (_pCodecCtx->height == 1088) {
            _pCodecCtx->height = 1080;
        }
        
        _outputWidth = _pCodecCtx->width;
        _outputHeight = _pCodecCtx->height;
        
        if (callback) {
            callback(got_picture);
        }
        
        av_free_packet(&packet);
    }
}

-(int)decode:(uint8_t*)buf length:(int)length callback:(void(^)(BOOL b))callback
{
    @synchronized (self)
    {
        if(_pCodecCtx == NULL) return false;
        int paserLength_In = length;
        int paserLen;
        int decode_data_length;
        int got_picture = 0;

        uint8_t *paserBuffer_In = buf;
        while (paserLength_In > 0) {
            AVPacket packet;
            av_init_packet(&packet);
            paserLen = av_parser_parse2(_pCodecPaser, _pCodecCtx, &packet.data, &packet.size, paserBuffer_In, paserLength_In, AV_NOPTS_VALUE, AV_NOPTS_VALUE, AV_NOPTS_VALUE);
            paserLength_In -= paserLen;
            paserBuffer_In += paserLen;
            
            if (packet.size > 0) {
                if(_delegate!=nil && [_delegate respondsToSelector:@selector(processVideoData:length:)]){
                    [_delegate processVideoData:packet.data length:packet.size];
                }                
                
                decode_data_length = avcodec_decode_video2(_pCodecCtx, _pFrame, &got_picture, &packet);
            } else {
                break;
            }
            
            av_free_packet(&packet);
            
            if (_pCodecCtx->height == 1088) {
                _pCodecCtx->height = 1080;
            }
            
            if (_outputWidth != _pCodecCtx->width
                || _outputHeight != _pCodecCtx->height) {
                _outputWidth = _pCodecCtx->width;
                _outputHeight = _pCodecCtx->height;
                continue;
            }
            _outputWidth = _pCodecCtx->width;
            _outputHeight = _pCodecCtx->height;
            
            
            if(got_picture)
            {
                callback(YES);
            }
        }
    }
    return  YES;
}


-(id)initExtractor
{
    @synchronized (self) {
        _usingDJIAircraftEncoder = YES;
        [self setupExtractor];
    }
    return self;
}

-(void)setupExtractor{
    _frameRate = 0;
    _shouldVerifyVideoStream = YES;
    AVCodec *pCodec;
    if(_pFrame == NULL)
    {
        av_register_all();
        
        pCodec = avcodec_find_decoder(AV_CODEC_ID_H264);
        _pCodecCtx = avcodec_alloc_context3(pCodec);
        _pFrame = av_frame_alloc();
        _pCodecPaser = av_parser_init(AV_CODEC_ID_H264);
        if (_pCodecPaser == NULL) {
            // NSLog(@"Can't find H264 frame paser!");
        }
        _pCodecCtx->flags2|=CODEC_FLAG2_FAST;
        _pCodecCtx->thread_count = 2;
        //_pCodecCtx->thread_type = FF_THREAD_SLICE;
        _pCodecCtx->thread_type = FF_THREAD_FRAME;
        
        if(pCodec->capabilities&CODEC_FLAG_LOW_DELAY){
            //                NSLog(@"capabilities: %X,flags: %X",pCodec->capabilities,pCodecCtx->flags);
            _pCodecCtx->flags|=CODEC_FLAG_LOW_DELAY;
        }
        
        if (avcodec_open2(_pCodecCtx, pCodec, NULL)) {
            // NSLog(@"Could not open codec");
            //Could not open codec
        }
        
        _frameInfoListCount = 0;
        _frameInfoList = nil;
    }
}

-(void)freeExtractor
{
    @synchronized (self) {
        if (_pFrame) av_free(_pFrame);
        _pFrame = NULL;
        
        if (_pCodecCtx) {
            avcodec_close(_pCodecCtx);
            av_free(_pCodecCtx);
            _pCodecCtx = NULL;
        }
        if (_pCodecPaser) {
            av_parser_close(_pCodecPaser);
            av_free(_pCodecCtx);
            _pCodecPaser = NULL;
        }
        
        if (_frameInfoList) {
            free(_frameInfoList);
            _frameInfoList = nil;
            _frameInfoListCount = 0;
        }
    }
}

- (void)clearBuffer{
    [self freeExtractor];

    @synchronized (self) {
        if(_pFrame == NULL)
        {
            [self setupExtractor];
            NSLog(@"Frame Extractor Init param:%d %d %d %d %d",_pCodecCtx->ticks_per_frame,_pCodecCtx->delay,_pCodecCtx->thread_count,_pCodecCtx->thread_type,_pCodecCtx->active_thread_type);

        }
    }
}

-(uint32_t) popNextFrameUUID{
    s_frameUuidCounter++;
    if (s_frameUuidCounter == H264_FRAME_INVALIED_UUID) {
        s_frameUuidCounter++;
    }
    
    return s_frameUuidCounter;
}

-(void)dealloc {
	[self freeExtractor];
}

@end
