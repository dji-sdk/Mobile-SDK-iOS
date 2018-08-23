//
//  DJIVTH264Encoder.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIVTH264CompressConfiguration.h"
#import "DJIVideoPoolStructs.h"
#import "DJIVTH264Compressor.h"


@class DJIVTH264Encoder;

@protocol DJIVTH264EncoderOutput <NSObject>

@required

- (BOOL)vtH264Encoder:(DJIVTH264Encoder *)encoder output:(VideoFrameH264Raw *)packet;

@end


@interface DJIVTH264Encoder : NSObject

@property (nonatomic, weak) id <DJIVTH264EncoderOutput> delegate;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong, readonly) NSData* currentSps;
@property (nonatomic, strong, readonly) NSData* currentPps;
@property (nonatomic, assign, readonly) NSUInteger inputVideoFrameNum;
@property (nonatomic, assign, readonly) NSUInteger outputVideoFrameNum;

@property (nonatomic, assign) DJIVideoStreamBasicInfo streamInfo;

- (instancetype)initWithConfig:(DJIVTH264CompressConfiguration *)config delegate:(id <DJIVTH264EncoderOutput>)delegate;

- (void)invalidate;


#pragma mark - Input

- (void)pushVideoFrame:(VideoFrameYUV*)frame;

- (void)pushAudioPacket:(AudioFrameAACRaw*)packet;



@end
