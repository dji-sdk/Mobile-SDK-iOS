//
//  DJIDecodeImageCalibrateDataSource.m
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIDecodeImageCalibrateDataSource.h"
//header
#import "DJILiveViewRenderDataSource_Private.h"
//buffer
#import "DJIDecodeImageCalibrateDataBuffer.h"

@interface DJIDecodeImageCalibrateDataSource(){
    CGSize _inputSize;
}
@end

@implementation DJIDecodeImageCalibrateDataSource

-(void)configOutputBuffer{
    if (outputFramebuffer == nil
        || !CGSizeEqualToSize(_inputSize, outputFramebuffer.size)){
        //do create
    }
    else{
        return;
    }
    outputFramebuffer = [[DJIDecodeImageCalibrateDataBuffer alloc] initWithContext:context
                                                                              size:_inputSize];
}

-(void) loadFrame:(VideoFrameYUV*)yuvFrame{
    if (yuvFrame != NULL){
        _inputSize = CGSizeMake(yuvFrame->width, yuvFrame->height);
    }
    [super loadFrame:yuvFrame];
}

@end
