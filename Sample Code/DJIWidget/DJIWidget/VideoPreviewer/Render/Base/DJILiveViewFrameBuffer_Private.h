//
//  DJILiveViewFrameBuffer_Private.h
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#ifndef DJILiveViewFrameBuffer_Private_h
#define DJILiveViewFrameBuffer_Private_h

#import "DJILiveViewFrameBuffer.h"
#import "DJILiveViewRenderContext.h"

@interface DJILiveViewFrameBuffer(){
    GLuint framebuffer;
    CVPixelBufferRef renderTarget;
    CVOpenGLESTextureRef renderTexture;
    NSUInteger readLockCount;
    NSUInteger framebufferReferenceCount;
    BOOL referenceCountingDisabled;
}

@property (nonatomic, strong) DJILiveViewRenderContext* context;

- (void)generateFramebuffer;
- (void)generateTexture;
- (void)destroyFramebuffer;
- (CVPixelBufferRef)privateRenderTarget;

@end

#endif /* DJILiveViewFrameBuffer_Private_h */
