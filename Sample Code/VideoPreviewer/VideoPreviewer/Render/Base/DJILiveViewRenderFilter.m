//
//  DJILiveViewRenderFilter.m
//

#import "DJILiveViewRenderCommon.h"
#import "DJILiveViewRenderFilter.h"
#import <OpenGLES/ES2/gl.h>


NSString *const kDJIImageVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 varying vec2 textureCoordinate;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );


NSString *const kDJIImagePassthroughFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
 }
 );


@implementation DJILiveViewRenderFilter

@synthesize preventRendering = _preventRendering;

#pragma mark -
#pragma mark Initialization and teardown

- (id)initWithContext:(DJILiveViewRenderContext *)acontext
vertexShaderFromString:(NSString *)vertexShaderString
fragmentShaderFromString:(NSString *)fragmentShaderString
{
    if (!(self = [super initWithContext:acontext]))
    {
        return nil;
    }
    
    uniformStateRestorationBlocks = [NSMutableDictionary dictionaryWithCapacity:10];
    _preventRendering = NO;
    inputRotation = VideoStreamRotationDefault;
    backgroundColorRed = 0.0;
    backgroundColorGreen = 0.0;
    backgroundColorBlue = 0.0;
    backgroundColorAlpha = 0.0;
    
    [context useAsCurrentContext];
    
    filterProgram = [[DJILiveViewRenderProgram alloc]
                     initWithContext:context
                     vertexShaderString:vertexShaderString
                     fragmentShaderString:fragmentShaderString];
    
    if (!filterProgram.initialized)
    {
        [self initializeAttributes];
        
        if (![filterProgram link])
        {
            NSString *progLog = [filterProgram programLog];
            NSLog(@"Program link log: %@", progLog);
            NSString *fragLog = [filterProgram fragmentShaderLog];
            NSLog(@"Fragment shader compile log: %@", fragLog);
            NSString *vertLog = [filterProgram vertexShaderLog];
            NSLog(@"Vertex shader compile log: %@", vertLog);
            filterProgram = nil;
            NSAssert(NO, @"Filter shader link failed");
        }
    }
    
    filterPositionAttribute = [filterProgram attributeIndex:@"position"];
    filterTextureCoordinateAttribute = [filterProgram attributeIndex:@"inputTextureCoordinate"];
    filterInputTextureUniform = [filterProgram uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputImageTexture" for the fragment shader
    
    [context setContextShaderProgram:filterProgram];
    
    glEnableVertexAttribArray(filterPositionAttribute);
    glEnableVertexAttribArray(filterTextureCoordinateAttribute);
    
    return self;
}

- (id)initWithContext:(DJILiveViewRenderContext *)acontext fragmentShaderFromString:(NSString *)fragmentShaderString
{
    if (!(self = [self initWithContext:acontext
                vertexShaderFromString:kDJIImageVertexShaderString
              fragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

- (id)initWithContext:(DJILiveViewRenderContext*)acontext
fragmentShaderFromFile:(NSString *)fragmentShaderFilename;
{
    NSString *fragmentShaderPathname = [[NSBundle mainBundle] pathForResource:fragmentShaderFilename ofType:@"fsh"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:fragmentShaderPathname encoding:NSUTF8StringEncoding error:nil];
    
    if (!(self = [self initWithContext:acontext
              fragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

- (id)initWithContext:(DJILiveViewRenderContext*)acontext
{
    if (!(self = [self initWithContext:acontext
              fragmentShaderFromString:kDJIImagePassthroughFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

- (void)initializeAttributes;
{
    [filterProgram addAttribute:@"position"];
    [filterProgram addAttribute:@"inputTextureCoordinate"];
    
    // Override this, calling back to this super method, in order to add new attributes to your vertex shader
}

- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    // This is where you can override to provide some custom setup, if your filter has a size-dependent element
}

-(void)releaseResources{
    if(filterProgram.released == NO){
        [context useAsCurrentContext];
        [filterProgram destory];
    }
    [super releaseResources];
}

- (void)dealloc
{
    
}

#pragma mark -
#pragma mark Still image processing


- (CGImageRef)newCGImageFromCurrentlyProcessedOutput
{
    DJILiveViewFrameBuffer* framebuffer = [self framebufferForOutput];
    CGImageRef image = [framebuffer newCGImageFromFramebufferContents];
    return image;
}

#pragma mark -
#pragma mark Managing the display FBOs

- (CGSize)sizeOfFBO;
{
    CGSize outputSize = [self maximumOutputSize];
    if ( (CGSizeEqualToSize(outputSize, CGSizeZero)) || (inputTextureSize.width < outputSize.width) )
    {
        return inputTextureSize;
    }
    else
    {
        return outputSize;
    }
}

#pragma mark -
#pragma mark Rendering

#define GPUImageRotationSwapsWidthAndHeight(rotation) ((rotation) == VideoStreamRotationCW270 || (rotation) == VideoStreamRotationCW90)

+ (const GLfloat *)textureCoordinatesForRotation:(VideoStreamRotationType)rotationMode;
{
    switch(rotationMode)
    {
        case VideoStreamRotationDefault: return g_yuvQuadTexCoordsNormal;
        case VideoStreamRotationCW270: return g_yuvQuadTexCoords270CW;
        case VideoStreamRotationCW90: return g_yuvQuadTexCoords90CW;
        //case kGPUImageFlipVertical: return verticalFlipTextureCoordinates;
        //case kGPUImageFlipHorizonal: return horizontalFlipTextureCoordinates;
        //case kGPUImageRotateRightFlipVertical: return rotateRightVerticalFlipTextureCoordinates;
        //case kGPUImageRotateRightFlipHorizontal: return rotateRightHorizontalFlipTextureCoordinates;
        case VideoStreamRotationCW180: return g_yuvQuadTexCoords180CW;
    }
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
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    
    glUniform1i(filterInputTextureUniform, 2);
    glEnableVertexAttribArray(filterPositionAttribute);
    glEnableVertexAttribArray(filterTextureCoordinateAttribute);
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)informTargetsAboutNewFrameAtTime:(CMTime)frameTime;
{
    // Get all targets the framebuffer so they can grab a lock on it
    for (id<DJILiveViewRenderInput> currentTarget in targets)
    {
        NSInteger indexOfObject = [targets indexOfObject:currentTarget];
        NSInteger textureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
        
        [self setInputFramebufferForTarget:currentTarget atIndex:textureIndex];
        [currentTarget setInputSize:[self outputFrameSize] atIndex:textureIndex];
    }
    
    // Trigger processing last, so that our unlock comes first in serial execution, avoiding the need for a callback
    for (id<DJILiveViewRenderInput> currentTarget in targets)
    {
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger textureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            [currentTarget newFrameReadyAtTime:frameTime atIndex:textureIndex];
        }
    }
}

- (CGSize)outputFrameSize;
{
    return inputTextureSize;
}

#pragma mark -
#pragma mark Input parameters

- (void)setBackgroundColorRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent alpha:(GLfloat)alphaComponent;
{
    backgroundColorRed = redComponent;
    backgroundColorGreen = greenComponent;
    backgroundColorBlue = blueComponent;
    backgroundColorAlpha = alphaComponent;
}

- (void)setInteger:(GLint)newInteger forUniformName:(NSString *)uniformName;
{
    GLint uniformIndex = [filterProgram uniformIndex:uniformName];
    [self setInteger:newInteger forUniform:uniformIndex program:filterProgram];
}

- (void)setFloat:(GLfloat)newFloat forUniformName:(NSString *)uniformName;
{
    GLint uniformIndex = [filterProgram uniformIndex:uniformName];
    [self setFloat:newFloat forUniform:uniformIndex program:filterProgram];
}

- (void)setSize:(CGSize)newSize forUniformName:(NSString *)uniformName;
{
    GLint uniformIndex = [filterProgram uniformIndex:uniformName];
    [self setSize:newSize forUniform:uniformIndex program:filterProgram];
}

- (void)setPoint:(CGPoint)newPoint forUniformName:(NSString *)uniformName;
{
    GLint uniformIndex = [filterProgram uniformIndex:uniformName];
    [self setPoint:newPoint forUniform:uniformIndex program:filterProgram];
}

- (void)setFloatVec3:(DJIGPUVector3)newVec3 forUniformName:(NSString *)uniformName;
{
    GLint uniformIndex = [filterProgram uniformIndex:uniformName];
    [self setVec3:newVec3 forUniform:uniformIndex program:filterProgram];
}

- (void)setFloatVec4:(DJIGPUVector4)newVec4 forUniform:(NSString *)uniformName;
{
    GLint uniformIndex = [filterProgram uniformIndex:uniformName];
    [self setVec4:newVec4 forUniform:uniformIndex program:filterProgram];
}

- (void)setFloatArray:(GLfloat *)array length:(GLsizei)count forUniform:(NSString*)uniformName
{
    GLint uniformIndex = [filterProgram uniformIndex:uniformName];
    
    [self setFloatArray:array length:count forUniform:uniformIndex program:filterProgram];
}

- (void)setMatrix3f:(DJIGPUMatrix3x3)matrix forUniform:(GLint)uniform program:(DJILiveViewRenderProgram *)shaderProgram;
{
    [self setAndExecuteUniformStateCallbackAtIndex:uniform forProgram:shaderProgram toBlock:^{
        glUniformMatrix3fv(uniform, 1, GL_FALSE, (GLfloat *)&matrix);
    }];
}

- (void)setMatrix4f:(DJIGPUMatrix4x4)matrix forUniform:(GLint)uniform program:(DJILiveViewRenderProgram *)shaderProgram;
{
    [self setAndExecuteUniformStateCallbackAtIndex:uniform forProgram:shaderProgram toBlock:^{
        glUniformMatrix4fv(uniform, 1, GL_FALSE, (GLfloat *)&matrix);
    }];
}

- (void)setFloat:(GLfloat)floatValue forUniform:(GLint)uniform program:(DJILiveViewRenderProgram *)shaderProgram;
{
    [self setAndExecuteUniformStateCallbackAtIndex:uniform forProgram:shaderProgram toBlock:^{
        glUniform1f(uniform, floatValue);
    }];
}

- (void)setPoint:(CGPoint)pointValue forUniform:(GLint)uniform program:(DJILiveViewRenderProgram *)shaderProgram;
{
    [self setAndExecuteUniformStateCallbackAtIndex:uniform forProgram:shaderProgram toBlock:^{
        GLfloat positionArray[2];
        positionArray[0] = pointValue.x;
        positionArray[1] = pointValue.y;
        
        glUniform2fv(uniform, 1, positionArray);
    }];
}

- (void)setSize:(CGSize)sizeValue forUniform:(GLint)uniform program:(DJILiveViewRenderProgram *)shaderProgram;
{
    [self setAndExecuteUniformStateCallbackAtIndex:uniform forProgram:shaderProgram toBlock:^{
        GLfloat sizeArray[2];
        sizeArray[0] = sizeValue.width;
        sizeArray[1] = sizeValue.height;
        
        glUniform2fv(uniform, 1, sizeArray);
    }];
}

- (void)setVec3:(DJIGPUVector3)vectorValue forUniform:(GLint)uniform program:(DJILiveViewRenderProgram *)shaderProgram;
{
    [self setAndExecuteUniformStateCallbackAtIndex:uniform forProgram:shaderProgram toBlock:^{
        glUniform3fv(uniform, 1, (GLfloat *)&vectorValue);
    }];
}

- (void)setVec4:(DJIGPUVector4)vectorValue forUniform:(GLint)uniform program:(DJILiveViewRenderProgram *)shaderProgram;
{
    [self setAndExecuteUniformStateCallbackAtIndex:uniform forProgram:shaderProgram toBlock:^{
        glUniform4fv(uniform, 1, (GLfloat *)&vectorValue);
    }];
}

- (void)setFloatArray:(GLfloat *)arrayValue length:(GLsizei)arrayLength forUniform:(GLint)uniform program:(DJILiveViewRenderProgram *)shaderProgram;
{
    // Make a copy of the data, so it doesn't get overwritten before async call executes
    NSData* arrayData = [NSData dataWithBytes:arrayValue length:arrayLength * sizeof(arrayValue[0])];
    [self setAndExecuteUniformStateCallbackAtIndex:uniform forProgram:shaderProgram toBlock:^{
        glUniform1fv(uniform, arrayLength, [arrayData bytes]);
    }];
}

- (void)setInteger:(GLint)intValue forUniform:(GLint)uniform program:(DJILiveViewRenderProgram *)shaderProgram;
{
    [self setAndExecuteUniformStateCallbackAtIndex:uniform forProgram:shaderProgram toBlock:^{
        glUniform1i(uniform, intValue);
    }];
}

- (void)setAndExecuteUniformStateCallbackAtIndex:(GLint)uniform forProgram:(DJILiveViewRenderProgram *)shaderProgram toBlock:(dispatch_block_t)uniformStateBlock;
{
    [uniformStateRestorationBlocks setObject:[uniformStateBlock copy] forKey:[NSNumber numberWithInt:uniform]];
    uniformStateBlock();
}

- (void)setUniformsForProgramAtIndex:(NSUInteger)programIndex;
{
    [uniformStateRestorationBlocks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        dispatch_block_t currentBlock = obj;
        currentBlock();
    }];
}

#pragma mark -
#pragma mark GPUImageInput

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    static const GLfloat imageVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    [self renderToTextureWithVertices:imageVertices textureCoordinates:[[self class] textureCoordinatesForRotation:inputRotation]];
    
    [self informTargetsAboutNewFrameAtTime:frameTime];
}

- (NSInteger)nextAvailableTextureIndex;
{
    return 0;
}

- (void)setInputFramebuffer:(DJILiveViewFrameBuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex;
{
    firstInputFramebuffer = newInputFramebuffer;
}

- (CGSize)rotatedSize:(CGSize)sizeToRotate forIndex:(NSInteger)textureIndex;
{
    CGSize rotatedSize = sizeToRotate;
    
    if (GPUImageRotationSwapsWidthAndHeight(inputRotation))
    {
        rotatedSize.width = sizeToRotate.height;
        rotatedSize.height = sizeToRotate.width;
    }
    
    return rotatedSize;
}

- (CGPoint)rotatedPoint:(CGPoint)pointToRotate forRotation:(VideoStreamRotationType)rotation;
{
    CGPoint rotatedPoint;
    switch(rotation)
    {
        case VideoStreamRotationDefault: return pointToRotate; break;
//        case kGPUImageFlipHorizonal:
//        {
//            rotatedPoint.x = 1.0 - pointToRotate.x;
//            rotatedPoint.y = pointToRotate.y;
//        }; break;
//        case kGPUImageFlipVertical:
//        {
//            rotatedPoint.x = pointToRotate.x;
//            rotatedPoint.y = 1.0 - pointToRotate.y;
//        }; break;
        case VideoStreamRotationCW270:
        {
            rotatedPoint.x = 1.0 - pointToRotate.y;
            rotatedPoint.y = pointToRotate.x;
        }; break;
        case VideoStreamRotationCW90:
        {
            rotatedPoint.x = pointToRotate.y;
            rotatedPoint.y = 1.0 - pointToRotate.x;
        }; break;
//        case kGPUImageRotateRightFlipVertical:
//        {
//            rotatedPoint.x = pointToRotate.y;
//            rotatedPoint.y = pointToRotate.x;
//        }; break;
//        case kGPUImageRotateRightFlipHorizontal:
//        {
//            rotatedPoint.x = 1.0 - pointToRotate.y;
//            rotatedPoint.y = 1.0 - pointToRotate.x;
//        }; break;
        case VideoStreamRotationCW180:
        {
            rotatedPoint.x = 1.0 - pointToRotate.x;
            rotatedPoint.y = 1.0 - pointToRotate.y;
        }; break;
    }
    
    return rotatedPoint;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;
{
    if (self.preventRendering)
    {
        return;
    }
    
    if (overrideInputSize)
    {
        if (CGSizeEqualToSize(forcedMaximumSize, CGSizeZero))
        {
        }
        else
        {
            CGRect insetRect = AVMakeRectWithAspectRatioInsideRect(newSize, CGRectMake(0.0, 0.0, forcedMaximumSize.width, forcedMaximumSize.height));
            inputTextureSize = insetRect.size;
        }
    }
    else
    {
        CGSize rotatedSize = [self rotatedSize:newSize forIndex:textureIndex];
        
        if (CGSizeEqualToSize(rotatedSize, CGSizeZero))
        {
            inputTextureSize = rotatedSize;
        }
        else if (!CGSizeEqualToSize(inputTextureSize, rotatedSize))
        {
            inputTextureSize = rotatedSize;
        }
    }
    
    [self setupFilterForSize:[self sizeOfFBO]];
}

- (void)setInputRotation:(VideoStreamRotationType)newInputRotation atIndex:(NSInteger)textureIndex;
{
    inputRotation = newInputRotation;
}

- (void)forceProcessingAtSize:(CGSize)frameSize;
{
    if (CGSizeEqualToSize(frameSize, CGSizeZero))
    {
        overrideInputSize = NO;
    }
    else
    {
        overrideInputSize = YES;
        inputTextureSize = frameSize;
        forcedMaximumSize = CGSizeZero;
    }
}

- (void)forceProcessingAtSizeRespectingAspectRatio:(CGSize)frameSize;
{
    if (CGSizeEqualToSize(frameSize, CGSizeZero))
    {
        overrideInputSize = NO;
        inputTextureSize = CGSizeZero;
        forcedMaximumSize = CGSizeZero;
    }
    else
    {
        overrideInputSize = YES;
        forcedMaximumSize = frameSize;
    }
}

- (CGSize)maximumOutputSize;
{
    // I'm temporarily disabling adjustments for smaller output sizes until I figure out how to make this work better
    return CGSizeZero;
    
    /*
     if (CGSizeEqualToSize(cachedMaximumOutputSize, CGSizeZero))
     {
     for (id<GPUImageInput> currentTarget in targets)
     {
     if ([currentTarget maximumOutputSize].width > cachedMaximumOutputSize.width)
     {
     cachedMaximumOutputSize = [currentTarget maximumOutputSize];
     }
     }
     }
     
     return cachedMaximumOutputSize;
     */
}

- (void)endProcessing
{
    if (!isEndProcessing)
    {
        isEndProcessing = YES;
        
        for (id<DJILiveViewRenderInput> currentTarget in targets)
        {
            [currentTarget endProcessing];
        }
    }
}

#pragma mark -
#pragma mark Accessors

@end

