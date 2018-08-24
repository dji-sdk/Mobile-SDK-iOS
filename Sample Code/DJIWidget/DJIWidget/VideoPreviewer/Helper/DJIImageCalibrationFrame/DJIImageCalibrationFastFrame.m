//
//  DJIImageCalibrationFastFrame.m
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIImageCalibrationFastFrame_Private.h"

@implementation DJIImageCalibrationFastFrame

-(void)dealloc{
    [self prepareToClean];
}

-(instancetype)initWithFastFrame:(VideoFrameYUV*)frame
                      fastUpload:(BOOL)fastUpload
                  andPixelBuffer:(DJIImageCacheQueue*)pixelCache{
    if ((self = [self init]) != nil){
        self.pixelQueue = pixelCache;
        [self loadFrame:frame
             fastUpload:fastUpload];
    }
    return self;
}

-(instancetype)init{
    if (self = [super init]){
        memset(&_internalFrame,0,sizeof(_internalFrame));
        self.nextFrame = nil;
        self.pixel = nil;
        self.cache = nil;
        self.pixelQueue = nil;
        self.cacheQueue = nil;
        self.fastUploadEnabled = NO;
        self.fastUploadType = kCVPixelFormatType_420YpCbCr8Planar;
    }
    return self;
}

-(void)loadFrame:(VideoFrameYUV*)frame
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
    memcpy([self frame],frame,sizeof(VideoFrameYUV));
    if (frame->cv_pixelbuffer_fastupload != NULL){
        CVPixelBufferRetain(frame->cv_pixelbuffer_fastupload);
    }
    else{
        [self reconstructFastUploadFrame];
    }
}

-(VideoFrameYUV*)frame{
    return &_internalFrame;
}

-(void)prepareBeforeUsing{
    //do nothing
}

-(void)prepareToClean{
    [self releaseCacheImage];
    [self releaseFrameAndCache];
}

-(void)releaseFrameAndCache{
    DJIImageCacheQueue* cacheQueue = self.cacheQueue;
    if (!cacheQueue){
        self.cache = nil;//Release
    }
    else{
        [cacheQueue push:self.cache];//Playback
    }
    DJIImageCacheQueue* pixelQueue = self.pixelQueue;
    if (!pixelQueue){
        self.pixel = nil;//Release
    }
    else{
        [pixelQueue push:self.pixel];//Playback
    }
}

-(void)releaseCacheImage{
    if (_internalFrame.cv_pixelbuffer_fastupload != NULL){
        CVPixelBufferRelease(_internalFrame.cv_pixelbuffer_fastupload);
        _internalFrame.cv_pixelbuffer_fastupload = NULL;
    }
}

#pragma mark - transform for fast-upload
-(CVPixelBufferRef)attachedPixelBuffer{
    if (!self.pixel){
        return NULL;
    }
    if (self.frame == NULL
        || self.frame->width <= 0
        || self.frame->height <= 0){
        return NULL;
    }
    CVPixelBufferRef pixbuffer = [self.pixel pixelBuffer];
    if (pixbuffer == NULL){
        return NULL;
    }
    if(kCVReturnSuccess != CVPixelBufferLockBaseAddress(pixbuffer, 0)){
        return NULL;
    }
    uint8_t* luma = (uint8_t*)CVPixelBufferGetBaseAddressOfPlane(pixbuffer, 0);
    uint8_t* chromaB = (uint8_t*)CVPixelBufferGetBaseAddressOfPlane(pixbuffer, 1);
    uint8_t* chromaR = (uint8_t*)CVPixelBufferGetBaseAddressOfPlane(pixbuffer, 2);
    
    if (!luma
        && !chromaB
        && !chromaR) {
        CVPixelBufferUnlockBaseAddress(pixbuffer, 0);
        return NULL;
    }
    
    int width = [self frame]->width;
    int height = [self frame]->height;
    int semiWidth = width / 2;
    int semiHeight = height / 2;
    
    //copy bytes
    if (self.frame->luma != NULL
        && luma != NULL){
        int copyLen = 0;
        switch ([self frame]->frameType){
            case VPFrameTypeRGBA:
                copyLen = width * height * 4;
                break;
            case VPFrameTypeYUV420Planer:
                copyLen = width * height;
                break;
            case VPFrameTypeYUV420SemiPlaner:
                copyLen = width * height;
                break;
            default:
                break;
        }
        memcpy(luma, self.frame->luma, copyLen);
    }
    if (self.frame->chromaB != NULL
        && chromaB != NULL){
        int copyLen = 0;
        switch ([self frame]->frameType){
            case VPFrameTypeRGBA:
                copyLen = 0;
                break;
            case VPFrameTypeYUV420Planer:
                copyLen = semiWidth * semiHeight;
                break;
            case VPFrameTypeYUV420SemiPlaner:
                copyLen = semiWidth * semiHeight * 2;
                break;
            default:
                break;
        }
        memcpy(chromaB, self.frame->chromaB, copyLen);
    }
    if (self.frame->chromaR != NULL
        && chromaR != NULL){
        int copyLen = 0;
        switch ([self frame]->frameType){
            case VPFrameTypeRGBA:
                copyLen = 0;
                break;
            case VPFrameTypeYUV420Planer:
                copyLen = semiWidth * semiHeight;
                break;
            case VPFrameTypeYUV420SemiPlaner:
                copyLen = 0;
                break;
            default:
                break;
        }
        memcpy(chromaR, self.frame->chromaR,copyLen);
    }
    CVPixelBufferUnlockBaseAddress(pixbuffer, 0);
    return pixbuffer;
}

-(void)reconstructFastUploadFrame{
    if (self.fastUploadEnabled){
        if (self.pixel != nil
            && self.frame != NULL
            && ![self.pixel checkFitsFrameWidth:self.frame->width
                                         height:self.frame->height
                                   andFrameType:self.fastUploadType]){
                self.pixel = nil;//release pixel
            }
        if (self.pixel == nil
            && self.frame != NULL){
            DJIImageCacheQueue* pixelQueue = self.pixelQueue;
            if (pixelQueue != nil){
                do{
                    self.pixel = [pixelQueue pull];
                    if (self.pixel == nil){//queue empty
                        break;
                    }
                    if (self.pixel != nil
                        && ![self.pixel checkFitsFrameWidth:self.frame->width
                                                     height:self.frame->height
                                               andFrameType:self.fastUploadType]){
                            self.pixel = nil;//release pixel
                        }
                } while(self.pixel == nil);
                if (self.pixel == nil){
                    self.pixel = [[DJIPixelCache alloc] initWithFrameWidth:self.frame->width
                                                                    height:self.frame->height
                                                              andFrameType:self.fastUploadType];
                }
            }
        }
        if (self.frame != NULL
            && self.pixel != nil){
            self.frame->cv_pixelbuffer_fastupload = [self attachedPixelBuffer];
            if (self.frame->cv_pixelbuffer_fastupload != NULL){
                CVPixelBufferRetain(self.frame->cv_pixelbuffer_fastupload);
            }
        }
    }
}

@end
