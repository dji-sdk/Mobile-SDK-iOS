//
//  PipelineDuplexLogic.h
//  DJISdkDemo
//
//  Copyright © 2020 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PipelineStatistical.h"
#import <DJISDK/DJISDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface PipelineDuplexLogic : NSObject

@property (atomic) PipelineStatistical *uploadStatistical;

@property (atomic) PipelineStatistical *downloadStatistical;

@property (nonatomic) BOOL isUploadTransmissionSuccessful;

@property (nonatomic) BOOL isDownloadTransmissionSuccessful;

@property (nonatomic) BOOL isUploadTransimssionFailure;

@property (nonatomic) BOOL isDownloadTransimssionFailure;

@property (atomic) BOOL stopDownload;

@property (atomic) BOOL isDownloading;

@property (atomic) BOOL stopUpload;

@property (atomic) BOOL isUploading;

@property (nonatomic) NSString *downloadTitle;

@property (nonatomic) NSString *uploadTitle;

@property (nonatomic, nullable) NSString *downloadFinalResult;

@property (nonatomic, nullable) NSString *uploadFinalResult;

- (void)download:(NSString *)fileName
   localFilePath:(NSString *)localStoragePath
        pipeline:(DJIPipeline *)pipeline
 withFinishBlock:(void (^)())finishBlock
withFailureBlock:(void(^)(DJIPipeline *_Nullable pipeline, NSString *_Nullable error))failureBlock;

- (void)stopDownload:(DJIPipeline *_Nullable)pipeline;

- (void)uploadFile:(NSString *)filePath
          pipeline:(DJIPipeline *)pipeline
       pieceLength:(NSInteger)pieceLength
         frequency:(double)frequency
   withFinishBlock:(void (^)())finishBlock
  withFailureBlock:(void(^)(DJIPipeline *_Nullable pipeline, NSString *_Nullable error))failureBlock;

- (void)stopUpload:(DJIPipeline *_Nullable)pipeline;

@end

NS_ASSUME_NONNULL_END
