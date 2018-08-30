//
//  DJIDecodeImageCalibrateDataBuffer.m
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIDecodeImageCalibrateDataBuffer.h"
#import "DJILiveViewFrameBuffer_Private.h"
#import "DJIImageCache.h"
#import "DJIImageCacheQueue.h"
#import <DJIWidget/DJIWidget.h>

@interface DJIDecodeImageCalibrateDataBuffer(){
    DJIImageCacheQueue* _pixelQueue;
}

@end

@implementation DJIDecodeImageCalibrateDataBuffer

-(id)init{
    if (self = [super init]){
        [self initData];
    }
    return self;
}

-(void)initData{
    _bufferFlag = 0;
    _pixelQueue = [[DJIImageCacheQueue alloc] initWithThreadSafe:NO];
}

-(CVPixelBufferRef)renderTarget{
    return [self privateRenderTarget];
}

- (void)requestRGBAPixelBuffer{
    [self.context useAsCurrentContext];
    if ([DJILiveViewRenderContext supportsFastTextureUpload]){
        //copy bytes
        [self lockForReading];
        GLubyte* bytes = [self byteBuffer];
        [self handlerRGBAData:bytes];
        [self unlockAfterReading];
    }
    else{
        [self activateFramebuffer];
        NSUInteger totalBytesForImage = (int)(self.size.width + 0.5) * (int)(self.size.height + 0.5) * 4;
        NSArray* cacheSizes = @[@(totalBytesForImage)];
        DJIImageCache* cache = nil;
        do{
            cache = [_pixelQueue pull];
            if (cache == nil){//queue empty
                break;
            }
            if (cache != nil
                && ![cache checkFitsSizeArray:cacheSizes]){
                cache = nil;//release pixel
            }
        } while(cache == nil);
        if (cache == nil){
            cache = [[DJIImageCache alloc] initWithCacheSizeArray:cacheSizes];
        }
        uint8_t* cacheData = [cache baseAddrForIndex:0];
        if (!cacheData) {
            [self handlerRGBAData:NULL];
            [_pixelQueue push:cache];
            return;
        }
        glReadPixels(0,
                     0,
                     (int)self.size.width,
                     (int)self.size.height,
                     GL_BGRA,
                     GL_UNSIGNED_BYTE,
                     cacheData);
        [self handlerRGBAData:cacheData];
        [_pixelQueue push:cache];
    }
}

-(uint8_t*)rgbaPixelBuffer{
    GLubyte* bytes = NULL;
    [self.context useAsCurrentContext];
    if ([DJILiveViewRenderContext supportsFastTextureUpload]){
        //copy bytes
        bytes = [self byteBuffer];
    }
    else{
        [self activateFramebuffer];
        NSUInteger totalBytesForImage = (int)(self.size.width + 0.5) * (int)(self.size.height + 0.5) * 4;
        NSArray* cacheSizes = @[@(totalBytesForImage)];
        DJIImageCache* cache = nil;
        do{
            cache = [_pixelQueue pull];
            if (cache == nil){//queue empty
                break;
            }
            if (cache != nil
                && ![cache checkFitsSizeArray:cacheSizes]){
                cache = nil;//release pixel
            }
        } while(cache == nil);
        if (cache == nil){
            cache = [[DJIImageCache alloc] initWithCacheSizeArray:cacheSizes];
        }
        uint8_t* cacheData = [cache baseAddrForIndex:0];
        if (!cacheData) {
            [_pixelQueue push:cache];
        }
        else{
            glReadPixels(0,
                         0,
                         (int)(self.size.width + 0.5),
                         (int)(self.size.height + 0.5),
                         GL_RGBA,
                         GL_UNSIGNED_BYTE,
                         cacheData);
            [_pixelQueue push:cache];
            bytes = cacheData;
        }
    }
    return bytes;
}

-(void)handlerRGBAData:(uint8_t*)data{
    if (self.dataBufferHandler != nil
        && [self.dataBufferHandler respondsToSelector:@selector(dataBuffer:arrivalRGBAData:withSize:)]){
        [self.dataBufferHandler dataBuffer:self
                           arrivalRGBAData:data
                                  withSize:self.size];
    }
}

@end
