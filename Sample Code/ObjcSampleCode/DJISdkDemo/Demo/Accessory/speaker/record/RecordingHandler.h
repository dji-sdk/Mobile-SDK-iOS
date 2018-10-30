//
//  RecordingHandler.h
//  DJISdkDemo
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RecordingHandler;

@protocol RecordingHandlerDelegate <NSObject>

- (void)recordingHandler:(RecordingHandler *)handler output:(NSData *)pcmData;

@end

@interface RecordingHandler : NSObject

@property (nonatomic, weak) id<RecordingHandlerDelegate> delegate;
@property (nonatomic) BOOL isRecording;

- (instancetype)initWithSampleRate:(Float64)sampleRate channelsPerFrame:(UInt32)channelPerFrame;

- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
