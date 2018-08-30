//
//  DJILiveViewRenderScaleFilter.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//


#import "DJILiveViewRenderScaleFilter.h"
#import "DJIVideoPresentViewAdjustHelper.h"

@interface DJILiveViewRenderScaleFilter ()
@property (nonatomic, strong) DJIVideoPresentViewAdjustHelper* helper;
@end

@implementation DJILiveViewRenderScaleFilter

-(id) initWithContext:(DJILiveViewRenderContext *)acontext{
    if (self = [super initWithContext:acontext]) {
        _helper = [[DJIVideoPresentViewAdjustHelper alloc] init];
        _helper.contentMode = VideoPresentContentModeAspectFill;
        _helper.contentClipRect = CGRectMake(0, 0, 1, 1);
    }
    
    return self;
}

//override
-(CGSize) sizeOfFBO{
    return _targetSize;
}

-(void) newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex{
    DJILiveViewFrameBuffer* inputBuffer = firstInputFramebuffer;
    
    GLfloat imageVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    //scale vertics to fit input buffer size
    //currently does not support rotation
    CGSize inputBufferSize = inputBuffer.size;
    CGSize outputBufferSize = [self sizeOfFBO];
    
    if (inputBufferSize.width != 0
        && inputBufferSize.height != 0
        && outputBufferSize.width != 0
        && outputBufferSize.height != 0)
    {
        //fit input inside ouput
        _helper.boundingFrame = CGRectMake(0, 0, outputBufferSize.width, outputBufferSize.height);
        _helper.videoSize = inputBufferSize;
        
        CGRect finalFrame = [_helper getFinalFrame];
        
        //convert to vertex
        CGFloat vertex_w = 2.0*(finalFrame.size.width/outputBufferSize.width);
        CGFloat vertex_h = 2.0*(finalFrame.size.height/outputBufferSize.height);
        CGFloat offset_x = 2.0*(finalFrame.origin.x/outputBufferSize.width);
        CGFloat offset_y = 2.0*(finalFrame.origin.y/outputBufferSize.height);
        
        imageVertices[0] = -1.0 + offset_x;
        imageVertices[1] = -1.0 + offset_y;
        
        imageVertices[2] = vertex_w + imageVertices[0];
        imageVertices[3] = imageVertices[1];
        
        imageVertices[4] = imageVertices[0];
        imageVertices[5] = imageVertices[1] + vertex_h;
        
        imageVertices[6] = imageVertices[2];
        imageVertices[7] = imageVertices[5];
    }
    
    [self renderToTextureWithVertices:imageVertices textureCoordinates:[[self class] textureCoordinatesForRotation:VideoStreamRotationDefault]];
    
    [self informTargetsAboutNewFrameAtTime:frameTime];
}
@end
