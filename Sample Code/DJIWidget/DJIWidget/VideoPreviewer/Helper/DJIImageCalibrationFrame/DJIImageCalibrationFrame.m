//
//  DJIImageCalibrationFrame.m
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "DJIImageCalibrationFrame.h"
#import "DJIImageCalibrationFastFrame_Private.h"
#import "DJIPixelCache.h"
#import "DJIImageCache.h"

@interface DJIImageCalibrationFrame(){
    //cache size indexed, count = 3 in current case
    NSArray* _cacheSizes;
}

@end

@implementation DJIImageCalibrationFrame

-(instancetype)initWithFrame:(VideoFrameYUV*)frame
                  fastUpload:(BOOL)fastUpload
             pixelCacheQueue:(DJIImageCacheQueue*)pixelQueue
            andMemCacheQueue:(DJIImageCacheQueue*)cacheQueue{
    if (self = [self init]){
        self.pixelQueue = pixelQueue;
        self.cacheQueue = cacheQueue;
        [self loadFrame:frame
             fastUpload:fastUpload];
    }
    return self;
}

-(void)loadFrame:(VideoFrameYUV *)frame
      fastUpload:(BOOL)fastUpload{
    [self prepareToClean];
    CGSize frameSize = CGSizeZero;
    VPFrameType frameType = VPFrameTypeYUV420Planer;
    if (frame != NULL){
        frameSize = CGSizeMake(frame->width, frame->height);
        frameType = frame->frameType;
        if (frame->cv_pixelbuffer_fastupload != NULL){
            self.fastUploadEnabled = YES;
            self.fastUploadType = CVPixelBufferGetPixelFormatType(frame->cv_pixelbuffer_fastupload);
        }
        else if (fastUpload){
            switch (frameType) {
                case VPFrameTypeYUV420Planer:
                    self.fastUploadEnabled = YES;
                    self.fastUploadType = kCVPixelFormatType_420YpCbCr8Planar;
                    break;
                case VPFrameTypeYUV420SemiPlaner:
                    self.fastUploadEnabled = YES;
                    self.fastUploadType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
                    break;
                default:
                    self.fastUploadEnabled = NO;
                    self.fastUploadType = kCVPixelFormatType_420YpCbCr8Planar;
                    break;
            }
        }
        else{
            self.fastUploadEnabled = NO;
            self.fastUploadType = kCVPixelFormatType_420YpCbCr8Planar;
        }
    }
    [self cacheInitWithFrameSize:frameSize
                    andFrameType:frameType];
    if (self.cache != nil){
        if (self.frame != NULL
            && frame != NULL){
            memcpy(self.frame,frame,sizeof(VideoFrameYUV));
            self.frame->luma = [self.cache baseAddrForIndex:0];
            self.frame->chromaB = [self.cache baseAddrForIndex:1];
            self.frame->chromaR = [self.cache baseAddrForIndex:2];
            self.frame->cv_pixelbuffer_fastupload = NULL;
            //copy luma
            if (self.frame->luma != NULL
                && frame->luma != NULL){
                NSNumber* size = _cacheSizes[0];
                memcpy(self.frame->luma,frame->luma,size.unsignedIntegerValue);
            }
            //copy chromaB
            if (self.frame->chromaB != NULL
                && frame->chromaB != NULL){
                NSNumber* size = _cacheSizes[1];
                memcpy(self.frame->chromaB,frame->chromaB,size.unsignedIntegerValue);
            }
            //copy chromaR
            if (self.frame->chromaR != NULL
                && frame->chromaR != NULL){
                NSNumber* size = _cacheSizes[2];
                memcpy(self.frame->chromaR,frame->chromaR,size.unsignedIntegerValue);
            }
        }
    }
}

-(void)cacheInitWithFrameSize:(CGSize)frameSize
                 andFrameType:(VPFrameType)frameType{
    int semiWidth = frameSize.width / 2;
    int semiHeight = frameSize.height / 2;
    switch (frameType){
        case VPFrameTypeRGBA:{
            _cacheSizes = @[
                            @(frameSize.width * frameSize.height * 4),//luma
                            @(0),//chromaB
                            @(0),//chromaR
                            ];
        }
            break;
        case VPFrameTypeYUV420Planer:{
            _cacheSizes = @[
                            @(frameSize.width * frameSize.height),//luma
                            @(semiWidth * semiHeight),//chromaB
                            @(semiWidth * semiHeight),//chromaR
                            ];
        }
            break;
        case VPFrameTypeYUV420SemiPlaner:{
            _cacheSizes = @[
                            @(frameSize.width * frameSize.height),//luma
                            @(frameSize.width * semiHeight),//chromaB
                            @(0),//chromaR
                            ];
        }
            break;
        default:{
            _cacheSizes = nil;
        }
            break;
    }
    if (_cacheSizes == nil){
        return;
    }
    DJIImageCacheQueue* cacheQueue = self.cacheQueue;
    if (cacheQueue != nil){
        do{
            self.cache = [cacheQueue pull];
            if (self.cache == nil){//queue empty
                break;
            }
            if (self.cache != nil
                && ![self.cache checkFitsSizeArray:_cacheSizes]){
                self.cache = nil;//release cache
            }
        } while(self.cache == nil);
        if (self.cache == nil){
            self.cache = [[DJIImageCache alloc] initWithCacheSizeArray:_cacheSizes];
        }
    }
}

-(instancetype)init{
    if (self = [super init]){
        _cacheSizes = nil;
    }
    return self;
}

-(void)prepareBeforeUsing{
    [super prepareBeforeUsing];
    if (self.fastUploadEnabled){
        [self reconstructFastUploadFrame];
    }
}

@end
