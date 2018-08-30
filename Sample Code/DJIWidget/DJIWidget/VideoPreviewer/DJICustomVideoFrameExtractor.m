//
//  DJICustomVideoFrameExtractor.m
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import "DJICustomVideoFrameExtractor.h"
#import "DJIVideoHelper.h"
#import <sys/time.h>
#import <pthread.h>

#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
#include "libavcodec/avcodec.h"


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

@interface DJICustomVideoFrameExtractor() {
		pthread_mutex_t _frameMutex; //mutex for pframe object
		pthread_mutex_t _codecMutex; //mutex for codec ctx and parser object
	
		AVFrame *_pFrame;   //frame
		AVCodecContext *_pCodecCtx; //decode
		AVCodecParserContext *_pCodecPaser;
		VideoFrameH264Raw* _frameInfoList;
}

@property(nonatomic, readwrite) int frameRate;
@property(nonatomic, readwrite) int outputWidth;
@property(nonatomic, readwrite) int outputHeight;
@property(nonatomic, readwrite) double duration;

@property(nonatomic) int sourceWidth;
@property(nonatomic) int sourceHeight;
@property(nonatomic) int codecInitited;
@property(nonatomic) int frameInfoListCount;
@property(nonatomic) uint32_t frameUuidCounter;

@end

@implementation DJICustomVideoFrameExtractor

#pragma mark - Life Cycle

- (instancetype)init {
	self = [self initExtractor];
	return self;
}

- (instancetype)initExtractor {
	self = [super init];
	
	_usingDJIAircraftEncoder = YES;
	pthread_mutex_init(&_frameMutex, nil);
	pthread_mutex_init(&_codecMutex, nil);
	[self setupExtractor];
	return self;
}

- (void)setupExtractor {
	
	_frameRate = 0;
	_shouldVerifyVideoStream = YES;
	
	AVCodec *pCodec;
	
	pthread_mutex_lock(&_frameMutex);
	if(_pFrame == NULL){
		_pFrame = av_frame_alloc();
	}
	pthread_mutex_unlock(&_frameMutex);
	
	pthread_mutex_lock(&_codecMutex);
	if(_codecInitited == NO){
		av_register_all();
		
		pCodec = avcodec_find_decoder(AV_CODEC_ID_H264);
		_pCodecCtx = avcodec_alloc_context3(pCodec);
		_pCodecPaser = av_parser_init(AV_CODEC_ID_H264);
		if (_pCodecPaser == NULL) {
			// NSLog(@"Can't find H264 frame paser!");
		}
		_pCodecCtx->flags2|=CODEC_FLAG2_FAST;
		_pCodecCtx->thread_count = 2;
		//_pCodecCtx->thread_type = FF_THREAD_SLICE;
		_pCodecCtx->thread_type = FF_THREAD_FRAME;
		
		if(pCodec->capabilities&CODEC_FLAG_LOW_DELAY){
			_pCodecCtx->flags|=CODEC_FLAG_LOW_DELAY;
		}
		
		if (avcodec_open2(_pCodecCtx, pCodec, NULL)) {
			// NSLog(@"Could not open codec");
			//Could not open codec
		}
		
		_frameInfoListCount = 0;
		_frameInfoList = nil;
		NSLog(@"Frame Extractor Init param:%d %d %d %d %d",_pCodecCtx->ticks_per_frame,_pCodecCtx->delay,_pCodecCtx->thread_count,_pCodecCtx->thread_type,_pCodecCtx->active_thread_type);
		_codecInitited = YES;
	}
	pthread_mutex_unlock(&_codecMutex);
}

- (void)freeExtractor {
	pthread_mutex_lock(&_frameMutex);
	if (_pFrame){
		av_free(_pFrame);
	}
	_pFrame = NULL;
	pthread_mutex_unlock(&_frameMutex);
	
	pthread_mutex_lock(&_codecMutex);
	if(_codecInitited == YES){
		
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
		
		_codecInitited = NO;
	}
	pthread_mutex_unlock(&_codecMutex);
}

- (void)clearExtractorBuffer {
	[self freeExtractor];
	[self setupExtractor];
}

- (void)dealloc {
	[self freeExtractor];
	
	pthread_mutex_destroy(&_frameMutex);
	pthread_mutex_destroy(&_codecMutex);
}

#pragma mark Parse Video

-(void)getYuvFrame:(VideoFrameYUV *)yuv {
	pthread_mutex_lock(&_frameMutex);
	do{
		if(!_pFrame) break ;
		
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
	}while (false);
	pthread_mutex_unlock(&_frameMutex);
}

