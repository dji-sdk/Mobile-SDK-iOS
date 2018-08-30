//
//  DJIImageCalibrateColorCPUConverter.m
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIImageCalibrateColorCPUConverter.h"
#import "DJIImageCalibrateColorConverter_Private.h"
//header
#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
//cache
#import "DJIImageCache.h"
//frame
#import "DJIDecodeImageCalibrateDataBuffer.h"

@interface DJIImageCalibrateColorCPUConverter()<DJIDecodeImageCalibrateDataBufferHandlerDelegate>{
    struct SwsContext* _pSwsContext;
    CGSize _inputSize;
    uint8_t* _yuvData[4];
    int _yuvSlice[4];
    NSArray* _cacheSizes;
    DJIImageCache* _cache;
}

@end

@implementation DJIImageCalibrateColorCPUConverter

-(void)dealloc{
    if (_pSwsContext != NULL){
        sws_freeContext(_pSwsContext);
        _pSwsContext = NULL;
    }
}

-(instancetype)init{
    if (self = [super init]){
        [self initData];
    }
    return self;
}

-(void)initData{
    _pSwsContext = NULL;
    _inputSize = CGSizeZero;
    _cacheSizes = nil;
    _cache = nil;
}

-(int)alignmentWithSlice:(int)slice{
    return (((slice + 3) >> 2) << 2);
}

-(void)resetDataAndSlice{
    if (_inputSize.width > 1.0e-6
        && _inputSize.height > 1.0e-6
        && _cacheSizes == nil){
        int width = (int)(_inputSize.width + 0.5);
        int height = (int)(_inputSize.height + 0.5);
        int semiWidth = width / 2;
        int semiHeight = height / 2;
        switch (self.type){
            case VPFrameTypeRGBA:{
                _cacheSizes = @[
                                @([self alignmentWithSlice:width * 4] * height),
                                @(0),
                                @(0),
                                @(0),
                                ];
                _yuvSlice[0] = [self alignmentWithSlice:width * 4];
                _yuvSlice[1] = 0;
                _yuvSlice[2] = 0;
                _yuvSlice[3] = 0;
            }
                break;
            case VPFrameTypeYUV420Planer:{
                _cacheSizes = @[
                                @([self alignmentWithSlice:width] * height),
                                @([self alignmentWithSlice:semiWidth] * semiHeight),
                                @([self alignmentWithSlice:semiWidth] * semiHeight),
                                @(0),
                                ];
                _yuvSlice[0] = [self alignmentWithSlice:width];
                _yuvSlice[1] = [self alignmentWithSlice:semiWidth];
                _yuvSlice[2] = [self alignmentWithSlice:semiWidth];
                _yuvSlice[3] = 0;
            }
                break;
            case VPFrameTypeYUV420SemiPlaner:{
                _cacheSizes = @[
                                @([self alignmentWithSlice:width] * height),
                                @([self alignmentWithSlice:semiWidth * 2] * semiHeight),
                                @(0),
                                @(0),
                                ];
                _yuvSlice[0] = [self alignmentWithSlice:width];
                _yuvSlice[1] = [self alignmentWithSlice:semiWidth * 2];
                _yuvSlice[2] = 0;
                _yuvSlice[3] = 0;
            }
                break;
            default:{
                _cacheSizes = @[
                                @(0),
                                @(0),
                                @(0),
                                @(0),
                                ];
                _yuvSlice[0] = 0;
                _yuvSlice[1] = 0;
                _yuvSlice[2] = 0;
                _yuvSlice[3] = 0;
            }
                break;
        }
    }
    if (_cache != nil
        && ![_cache checkFitsSizeArray:_cacheSizes]){
        _cache = nil;
    }
    if (!_cache){
        _cache = [[DJIImageCache alloc] initWithCacheSizeArray:_cacheSizes];
    }
    for (int i = 0; i < sizeof(_yuvData)/sizeof(_yuvData[0]); i++){
        _yuvData[i] = [_cache baseAddrForIndex:i];
    }
}

-(void)convertFromRGBA:(uint8_t*)rgba
              withSize:(CGSize)size{
    
    int width = (int)(size.width + 0.5);
    int height = (int)(size.height + 0.5);
    if (width <= 0
        || height <= 0){
        [self handlerYUVData:NULL
                 andYUVSlice:NULL
              withFastUpload:NULL];
        return;
    }
    if (!CGSizeEqualToSize(_inputSize,size)){
        if (_pSwsContext != NULL){
            sws_freeContext(_pSwsContext);
            _pSwsContext = NULL;
        }
        _inputSize = size;
        _cacheSizes = nil;
    }
    if (_pSwsContext == NULL){
        _pSwsContext = sws_getContext(width,
                                      height,
                                      PIX_FMT_RGBA,
                                      width,
                                      height,
                                      [self outputFormat],
                                      SWS_FAST_BILINEAR,
                                      NULL,
                                      NULL,
                                      NULL);
    }
    
    if (NULL == _pSwsContext){
        [self handlerYUVData:NULL
                 andYUVSlice:NULL
              withFastUpload:NULL];
        return;
    }
    
    [self resetDataAndSlice];
    int inLineSize[] = {4 * width,0,0,0};
    const uint8_t* rgbaData[] = {rgba,NULL,NULL,NULL};
    //FIXED ME:Need to optimize, this conversion will take up a higher CPU, please be cautious
    int outHeight = sws_scale(_pSwsContext,
                              rgbaData,
                              inLineSize,
                              0,
                              height,
                              _yuvData,
                              _yuvSlice);
    if (outHeight <= 0){
        [self handlerYUVData:NULL
                 andYUVSlice:NULL
              withFastUpload:NULL];
        return;
    }
    //done
    [self handlerYUVData:_yuvData
             andYUVSlice:_yuvSlice
          withFastUpload:NULL];
}

-(enum AVPixelFormat)outputFormat{
    switch (self.type){
        case VPFrameTypeYUV420Planer:{
            return PIX_FMT_YUV420P;
        }
        case VPFrameTypeYUV420SemiPlaner:{
            return PIX_FMT_NV12;
        }
        default:
            break;
    }
    return PIX_FMT_RGBA;
}

#pragma mark - override
- (void)setColorConverterInputFramebuffer:(DJILiveViewFrameBuffer *)newInputFramebuffer
                                  atIndex:(NSInteger)textureIndex{
    if ([newInputFramebuffer isKindOfClass:[DJIDecodeImageCalibrateDataBuffer class]]){
        DJIDecodeImageCalibrateDataBuffer* dataBuffer = (DJIDecodeImageCalibrateDataBuffer*)newInputFramebuffer;
        if (dataBuffer.dataBufferHandler != self){
            dataBuffer.dataBufferHandler = self;
        }
        [dataBuffer requestRGBAPixelBuffer];
    }
}

#pragma mark - data buffer
-(void)dataBuffer:(DJIDecodeImageCalibrateDataBuffer*)dataBuffer
  arrivalRGBAData:(uint8_t*)rgbaData
         withSize:(CGSize)size{
    if (rgbaData == NULL
        || size.width < 1.0e-3
        || size.height < 1.0e-3){
        return;
    }
    [self updateNewFrameWithPixelData:rgbaData
                             withSize:size];
}

-(void)updateNewFrameWithPixelData:(uint8_t*)pixelData
                          withSize:(CGSize)size{
    if (pixelData == NULL
        || size.width < 1.0e-3
        || size.height < 1.0e-3){
        return;
    }
    [self convertFromRGBA:pixelData
                 withSize:size];
}

@end
