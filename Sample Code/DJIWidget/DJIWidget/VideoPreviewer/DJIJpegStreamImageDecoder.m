//
//  DJIJpegStreamImageDecoder.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import "DJIJpegStreamImageDecoder.h"
#define RENDER_FRAME_NUMBER (1)

@interface DJIJpegStreamImageDecoder (){
    VideoFrameYUV* _renderYUVFrame[RENDER_FRAME_NUMBER];
}
@end

@implementation DJIJpegStreamImageDecoder

-(id) init{
    self = [super init];
    if (self) {
        for(int i = 0;i<RENDER_FRAME_NUMBER;i++){
            _renderYUVFrame[i] = (VideoFrameYUV *)malloc(sizeof(VideoFrameYUV));
            memset(_renderYUVFrame[i], 0, sizeof(VideoFrameYUV));
        }
    }
    return self;
}

-(void) dealloc{
    for(int i = 0;i<RENDER_FRAME_NUMBER;i++){
        if (_renderYUVFrame[i]) {
            if (_renderYUVFrame[i]->luma) {
                free(_renderYUVFrame[i]->luma);
                _renderYUVFrame[i]->luma = nil;
            }
            free(_renderYUVFrame[i]);
            _renderYUVFrame[i] = NULL;
        }
    }
}

-(BOOL) streamProcessorHandleFrameRaw:(VideoFrameH264Raw *)frame{
    if (!frame
        || frame->frame_size == 0
        || frame->type_tag != TYPE_TAG_VideoFrameJPEG) {
        return NO;
    }

    // The decoding of JPEG can be optimized later.
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(nil, frame->frame_data, frame->frame_size, nil);
    CGImageRef cgimage = CGImageCreateWithJPEGDataProvider(dataProvider, NULL, NO, kCGRenderingIntentDefault);
    if (!cgimage) {
        return NO;
    }
    
    size_t width  = CGImageGetWidth(cgimage);
    size_t height = CGImageGetHeight(cgimage);
    
    size_t bpp = CGImageGetBitsPerPixel(cgimage);
    size_t bpc = CGImageGetBitsPerComponent(cgimage);
    size_t bytes_per_pixel = bpp / bpc;
    
    if (bytes_per_pixel != 4) {
        CFRelease(cgimage);
        return NO;
    }
    
    VideoFrameYUV* output = _renderYUVFrame[0];
    if (output->width != width
        || output->height != height) {
        if (output->luma) {
            free(output->luma);
            output->luma = nil;
        }
        
        output->width = (int)width;
        output->height = (int)height;
        output->luma = malloc(width*height*4);
    }
    
    if (output->luma) {
        //cpy data
        CGDataProviderRef provider = CGImageGetDataProvider(cgimage);
        CFDataRef data = CGDataProviderCopyData(provider);
        
        if (data) {
            CFDataGetBytes(data, CFRangeMake(0, MIN(CFDataGetLength(data), width*height*4)), output->luma);
            CFRelease(data);
        }
    }
    
    output->frameType = VPFrameTypeRGBA;
    CFRelease(cgimage);
    [_frameProcessor videoProcessFrame:output];
    return YES;
}

-(void) streamProcessorInfoChanged:(DJIVideoStreamBasicInfo *)info{
    //do nothing
}

-(DJIVideoStreamProcessorType) streamProcessorType{
    return DJIVideoStreamProcessorType_Decoder;
}

-(BOOL) streamProcessorEnabled{
    return self.enabled;
}


@end
