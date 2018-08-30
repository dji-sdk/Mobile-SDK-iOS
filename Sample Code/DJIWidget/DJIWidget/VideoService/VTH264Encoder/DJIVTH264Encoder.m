//
//  DJIVTH264Encoder.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import "DJIVTH264Encoder.h"
#import "DJIWidgetLinkQueue.h"
#import "DJIWidgetMacros.h"
#import <CoreMedia/CoreMedia.h>


#define MAX_VIDEO_FRAME_BUFFER_COUNT (4)

@interface DJIVTH264Encoder () {
    DJIWidgetLinkQueue* _videoFramePool;
    CMMemoryPoolRef _pixelBufferMemoryPool;
    pthread_mutex_t _threadLock;
}

@property (nonatomic, strong) DJIVTH264Compressor* vtCompressor;
@property (nonatomic, strong) DJIVTH264CompressConfiguration* compressConfig;

@property (nonatomic, assign, readwrite) NSUInteger inputVideoFrameNum;
@property (nonatomic, assign, readwrite) NSUInteger outputVideoFrameNum;
@property (nonatomic, strong) NSThread* workThread;

@end


@implementation DJIVTH264Encoder

#pragma mark - LifeCycle


- (void)dealloc {
    [self reset];
    if (_pixelBufferMemoryPool != NULL) {
        CMMemoryPoolFlush(_pixelBufferMemoryPool);
        CFRelease(_pixelBufferMemoryPool);
        _pixelBufferMemoryPool = NULL;
    }
    pthread_mutex_destroy(&_threadLock);
}

- (instancetype)initWithConfig:(DJIVTH264CompressConfiguration *)config delegate:(id <DJIVTH264EncoderOutput>)delegate {
    self = [super init];
    if (self) {
        if (!config) {
            return nil;
        }
        self.delegate = delegate;
        self.compressConfig = config;
        self.enabled = NO;
        self.vtCompressor = [[DJIVTH264Compressor alloc] init];
        
        //memory pool
        _pixelBufferMemoryPool = CMMemoryPoolCreate(NULL);
        
        //buffer queue
        _videoFramePool = [[DJIWidgetLinkQueue alloc] initWithSize:MAX_VIDEO_FRAME_BUFFER_COUNT];
        pthread_mutex_init(&_threadLock, NULL);
    }
    return self;
}

#pragma mark - Getter

- (NSData *)currentSps {
    return self.vtCompressor.sps;
}

- (NSData *)currentPps {
    return self.vtCompressor.pps;
}

#pragma mark - Public

- (void)setEnabled:(BOOL)enabled {
    if (_enabled == enabled) {
        return;
    }
    _enabled = enabled;
    if (_enabled) {
        [self start];
        return;
    }
    [self invalidate];
}

- (void)setStreamInfo:(DJIVideoStreamBasicInfo)streamInfo {
    if (memcmp(&_streamInfo, &streamInfo, sizeof(streamInfo)) != 0) {
        _streamInfo = streamInfo;
        [self reset];
    }
}

- (void)resetCompressionConfiguration {
    NSUInteger frameRate = _streamInfo.frameRate;
    if (frameRate <= 0) {
        frameRate = kDefaultFrameRate;
    }
    [self.compressConfig setStreamFrameRate:frameRate];
}

#pragma mark - Private

- (void)start {
    @synchronized (self) {
        if (self.workThread) {
            return;
        }
        self.workThread = [[NSThread alloc] initWithTarget:self selector:@selector(working) object:nil];
        self.workThread.name = @"com.dji.compressionThread";
        [self.workThread start];
    }
}

- (void)reset {
    @synchronized (self) {
        [self resetCompressionConfiguration];
        [self.vtCompressor reset];
        [self cleanupBuffers];
        self.inputVideoFrameNum = 0;
        self.outputVideoFrameNum = 0;
    }
}

- (void)invalidate {
    @synchronized (self) {
        if (!self.workThread) {
            return;
        }
        [self.workThread cancel];
        self.workThread = nil;
    }
}

- (void)cleanupBuffers {
    while (_videoFramePool.count) {
        int size = 0;
        VideoFrameYUV* frame = (VideoFrameYUV *)[_videoFramePool pull:&size];
        if (frame) {
            if (frame->cv_pixelbuffer_fastupload) {
                CFRelease(frame->cv_pixelbuffer_fastupload);
            }
            free(frame);
        }
    }
    CMMemoryPoolFlush(_pixelBufferMemoryPool);
}

- (void)videoFrameDequeue {
    int size = 0;
    VideoFrameYUV* frame = (VideoFrameYUV *)[_videoFramePool pull:&size];
    if (frame) {
        if (frame->cv_pixelbuffer_fastupload) {
            CFRelease(frame->cv_pixelbuffer_fastupload);
        }
        free(frame);
    }
}

#pragma mark - Input

