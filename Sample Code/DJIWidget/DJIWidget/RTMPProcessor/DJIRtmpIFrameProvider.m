//
//  DJIIFrameProvider.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import "DJIRtmpIFrameProvider.h"

#define DJI_RTMP_DUMP_FILE_NAME @"rtmp_i_frame_provider.h264"



@interface DJIRtmpIFrameProvider ()
{
    FILE* _fileHandle;
}

@property (nonatomic, assign, readwrite) DJIRtmpIFrameProviderStatus status;
@property (nonatomic, copy) NSString* filePath;
@property (nonatomic) dispatch_queue_t workingQueue;
@property (nonatomic, strong) NSMutableData* data;

@end

@implementation DJIRtmpIFrameProvider

- (id)init {
    self = [super init];
    if (self) {
        _fileHandle = NULL;
        _status = DJIRtmpIFrameProviderStatusNotStartYet;
        self.workingQueue = dispatch_queue_create("com.dji.rtmpIFrameProvider.workingQueue",DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)processFrame:(VideoFrameH264Raw *)frame sps:(NSData *)sps pps:(NSData *)pps {
    if (frame->type_tag == TYPE_TAG_AudioFrameAACRaw) {
        return;
    }
    BOOL isKeyFrame = frame -> frame_info.frame_flag.has_idr;
    if (!sps || !pps || !isKeyFrame) {
        return;
    }
    dispatch_sync(self.workingQueue, ^{
        @autoreleasepool {
            _status = DJIRtmpIFrameProviderStatusProcessing;
            //save iframe
            [self dumpData:frame->frame_data length:frame->frame_size];
            //concatenate sps and pps
            uint8_t startCode [] = {0x00,0x00,0x00,0x01};
            int length = sizeof(startCode);
            self.data = [[NSMutableData alloc] init];
            [self.data appendBytes:startCode length:length];
            [self.data appendData:sps];
            [self.data appendBytes:startCode length:length];
            [self.data appendData:pps];
            _status = DJIRtmpIFrameProviderStatusFinish;
        }
    });
}

- (void)reset {
    dispatch_async(self.workingQueue, ^{
        if (_fileHandle) {
            fclose(_fileHandle);
            _fileHandle = NULL;
        }
        self.data = nil;
        _status = DJIRtmpIFrameProviderStatusNotStartYet;
    });
}

- (DJIRtmpIFrameProviderStatus)status {
    __block DJIRtmpIFrameProviderStatus status;
    dispatch_sync(self.workingQueue, ^{
        status = _status;
    });
    return status;
}

- (NSString *)iFrameFilePath {
    __block NSString* filePath = @"";
    dispatch_sync(self.workingQueue, ^{
        filePath = _filePath;
    });
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    return filePath;
}

- (NSData *)extraData {
    __block NSData* extraData = nil;
    dispatch_sync(self.workingQueue, ^{
        extraData = _data.copy;
    });
    return extraData;
}


#pragma mark - Private

- (void)dumpData:(uint8_t *)data length:(int)nDataSize {
    if (data == NULL || nDataSize <= 0) {
        return;
    }
    if (_fileHandle == NULL) {
        [self openCacheFile:DJI_RTMP_DUMP_FILE_NAME];
    }
    if (_fileHandle) {
        fwrite(data, 1, nDataSize, _fileHandle);
        fflush(_fileHandle);
    }
    _filePath = [self filePath];
}

- (void)openCacheFile:(NSString *)fileName {
    if (_fileHandle) {
        return;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self filePath]]) {
        [[NSFileManager defaultManager] removeItemAtPath:[self filePath] error:nil];
    }
    _fileHandle = fopen([[self filePath] UTF8String], "wb");
}


- (NSString *)filePath {
    NSArray* doucuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* filePath = [doucuments objectAtIndex:0];
    filePath = [filePath stringByAppendingPathComponent:DJI_RTMP_DUMP_FILE_NAME];
    return filePath;
}


@end