#undef _CP_YUV_FRAME_

-(void) privateParseVideo:(uint8_t*)buf length:(int)length withOutputBlock:(void (^)(AVPacket* frame))block
{
	// Need padding for FFMpeg. Otherwise Address Sanitizer will complain heap overflow.
	size_t lengthWithPadding = length + FF_INPUT_BUFFER_PADDING_SIZE;
	uint8_t *bufWithPadding = malloc(lengthWithPadding);
	memset(bufWithPadding, 0, lengthWithPadding);
	memcpy(bufWithPadding, buf, length);
	
	uint8_t *paserBuffer_In = bufWithPadding;
	int paserLength_In = (int)length;
	int paserLen = 0;
	//Number of frames to call back after getting the frame information
	NSUInteger callbackCount = 0;
	//Number of successful framing
	NSUInteger packetFoundCount = 0;
	
	while (paserLength_In > 0) {
		BOOL shouldDoCallback = NO;
		AVPacket packet;
		av_init_packet(&packet);
		pthread_mutex_lock(&_codecMutex);
		do{
			if (_pCodecCtx == NULL
				|| _pCodecPaser == NULL) {
				break;
			}
			
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
			
			if (packet.size <= 0) {
				break;
			}
			packetFoundCount++;
			
			//Workaround
			if(_pCodecPaser->height_in_pixel == 1088){
				//1080p hack
				_pCodecPaser->height_in_pixel = 1080;
			}
			
			//Workaround
			BOOL isNeedFitFrameWidth = NO;
			if (self.delegate && [self.delegate respondsToSelector:@selector(isNeedFitFrameWidth)]) {
				isNeedFitFrameWidth = [self.delegate isNeedFitFrameWidth];
			}
			
			if (_pCodecPaser->width_in_pixel == 1088
				&& isNeedFitFrameWidth) {
				_pCodecPaser->width_in_pixel = 1080;
			}
			
			bool isSpsPpsFound = false;
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
					break;
				}
			}
			
			if (!_shouldVerifyVideoStream){
				//need do callback for this frame
				shouldDoCallback = YES;
			}
		}while(false);
		pthread_mutex_unlock(&_codecMutex);
		
		if(shouldDoCallback){
			callbackCount++;
			if (block != nil){
				block(&packet);
			}
		}
		
		av_free_packet(&packet);
	}
	
	if (callbackCount == 0 && packetFoundCount > 0) {
		if (self.delegate && [self.delegate respondsToSelector:@selector(frameExtractorDidFailToParseFrames:)]) {
			[self.delegate frameExtractorDidFailToParseFrames:self];
		}
	}
	
	if (bufWithPadding){
		free(bufWithPadding);
	}
}


