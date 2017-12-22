//
//  SoftwareDecodeProcessor.m
//
//  Copyright (c) 2015 DJI. All rights reserved.
//


#import "SoftwareDecodeProcessor.h"
#define RENDER_FRAME_NUMBER (2)

@interface SoftwareDecodeProcessor (){
    VideoFrameYUV *_renderYUVFrame[RENDER_FRAME_NUMBER];
    int _decodeFrameIndex;   //decoding frame index
}

@property (nonatomic, strong) VideoFrameExtractor* extractor;
@end

@implementation SoftwareDecodeProcessor

-(id) initWithExtractor:(VideoFrameExtractor*)extractor{
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
    __weak SoftwareDecodeProcessor* weakself = self;
    
    //decode
    [_extractor decodeRawFrame:frame callback:^(BOOL hasPicture) {
        if (!weakself) {
            return;
        }
        
        if (hasPicture) {
            //render
            [weakself.extractor getYuvFrame:_renderYUVFrame[_decodeFrameIndex]];
            [weakself.frameProcessor videoProcessFrame:_renderYUVFrame[_decodeFrameIndex]];

            _decodeFrameIndex = (++_decodeFrameIndex)%RENDER_FRAME_NUMBER;
            
        }else{
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
