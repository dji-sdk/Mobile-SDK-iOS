//
//  RecordingHandler.m
//  DJISdkDemo
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import "RecordingHandler.h"
#import <AudioToolbox/AudioToolbox.h>

@interface RecordingHandler ()

@property (nonatomic) Float64 sampleRate;
@property (nonatomic) UInt32 channelPerFrame;

@property (nonatomic) AudioComponentInstance audioUnit;
@property (nonatomic) AudioStreamBasicDescription pcmDesc;

@end

@implementation RecordingHandler

- (instancetype)initWithSampleRate:(Float64)sampleRate channelsPerFrame:(UInt32)channelPerFrame {
    self = [super init];
    if (self) {
        self->_channelPerFrame = channelPerFrame;
        self->_sampleRate = sampleRate;
        self->_pcmDesc = [self setupPCMDesc];
        [self setupAudioUnit];
    }
    return self;
}

- (void)start {
    OSStatus status = AudioOutputUnitStart(self.audioUnit);
    if (status != noErr) {
        NSLog(@"Failed to start microphone!");
    } else {
        self.isRecording = YES;
    }
}

- (void)stop {
    AudioOutputUnitStop(self.audioUnit);
    self.isRecording = NO;
}

- (AudioStreamBasicDescription)setupPCMDesc {
    AudioStreamBasicDescription pcmDesc = {0};
    pcmDesc.mSampleRate = self.sampleRate;
    pcmDesc.mFormatID = kAudioFormatLinearPCM;
    pcmDesc.mFormatFlags = (kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked);
    pcmDesc.mChannelsPerFrame = self.channelPerFrame;
    pcmDesc.mFramesPerPacket = 1;
    pcmDesc.mBitsPerChannel = 16;
    pcmDesc.mBytesPerFrame = pcmDesc.mBitsPerChannel / 8 * pcmDesc.mChannelsPerFrame;
    pcmDesc.mBytesPerPacket = pcmDesc.mBytesPerFrame * pcmDesc.mFramesPerPacket;
    pcmDesc.mReserved = 0;
    return pcmDesc;
}

- (void)setupAudioUnit {
    
    AudioComponentDescription component;
    component.componentType = kAudioUnitType_Output;
    component.componentSubType = kAudioUnitSubType_RemoteIO;
    component.componentManufacturer = kAudioUnitManufacturer_Apple;
    component.componentFlags = 0;
    component.componentFlagsMask = 0;
    
    AudioComponent m_component = AudioComponentFindNext(NULL, &component);
    AudioComponentInstanceNew(m_component, &self->_audioUnit);
    if (!self.audioUnit) {
        NSLog(@"AudioComponentInstanceNew Fail !!");
        return;
    }
    
    UInt32 flagOne = 1;
    AudioUnitSetProperty(self.audioUnit, kAudioOutputUnitProperty_EnableIO,
                         kAudioUnitScope_Input,
                         1,
                         &flagOne,
                         sizeof(flagOne));
    
    AURenderCallbackStruct cb;
    cb.inputProcRefCon = (__bridge void * _Nullable)(self);
    cb.inputProc = inputProc;
    AudioUnitSetProperty(self.audioUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Output,
                         1,
                         &_pcmDesc,
                         sizeof(_pcmDesc));
    
    AudioUnitSetProperty(self.audioUnit,
                         kAudioOutputUnitProperty_SetInputCallback,
                         kAudioUnitScope_Global,
                         1,
                         &cb,
                         sizeof(cb));
    
    AudioUnitInitialize(self.audioUnit);
    
}

static OSStatus inputProc(void *inRefCon,
                          AudioUnitRenderActionFlags *ioActionFlags,
                          const AudioTimeStamp *inTimeStamp,
                          UInt32 inBusNumber,
                          UInt32 inNumberFrames,
                          AudioBufferList *ioData) {
    
    RecordingHandler *src = (__bridge RecordingHandler*)inRefCon;
    
    AudioBuffer buffer;
    buffer.mData = NULL;
    buffer.mDataByteSize = 0;
    buffer.mNumberChannels = src.pcmDesc.mChannelsPerFrame;
    
    AudioBufferList buffers;
    buffers.mNumberBuffers = 1;
    buffers.mBuffers[0] = buffer;
    
    OSStatus status = AudioUnitRender(src.audioUnit,
                                      ioActionFlags,
                                      inTimeStamp,
                                      inBusNumber,
                                      inNumberFrames,
                                      &buffers);
    if (status == noErr) {
        [src handleInputData:buffers.mBuffers[0].mData size:buffers.mBuffers[0].mDataByteSize frameCount:inNumberFrames];
    }
    return status;
}

- (void)handleInputData:(void *)pcmBuf size:(int)pcmSize frameCount:(int)inNumberFrames {
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordingHandler:output:)]) {
        [self.delegate recordingHandler:self output:[[NSData alloc] initWithBytes:pcmBuf length:pcmSize]];
    }
}

@end
