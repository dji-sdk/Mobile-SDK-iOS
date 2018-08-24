//
//  DJIVTH264CompressSession.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import "DJIVTH264CompressSession.h"
#import "NSError+DJIVTH264CompressSession.h"
#import <VideoToolbox/VTErrors.h>
#import <VideoToolbox/VTCompressionSession.h>


@interface DJIVTH264CompressSession () {
    VTCompressionSessionRef _compressSession;
}


@property (nonatomic, assign, readwrite) int width;
@property (nonatomic, assign, readwrite) int height;
@property (nonatomic, assign, readwrite) BOOL isPrepared;


@end


@implementation DJIVTH264CompressSession

- (instancetype)initWithWidth:(int)width height:(int)height {
    self = [super init];
    if (self) {
        self.isPrepared = NO;
        self.width = width;
        self.height = height;
        if (self.width * self.height == 0 ) {
            return nil;
        }
        OSStatus status = VTCompressionSessionCreate(NULL,
                                                     _width,
                                                     _height,
                                                     kCMVideoCodecType_H264,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     NULL,//Pass NULL if and only if you will be calling VTCompressionSessionEncodeFrameWithOutputHandler for encoding frames.
                                                     (__bridge void *)(self),
                                                     &_compressSession);
        if (status != 0) {
            return nil;
        }
    }
    return self;
}

- (BOOL)prepareEncode {
    OSStatus ret = VTCompressionSessionPrepareToEncodeFrames(_compressSession);
    if(ret != 0){
        self.isPrepared = NO;
        return NO;
    }
    self.isPrepared = YES;
    return YES;
}

- (OSStatus)encodeWithCVPixelBuffer:(CVPixelBufferRef)imageBuffer
                   presentationTime:(CMTime)presentationTimeStamp
                           duration:(CMTime)duration
                  sourceFrameRefCon:(void *)sourceFrameRefCon
                      shouldRelease:(BOOL)released {
    __weak typeof(self) weakSelf = self;
    return VTCompressionSessionEncodeFrameWithOutputHandler(_compressSession,
                                                            imageBuffer,
                                                            presentationTimeStamp,
                                                            duration,
                                                            NULL,
                                                            NULL,
                                                            ^(OSStatus status,
                                                              VTEncodeInfoFlags infoFlags,
                                                              CMSampleBufferRef  _Nullable sampleBuffer) {
                                                                __strong typeof(weakSelf) strongSelf = weakSelf;
                                                                [strongSelf compressionSessionEncodeFrameOutputHandler:sampleBuffer status:status];
                                                                if (imageBuffer != NULL && released) {
                                                                    CFRelease(imageBuffer);
                                                                }
                                                            });
}

- (void)compressionSessionEncodeFrameOutputHandler:(CMSampleBufferRef)sampleBuffer status:(OSStatus)status {
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(DJIVTH264CompressSessionDelegate)]) {
        [self.delegate vth264compressSession:self didCompressWithSampleBuffer:sampleBuffer status:status];
    }
}

- (void)setupWithConfig:(DJIVTH264CompressConfiguration *)config {
    NSDictionary* configDict = [config configDict];
    NSArray* allKeys = configDict.allKeys;
    for (NSString* key in allKeys) {
        NSError* error = nil;
        [self internalSetValue:configDict[key] forProperty:key error:&error];
        if (error) {
            NSLog(@"set vt compress session property faild : %@ - %@",key,configDict[key]);
        } else {
            NSLog(@"set vt compress session property success : %@ - %@",key,configDict[key]);
        }
    }
}

- (BOOL)internalSetValue:(id)value forProperty:(NSString *)property error:(NSError **)outError {
    if (self.isPrepared) {
        return NO;
    }
    OSStatus status = VTSessionSetProperty(_compressSession, (__bridge CFStringRef)property, (__bridge CFTypeRef)value);
    if (status != noErr) {
        NSError* error = [NSError videoToolboxErrorWithStatus:status];
        if(outError != nil) {
            *outError = error;
        }
        return NO;
    }
    return YES;
}


- (void)dealloc {
    if (_compressSession) {
        NSLog(@"vt session release");
        VTCompressionSessionCompleteFrames(_compressSession, kCMTimeInvalid);
        VTCompressionSessionInvalidate(_compressSession);
        CFRelease(_compressSession);
        _compressSession = nil;
    }
}

@end



