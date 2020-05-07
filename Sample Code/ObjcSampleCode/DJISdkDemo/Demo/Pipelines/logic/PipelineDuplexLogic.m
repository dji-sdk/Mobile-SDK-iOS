//
//  PipelineDuplexLogic.m
//  DJISdkDemo
//
//  Copyright © 2020 DJI. All rights reserved.
//

#import "PipelineDuplexLogic.h"
#import "PipelineProtocol.h"
#import "DemoUtilityMacro.h"
#import "DemoUtilityMethod.h"

static NSString *PipelineUploadLogTag = @"[Pipeline UploadLogic]";
static NSString *PipelineDownloadLogTag = @"[Pipeline DownloadLogic]";

@interface PipelineDuplexLogic ()

@property (nonatomic, copy) void (^downloadFinishBlock)();
@property (nonatomic, copy) void(^downloadFailureBlock)(DJIPipeline *_Nullable pipeline, NSString *_Nullable error);

@property (nonatomic, copy) void (^uploadFinishBlock)();
@property (nonatomic, copy) void(^uploadFailureBlock)(DJIPipeline *_Nullable pipeline, NSString *_Nullable error);

@property (nonatomic) dispatch_queue_t readQueue;
@property (nonatomic) dispatch_queue_t writeQueue;

@property (atomic) uint16_t seqNum;

@property (atomic) int downloadACKSeqNum;
@property (atomic) NSString *downloadFileName;
@property (nonatomic) PipelineFileInfo fileInformation;
@property (atomic) NSString *localStoragePath;

@property (atomic) int uploadACKSeqNum;
@property (nonatomic) NSInteger pieceLength;
@property (nonatomic) double frequency;
@property (atomic) NSString *uploadFilePath;

@property (nonatomic) FILE *file_handle;

@property (atomic) BOOL readLoopStart;

@end

@implementation PipelineDuplexLogic

- (instancetype)init {
    self = [super init];
    if (self) {
        self.readQueue = dispatch_queue_create("com.dji.duplex.read", NULL);
        self.writeQueue = dispatch_queue_create("com.dji.duplex.write", NULL);
        self.downloadACKSeqNum = -1;
        self.uploadACKSeqNum = -1;
        self.seqNum = 10000;
    }
    return self;
}

- (void)download:(NSString *)fileName
   localFilePath:(NSString *)localStoragePath
        pipeline:(DJIPipeline *)pipeline
 withFinishBlock:(void (^)())finishBlock
withFailureBlock:(void(^)(DJIPipeline *_Nullable pipeline, NSString *_Nullable error))failureBlock {
    WeakRef(target);
    if (self.isDownloading) {
        dispatch_async(dispatch_get_main_queue(), ^{
            WeakReturn(target);
            
            if (failureBlock) {
                failureBlock(pipeline, @"The download already exists.");
            }
        });
        
        return;
    }
         
    self.isDownloadTransmissionSuccessful = NO;
    self.isDownloadTransimssionFailure = NO;
    self.downloadFinalResult = nil;
    self.downloadStatistical = [[PipelineStatistical alloc] init];
    self.downloadStatistical.startTime = CFAbsoluteTimeGetCurrent();
    self.stopDownload = NO;
    self.downloadFileName = fileName;
    self.localStoragePath = localStoragePath;
    
    self.downloadFinishBlock = finishBlock;
    self.downloadFailureBlock = failureBlock;
    
    self.isDownloading = YES;
    
    if (fileName.length > sizeof(PipelineDownloadReq)) {
        [self downloadFailure:@"file name over 32 bytes" pipeline:pipeline];
        return;
    }
    
    [self startReadLoop:pipeline];
    
    self.file_handle = fopen(localStoragePath.UTF8String, "w+");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        WeakReturn(target);
        
        PipelineReqType request = {0};
        request.cmd = PipelineCmdType_Request;
        request.subcmd = PipelineCmdTypeRequestSubcmd_Download;
        request.seqNum = target.seqNum;
        target.downloadACKSeqNum = target.seqNum;
        target.seqNum ++;
        NSData *data = [NSData dataWithBytes:&request length:sizeof(request)];
        NSLog(@"%@ start download seqNum: %d", PipelineUploadLogTag, target.downloadACKSeqNum);
        [target writeDataUtilsSuccess:pipeline needToWrite:data logTag:PipelineDownloadLogTag completion:nil];
    });
}

