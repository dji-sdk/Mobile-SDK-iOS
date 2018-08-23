//
//  DJICalibratePixelBufferProvider.m
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import "DJICalibratePixelBufferProvider.h"
#import <pthread.h>

@interface DJICalibratePixelBufferProvider () {
    VideoFrameH264BasicInfo* _updatedFrameInfo;
    pthread_mutex_t _lock;
}

@end

@implementation DJICalibratePixelBufferProvider

- (instancetype)init {
    self = [super init];
    if (self) {
        self.providerEnabled = NO;
        _updatedFrameInfo = malloc(sizeof(VideoFrameH264BasicInfo));
        pthread_mutex_init(&_lock, NULL);
    }
    return self;
}

- (void)dealloc {
    if (_updatedFrameInfo) {
        free(_updatedFrameInfo);
    }
    pthread_mutex_destroy(&_lock);
}

- (BOOL)enabled {
    return self.providerEnabled;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex {
    // do nothing ..
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    // do nothing ..
}

- (void)endProcessing {
    // do nothing ..
}

- (void)updateFrameInfoWithFrameYUV:(VideoFrameYUV *)frame {
    if (frame) {
        pthread_mutex_lock(&_lock);
        memcpy(_updatedFrameInfo, &frame->frame_info, sizeof(VideoFrameH264BasicInfo));
        pthread_mutex_unlock(&_lock);
    }
}

- (void)setInputFramebuffer:(DJILiveViewFrameBuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex {
    if (self.providerEnabled == NO) {
        return;
    }
    [newInputFramebuffer lockForReading];
    CVPixelBufferRef pixelBuffer = newInputFramebuffer.pixelBuffer;
    VideoFrameYUV frame = {0};
    frame.frameType = VPFrameTypeRGBA;
    frame.width = (int)CVPixelBufferGetWidth(pixelBuffer);
    frame.height = (int)CVPixelBufferGetHeight(pixelBuffer);
    frame.luma = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    frame.lumaSlice = (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    frame.frame_uuid = -1;
    frame.cv_pixelbuffer_fastupload = newInputFramebuffer.pixelBuffer;
    
    pthread_mutex_lock(&_lock);
    memcpy(&frame.frame_info, _updatedFrameInfo, sizeof(VideoFrameH264BasicInfo));
    pthread_mutex_unlock(&_lock);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(calibratePixelBufferProviderDidOutputFrame:)]) {
        [self.delegate calibratePixelBufferProviderDidOutputFrame:&frame];
    }
    [newInputFramebuffer unlockAfterReading];
}

@end
