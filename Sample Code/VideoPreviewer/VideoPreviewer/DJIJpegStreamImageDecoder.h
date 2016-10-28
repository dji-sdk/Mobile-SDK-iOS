//
//  DJIJpegStreamImageDecoder.h
//
//  Copyright (c) 2016 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIStreamCommon.h"

@interface DJIJpegStreamImageDecoder : NSObject <VideoStreamProcessor>
@property (nonatomic, weak) id<VideoFrameProcessor> frameProcessor;
@property (nonatomic, assign) BOOL enabled;
@end