- (void)uploadFile:(NSString *)filePath
          pipeline:(DJIPipeline *)pipeline
       pieceLength:(NSInteger)pieceLength
         frequency:(double)frequency
   withFinishBlock:(void (^)())finishBlock
  withFailureBlock:(void(^)(DJIPipeline *_Nullable pipeline, NSString *_Nullable error))failureBlock {
    WeakRef(target);
    if (self.isUploading) {
        dispatch_async(dispatch_get_main_queue(), ^{
            WeakReturn(target);
            
            if (failureBlock) {
                failureBlock(pipeline, @"The upload already exists.");
            }
        });
        
        return;
    }
    
    self.isUploadTransimssionFailure = NO;
    self.isUploadTransmissionSuccessful = NO;
    self.uploadFinalResult = nil;
    self.uploadStatistical = [[PipelineStatistical alloc] init];
    self.uploadStatistical.startTime = CFAbsoluteTimeGetCurrent();
    self.stopUpload = NO;
    self.pieceLength = pieceLength;
    self.frequency = frequency;
    self.uploadFilePath = filePath;
    
    self.uploadFinishBlock = finishBlock;
    self.uploadFailureBlock = failureBlock;
    
    self.isUploading = YES;
    [self startReadLoop:pipeline];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        WeakReturn(target);
        
        PipelineReqType request = {0};
        request.cmd = PipelineCmdType_Request;
        request.subcmd = PipelineCmdTypeRequestSubcmd_Upload;
        request.seqNum = target.seqNum;
        target.uploadACKSeqNum = target.seqNum;
        target.seqNum ++;
        NSData *requestData = [NSData dataWithBytes:&request length:sizeof(request)];
        NSLog(@"%@ start upload seqNum: %d", PipelineUploadLogTag, target.uploadACKSeqNum);
        [target writeDataUtilsSuccess:pipeline needToWrite:requestData logTag:PipelineDownloadLogTag completion:nil];
    });
}

//MARK: - Read distribution

- (void)startReadLoop:(DJIPipeline *)pipeline {
    if (self.readLoopStart) {
        return;
    }
    
    self.readLoopStart = YES;
    
    WeakRef(target);
    dispatch_async(self.readQueue, ^{
        WeakReturn(target);
        
        void (^ReadDataUtilsSuccess) (NSMutableData *, uint32_t, DJIPipeline *) = ^(NSMutableData *readData, uint32_t expectedLen, DJIPipeline *internalPipeline) {
            
            while (1) {
                if (target.stopUpload && target.stopDownload) {
                    [target downloadFailure:@"logic is stopped." pipeline:internalPipeline];
                    [target uploadFailure:@"logic is stopped." pipeline:internalPipeline];
                    return;
                }
                
                NSError *error = nil;
                
                uint32_t readLen = (expectedLen - (uint32_t)readData.length);
                NSData *pieceData = [internalPipeline readData:readLen error:&error];
                if (error) {
                    [NSThread sleepForTimeInterval:0.02];
                    continue;
                }
                
                [readData appendData:pieceData];
                
                if (readData.length == expectedLen) {
                    break;
                }
            }
        };
        
        while (1) {
            if (target.stopUpload && target.stopDownload) {
                [target downloadFailure:@"logic is stopped." pipeline:pipeline];
                [target uploadFailure:@"logic is stopped." pipeline:pipeline];
                break;
            }
            
            NSMutableData *packData = [NSMutableData data];
            uint32_t expectedLen = sizeof(PipelineReqType);
            NSMutableData *headerData = [NSMutableData data];
            ReadDataUtilsSuccess(headerData, expectedLen, pipeline);
            
            [packData appendData:headerData];
            
            PipelineReqType *header = (PipelineReqType *)headerData.bytes;
            expectedLen = header->dataLen;
            if (expectedLen > 0) {
                NSMutableData *bodyData = [NSMutableData data];
                ReadDataUtilsSuccess(bodyData, expectedLen, pipeline);
                [packData appendData:bodyData];
            }
            [target distributionDataReceived:packData pipeline:pipeline];
        }
        target.readLoopStart = NO;
    });
}

