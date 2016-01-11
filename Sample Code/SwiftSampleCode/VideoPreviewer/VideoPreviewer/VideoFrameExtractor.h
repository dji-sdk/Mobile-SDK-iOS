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


#import "MovieGLView.h"

@protocol VideoDataProcessDelegate <NSObject>

@optional

- (void)processVideoData:(uint8_t *)data length:(int)length;
@end


@interface VideoFrameExtractor : NSObject
{    
	int _videoStream;
	int _sourceWidth, _sourceHeight;
	int _outputWidth, _outputHeight;
	double _duration;
}

@property (weak) id<VideoDataProcessDelegate> delegate;


-(id)initExtractor;


- (void)clearBuffer;


-(void)freeExtractor;


-(int)decode:(uint8_t*)buf length:(int)length callback:(void(^)(BOOL b))callback;


-(int)parse:(uint8_t*)buf length:(int)length callback:(void(^)(uint8_t* frame, int length, int frame_width, int frame_height))callback;


-(void)getYuvFrame:(VideoFrameYUV *)yuv;

@end
