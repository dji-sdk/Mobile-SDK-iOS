//
//  DJIVTH264Compressor.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import "DJIVTH264Compressor.h"
#import "DJIVTH264CompressSession.h"
#import "DJIVideoPreviewer.h"

@import VideoToolbox;
@import AVFoundation;


#define DESIGNED_TIME_BASE (90000)
#define INFO(fmt, ...) DJILOG_DEBUG(@"[VTCompress]", fmt, ##__VA_ARGS__)
#define DUMP_DATA (0)


@interface DJIVTH264Compressor () <DJIVTH264CompressSessionDelegate>


#if DUMP_DATA
@property (nonatomic, strong) DJIDataDumper* dump;
#endif

@property (nonatomic, strong, readwrite) NSData* sps;
@property (nonatomic, strong, readwrite) NSData* pps;


@property (nonatomic, weak) DJIVTH264CompressConfiguration* configuration;
@property (nonatomic, strong) DJIVTH264CompressSession* compressSession;
@property (nonatomic, assign, readwrite) DJIVTH264CompressorStatus status;

@property (nonatomic, assign) int configRotate;
@property (nonatomic, assign) int configWidth;
@property (nonatomic, assign) int configHeight;

@property (nonatomic, assign) NSUInteger frameCounter;
@property (nonatomic, assign) NSUInteger encodeCounter;
@property (nonatomic, assign) NSTimeInterval encodeBeginTime;


@end



@implementation DJIVTH264Compressor

- (BOOL)setupCompressSessionWithWidth:(int)width height:(int)height rotate:(int)rotate compressConfig:(DJIVTH264CompressConfiguration *)config {
    
    @synchronized (self) {
        
        if (self.status == DJIVTH264CompressorStatusReady) {
            [self reset];
            return NO;
        }
        
        self.configWidth = width;
        self.configHeight = height;
        self.configRotate = rotate;
        self.configuration = config;
        
        self.compressSession = [[DJIVTH264CompressSession alloc] initWithWidth:self.configWidth height:self.configHeight];
        self.compressSession.delegate = self;
        if (!self.compressSession) {
            self.status = DJIVTH264CompressorStatusFailed;
            return NO;
        }
        [self.compressSession setupWithConfig:config];
        
        BOOL prepared = [self.compressSession prepareEncode];
        if(!prepared) {
            self.status = DJIVTH264CompressorStatusFailed;
            return NO;
        }
        
        self.frameCounter = 0;
        self.encodeCounter = 0;
        self.status = DJIVTH264CompressorStatusReady;
        
#if DUMP_DATA
        self.dump = [[DJIDataDumper alloc] init];
        self.dump.namePerfix = [NSString stringWithFormat:@"vtH264Compress_",self.config.usageType];
#endif
        
    }
    return YES;
}


- (BOOL)encodePixelBuffer:(CVPixelBufferRef)pixelBuffer shouldReleased:(BOOL)shouldReleased {
    
    if(self.status != DJIVTH264CompressorStatusReady || self.compressSession == nil) {
        if (shouldReleased && pixelBuffer != NULL) {
            CFRelease(pixelBuffer);
        }
        return NO;
    }
    
    NSTimeInterval current = CFAbsoluteTimeGetCurrent();
    if (self.frameCounter == 0) {
        self.encodeBeginTime = current;
    }
    

    NSUInteger frameIntervel = (NSUInteger) (DESIGNED_TIME_BASE / 30);
    NSUInteger fps = 0;
    if ([DJIVideoPreviewer instance].detectRealtimeFrameRate) {
        fps  = [DJIVideoPreviewer instance].realTimeFrameRate;
    }
    else {
        fps =  [self.configuration configFrameRate];
    }
    
    if (fps > 0) {
        frameIntervel = (NSUInteger) (DESIGNED_TIME_BASE / fps);
    }
    
    CMTime presentationTimeStamp = kCMTimeInvalid;
    if (frameIntervel > 0) {
        presentationTimeStamp = CMTimeMake(self.frameCounter * frameIntervel, DESIGNED_TIME_BASE);
    }
    else {
        NSTimeInterval diff = current - self.encodeBeginTime;
        presentationTimeStamp = CMTimeMake(diff * DESIGNED_TIME_BASE, DESIGNED_TIME_BASE);
    }
    
    
    CVPixelBufferRef imageBuffer = pixelBuffer;
    if (!self.compressSession || !self.compressSession.isPrepared) {
        if (shouldReleased && pixelBuffer != NULL) {
            CFRelease(pixelBuffer);
        }
        return NO;
    }
    
    OSStatus status = [self.compressSession encodeWithCVPixelBuffer:imageBuffer
                                                   presentationTime:presentationTimeStamp
                                                           duration:kCMTimeInvalid
                                                  sourceFrameRefCon:imageBuffer
                                                      shouldRelease:shouldReleased];
    self.frameCounter ++;
    
    if (status != 0) {
        return NO;
    }
    return YES;
}


#pragma mark - DJIVTH264CompressSessionDelegate

