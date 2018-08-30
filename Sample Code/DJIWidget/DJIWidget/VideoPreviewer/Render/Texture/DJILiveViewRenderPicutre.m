//
//  DJILiveViewRenderPicutre.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//


#import "DJILiveViewRenderPicutre.h"
#import "DJILiveViewRenderTexture.h"

@interface DJILiveViewRenderPicutre ()
@property (nonatomic, strong) DJILiveViewRenderTexture* texture;
@end

@implementation DJILiveViewRenderPicutre

-(id) initWithContext:(DJILiveViewRenderContext *)acontext picture:(UIImage *)image{
    self = [super initWithContext:acontext];
    _texture = [[DJILiveViewRenderTexture alloc] initWithContext:acontext image:image];
    inputTextureSize = [_texture pixelSizeOfImage];
    return self;
}

-(void) render{
    [self newFrameReadyAtTime:kCMTimeZero atIndex:0];
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;
{
    if (self.preventRendering)
    {
        return;
    }
    
    [context setContextShaderProgram:filterProgram];
    CGSize FBOSize = [self sizeOfFBO];
    
    if (outputFramebuffer == nil
        || NO == CGSizeEqualToSize(FBOSize, self.framebufferForOutput.size)) {
        outputFramebuffer = [[DJILiveViewFrameBuffer alloc]
                             initWithContext:context
                             size:FBOSize
                             textureOptions:self.outputTextureOptions
                             onlyTexture:NO];
    }
    
    [outputFramebuffer activateFramebuffer];
    
    [self setUniformsForProgramAtIndex:0];
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [_texture texture]);
    
    glUniform1i(filterInputTextureUniform, 2);
    glEnableVertexAttribArray(filterPositionAttribute);
    glEnableVertexAttribArray(filterTextureCoordinateAttribute);
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


@end