- (void)pushAudioPacket:(AudioFrameAACRaw *)audioFrame {
    
    if (!audioFrame) {
        return;
    }
    
    if (!self.enabled || !self.workThread) {
        if (audioFrame) {
            free(audioFrame);
        }
        return;
    }
    
    if (audioFrame -> type_tag == TYPE_TAG_AudioFrameAACRaw) {
        if ([self.delegate conformsToProtocol:@protocol(DJIVTH264EncoderOutput)]) {
            [self.delegate vtH264Encoder:self output:(VideoFrameH264Raw *)audioFrame];
        }
        else {
            free(audioFrame);
        }
    }
    else {
        free(audioFrame);
    }
}

- (void)pushVideoFrame:(VideoFrameYUV *)frame {
    if (!self.enabled || !self.workThread || !frame) {
        return;
    }
    if ([_videoFramePool count] >= MAX_VIDEO_FRAME_BUFFER_COUNT) {
        [self videoFrameDequeue];
    }
    // Software decode frame
    if (!frame -> cv_pixelbuffer_fastupload) {
        VideoFrameYUV* yuvFrame = malloc(sizeof(VideoFrameYUV));
        memcpy(yuvFrame, frame, sizeof(VideoFrameYUV));
        [_videoFramePool push:(uint8_t *)yuvFrame length:sizeof(VideoFrameYUV)];
    }
    // Hardware decode frame with fastupload，It could be YUV420SemiPlaner or RGB fromat.
    else {
        VideoFrameYUV* yuvFrame = malloc(sizeof(VideoFrameYUV));
        memcpy(yuvFrame, frame, sizeof(VideoFrameYUV));
        CFRetain(frame -> cv_pixelbuffer_fastupload);
        if ([_videoFramePool push:(uint8_t *)yuvFrame length:sizeof(VideoFrameYUV)] == NO) {
            CFRelease(frame -> cv_pixelbuffer_fastupload);
        }
    }
}

#pragma mark - Compression Work

- (void)working {
    pthread_mutex_lock(&_threadLock);
    while (![NSThread currentThread].isCancelled) {
        @autoreleasepool {
            int size = 0;
            VideoFrameYUV* videoFrame = (VideoFrameYUV *)[_videoFramePool pull:&size];
            if (!videoFrame) {
                continue;
            }
            [self encodeVideoFrame:videoFrame];
        }
    }
    pthread_mutex_unlock(&_threadLock);
}

- (void)encodeVideoFrame:(VideoFrameYUV *)videoFrame {
    if (!videoFrame) {
        return;
    }
    // if has fastupload，it must be hardware decode rame.
    if (videoFrame -> cv_pixelbuffer_fastupload) {
        // RGBA format.
        if (videoFrame -> frameType == VPFrameTypeRGBA) {
            [self internalEncodeRGBAFrame:videoFrame];
        }
        // YUV420SemiPlaner format.
        else if (videoFrame -> frameType == VPFrameTypeYUV420SemiPlaner) {
            [self internalEncodeYUV420SemiPlanerFrame:videoFrame];
        }
        // Unsupport format.
        else {
            CFRelease(videoFrame -> cv_pixelbuffer_fastupload);
            free(videoFrame);
        }
    }
    // software decode frame
    else {
        //YUV420Planer
        if (videoFrame -> frameType == VPFrameTypeYUV420Planer) {
            [self internalEncodeYUV420PlanerFrame:videoFrame];
        }
		// Unsupport format.
        else {
            free(videoFrame);
        }
    }
}

- (void)internalEncodeYUV420SemiPlanerFrame:(VideoFrameYUV *)yuvFrame {
    
    if (!yuvFrame -> cv_pixelbuffer_fastupload) {
        if (yuvFrame) {
            free(yuvFrame);
        }
        return;
    }
    
    if (self.vtCompressor.status == DJIVTH264CompressorStatusIdel) {
        [self.vtCompressor setupCompressSessionWithWidth:yuvFrame -> frame_info.width
                                                  height:yuvFrame -> frame_info.height
                                                  rotate:yuvFrame -> frame_info.rotate
                                          compressConfig:self.compressConfig];
        weakSelf(target);
        self.vtCompressor.encodeOutput = ^(VideoFrameH264Raw* frame, NSError* error) {
            weakReturn(target);
            [target vtEncoderOutputHandler:frame error:error];
        };
    }
    
    if (self.vtCompressor.status == DJIVTH264CompressorStatusFailed) {
        if (yuvFrame) {
            if (yuvFrame->cv_pixelbuffer_fastupload) {
                CFRelease(yuvFrame->cv_pixelbuffer_fastupload);
            }
            free(yuvFrame);
        }
        return;
    }
    
    [self.vtCompressor encodePixelBuffer:yuvFrame -> cv_pixelbuffer_fastupload shouldReleased:NO];
    self.inputVideoFrameNum ++;
    
    if (yuvFrame) {
        if (yuvFrame->cv_pixelbuffer_fastupload) {
            CFRelease(yuvFrame->cv_pixelbuffer_fastupload);
        }
        free(yuvFrame);
    }
}

