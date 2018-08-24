//
//  DJIImageCalibrateColorConverter_Private.h
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#ifndef DJIImageCalibrateColorConverter_Private_h
#define DJIImageCalibrateColorConverter_Private_h

#import "DJIImageCalibrateColorConverter.h"

@interface DJIImageCalibrateColorConverter(){
    DJIImageCalibrateColorConverterHolder* _holder;
}
//output type
@property (nonatomic,assign) VPFrameType type;

//call back delegate
-(void)handlerYUVData:(uint8_t**)yuvData
          andYUVSlice:(int*)slice
       withFastUpload:(CVPixelBufferRef)fastUpload;

//holder
- (BOOL)enabledColorConverter;

- (void)setColorConverterInputSize:(CGSize)newSize
                           atIndex:(NSInteger)textureIndex;

- (void)setColorConverterInputFramebuffer:(DJILiveViewFrameBuffer*)newInputFramebuffer
                                  atIndex:(NSInteger)textureIndex;

- (void)newColorConverterFrameReadyAtTime:(CMTime)frameTime
                                  atIndex:(NSInteger)textureIndex;

- (void)endProcessingColorConverter;

@end

#endif /* DJIImageCalibrateColorConverter_Private_h */
