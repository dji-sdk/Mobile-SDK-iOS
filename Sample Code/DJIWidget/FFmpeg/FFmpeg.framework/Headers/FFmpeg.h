//
//  FFmpeg.h
//  FFmpeg
//
//  Copyright © 2018 DJI. All rights reserved.
//


#import <UIKit/UIKit.h>

//! Project version number for FFmpeg.
FOUNDATION_EXPORT double FFmpegVersionNumber;

//! Project version string for FFmpeg.
FOUNDATION_EXPORT const unsigned char FFmpegVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <FFmpeg/PublicHeader.h>

#import <Foundation/Foundation.h>

#import "libavformat/avformat.h"
#import "libswscale/swscale.h"
#import "libavcodec/avcodec.h"
#import "libavutil/avutil.h"
#import "libswresample/swresample.h"
#import "libavresample/avresample.h"
#import "libavfilter/avfilter.h"
#import "libavdevice/avdevice.h"