//MARK: - distribution

- (void)distributionDataReceived:(NSData *)packData pipeline:(DJIPipeline *)pipeline {
    PipelineReqType *header = (PipelineReqType *)packData.bytes;
    
    NSLog(@"duplex distribution cmd: %d subcmd: %d seqNum: %d dataLen: %d", header->cmd, header->subcmd, header->seqNum, header->dataLen);
    
    switch ((PipelineCmdType)header->cmd) {
        case PipelineCmdType_Response:
        {
            if (header->seqNum == self.downloadACKSeqNum) {
                if (header->subcmd == PipelineCmdTypeResponseSubcmd_OK) {
                    [self requestFile:pipeline];
                } else {
                    [self downloadFailure:[NSString stringWithFormat:@"request file failure %d", self.downloadACKSeqNum] pipeline:pipeline];
                    self.downloadACKSeqNum = -1;
                }
            } else if (header->seqNum == self.uploadACKSeqNum) {
                if (header->subcmd == PipelineCmdTypeResponseSubcmd_OK) {
                    [self uploadFileInformation:pipeline];
                } else {
                    [self uploadFailure:[NSString stringWithFormat:@"upload file require failure %d", self.uploadACKSeqNum] pipeline:pipeline];
                }
                self.uploadACKSeqNum = -1;
            }
        }
            break;
        case PipelineCmdType_FileInformation:
        {
            if (header->seqNum == self.downloadACKSeqNum) {
                [self getRemoteFileInformation:pipeline responseData:packData];
                
                self.downloadACKSeqNum = -1;
            }
        }
            break;
        case PipelineCmdType_FileData:
        {
            [self storeDownloadFile:pipeline responseData:packData];
        }
            break;
        case PipelineCmdType_Result:
        {
            [self checkUploadResult:pipeline responseData:packData];
        }
            break;
        case PipelineCmdType_Terminate:
        {
            self.stopUpload = YES;
        }
            break;
            
        default:
            break;
    }
}

//MARK: - Write

- (void)writeDataUtilsSuccess:(DJIPipeline *)pipeline
                  needToWrite:(NSData *)needToWrite
                       logTag:(NSString *)tag completion:(void (^)())completion {
    WeakRef(target);
    dispatch_async(self.writeQueue, ^{
        WeakReturn(target);
        int32_t hadWriteLen = 0;
        while (1) {
            if ([tag isEqualToString:PipelineDownloadLogTag] && self.stopDownload) {
                [target downloadFailure:@"logic is stopped." pipeline:pipeline];
                return;
            }
            
            if ([tag isEqualToString:PipelineUploadLogTag] && self.stopUpload) {
                [target uploadFailure:@"logic is stopped." pipeline:pipeline];
                return;
            }
            
            NSError *error = nil;
            NSData *needToSend = [needToWrite subdataWithRange:NSMakeRange(hadWriteLen, needToWrite.length - hadWriteLen)];
            int32_t writtenLen = [pipeline writeData:needToSend error:&error];
            
            if (error) {
                NSLog(@"%@ send result pack failure. error: %@ %@", tag, @(error.code), error.description);
                [NSThread sleepForTimeInterval:0.02];
            } else {
                hadWriteLen += writtenLen;
            }
            
            if (hadWriteLen == needToWrite.length) {
                break;
            }
        }
        
        if (completion) {
            completion();
        }
    });
}

