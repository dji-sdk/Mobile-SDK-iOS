//
//  SoftwareDecodeProcessor.h
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIStreamCommon.h"
#import "DJICustomVideoFrameExtractor.h"

@interface SoftwareDecodeProcessor : NSObject <VideoStreamProcessor>
@property (nonatomic, weak) id<VideoFrameProcessor> frameProcessor;
@property (nonatomic, assign) BOOL enabled;

-(id) initWithExtractor:(DJICustomVideoFrameExtractor*)extractor;
@end
