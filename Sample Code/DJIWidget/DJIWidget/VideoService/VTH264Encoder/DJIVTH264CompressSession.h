//
//  DJIVTH264CompressSession.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIVTH264CompressConfiguration.h"
#import <CoreMedia/CoreMedia.h>




@class DJIVTH264CompressSession;


@protocol DJIVTH264CompressSessionDelegate <NSObject>

@required

- (void)vth264compressSession:(DJIVTH264CompressSession *)session
  didCompressWithSampleBuffer:(CMSampleBufferRef)sampleBuffer
                       status:(OSStatus)status;


@end


@interface DJIVTH264CompressSession : NSObject

@property (nonatomic, weak) id <DJIVTH264CompressSessionDelegate> delegate;
@property (nonatomic, assign, readonly) int width;
@property (nonatomic, assign, readonly) int height;
@property (nonatomic, assign, readonly) BOOL isPrepared;

- (instancetype)initWithWidth:(int)width height:(int)height;
- (BOOL)prepareEncode;

- (OSStatus)encodeWithCVPixelBuffer:(CVPixelBufferRef)imageBuffer
                   presentationTime:(CMTime)presentationTimeStamp
                           duration:(CMTime)duration
                  sourceFrameRefCon:(void *)sourceFrameRefCon
                      shouldRelease:(BOOL)released;

- (void)setupWithConfig:(DJIVTH264CompressConfiguration *)config;
@end



