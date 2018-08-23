//
//  DJISoftwareDecodeProcessor.m
//
//  Copyright (c) 2015 DJI. All rights reserved.
//


#import "DJISoftwareDecodeProcessor.h"
#define RENDER_FRAME_NUMBER (2)

@interface DJISoftwareDecodeProcessor (){
    VideoFrameYUV *_renderYUVFrame[RENDER_FRAME_NUMBER];
    int _decodeFrameIndex;   //decoding frame index
}

@property (nonatomic, strong) DJICustomVideoFrameExtractor* extractor;
@end

@implementation DJISoftwareDecodeProcessor

-(id) initWithExtractor:(DJICustomVideoFrameExtractor*)extractor{
    self = [super init];
    if (self) {
        _extractor = extractor;
        _enabled = YES;
        
        for(int i = 0;i<RENDER_FRAME_NUMBER;i++){
            _renderYUVFrame[i] = (VideoFrameYUV *)malloc(sizeof(VideoFrameYUV));
            memset(_renderYUVFrame[i], 0, sizeof(VideoFrameYUV));
        }
    }
    return self;
}

-(void) dealloc{
    for(int i = 0;i<RENDER_FRAME_NUMBER;i++){
        if (_renderYUVFrame[i]) {
            if (_renderYUVFrame[i]->luma) {
                free(_renderYUVFrame[i]->luma);
            }
            if (_renderYUVFrame[i]->chromaB) {
                free(_renderYUVFrame[i]->chromaB);
            }
            if (_renderYUVFrame[i]->chromaR) {
                free(_renderYUVFrame[i]->chromaR);
            }
            free(_renderYUVFrame[i]);
            _renderYUVFrame[i] = NULL;
        }
    }
}

-(BOOL) streamProcessorHandleFrame:(uint8_t *)data size:(int)size{
    return NO;
}

-(BOOL) streamProcessorHandleFrameRaw:(VideoFrameH264Raw *)frame{
    __block BOOL decodeSuccess = YES;
    __weak DJISoftwareDecodeProcessor* weakself = self;
    
    //decode
    [_extractor decodeRawFrame:frame callback:^(BOOL hasPicture) {
        if (!weakself) {
            return;
        }
        
        if (hasPicture) {
            //render
            [weakself.extractor getYuvFrame:self->_renderYUVFrame[_decodeFrameIndex]];
            [weakself.frameProcessor videoProcessFrame:self->_renderYUVFrame[_decodeFrameIndex]];
            
            _decodeFrameIndex = (++_decodeFrameIndex)%RENDER_FRAME_NUMBER;
            
        }
        else{
            decodeSuccess = NO;
        }
    }];
    
    return decodeSuccess;
}

-(void) streamProcessorInfoChanged:(DJIVideoStreamBasicInfo *)info{
    //do nothing
}

-(DJIVideoStreamProcessorType) streamProcessorType{
    return DJIVideoStreamProcessorType_Decoder;
}

-(BOOL) streamProcessorEnabled{
    return self.enabled;
}

@end
