//
//  DJIVideoPreviewerH264Parser.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import "DJIVideoPreviewerH264Parser.h"
#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
#import "DJICustomVideoFrameExtractor.h"

@interface DJIVideoPreviewerH264Parser (){
    AVCodecContext *_pCodecCtx; //decode
    AVCodecParserContext *_pCodecPaser;
}
@property (nonatomic, strong) NSLock* parserLock;
@property (nonatomic, assign) uint32_t frameCounter;
@property (nonatomic, assign) uint32_t frameUuidCounter;
@end

@implementation DJIVideoPreviewerH264Parser

-(id) init{
    if(self = [super init]){
        self.parserLock = [[NSLock alloc] init];
        [self initParser];
    }
    return self;
}

-(void) dealloc{
    [self freeParser];
}

-(void) reset{
    if (_pCodecCtx) {
        [self freeParser];
    }
    
    [self initParser];
}

#pragma mark - parset work

-(void) initParser{
    [_parserLock lock];
    
    _frameRate = 0;
    _frameInterval = 0;
    _frameCounter = 0;
    _outputWidth = 0;
    _outputHeight = 0;
    
    //create parser
    av_register_all();
    AVCodec *pCodec = avcodec_find_decoder(AV_CODEC_ID_H264);
    _pCodecCtx = avcodec_alloc_context3(pCodec);
    _pCodecPaser = av_parser_init(AV_CODEC_ID_H264);
    
    [_parserLock unlock];
}

-(void) freeParser{
    [_parserLock lock];
        
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
    
    [_parserLock unlock];
}



-(VideoFrameH264Raw*) parseVideo:(uint8_t*)buf
                          length:(int)length
                      usedLength:(int*)usedLength
{
    
    if(_pCodecCtx == NULL){
        if (usedLength) {
            *usedLength = 0;
        }
        return nil;
    }
    
    [_parserLock lock];
    
    int paserLength_In = length;
    int paserLen = 0;
    if (usedLength) {
        *usedLength = 0;
    }
    
    VideoFrameH264Raw* outputFrame = nil;
    uint8_t *paserBuffer_In = buf;
    while (paserLength_In > 0)
    {
        AVPacket packet;
        av_init_packet(&packet);
        paserLen = av_parser_parse2(_pCodecPaser,
                                    _pCodecCtx,
                                    &packet.data,
                                    &packet.size,
                                    paserBuffer_In,
                                    paserLength_In,
                                    AV_NOPTS_VALUE,
                                    AV_NOPTS_VALUE,
                                    AV_NOPTS_VALUE);
        
        paserLength_In -= paserLen;
        paserBuffer_In += paserLen;
        if (usedLength) {
            *usedLength += paserLen;
        }
        
        if (packet.size > 0) {
            
            //generate frame
            
            bool isSpsPpsFound = false;
            if(_pCodecPaser->height_in_pixel == 1088) {
                //1080p workaround
                _pCodecPaser->height_in_pixel = 1080;
            }
            
            _outputWidth = _pCodecPaser->width_in_pixel;
            _outputHeight = _pCodecPaser->height_in_pixel;
            isSpsPpsFound = _pCodecPaser->frame_has_sps?YES:NO;
            
            int rate = 0;
            if (_pCodecPaser->frame_rate_den && _pCodecPaser->frame_rate_num)
            {
                // If the stream is encoded by DJI's encoder, the frame rate
                // should be double of the value from the parser.
                double scale = _usingDJIAircraftEncoder?2.0:1.0;
                rate = ceil(_pCodecPaser->frame_rate_num/(scale*_pCodecPaser->frame_rate_den));
                
                _frameInterval = scale*_pCodecPaser->frame_rate_den/_pCodecPaser->frame_rate_num;
                _frameRate = rate;
            }
            
            else{
                _frameRate = 0; //unknown
                _frameInterval = 0;
            }
            
            
            if (_shouldVerifyVideoStream) {
                if (isSpsPpsFound) {
                    _shouldVerifyVideoStream = NO;
                }
                else{
                    continue;
                }
            }
            
            
            
            outputFrame = (VideoFrameH264Raw*)malloc(sizeof(VideoFrameH264Raw) + packet.size);
            outputFrame->type_tag = TYPE_TAG_VideoFrameH264Raw;
            memset(outputFrame, 0, sizeof(VideoFrameH264Raw));
            memcpy(outputFrame+1, packet.data, packet.size);
            
            [self popNextFrameUUID];
            
            outputFrame->frame_uuid = _frameUuidCounter;
            outputFrame->frame_size = packet.size;
            /*
            [VideoFrameExtractor setupSeiInfoWithFramebuffr:packet.data
                                                     length:packet.size
                                             lastFrameIndex:0
                                                outputFrame:outputFrame];
             */
            { //patch by amanda
                outputFrame->frame_info.frame_index = _pCodecPaser->frame_num;
                outputFrame->frame_info.max_frame_index_plus_one = _pCodecPaser->max_frame_num_plus1;
                
                if (outputFrame->frame_info.frame_index
                    >= outputFrame->frame_info.max_frame_index_plus_one)
                {
                    // something wrong;
                }
                
                if(_pCodecPaser->height_in_pixel == 1088) {
                    //1080p workaround
                    _pCodecPaser->height_in_pixel = 1080;
                }
                
                outputFrame->frame_info.frame_poc = _pCodecPaser->output_picture_number;
                outputFrame->frame_info.width = _pCodecPaser->width_in_pixel;
                outputFrame->frame_info.height = _pCodecPaser->height_in_pixel;
                outputFrame->frame_info.fps = _frameRate;
                outputFrame->frame_info.frame_flag.has_sps = _pCodecPaser->frame_has_sps;
                outputFrame->frame_info.frame_flag.has_pps = _pCodecPaser->frame_has_pps;
                outputFrame->frame_info.frame_flag.has_idr = (_pCodecPaser->key_frame ==1)?1:0;
                outputFrame->frame_info.frame_flag.is_fullrange = NO; //we can only get this in sps, set this bit later
            }
            
        }
        
        av_free_packet(&packet);
        if (outputFrame != nil) {
            //we have output
            break;
        }
    }
    
    if(outputFrame){
        _frameCounter++;
    }
    [_parserLock unlock];
    return outputFrame;
}

-(uint32_t) popNextFrameUUID{
    _frameUuidCounter++;
    if (_frameUuidCounter == H264_FRAME_INVALIED_UUID) {
        _frameUuidCounter++;
    }
    
    return _frameUuidCounter;
}

@end