//MARK: - Download Logic

- (void)stopDownload:(DJIPipeline *_Nullable)pipeline {
    self.stopDownload = YES;
    [self downloadFailure:@"logic is stopped" pipeline:pipeline];
}

- (void)downloadFailure:(NSString *)finalResult pipeline:(DJIPipeline *)pipeline {
    if (self.file_handle) {
        int result = fflush(self.file_handle);
        if (result != 0) {
            NSLog(@"%@ flush failure: %@", PipelineDownloadLogTag, @(result));
        }
        fclose(self.file_handle);
        self.file_handle = NULL;
    }
    
    WeakRef(target);
    dispatch_async(dispatch_get_main_queue(), ^{
        WeakReturn(target);
        
        if (target.isDownloadTransimssionFailure) {
            return;
        }
        
        NSLog(@"%@ pipeline id: %@ device: %@ failure result: %@", PipelineDownloadLogTag, @(pipeline.Id), @(pipeline.deviceType), finalResult);
        
        PipelineReqType requestPack = {0};
        requestPack.cmd = PipelineCmdType_Terminate;
        requestPack.subcmd = 0xFF;
        requestPack.seqNum = self.seqNum;
        target.seqNum ++;
        NSMutableData *terminateRequest = [NSMutableData data];
        [terminateRequest appendBytes:&requestPack length:sizeof(requestPack)];
        [target writeDataUtilsSuccess:pipeline needToWrite:terminateRequest logTag:PipelineDownloadLogTag completion:nil];
        
        target.isDownloading = NO;
        target.isDownloadTransimssionFailure = YES;
        target.downloadStatistical.endTime = CFAbsoluteTimeGetCurrent();
        target.downloadFinalResult = finalResult;
        target.downloadFileName = nil;
        target.localStoragePath = nil;
        
        if (target.downloadFailureBlock) {
            target.downloadFailureBlock(pipeline, finalResult);
            target.downloadFailureBlock = nil;
        }
        target.downloadFinishBlock = nil;
    });
}

- (void)downloadSuccess:(NSString *)finalResult pipeline:(DJIPipeline *)pipeline {
    WeakRef(target);
    dispatch_sync(dispatch_get_main_queue(), ^{
        WeakReturn(target);
        
        if (target.isDownloadTransmissionSuccessful) {
            return;
        }
        
        NSLog(@"%@ pipeline id: %@ device: %@ success result: %@", PipelineDownloadLogTag, @(pipeline.Id), @(pipeline.deviceType), finalResult);
        
        target.isDownloading = NO;
        target.isDownloadTransmissionSuccessful = YES;
        target.downloadStatistical.endTime = CFAbsoluteTimeGetCurrent();
        target.downloadFinalResult = finalResult;
        target.downloadFileName = nil;
        target.localStoragePath = nil;
        
        if (target.downloadFinishBlock) {
            target.downloadFinishBlock();
            target.downloadFinishBlock = nil;
        }
        target.downloadFailureBlock = nil;
    });
}

