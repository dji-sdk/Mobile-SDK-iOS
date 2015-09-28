//
//  Video.h
//  iFrameExtractor
//
//  Created by lajos on 1/10/10.
//
//  Copyright 2010 Lajos Kamocsay
//
//  lajos at codza dot com
//
//  iFrameExtractor is free software; you can redistribute it and/or
//  modify it under the terms of the GNU Lesser General Public
//  License as published by the Free Software Foundation; either
//  version 2.1 of the License, or (at your option) any later version.
// 
//  iFrameExtractor is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//  Lesser General Public License for more details.
//


#import <Foundation/Foundation.h>

#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
#import "MovieGLView.h"

@protocol VideoDataProcessDelegate <NSObject>

@optional

/**
 *  如果实现了该委托，将会在组帧后进行回调
 *
 *  @param data   数据指针
 *  @param length 长度
 */
- (void)processVideoData:(uint8_t *)data length:(int)length;
@end

/**
 *  使用前先初始化解码器
 *  
 */
@interface VideoFrameExtractor : NSObject {
//	AVFormatContext *pFormatCtx;
	AVCodecContext *_pCodecCtx; //解码
    AVFrame *_pFrame;   //帧
    AVCodecParserContext *_pCodecPaser;
    
	int _videoStream;
	int _sourceWidth, _sourceHeight;
	int _outputWidth, _outputHeight;
	double _duration;
}

@property (weak) id<VideoDataProcessDelegate> delegate;

/**
 *  初始化解码器
 *
 *  @return 解码器
 */
-(id)initExtractor;

/**
 *  清空解码器缓存
 */
- (void)clearBuffer;

/**
 *  释放解码器
 */
-(void)freeExtractor;

/**
 *  调用解码
 *
 *  @param buf      数据指针
 *  @param length   数据长度
 *  @param callback 解包后的回调
 *
 *  @return 返回解出来的帧数
 */
-(int)decode:(uint8_t*)buf length:(int)length callback:(void(^)(BOOL b))callback;

-(int)parse:(uint8_t*)buf length:(int)length callback:(void(^)(uint8_t* frame, int length))callback;

/**
 *  获取yuv Frame
 *
 *  @param yuv YuvFrame
 */
-(void)getYuvFrame:(VideoFrameYUV *)yuv;

/**
 *  从buffer中查找I帧或者SPS,PPS位置，返回指向I帧开头的指针，没找到返回NULL
 *
 *  @param
 */
-(uint8_t*) getIFrameFromBuffer:(uint8_t*)buffer length:(int)bufferSize;

@end