- (void)internalEncodeYUV420PlanerFrame:(VideoFrameYUV *)yuvFrame {
    if (!yuvFrame -> luma || !yuvFrame -> chromaB || !yuvFrame -> chromaR) {
        if (yuvFrame) {
            free(yuvFrame);
        }
        return;
    }
    if (self.vtCompressor.status == DJIVTH264CompressorStatusIdel) {
        [self.vtCompressor setupCompressSessionWithWidth:yuvFrame -> frame_info.width
                                                  height:yuvFrame -> frame_info.height
                                                  rotate:yuvFrame -> frame_info.rotate
                                          compressConfig:self.compressConfig];
        weakSelf(target);
        self.vtCompressor.encodeOutput = ^(VideoFrameH264Raw* frame, NSError* error) {
            weakReturn(target);
            [target vtEncoderOutputHandler:frame error:error];
        };
    }
    
    if (self.vtCompressor.status == DJIVTH264CompressorStatusFailed) {
        if (yuvFrame) {
            free(yuvFrame);
        }
        return;
    }
    NSDictionary* options = @{(__bridge NSString *)kCVPixelBufferCGImageCompatibilityKey:@(YES),
                              (__bridge NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey:@(YES)};
    CVPixelBufferRef pixelBuffer = NULL;
    CVReturn err = CVPixelBufferCreate(CMMemoryPoolGetAllocator(_pixelBufferMemoryPool),
                                       yuvFrame -> width,
                                       yuvFrame -> height,
                                       kCVPixelFormatType_420YpCbCr8Planar,
                                       (__bridge CFDictionaryRef)options,
                                       &pixelBuffer);
    if (err) {
        if (yuvFrame) {
            free(yuvFrame);
        }
        NSAssert(0, @"create pixel buffer failed ..");
        return;
    }
    
    if (kCVReturnSuccess != CVPixelBufferLockBaseAddress(pixelBuffer, 0) || pixelBuffer == NULL){
        if (yuvFrame) {
            free(yuvFrame);
        }
        return;
    }
    
    long yPlaneWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
    long yPlaneHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer,0);
    
    long uPlaneWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
    long uPlaneHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
    
    long vPlaneWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 2);
    long vPlaneHeight =  CVPixelBufferGetHeightOfPlane(pixelBuffer, 2);
    
    uint8_t* yDestination = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    memcpy(yDestination, yuvFrame->luma, yPlaneWidth * yPlaneHeight);
    
    uint8_t* uDestination = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    memcpy(uDestination, yuvFrame->chromaB, uPlaneWidth * uPlaneHeight);
    
    uint8_t* vDestination = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 2);
    memcpy(vDestination, yuvFrame->chromaR, vPlaneWidth * vPlaneHeight);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    [self.vtCompressor encodePixelBuffer:pixelBuffer shouldReleased:YES];
    self.inputVideoFrameNum ++;
    
    if (yuvFrame) {
        free(yuvFrame);
    }
}

- (void)internalEncodeRGBAFrame:(VideoFrameYUV *)rgbaFrame {
    
    if (!rgbaFrame -> cv_pixelbuffer_fastupload) {
        if (rgbaFrame) {
            free(rgbaFrame);
        }
        return;
    }
    
    if (self.vtCompressor.status == DJIVTH264CompressorStatusIdel) {
        [self.vtCompressor setupCompressSessionWithWidth:rgbaFrame -> frame_info.width
                                                  height:rgbaFrame -> frame_info.height
                                                  rotate:rgbaFrame -> frame_info.rotate
                                          compressConfig:self.compressConfig];
        
        weakSelf(target);
        self.vtCompressor.encodeOutput = ^(VideoFrameH264Raw* frame, NSError* error) {
            weakReturn(target);
            [target vtEncoderOutputHandler:frame error:error];
        };
    }
    
    if (self.vtCompressor.status == DJIVTH264CompressorStatusFailed) {
        if (rgbaFrame) {
            if (rgbaFrame->cv_pixelbuffer_fastupload) {
                CFRelease(rgbaFrame->cv_pixelbuffer_fastupload);
            }
            free(rgbaFrame);
        }
        return;
    }
    
    [self.vtCompressor encodePixelBuffer:rgbaFrame -> cv_pixelbuffer_fastupload shouldReleased:NO];
    self.inputVideoFrameNum ++;
    
    if (rgbaFrame) {
        if (rgbaFrame->cv_pixelbuffer_fastupload) {
            CFRelease(rgbaFrame->cv_pixelbuffer_fastupload);
        }
        free(rgbaFrame);
    }
}

- (void)vtEncoderOutputHandler:(VideoFrameH264Raw *)frame error:(NSError *)error {
    if (!frame) {
        return;
    }
    if ([self.delegate conformsToProtocol:@protocol(DJIVTH264EncoderOutput)]) {
        [self.delegate vtH264Encoder:self output:frame];
        self.outputVideoFrameNum ++;
    }
    else {
        free(frame);
    }
}

@end
