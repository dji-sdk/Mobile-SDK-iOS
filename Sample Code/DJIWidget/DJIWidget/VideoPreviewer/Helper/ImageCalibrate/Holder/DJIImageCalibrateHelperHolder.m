//
//  DJIImageCalibrateHelperHolder.m
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIImageCalibrateHelperHolder.h"

@implementation DJIImageCalibrateHelperHolder

- (BOOL)enabled{
    id<DJILiveViewRenderInput> target = _target;
    if (target != nil
        && [target respondsToSelector:_cmd]){
        return [target enabled];
    }
    return NO;
}

- (void)setInputSize:(CGSize)newSize
             atIndex:(NSInteger)textureIndex{
    if (![self enabled]){
        return;
    }
    id<DJILiveViewRenderInput> target = _target;
    if (target != nil
        && [target respondsToSelector:_cmd]){
        [target setInputSize:newSize
                     atIndex:textureIndex];
    }
}

- (void)setInputFramebuffer:(DJILiveViewFrameBuffer *)newInputFramebuffer
                    atIndex:(NSInteger)textureIndex{
    if (![self enabled]){
        return;
    }
    id<DJILiveViewRenderInput> target = _target;
    if (target != nil
        && [target respondsToSelector:_cmd]){
        [target setInputFramebuffer:newInputFramebuffer
                            atIndex:textureIndex];
    }
}

- (void)newFrameReadyAtTime:(CMTime)frameTime
                    atIndex:(NSInteger)textureIndex{
    if (![self enabled]){
        return;
    }
    id<DJILiveViewRenderInput> target = _target;
    if (target != nil
        && [target respondsToSelector:_cmd]){
        [target newFrameReadyAtTime:frameTime
                            atIndex:textureIndex];
    }
}

- (void)endProcessing{
    if (![self enabled]){
        return;
    }
    id<DJILiveViewRenderInput> target = _target;
    if (target != nil
        && [target respondsToSelector:_cmd]){
        [target endProcessing];
    }
}

@end

