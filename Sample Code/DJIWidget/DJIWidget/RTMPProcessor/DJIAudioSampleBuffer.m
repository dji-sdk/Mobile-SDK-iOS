//
//  DJIAudioSampleBuffer.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import "DJIAudioSampleBuffer.h"

#pragma mark - audio buffer
#define AUDIO_MAX_BUF_SIZE 16384  //
#define AUDIO_MAX_BYTE_BUF_SIZE 16384*4*2 //

@interface DJIAudioSampleBuffer (){
    float g_audio_buf[AUDIO_MAX_BUF_SIZE];
    int g_audio_buf_size;
}
@end

@implementation DJIAudioSampleBuffer

-(id) init{
    if (self = [super init]) {
        g_audio_buf_size = 0;
    }
    return self;
}

-(void) audioBufferPush:(const short *)audio count:(int)num_samples{
    num_samples = MIN(num_samples, AUDIO_MAX_BUF_SIZE - (num_samples + g_audio_buf_size));
    if (num_samples <= 0) {
        return;
    }
    
    if (audio) {
        for (int i = 0; i < num_samples; i++) {
            g_audio_buf[g_audio_buf_size++] = (audio[i]/(float)SHRT_MAX);
        }
    }
    else{
        for (int i = 0; i < num_samples; i++) {
            g_audio_buf[g_audio_buf_size++] = 0;
        }
    }
}

-(int) audioBufferSize{
    return g_audio_buf_size;
}

-(float*) audioBufferGet{
    return g_audio_buf;
}

-(void) audioBufferPop:(int)num_samples {
    if (num_samples > g_audio_buf_size) {
        g_audio_buf_size = 0;
        return;
    }
    
    g_audio_buf_size -= num_samples;
    memmove(g_audio_buf, g_audio_buf + num_samples, g_audio_buf_size * sizeof(g_audio_buf[0]));
}

-(void)audioBufferClear{
    memset(g_audio_buf, 0, sizeof(g_audio_buf));
    g_audio_buf_size = 0;
}

@end

#pragma mark - audio byte buffer

@interface DJIP3AudioByteBuffer (){
    uint8_t g_audio_buf[AUDIO_MAX_BYTE_BUF_SIZE];
    int g_audio_buf_size;
}
@end

@implementation DJIP3AudioByteBuffer

-(id) init{
    if (self = [super init]) {
        g_audio_buf_size = 0;
    }
    return self;
}

-(int) audioBufferPush:(const uint8_t *)audio count:(int)length{
    length = MIN(length, AUDIO_MAX_BYTE_BUF_SIZE - (length+g_audio_buf_size));
    if (length <= 0) {
        return 0;
    }
    
    if (audio) {
        memcpy(g_audio_buf + g_audio_buf_size, audio, length);
    }
    else{
        memset(g_audio_buf + g_audio_buf_size, 0, length);
    }
    
    g_audio_buf_size += length;
    return length;
}

-(int) audioBufferPushFloat:(Float32*)sample count:(int)num_samples{
    int length = MIN(num_samples*2, AUDIO_MAX_BYTE_BUF_SIZE - (num_samples*2+g_audio_buf_size));
    if (length <= 0) {
        return 0;
    }
    
    if (sample) {
        short* buf = (short*)(g_audio_buf+g_audio_buf_size);
        for (int i=0; i<num_samples; i++) {
            short val = (short)(sample[i]*32767.0);
            buf[i] = val;
        }
    }
    else{
        memset(g_audio_buf + g_audio_buf_size, 0, length);
    }
    
    g_audio_buf_size += length;
    return length;
}

-(int) audioBufferPushFloat:(Float32**)channels channel:(int)channel sampleCount:(int)num_samples{
    int length = MIN(channel*num_samples*2, AUDIO_MAX_BYTE_BUF_SIZE - (channel*num_samples*2+g_audio_buf_size));
    if (length <= 0) {
        return 0;
    }
    
    if (channels) {
        short* buf = (short*)(g_audio_buf+g_audio_buf_size);
        for (int i=0; i<num_samples; i++) {
            for (int c=0; c<channel; c++) {
                short val = (short)(channels[c][i]*32767.0);
                *buf = val;
                buf++;
            }
        }
    }
    else{
        memset(g_audio_buf + g_audio_buf_size, 0, length);
    }
    
    g_audio_buf_size += length;
    return length;
}

-(int) audioBufferSize{
    return g_audio_buf_size;
}

-(uint8_t*) audioBufferGet{
    return g_audio_buf;
}

-(void) audioBufferPop:(int)bytes {
    if (bytes > g_audio_buf_size) {
        g_audio_buf_size = 0;
        return;
    }
    
    g_audio_buf_size -= bytes;
    memmove(g_audio_buf, g_audio_buf + bytes, g_audio_buf_size * sizeof(g_audio_buf[0]));
}

-(void)audioBufferClear{
    memset(g_audio_buf, 0, sizeof(g_audio_buf));
    g_audio_buf_size = 0;
}

@end
