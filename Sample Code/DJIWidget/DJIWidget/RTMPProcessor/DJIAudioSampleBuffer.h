//
//  DJIAudioSampleBuffer.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface DJIAudioSampleBuffer : NSObject
-(id) init;
-(void) audioBufferPush:(const short *)audio count:(int)num_samples;
-(int) audioBufferSize;
-(void) audioBufferPop:(int)num_samples;
-(float*) audioBufferGet;
-(void) audioBufferClear;
@end

@interface DJIP3AudioByteBuffer : NSObject
-(id) init;
-(int) audioBufferPush:(const uint8_t *)audio count:(int)num_samples;
-(int) audioBufferPushFloat:(Float32*)sample count:(int)num_samples;
-(int) audioBufferPushFloat:(Float32**)channels channel:(int)channel sampleCount:(int)num_sample;
-(int) audioBufferSize;
-(void) audioBufferPop:(int)bytes;
-(uint8_t*) audioBufferGet;
-(void) audioBufferClear;
@end