- (void)vth264compressSession:(DJIVTH264CompressSession *)session
  didCompressWithSampleBuffer:(CMSampleBufferRef)sampleBuffer
                       status:(OSStatus)status {
    if (status != 0) {
        return;
    }
    
    if (!CMSampleBufferDataIsReady(sampleBuffer)) {
        return;
    }
    
    // Check if we have got a key frame first
    BOOL isKeyFrame = NO;
    CFArrayRef infoArray = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true);
    if (infoArray && CFArrayGetCount(infoArray)) {
        CFDictionaryRef infoDict = CFArrayGetValueAtIndex(infoArray, 0);
        if(infoDict){
            isKeyFrame = !CFDictionaryContainsKey(infoDict, kCMSampleAttachmentKey_NotSync);
        }
    }
    
    if (isKeyFrame && self.sps == nil && self.pps == nil) {
        
        CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
        size_t sparameterSetSize, sparameterSetCount;
        const uint8_t* sparameterSet = nil;
        OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format,
                                                                                 0,
                                                                                 &sparameterSet,
                                                                                 &sparameterSetSize,
                                                                                 &sparameterSetCount,
                                                                                 0);
        if (statusCode == noErr) {
            // Found sps and now check for pps
            size_t pparameterSetSize, pparameterSetCount;
            const uint8_t* pparameterSet;
            OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format,
                                                                                     1,
                                                                                     &pparameterSet,
                                                                                     &pparameterSetSize,
                                                                                     &pparameterSetCount,
                                                                                     0 );
            
            if (statusCode == noErr) {
                self.sps = [NSData dataWithBytes:sparameterSet length:sparameterSetSize];
                self.pps = [NSData dataWithBytes:pparameterSet length:pparameterSetSize];
            }
        }
    }
    
    if (self.encodeOutput == nil) {
        return;
    }
    
    //get buffer
    CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t length, totalLength;
    char* dataPointer;
    OSStatus statusCodeRet = CMBlockBufferGetDataPointer(dataBuffer,
                                                         0,
                                                         &length,
                                                         &totalLength,
                                                         &dataPointer);
    
    //create frame
    static const int AVCCHeaderLength = 4;
    NSUInteger outputSize = sizeof(VideoFrameH264Raw) + totalLength;
    if (isKeyFrame) {
        outputSize += self.sps.length + AVCCHeaderLength;
        outputSize += self.pps.length + AVCCHeaderLength;
    }
    
    if (statusCodeRet == noErr) {
        
        VideoFrameH264Raw* frame = (VideoFrameH264Raw*)malloc(outputSize);
        size_t bufferOffset = 0;

		if ([DJIVideoPreviewer instance].detectRealtimeFrameRate) {
            frame->frame_info.fps = [DJIVideoPreviewer instance].realTimeFrameRate;
        }
        else {
            frame->frame_info.fps =  [self.configuration configFrameRate];
        }
        
        frame->frame_info.frame_flag.has_idr = isKeyFrame;
        frame->frame_info.frame_flag.has_pps = isKeyFrame;
        frame->frame_info.frame_flag.has_sps = isKeyFrame;
        frame->frame_info.frame_index = self.encodeCounter;
        frame->frame_info.width = self.configWidth;
        frame->frame_info.height = self.configHeight;
        frame->frame_info.rotate = self.configRotate;
        
        frame->frame_size = (int)totalLength - sizeof(VideoFrameH264Raw);
        frame->type_tag = TYPE_TAG_VideoFrameH264Raw;
        frame->time_tag = 1000 * CMTimeGetSeconds(CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer));
        frame->frame_info.ca_media_time_ms = (CACurrentMediaTime() * 1000);
        frame->frame_uuid = 0;
        
        self.encodeCounter ++;
        const uint32_t h264NaluHeader = 0x01000000;
        
        //set pps and sps
        uint8_t* outbuffer = frame->frame_data;
        
        if(isKeyFrame){
            if(self.sps.length){
                *(uint32_t*)outbuffer = h264NaluHeader;
                outbuffer += AVCCHeaderLength;
                
                memcpy(outbuffer, self.sps.bytes, self.sps.length);
                outbuffer += self.sps.length;
            }
            
            if(self.pps.length){
                *(uint32_t*)outbuffer = h264NaluHeader;
                outbuffer += AVCCHeaderLength;
                
                memcpy(outbuffer, self.pps.bytes, self.pps.length);
                outbuffer += self.pps.length;
            }
        }
        
        
        while (bufferOffset < totalLength - AVCCHeaderLength) {
            
            uint32_t NALUnitLength = 0;
            memcpy(&NALUnitLength, dataPointer + bufferOffset, AVCCHeaderLength);
            
            NALUnitLength = CFSwapInt32BigToHost(NALUnitLength);
            
            *(uint32_t*)outbuffer = h264NaluHeader;
            outbuffer += AVCCHeaderLength;
            
            memcpy(outbuffer, dataPointer + bufferOffset + AVCCHeaderLength, NALUnitLength);
            
            bufferOffset += AVCCHeaderLength + NALUnitLength;
            outbuffer += NALUnitLength;
        }
        
        frame->frame_size = (int)(outbuffer - frame->frame_data);
        
#if DUMP_DATA
        [self.dump dumpData:frame->frame_data length:frame->frame_size];
#endif
        if (self.encodeOutput) {
            self.encodeOutput(frame, nil);
        }
    }
}

- (void)dealloc{
    [self reset];
}

- (void)reset {
    @synchronized (self) {
        self.sps = nil;
        self.pps = nil;
        self.compressSession = nil;
        self.status = DJIVTH264CompressorStatusIdel;
#if DUMP_DATA
        [self.dump reset];
#endif
    }
}

@end
