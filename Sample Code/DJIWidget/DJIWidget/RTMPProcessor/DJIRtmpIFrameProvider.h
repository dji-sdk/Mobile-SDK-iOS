//
//  DJIIFrameProvider.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJIWidget/DJIStreamCommon.h>

typedef NS_ENUM(NSUInteger, DJIRtmpIFrameProviderStatus) {
    DJIRtmpIFrameProviderStatusNotStartYet, // not yet started creating an iframe
    DJIRtmpIFrameProviderStatusProcessing, // processing iframes
    DJIRtmpIFrameProviderStatusFinish, // processing frame is completed
};


/*
  This class is used to read the iframe coded by the encoder and save it, provided to ffmpeg to create codec_context for live streaming
 */

@interface DJIRtmpIFrameProvider : NSObject

@property (nonatomic, assign, readonly) DJIRtmpIFrameProviderStatus status;

@property (nonatomic, strong, readonly) NSData* extraData; // sps and pps information

- (void)processFrame:(VideoFrameH264Raw *)frame sps:(NSData *)sps pps:(NSData *)pps;

- (NSString *)iFrameFilePath;

- (void)reset;

@end
