//
//  DJIImageCalibrateColorConverter.m
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import "DJIImageCalibrateColorConverter_Private.h"

@implementation DJIImageCalibrateColorConverterHolder

- (BOOL)enabled{
    DJIImageCalibrateColorConverter* target = _converter;
    if (target != nil){
        return [target enabledColorConverter];
    }
    return NO;
}

- (void)setInputSize:(CGSize)newSize
             atIndex:(NSInteger)textureIndex{
    if (![self enabled]){
        return;
    }
    DJIImageCalibrateColorConverter* target = _converter;
    if (target != nil){
        [target setColorConverterInputSize:newSize
                     atIndex:textureIndex];
    }
}

- (void)setInputFramebuffer:(DJILiveViewFrameBuffer *)newInputFramebuffer
                    atIndex:(NSInteger)textureIndex{
    if (![self enabled]){
        return;
    }
    DJIImageCalibrateColorConverter* target = _converter;
    if (target != nil){
        [target setColorConverterInputFramebuffer:newInputFramebuffer
                            atIndex:textureIndex];
    }
}

- (void)newFrameReadyAtTime:(CMTime)frameTime
                    atIndex:(NSInteger)textureIndex{
    if (![self enabled]){
        return;
    }
    DJIImageCalibrateColorConverter* target = _converter;
    if (target != nil){
        [target newColorConverterFrameReadyAtTime:frameTime
                            atIndex:textureIndex];
    }
}

- (void)endProcessing{
    if (![self enabled]){
        return;
    }
    DJIImageCalibrateColorConverter* target = _converter;
    if (target != nil){
        [target endProcessingColorConverter];
    }
}

@end

@implementation DJIImageCalibrateColorConverter

-(void)dealloc{
    [self prepareToClean];
}

-(instancetype)initWithFrameType:(VPFrameType)type{
    if (self = [self init]){
        self.type = type;
    }
    return self;
}

-(instancetype)init{
    if (self = [super init]){
        _holder = nil;
        _type = VPFrameTypeRGBA;
        _enabledConverter = NO;
    }
    return self;
}

#pragma mark - holder
-(DJIImageCalibrateColorConverterHolder*)holder{
    if (!_holder){
        _holder = [[DJIImageCalibrateColorConverterHolder alloc] init];
        _holder.converter = self;
    }
    return _holder;
}

#pragma mark - call by holder
- (BOOL)enabledColorConverter{
    return _enabledConverter;
}

- (void)setColorConverterInputSize:(CGSize)newSize
                           atIndex:(NSInteger)textureIndex{
    return;
}

- (void)setColorConverterInputFramebuffer:(DJILiveViewFrameBuffer *)newInputFramebuffer
                                  atIndex:(NSInteger)textureIndex{
    return;
}

- (void)newColorConverterFrameReadyAtTime:(CMTime)frameTime
                                  atIndex:(NSInteger)textureIndex{
    return;
}

- (void)endProcessingColorConverter{
    return;
}

//clean when dealloc
-(void)prepareToClean{
    return;
}

#pragma mark - call back delegate
-(void)handlerYUVData:(uint8_t**)yuvData
          andYUVSlice:(int*)slice
       withFastUpload:(CVPixelBufferRef)fastUpload{
    if (self.delegate != nil
        && [self.delegate respondsToSelector:@selector(colorConverter:passYUVData:yuvSlice:withFastload:)]){
        [self.delegate colorConverter:self
                          passYUVData:yuvData
                             yuvSlice:slice
                         withFastload:fastUpload];
    }
}

@end