-(void) parseVideo:(uint8_t *)buf length:(int)length withFrame:(void (^)(VideoFrameH264Raw *))block{
	
	[self privateParseVideo:buf length:length withOutputBlock:^(AVPacket* frame) {
		if (!block
			|| !frame
			|| !frame->data) {
			return;
		}
		int frameSize = frame->size;
		
		VideoFrameH264Raw* outputFrame = (VideoFrameH264Raw*)malloc(sizeof(VideoFrameH264Raw) + frameSize);
		outputFrame->type_tag = TYPE_TAG_VideoFrameH264Raw;
		memset(outputFrame, 0, sizeof(VideoFrameH264Raw));
		memcpy(outputFrame+1, frame->data, frameSize);
		
		[self popNextFrameUUID];
		
		outputFrame->frame_uuid = _frameUuidCounter;
		outputFrame->frame_size = frame->size;
		
		BOOL shouldCallback = YES;
		if (self.delegate && [self.delegate respondsToSelector:@selector(parseDecodingAssistInfoWithBuffer:length:assistInfo:)]) {
			DJIDecodingAssistInfo assistInfo = {0};
			shouldCallback = [self.delegate parseDecodingAssistInfoWithBuffer:frame->data length:frame->size assistInfo:&assistInfo];
			memcpy(&outputFrame->frame_info.assistInfo, &assistInfo, sizeof(DJIDecodingAssistInfo));
		}
		
		pthread_mutex_lock(&_codecMutex);
		
		if(_pCodecPaser){ //patch by amanda
			
			outputFrame->frame_info.frame_index = _pCodecPaser->frame_num;
			outputFrame->frame_info.max_frame_index_plus_one = _pCodecPaser->max_frame_num_plus1;
			
			if (outputFrame->frame_info.frame_index >= outputFrame->frame_info.max_frame_index_plus_one) {
				// something wrong;
			}
			
			//Workaround:The actual picture is 1080P, but the parsing is 1088P, and the decoder will automatically cut to 1080P, so you need to ensure the correct resolution first.
			if(_pCodecPaser->height_in_pixel == 1088){
				//1080p hack
				_pCodecPaser->height_in_pixel = 1080;
			}
			
			BOOL isNeedFitFrameWidth = NO;
			if (self.delegate && [self.delegate respondsToSelector:@selector(isNeedFitFrameWidth)]) {
				isNeedFitFrameWidth = [self.delegate isNeedFitFrameWidth];
			}
			if (_pCodecPaser->width_in_pixel == 1088 &&
				isNeedFitFrameWidth) {
				_pCodecPaser->width_in_pixel = 1080;
			}
			
			outputFrame->frame_info.width = _pCodecPaser->width_in_pixel;
			outputFrame->frame_info.height = _pCodecPaser->height_in_pixel;
			
			if (_pCodecPaser->frame_rate_den) {
				// If the stream is encoded by DJI's encoder, the frame rate
				// should be double of the value from the parser.
				double scale = _usingDJIAircraftEncoder?2.0:1.0;
				outputFrame->frame_info.fps = ceil(_pCodecPaser->frame_rate_num/(scale*_pCodecPaser->frame_rate_den));
			}
			//Workaround: In the pigeon scheme, the sky-end image transmission mode selects the smooth mode,
			//there will be 60fps code stream, in order to avoid additional overhead, in this case enable force_30_fps, guaranteed to only render to 30fps, and full frame encoding is also used 30fps
			if (outputFrame->frame_info.assistInfo.force_30_fps != 0){
				outputFrame->frame_info.fps = 30;//强制30fps
				_frameRate = 30;
			}
			
			outputFrame->frame_info.frame_poc = _pCodecPaser->output_picture_number;
			outputFrame->frame_info.frame_flag.has_sps = _pCodecPaser->frame_has_sps;
			outputFrame->frame_info.frame_flag.has_pps = _pCodecPaser->frame_has_pps;
			outputFrame->frame_info.frame_flag.has_idr = (_pCodecPaser->key_frame ==1)?1:0;
			outputFrame->frame_info.frame_flag.is_fullrange = NO; //we can only get this in sps, set this bit later
		}
		pthread_mutex_unlock(&_codecMutex);
		
		if (shouldCallback
			&& block != nil
			&& outputFrame != NULL){
			block(outputFrame);
			return;
		}
		if (outputFrame != NULL){
			free(outputFrame);
			outputFrame = NULL;
		}
	}];
}

-(void) decodeRawFrame:(VideoFrameH264Raw*)frame callback:(void(^)(BOOL b))callback{
	if (!frame) {
		if (callback) {
			callback(NO);
		}
		
		return;
	}
	
	AVPacket packet;
	av_init_packet(&packet);
	packet.data = frame->frame_data;
	packet.size = frame->frame_size;
	
	pthread_mutex_lock(&_codecMutex);
	
	if (_frameInfoListCount > frame->frame_info.frame_index) {
		_frameInfoList[frame->frame_info.frame_index] = *frame;
	}else{
	}
	
	int got_picture;
	pthread_mutex_lock(&_frameMutex);
	avcodec_decode_video2(_pCodecCtx, _pFrame, &got_picture, &packet);
	pthread_mutex_unlock(&_frameMutex);
	//Workaround:The actual picture is 1080P, but the parsing is 1088P, and the decoder will automatically cut to 1080P, so you need to ensure the correct resolution first.

	if (_pCodecCtx->height == 1088) {
		_pCodecCtx->height = 1080;
	}
	
	if (_pCodecCtx->width == 1088) {
		_pCodecCtx->width = 1080;
	}
	
	_outputWidth = _pCodecCtx->width;
	_outputHeight = _pCodecCtx->height;
	
	pthread_mutex_unlock(&_codecMutex);
	
	if (callback) {
		callback(got_picture);
	}
	av_free_packet(&packet);
}

-(uint32_t) popNextFrameUUID {
	_frameUuidCounter++;
	if (_frameUuidCounter == H264_FRAME_INVALIED_UUID) {
		_frameUuidCounter++;
	}
	
	return _frameUuidCounter;
}

@end
