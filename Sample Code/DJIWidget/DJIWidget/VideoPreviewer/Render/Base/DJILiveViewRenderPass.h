//
//  DJILiveViewRenderPass.h
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "DJILiveViewFrameBuffer.h"
#import "DJILiveViewRenderContext.h"

@protocol DJILiveViewRenderInput <NSObject>
- (BOOL)enabled;

- (void)setInputSize:(CGSize)newSize
             atIndex:(NSInteger)textureIndex;

- (void)setInputFramebuffer:(DJILiveViewFrameBuffer *)newInputFramebuffer
                    atIndex:(NSInteger)textureIndex;

- (void)newFrameReadyAtTime:(CMTime)frameTime
                    atIndex:(NSInteger)textureIndex;

- (void)endProcessing;
@end

/*
 * a render pass is a step of render, with at least one texture input, one for output
 */
@interface DJILiveViewRenderPass : NSObject{
    DJILiveViewRenderContext* context;
    DJILiveViewFrameBuffer *outputFramebuffer;
    NSMutableArray *targets, *targetTextureIndices;
    CGSize inputTextureSize, forcedMaximumSize;
    BOOL overrideInputSize;
    BOOL usingNextFrameForImageCapture;
}

@property (assign, nonatomic) BOOL enabled;
@property (assign, nonatomic) BOOL released;
@property (assign, nonatomic) DJILiveViewRenderTextureOptions outputTextureOptions;

-(instancetype) initWithContext:(DJILiveViewRenderContext*)context;

/*
 * call before dealloc
 */
-(void) releaseResources;

/** Adds a target to receive notifications when new frames are available.
 
 See [GPUImageInput newFrameReadyAtTime:]
 
 @param newTarget Target to be added
 */
- (void)addTarget:(id<DJILiveViewRenderInput>)newTarget atTextureLocation:(NSInteger)textureLocation;

/** Removes a target. The target will no longer receive notifications when new frames are available.
 
 @param targetToRemove Target to be removed
 */
- (void)removeTarget:(id<DJILiveViewRenderInput>)targetToRemove;

/** Removes all targets.
 */
- (void)removeAllTargets;

- (void)setInputFramebufferForTarget:(id<DJILiveViewRenderInput>)target
                             atIndex:(NSInteger)inputTextureIndex;

#pragma mark - result output
- (DJILiveViewFrameBuffer*) framebufferForOutput;
- (CGImageRef)newCGImageFromCurrentlyProcessedOutput;
- (UIImage *)imageFromCurrentFramebuffer;
@end
