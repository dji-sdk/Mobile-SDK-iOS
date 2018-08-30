//
//  DJIJpegStreamImageDecoder.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJIStreamCommon.h"

@interface DJIJpegStreamImageDecoder : NSObject <VideoStreamProcessor>
@property (nonatomic, weak) id<VideoFrameProcessor> frameProcessor;
@property (nonatomic, assign) BOOL enabled;
@end
