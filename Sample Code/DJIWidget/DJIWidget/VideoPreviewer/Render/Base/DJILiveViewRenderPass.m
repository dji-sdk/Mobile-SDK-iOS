//
//  DJILiveViewRenderPass.m
//

#import "DJILiveViewRenderPass.h"

@implementation DJILiveViewRenderPass

- (id)initWithContext:(DJILiveViewRenderContext *)aContext;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    context = aContext;
    targets = [[NSMutableArray alloc] init];
    targetTextureIndices = [[NSMutableArray alloc] init];
    _outputTextureOptions = defaultOptionsForTexture();
    _enabled = YES;
    
    return self;
}

-(void) releaseResources{
    if(outputFramebuffer.released == NO){
        
        [context useAsCurrentContext];
        [outputFramebuffer destroyFramebuffer];
    }
    self.released = YES;
}

- (void)dealloc
{
    [self removeAllTargets];
}

#pragma mark -
#pragma mark Managing targets

- (void)setInputFramebufferForTarget:(id<DJILiveViewRenderInput>)target
                             atIndex:(NSInteger)inputTextureIndex;
{
    [target setInputFramebuffer:[self framebufferForOutput] atIndex:inputTextureIndex];
}

- (DJILiveViewFrameBuffer *)framebufferForOutput;
{
    return outputFramebuffer;
}

- (void)removeOutputFramebuffer;
{
    outputFramebuffer = nil;
}

- (void)notifyTargetsAboutNewOutputTexture;
{
    for (id<DJILiveViewRenderInput> currentTarget in targets)
    {
        NSInteger indexOfObject = [targets indexOfObject:currentTarget];
        NSInteger textureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
        
        [self setInputFramebufferForTarget:currentTarget atIndex:textureIndex];
    }
}

- (NSArray*)targets;
{
    return [NSArray arrayWithArray:targets];
}


- (void)addTarget:(id<DJILiveViewRenderInput>)newTarget atTextureLocation:(NSInteger)textureLocation;
{
    if([targets containsObject:newTarget])
    {
        return;
    }
    
    [self setInputFramebufferForTarget:newTarget atIndex:textureLocation];
    [targets addObject:newTarget];
    [targetTextureIndices addObject:[NSNumber numberWithInteger:textureLocation]];
}

- (void)removeTarget:(id<DJILiveViewRenderInput>)targetToRemove;
{
    if(![targets containsObject:targetToRemove])
    {
        return;
    }
    
    NSInteger indexOfObject = [targets indexOfObject:targetToRemove];
    NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
    
    [targetToRemove setInputSize:CGSizeZero atIndex:textureIndexOfTarget];
    [targetTextureIndices removeObjectAtIndex:indexOfObject];
    [targets removeObject:targetToRemove];
    [targetToRemove endProcessing];
}

- (void)removeAllTargets;
{
    for (id<DJILiveViewRenderInput> targetToRemove in targets)
    {
        NSInteger indexOfObject = [targets indexOfObject:targetToRemove];
        NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
        
        [targetToRemove setInputSize:CGSizeZero atIndex:textureIndexOfTarget];
    }
    [targets removeAllObjects];
    [targetTextureIndices removeAllObjects];
}

#pragma mark -
#pragma mark Manage the output texture

- (void)forceProcessingAtSize:(CGSize)frameSize;
{
    
}

- (void)forceProcessingAtSizeRespectingAspectRatio:(CGSize)frameSize;
{
}

- (CGImageRef)newCGImageFromCurrentlyProcessedOutput;
{
    DJILiveViewFrameBuffer* framebuffer = [self framebufferForOutput];
    CGImageRef image = [framebuffer newCGImageFromFramebufferContents];
    return image;
}

#pragma mark -
#pragma mark Platform-specific image output methods

- (UIImage *)imageFromCurrentFramebuffer;
{
    UIImageOrientation imageOrientation = UIImageOrientationUp;
    return [self imageFromCurrentFramebufferWithOrientation:imageOrientation];
}

- (UIImage *)imageFromCurrentFramebufferWithOrientation:(UIImageOrientation)imageOrientation;
{
    CGImageRef cgImageFromBytes = [self newCGImageFromCurrentlyProcessedOutput];
    UIImage *finalImage = [UIImage imageWithCGImage:cgImageFromBytes scale:1.0 orientation:imageOrientation];
    CGImageRelease(cgImageFromBytes);
    
    return finalImage;
}


@end
