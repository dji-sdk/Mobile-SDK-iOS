//
//  DJILB2AUDRemoveParser.m
//
//  Copyright (c) 2013 DJI. All rights reserved.
//

/**
 *  A workaround for Lightbridge 2's video feed.
 */

#import "DJILB2AUDRemoveParser.h"

typedef enum : NSUInteger {
    DJILB2AUDRemoveParserStatus_SeekNAL, //searching nal
    DJILB2AUDRemoveParserStatus_SeekAUD, //searching aud
    DJILB2AUDRemoveParserStatus_SeekFilter, //searching filter
} DJILB2AUDRemoveParserStatus;

#define DATA_BUFFER_SIZE (1024*1024)
static const uint8_t g_DJILB2AUDRemoveParser_aud[] = {0x09, 0x10};
//static const uint8_t g_DJILB2AUDRemoveParser_filter[] = {0x00, 0x00, 0x00, 0x01, 0x0c};

@interface DJILB2AUDRemoveParser (){
    uint8_t* dataBuffer;
    int bufferSize;
}

@property (nonatomic, assign) DJILB2AUDRemoveParserStatus status;
@property (nonatomic, assign) int seekNALZeroCount; //counter for searching nal. init value is 0.
@property (nonatomic, assign) int seekAUDPos; //search aud's current position (in byte)
@end

@implementation DJILB2AUDRemoveParser
-(id) init{
    if (self = [super init]) {
        dataBuffer = (uint8_t*)malloc(DATA_BUFFER_SIZE);
        [self reset];
    }
    
    return self;
}

-(void) dealloc{
    if (dataBuffer) {
        free(dataBuffer);
    }
}

-(void) reset{
    _status = DJILB2AUDRemoveParserStatus_SeekNAL;
    bufferSize = 0;
    _seekAUDPos = 0;
    _seekNALZeroCount = 0;
}

-(void) parse:(void *)data_in inSize:(int)in_size{
    if (!data_in || in_size == 0) {
        [self flushBufferWithAppendData:nil size:0];
        return;
    }

    // if the end of aud is not 000000010c, then remove the aud
    int workOffset = 0;

    uint8_t* outputBuf = (uint8_t*)data_in;
    
    while (workOffset < in_size) {
        uint8_t current_byte = *((uint8_t*)data_in + workOffset);
        
        if (_status == DJILB2AUDRemoveParserStatus_SeekNAL) {
            // search nalu's head
            if (current_byte == 0) {
                _seekNALZeroCount++;
            }else if(current_byte == 1){
                if (_seekNALZeroCount >= 3) {
                    // nalu is found
                    self.status = DJILB2AUDRemoveParserStatus_SeekAUD;
                }else{
                    _seekNALZeroCount = 0;
                }
            }else{
                _seekNALZeroCount = 0;
            }
        }
        else if(_status == DJILB2AUDRemoveParserStatus_SeekAUD){
            // search aud
            if (current_byte == g_DJILB2AUDRemoveParser_aud[_seekAUDPos]) {
                // it is aud
                _seekAUDPos++;
                if (_seekAUDPos == sizeof(g_DJILB2AUDRemoveParser_aud)) {
                    // the aud is complete
                    self.status = DJILB2AUDRemoveParserStatus_SeekFilter;
                }
            }else{
                // not aud, continue to search
                self.status = DJILB2AUDRemoveParserStatus_SeekNAL;
            }
        }
        else if(_status == DJILB2AUDRemoveParserStatus_SeekFilter){
                //It is not a filer. Remove the aud found before
                if (workOffset > 6) {
                    //aud is in the same pack. For this case, skipping it is enough.
                    int outputSize = (workOffset - (int)(outputBuf - (uint8_t*)data_in)) - 6;
                    [self flushBufferWithAppendData:outputBuf size:outputSize];
                    
                    //skip aud
                    outputBuf = (uint8_t*)data_in + workOffset;
                }else{
                    int bufferSub = 6 - workOffset;
                    bufferSize -= bufferSub;
                    if (bufferSize < 0) {
                        bufferSize = 0;
                    }
                    
                    // Move the pointer
                    outputBuf = ((uint8_t*)data_in + workOffset);
                    //flush buffer
                    [self flushBufferWithAppendData:nil size:0];
                }
                
                workOffset--;
                self.status = DJILB2AUDRemoveParserStatus_SeekNAL;
        }
        
        workOffset++; // work on the next byte
    }
    
    //Finish parsing. Then we need to determine if data in buffer is usable.
    if (outputBuf - (uint8_t*)data_in < in_size) {
        int remainSize = in_size - (int)(outputBuf - (uint8_t*)data_in);
        
        if (_status == DJILB2AUDRemoveParserStatus_SeekNAL && _seekNALZeroCount == 0) {
            //If we are still searching nal, we assume the data is usable.
            [self flushBufferWithAppendData:outputBuf size:remainSize];
        }else{
            //We are still not sure if aud should remove or not. Then keep the data.
            [self pushBuffer:outputBuf size:remainSize];
        }
    }
}

-(void) setStatus:(DJILB2AUDRemoveParserStatus)status{
    _status = status;
    
    // reset the variable whenever the status changes
    _seekNALZeroCount = 0;
    _seekAUDPos = 0;
}

-(void) pushBuffer:(uint8_t*)data size:(int)size{
    if (!data || size == 0) {
        return;
    }
    
    // Cache data
    if (bufferSize + size > DATA_BUFFER_SIZE) { // overflow, flush the buffer
        [self flushBufferWithAppendData:nil size:0];
    }
    
    // If size is larger than the buffer size, discard the exceeding part.
    int writeSize = MIN(size, DATA_BUFFER_SIZE);
    memcpy(dataBuffer+bufferSize, data, writeSize);
    bufferSize += writeSize;
}

-(void) flushBufferWithAppendData:(uint8_t*)appand size:(int)size{
    if (![_delegate respondsToSelector:@selector(lb2AUDRemoveParser:didParsedData:size:)]) {
        bufferSize = 0;
        return;
    }
    
    // Output the data
    if (bufferSize) {
        //data in buffer first
        [_delegate lb2AUDRemoveParser:self didParsedData:dataBuffer size:bufferSize];
        bufferSize = 0;
    }
    
    if (appand && size != 0) {
        [_delegate lb2AUDRemoveParser:self didParsedData:appand size:size];
    }
}
@end