- (void)requestFile:(DJIPipeline *)pipeline {
    PipelineReqType requestPack = {0};
    requestPack.cmd = PipelineCmdType_DownloadFile;
    requestPack.subcmd = 0xFF;
    requestPack.dataLen = sizeof(PipelineDownloadReq);
    requestPack.seqNum = self.seqNum;
    self.seqNum ++;
    
    PipelineDownloadReq downloadReq = {0};
    const char *fileNameCString = [self.downloadFileName cStringUsingEncoding:NSUTF8StringEncoding];
    NSUInteger fileNameCLength = [self.downloadFileName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    memcpy(&downloadReq.fileName, fileNameCString, fileNameCLength);
    
    NSMutableData *downloadData = [NSMutableData data];
    [downloadData appendBytes:&requestPack length:sizeof(requestPack)];
    [downloadData appendBytes:&downloadReq length:sizeof(downloadReq)];
    
    NSLog(@"%@ request file information seq: %d", PipelineDownloadLogTag, requestPack.seqNum);
    [self writeDataUtilsSuccess:pipeline needToWrite:downloadData logTag:PipelineDownloadLogTag completion:nil];
    
    self.downloadACKSeqNum = requestPack.seqNum;
}

- (void)getRemoteFileInformation:(DJIPipeline *)pipeline responseData:(NSData *)responseData {
    PipelineReqType *header = (PipelineReqType *)responseData.bytes;
    
    memcpy(&_fileInformation, header->data, MIN(header->dataLen, sizeof(PipelineFileInfo)));
    NSLog(@"%@ start to download file length: %d", PipelineDownloadLogTag, self.fileInformation.fileLength);
    
    if (self.fileInformation.isExist == false) {
        [self downloadFailure:[NSString stringWithFormat:@"%@ not exist", self.downloadFileName] pipeline:pipeline];
        return;
    }
}

- (void)storeDownloadFile:(DJIPipeline *)pipeline responseData:(NSData *)responseData {
    PipelineReqType *header = (PipelineReqType *)responseData.bytes;
    if (!self.file_handle) {
        [self downloadFailure:[NSString stringWithFormat:@"not exist file handle, seqNum: %d", header->seqNum] pipeline:pipeline];
        return;
    }
    
    size_t ret = fwrite(header->data, 1, header->dataLen, self.file_handle);
    if (ret != header->dataLen) {
        long writeOffset = ftell(self.file_handle);
        NSString *errorString = [NSString stringWithFormat:@"%@ write local file failure.(%ld)", PipelineDownloadLogTag, writeOffset];
        [self downloadFailure:errorString pipeline:pipeline];
        return;
    }
    
    self.downloadStatistical.numberOfBytesSuccessfully += responseData.length;
    self.downloadStatistical.numberOfPacketsSuccessfully ++;
    self.downloadStatistical.totalSuccessful += responseData.length;
    
    NSLog(@"%@ store file length: %d seq: %d subcmd: %d", PipelineDownloadLogTag, header->dataLen, header->seqNum, header->subcmd);
    if (header->subcmd == PipelineCmdTypeFileDataSubcmd_End) {
        // 开始校验文件
        if (self.file_handle) {
            int result = fflush(self.file_handle);
            if (result != 0) {
                NSLog(@"%@ flush failure: %@", PipelineDownloadLogTag, @(result));
            }
            fclose(self.file_handle);
            self.file_handle = NULL;
        }
        
        PipelineReqType requestPack = {0};
        requestPack.cmd = PipelineCmdType_Result;
        requestPack.subcmd = PipelineCmdTypeResultSubcmd_Failure;
        requestPack.seqNum = self.seqNum;
        self.seqNum ++;
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSInteger fileSize = [[fileManager attributesOfItemAtPath:self.localStoragePath error:nil] fileSize];
        if (fileSize != self.fileInformation.fileLength) {
            NSData *resultData = [NSData dataWithBytes:&requestPack length:sizeof(requestPack)];
            [self writeDataUtilsSuccess:pipeline needToWrite:resultData logTag:PipelineDownloadLogTag completion:nil];
            
            NSString *errorString = [NSString stringWithFormat:@"file size not match remote length: %d local length: %lu", self.fileInformation.fileLength, fileSize];
            [self downloadFailure:errorString pipeline:pipeline];
            return;
        }
        
        NSData *md5 = [NSData md5:self.localStoragePath];
        NSAssert((md5 != nil && md5.length == 16), @"invalid md5");
        
        if (md5 == nil || md5.length != 16) {
            NSString *errorString = [NSString stringWithFormat:@"the download file can't get md5"];
            [self downloadFailure:errorString pipeline:pipeline];
            
            NSData *resultData = [NSData dataWithBytes:&requestPack length:sizeof(requestPack)];
            [self writeDataUtilsSuccess:pipeline needToWrite:resultData logTag:PipelineDownloadLogTag completion:nil];
            
            return;
        }
        
        if (memcmp(md5.bytes, self.fileInformation.md5Buf, 16) != 0) {
            NSString *remoteMd5 = [NSString stringWithCharacters:(const unichar *)self.fileInformation.md5Buf length:16];
            NSString *localMd5 = [[NSString alloc] initWithData:md5 encoding:NSUTF8StringEncoding];
            NSString *errorString = [NSString stringWithFormat:@"MD5 Checksum failure. Remote md5: %@ Local md5: %@", remoteMd5, localMd5];
            [self downloadFailure:errorString pipeline:pipeline];
            
            NSData *resultData = [NSData dataWithBytes:&requestPack length:sizeof(requestPack)];
            [self writeDataUtilsSuccess:pipeline needToWrite:resultData logTag:PipelineDownloadLogTag completion:nil];
            
            return;
        }
        
        requestPack.subcmd = PipelineCmdTypeResultSubcmd_Success;
        NSData *resultData = [NSData dataWithBytes:&requestPack length:sizeof(requestPack)];
        [self writeDataUtilsSuccess:pipeline needToWrite:resultData logTag:PipelineDownloadLogTag completion:nil];
        
        [self downloadSuccess:@"Success Download" pipeline:pipeline];
    }
}

//MARK: - Upload Logic

- (void)stopUpload:(DJIPipeline *_Nullable)pipeline {
    self.stopUpload = YES;
    [self uploadFailure:@"logic is stopped" pipeline:pipeline];
}

- (void)uploadFailure:(NSString *)finalResult pipeline:(DJIPipeline *)pipeline {
    WeakRef(target);
    dispatch_async(dispatch_get_main_queue(), ^{
        WeakReturn(target);
        
        if (target.isUploadTransimssionFailure) {
            return;
        }
        
        NSLog(@"%@ pipeline id: %@ device: %@ failure result: %@", PipelineUploadLogTag, @(pipeline.Id), @(pipeline.deviceType), finalResult);
        
        target.isUploading = NO;
        target.isUploadTransimssionFailure = YES;
        target.uploadStatistical.endTime = CFAbsoluteTimeGetCurrent();
        target.uploadFinalResult = finalResult;
        target.uploadFilePath = nil;
        
        if (target.uploadFailureBlock) {
            target.uploadFailureBlock(pipeline, finalResult);
            target.uploadFailureBlock = nil;
        }
        target.uploadFinishBlock = nil;
    });
}

- (void)uploadSuccess:(NSString *)finalResult pipeline:(DJIPipeline *)pipeline {
    WeakRef(target);
    dispatch_sync(dispatch_get_main_queue(), ^{
        WeakReturn(target);
        
        if (target.isUploadTransmissionSuccessful) {
            return;
        }
        
        NSLog(@"%@ pipeline id: %@ device: %@ success result: %@", PipelineUploadLogTag, @(pipeline.Id), @(pipeline.deviceType), finalResult);
        
        target.isUploading = NO;
        target.isUploadTransmissionSuccessful = YES;
        target.uploadStatistical.endTime = CFAbsoluteTimeGetCurrent();
        target.uploadFinalResult = finalResult;
        target.uploadFilePath = nil;
        
        if (target.uploadFinishBlock) {
            target.uploadFinishBlock(pipeline, finalResult);
            target.uploadFinishBlock = nil;
        }
        target.uploadFailureBlock = nil;
    });
}

- (void)uploadFileInformation:(DJIPipeline *)pipeline {
    NSLog(@"%@ try to upload file information.", PipelineUploadLogTag);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSInteger fileSize = [[fileManager attributesOfItemAtPath:self.uploadFilePath error:nil] fileSize];
    
    PipelineReqType fileRequest = {0};
    fileRequest.cmd = PipelineCmdType_FileInformation;
    fileRequest.subcmd = 0xFF;
    fileRequest.dataLen = sizeof(PipelineFileInfo);
    fileRequest.seqNum = self.seqNum;
    self.seqNum ++;
    
    PipelineFileInfo fileInformation = {0};
    fileInformation.isExist = true;
    fileInformation.fileLength = (uint32_t)fileSize;
    NSString *fileName = [self.uploadFilePath.pathComponents lastObject];
    const char *fileNameCString = [fileName cStringUsingEncoding:NSUTF8StringEncoding];
    NSUInteger fileNameCLength = [fileName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    memcpy(fileInformation.fileName, fileNameCString, MIN(fileNameCLength, 32));
    
    NSData *md5 = [NSData md5:self.uploadFilePath];
    NSAssert((md5 != nil || md5.length != 16), @"invalid md5");
    
    memcpy(fileInformation.md5Buf, md5.bytes, 16);
    
    NSMutableData *fileRequestData = [[NSMutableData alloc] init];
    [fileRequestData appendBytes:&fileRequest length:sizeof(fileRequest)];
    [fileRequestData appendBytes:&fileInformation length:sizeof(fileInformation)];
    [self writeDataUtilsSuccess:pipeline needToWrite:fileRequestData logTag:PipelineUploadLogTag completion:nil];
    
    WeakRef(target);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        WeakReturn(target);
        
        NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:target.uploadFilePath];
        NSTimeInterval sleepInternal = 1 / target.frequency;
        
        while (1) {
            if (target.stopUpload) {
                [target uploadFailure:@"logic is stopped." pipeline:pipeline];
                return;
            }
            
            NSData *piece = [handle readDataOfLength:target.pieceLength];
            
            PipelineReqType fileRequest = {0};
            fileRequest.cmd = PipelineCmdType_FileData;
            fileRequest.subcmd = (handle.offsetInFile == fileSize) ? PipelineCmdTypeFileDataSubcmd_End : PipelineCmdTypeFileDataSubcmd_Normal;
            fileRequest.seqNum = target.seqNum;
            target.seqNum ++;
            fileRequest.dataLen = (uint32_t)piece.length;
            
            NSMutableData *fileData = [NSMutableData data];
            [fileData appendBytes:&fileRequest length:sizeof(fileRequest)];
            [fileData appendData:piece];

            [target writeDataUtilsSuccess:pipeline needToWrite:fileData logTag:PipelineUploadLogTag completion:^{
                NSLog(@"%@ upload piece file data: %d seqNum: %d subcmd: %d offset: %@ fileSize: %@", PipelineUploadLogTag, piece.length, fileRequest.seqNum, fileRequest.subcmd, @(handle.offsetInFile), @(fileSize));
                WeakReturn(target);
                target.uploadStatistical.numberOfBytesSuccessfully += fileData.length;
                target.uploadStatistical.numberOfPacketsSuccessfully ++;
                target.uploadStatistical.totalSuccessful += fileData.length;
            }];
            
            if (fileRequest.subcmd == PipelineCmdTypeFileDataSubcmd_End) {
                break;
            }
            
            [NSThread sleepForTimeInterval:sleepInternal];
        }
    });
}

- (void)checkUploadResult:(DJIPipeline *)pipeline responseData:(NSData *)responseData {
    PipelineReqType *header = (PipelineReqType *)responseData.bytes;
    
    switch ((PipelineCmdTypeResultSubcmd)header->subcmd) {
        case PipelineCmdTypeResultSubcmd_Success:
        {
            [self uploadSuccess:@"Upload Success" pipeline:pipeline];
        }
            break;
            
        default:
        {
            NSString *errorString = [NSString stringWithFormat:@"Upload verification failure"];
            [self uploadFailure:errorString pipeline:pipeline];
        }
            break;
    }
}

@end
