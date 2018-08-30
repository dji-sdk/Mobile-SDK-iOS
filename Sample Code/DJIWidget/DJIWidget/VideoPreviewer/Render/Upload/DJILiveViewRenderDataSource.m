//
//  DJILiveViewRenderDataSource.m
//

#import "DJILiveViewRenderCommon.h"
#import "DJILiveViewRenderDataSource.h"
#import "DJILiveViewRenderDataSource_Private.h"

GLfloat g_yuvTransformMatGray[16] = {
    1.0, 1.0, 1.0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 1
};

//BT.709, standard for HDTV, P3, P4, Mavic, in2, in2FPV, ...etc
//yuv convert mat from yunyou.lu
GLfloat g_yuvTransformMatRBGVideoRange[] = {
    1.1644,     1.1644,     1.1644,     0.0,
    0.0,        -0.2132,    2.1124,     0.0,
    1.7927,     -0.5329,    0.0,        0.0,
    0.0,        0.0,        0.0,        1.0,
};

//for yuv data in full range 0~255
GLfloat g_yuvTransformMatRBGFullRange[16] = {
    1.0, 1.0, 1.0, 0,
    0, -0.343, 1.765, 0,
    1.4, -0.711, 0, 0,
    0, 0, 0, 1
};

//yuv convert with lumance scale
NSString *const yuvConvertFS = SHADER_STRING
(
 varying highp vec2 v_texcoord;
 
 uniform sampler2D s_texture_y;
 uniform sampler2D s_texture_u;
 uniform sampler2D s_texture_v;
 
 //yuv full range convert matrix
 uniform highp mat4 yuvTransformMatrix;
 uniform highp vec4 luminanceScale;
 
 void main()
 {
     //get rgb color
     highp vec4 yuv_color = vec4(texture2D(s_texture_y, v_texcoord).r + luminanceScale.x,
                                 texture2D(s_texture_u, v_texcoord).r - 0.5,
                                 texture2D(s_texture_v, v_texcoord).r - 0.5,
                                 1.0) * luminanceScale.y;
     highp vec4 rgb_color = yuvTransformMatrix * yuv_color;
     gl_FragColor = vec4(rgb_color.xyz, yuv_color.x * yuvTransformMatrix[0][0]);
     //gl_FragColor = vec4(yuv_color.g);
 }
 );

//For convertingy - crcb
NSString *const yuvBiConvertFS = SHADER_STRING
(
 varying highp vec2 v_texcoord;
 
 uniform sampler2D s_texture_y;
 uniform sampler2D s_texture_u;
 
 //yuv full range convert matrix
 uniform highp mat4 yuvTransformMatrix;
 //l = (scale.x + orig) * scale.y
 uniform highp vec4 luminanceScale;
 
 void main()
 {
     //get rgb color
     highp vec4 crcb = texture2D(s_texture_u, v_texcoord);
     highp vec4 yuv_color = vec4(texture2D(s_texture_y, v_texcoord).r + luminanceScale.x,
                                 crcb.r - 0.5,
                                 crcb.a - 0.5,
                                 1.0) * luminanceScale.y;
     highp vec4 rgb_color = yuvTransformMatrix * yuv_color;
     gl_FragColor = vec4(rgb_color.xyz, yuv_color.x * yuvTransformMatrix[0][0]);
 }
 );

//For RGB input form
NSString *const rgbaFS = SHADER_STRING
(
 varying highp vec2 v_texcoord;
 uniform sampler2D s_texture_y;
 
 uniform highp vec4 luminanceScale;
 uniform highp mat4 yuvTransformMatrix;
 
 void main()
 {
     //get rgb color
     highp vec4 rgb = vec4((texture2D(s_texture_y, v_texcoord)* luminanceScale.y ).xyz, 1.0);
     highp vec4 yuv_color = yuvTransformMatrix * rgb;
     gl_FragColor = vec4(rgb.xyz, yuv_color.x);
     //    gl_FragColor = vec4(yuv_color.x,yuv_color.x,yuv_color.x, yuv_color.x);
 }
 );

@implementation DJILiveViewRenderDataSource

-(id) initWithContext:(DJILiveViewRenderContext *)aContext{
    if (self == [super initWithContext:aContext]) {
        
        _luminanceScale = 1.0;
        _grayScale = NO;
        _rotation = VideoStreamRotationDefault;
        _outputWidth = 1280;
        _outputHeight = 720;
        
        [self loadShaders];
    }
    
    return self;
}

-(void) dealloc{
    if (textureInput[0]) {
        glDeleteTextures(3, textureInput);
        textureInput[0] = 0;
    }
    
    if (textureInputRGB) {
        glDeleteTextures(1, &textureInputRGB);
        textureInputRGB = 0;
    }
}

-(void) loadShaders{
    _programRGBA = [[DJILiveViewRenderProgram alloc] initWithContext:context
                                                  vertexShaderString:passThroughVS
                                                fragmentShaderString:rgbaFS];
    [self setupShader:_programRGBA];
    
    _programYUV = [[DJILiveViewRenderProgram alloc] initWithContext:context
                                                 vertexShaderString:passThroughVS
                                               fragmentShaderString:yuvConvertFS];
    [self setupShader:_programYUV];
    
    _programBiYUV = [[DJILiveViewRenderProgram alloc] initWithContext:context
                                                   vertexShaderString:passThroughVS
                                                 fragmentShaderString:yuvBiConvertFS];
    [self setupShader:_programBiYUV];
}

-(void) loadFrame:(VideoFrameYUV*)yuvFrame {
    
    //load texture frame
    if(yuvFrame){
        if (_rotation == VideoStreamRotationDefault
            || _rotation == VideoStreamRotationCW180) {
            _outputWidth = yuvFrame->width;
            _outputHeight = yuvFrame->height;
        }else{
            _outputHeight = yuvFrame->width;
            _outputWidth = yuvFrame->height;
        }
    }
    
    //create a new buffer if the size is not correct
    [self configOutputBuffer];
    
    _inputLoaded = NO;
    if (yuvFrame) {
        if ([DJILiveViewRenderContext supportsFastTextureUpload]
            && yuvFrame->cv_pixelbuffer_fastupload) {
            //support yuv semiplaner now
            [self loadTexttureFastupload:yuvFrame];
        }else{
            textureInputFastupload[0] = 0;
            textureInputFastupload[1] = 0;
            textureInputFastupload[2] = 0;
            
            //support rgb，yuvplaner
            [self loadTextureNormal:yuvFrame];
        }
    }
}

-(void) loadTextureNormal:(VideoFrameYUV*)yuvFrame{
    
    if (!yuvFrame || !yuvFrame->luma) {
        return;
    }
    
    GLuint frameWidth = yuvFrame->width;
    GLuint frameHeight = yuvFrame->height;
    
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    
    if (yuvFrame->frameType == VPFrameTypeYUV420Planer) {
        
        if (0 == textureInput[0]){
            glGenTextures(3, textureInput);
        }
        
        UInt8 *pixels[3] = { yuvFrame->luma, yuvFrame->chromaB, yuvFrame->chromaR };
        int widths[3]  = { frameWidth, frameWidth / 2, frameWidth / 2 };
        int heights[3] = { frameHeight, frameHeight / 2, frameHeight / 2 };
        
        if (frameHeight != _inputHeight
            || frameWidth != _inputWidth) {
            
            _inputWidth = frameWidth;
            _inputHeight = frameHeight;
            
            for (int i = 0; i < 3; ++i) { //create texture storage
                glBindTexture(GL_TEXTURE_2D, textureInput[i]);
                glTexImage2D(GL_TEXTURE_2D,
                             0,
                             GL_LUMINANCE,
                             widths[i],
                             heights[i],
                             0,
                             GL_LUMINANCE,
                             GL_UNSIGNED_BYTE,
                             pixels[i]);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            }
        }
        
        else{//update texture
            for (int i = 0; i < 3; ++i) {
                glBindTexture(GL_TEXTURE_2D, textureInput[i]);
                glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, widths[i], heights[i], GL_LUMINANCE, GL_UNSIGNED_BYTE, pixels[i]);
            }
        }
    }
    
    else if(yuvFrame->frameType == VPFrameTypeRGBA) {
        
        if (0 == textureInputRGB) {
            glGenTextures(1, &textureInputRGB);
        }
        
        if (frameWidth != _inputWidthRGB
            || frameHeight != _inputHeightRGB) {
            
            _inputWidthRGB = frameWidth;
            _inputHeightRGB = frameHeight;
            
            
            glBindTexture(GL_TEXTURE_2D, textureInputRGB);
            glTexImage2D(GL_TEXTURE_2D,
                         0,
                         GL_RGBA,
                         frameWidth,
                         frameHeight,
                         0,
                         GL_RGBA,
                         GL_UNSIGNED_BYTE,
                         yuvFrame->luma);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        }
        
        else {
            glBindTexture(GL_TEXTURE_2D, textureInputRGB);
            glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, frameWidth, frameHeight, GL_RGBA, GL_UNSIGNED_BYTE, yuvFrame->luma);
        }
    }
    else{
        return;
    }
    
    _lastFrameType = yuvFrame->frameType;
    _inputLoaded = YES;
    isFullRange = yuvFrame->frame_info.frame_flag.is_fullrange;
}

-(void) loadTexttureFastupload:(VideoFrameYUV*)yuvFrame{
    CVPixelBufferRef frame = yuvFrame->cv_pixelbuffer_fastupload;
    
    if (frame == NULL) {
        return;
    }
    
    
    //y-cr-cb
    if (CVPixelBufferGetPlaneCount(frame) == 3) {
        const int frameWidth = yuvFrame->width;
        const int frameHeight = yuvFrame->height;
        int widths[3]  = { frameWidth, frameWidth / 2, frameWidth / 2 };
        int heights[3] = { frameHeight, frameHeight / 2, frameHeight / 2 };
        int byteTypes[3] = {GL_LUMINANCE, GL_LUMINANCE, GL_LUMINANCE};

        for (int i=0; i<3; i++) {
            glActiveTexture(GL_TEXTURE0 + i);
            CFAllocatorRef allcator = CMMemoryPoolGetAllocator(context.memoryPool);
            CVReturn err;
            // Y-plane
            err = CVOpenGLESTextureCacheCreateTextureFromImage(allcator,
                                                               context.coreVideoTextureCache,
                                                               frame,
                                                               NULL,
                                                               GL_TEXTURE_2D,
                                                               byteTypes[i],
                                                               widths[i],
                                                               heights[i],
                                                               byteTypes[i],
                                                               GL_UNSIGNED_BYTE,
                                                               i,
                                                               &fastuploadCVRef[i]);
            
            if (err != kCVReturnSuccess
                || fastuploadCVRef[i] == NULL){
                NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
                return;
            }
            textureInputFastupload[i] = CVOpenGLESTextureGetName(fastuploadCVRef[i]);
            glBindTexture(GL_TEXTURE_2D, textureInputFastupload[i]);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        }
    }
    
    //y-cr-cb-bi
    else if(CVPixelBufferGetPlaneCount(frame) == 2) {
        const int frameWidth = yuvFrame->width;
        const int frameHeight = yuvFrame->height;
        int widths[2]  = { frameWidth, frameWidth / 2};
        int heights[2] = { frameHeight, frameHeight / 2,};
        int byteTypes[2] = {GL_LUMINANCE, GL_LUMINANCE_ALPHA};
        
        for (int i = 0; i < 2; i++) {
            glActiveTexture(GL_TEXTURE0 + i);
            CVReturn err = kCVReturnSuccess;
            CFAllocatorRef allcator = CMMemoryPoolGetAllocator(context.memoryPool);
            // Y-plane
            err = CVOpenGLESTextureCacheCreateTextureFromImage(allcator,
                                                               context.coreVideoTextureCache,
                                                               frame,
                                                               NULL,
                                                               GL_TEXTURE_2D,
                                                               byteTypes[i],
                                                               widths[i],
                                                               heights[i],
                                                               byteTypes[i],
                                                               GL_UNSIGNED_BYTE,
                                                               i,
                                                               &fastuploadCVRef[i]);
            
            if (err != kCVReturnSuccess || fastuploadCVRef[i] == NULL){
                NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
                return;
            }
            
            textureInputFastupload[i] = CVOpenGLESTextureGetName(fastuploadCVRef[i]);
            glBindTexture(GL_TEXTURE_2D, textureInputFastupload[i]);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        }
        textureInputFastupload[2] = 0;
    }
    else{
        return;
    }
    
    _lastFrameType = yuvFrame->frameType;
    _inputLoaded = YES;
    isFullRange = yuvFrame->frame_info.frame_flag.is_fullrange;
}

-(void) renderBlack{
    _inputLoaded = NO;
}

-(void) renderPass {
    
    //bind framebuffer
    [outputFramebuffer activateFramebuffer];
    
    //clear
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    if (!_inputLoaded) {
        _inputLoaded = NO;
    }
    
    else {
        
        //switch input type, set default
        int textureCount = 3;
        GLuint* samplers = textureUniforms;
        GLint uniformColorMatrix = uniformYUVMatrix;
        GLint uniformLumianceScale = luminanceScaleUniform;
        GLfloat* colorTransformMat = g_yuvTransformMatRBGVideoRange;
        
        //y offset for yuv transform mat
        GLfloat yuvTransYOffset = 0;
        if (isFullRange) {
            colorTransformMat = g_yuvTransformMatRBGFullRange;
        }
        else{
            yuvTransYOffset = -0.0627451;
        }
        
        
        //load shader
        if (_lastFrameType == VPFrameTypeYUV420Planer) {
            [self setActiveProgram:_programYUV];
            
            //set color transform mat
            if (_grayScale) {
                colorTransformMat = g_yuvTransformMatGray;
            }
            
        }
        else if(_lastFrameType == VPFrameTypeYUV420SemiPlaner) {
            [self setActiveProgram:_programBiYUV];
            textureCount = 2;
            
            //set color transform mat
            if (_grayScale) {
                colorTransformMat = g_yuvTransformMatGray;
            }
        }
        else if(_lastFrameType == VPFrameTypeRGBA) {
            [self setActiveProgram:_programRGBA];
            textureCount = 1;
        }
        
        //select input texture
        GLuint* textures = textureInput;
        if (textureInputFastupload[0] != 0) {
            textures = textureInputFastupload;
        }
        else if (_lastFrameType == VPFrameTypeRGBA) {
            textures = &textureInputRGB;
            textureCount = 1;
        }
        
        for (int i = 0; i < textureCount; ++i) {
            glActiveTexture(GL_TEXTURE0 + i);
            glBindTexture(GL_TEXTURE_2D, textures[i]);
            glUniform1i(samplers[i], i);
        }
        
        glUniformMatrix4fv(uniformColorMatrix, 1, false, colorTransformMat);
        glUniform4f(uniformLumianceScale,yuvTransYOffset,_luminanceScale,0,0);
        
        
        glVertexAttribPointer(positionAttribute, 2, GL_FLOAT, 0, 0, g_defaultVertexs);
        glEnableVertexAttribArray(positionAttribute);
        glVertexAttribPointer(textureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [self currentYUVCoord]);
        glEnableVertexAttribArray(textureCoordinateAttribute);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    }
    
    glFlush();
    
    [self cleanupTexture];
    [self informTargetsAboutNewFrameAtTime:kCMTimeZero];
}


//release CVOpenGLESTextureRef
- (void)cleanupTexture {
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    for (int i = 0; i < 3; i ++) {
        if (fastuploadCVRef[i] != NULL) {
            glBindTexture(CVOpenGLESTextureGetTarget(fastuploadCVRef[i]),0);
            CFRelease(fastuploadCVRef[i]);
            fastuploadCVRef[i] = NULL;
        }
        
        textureInputFastupload[i] = 0;
    }
}

#pragma shader helper

-(void) setupShader:(DJILiveViewRenderProgram*)progam {
    
    [context useAsCurrentContext];
    
    if (!progam.initialized) {
        
        [progam addAttribute:@"position"];
        [progam addAttribute:@"texcoord"];
        
        
        if (![progam link])
        {
            NSString *progLog = [progam programLog];
            NSLog(@"Program link log: %@", progLog);
            NSString *fragLog = [progam fragmentShaderLog];
            NSLog(@"Fragment shader compile log: %@", fragLog);
            NSString *vertLog = [progam vertexShaderLog];
            NSLog(@"Vertex shader compile log: %@", vertLog);
            NSAssert(NO, @"Filter shader link failed");
            return;
        }
    }
}

-(void) setActiveProgram:(DJILiveViewRenderProgram *)activeProgram {
    
    if (_activeProgram == activeProgram) {
        [context setContextShaderProgram:_activeProgram];
        return;
    }
    
    _activeProgram = activeProgram;
    [context useAsCurrentContext];
    
    
    if (_activeProgram) {
        positionAttribute = [_activeProgram attributeIndex:@"position"];
        textureCoordinateAttribute = [_activeProgram attributeIndex:@"texcoord"];
        
        textureUniforms[0] = [_activeProgram uniformIndex:@"s_texture_y"];
        textureUniforms[1] = [_activeProgram uniformIndex:@"s_texture_u"];
        textureUniforms[2] = [_activeProgram uniformIndex:@"s_texture_v"];
        uniformYUVMatrix = [_activeProgram uniformIndex:@"yuvTransformMatrix"];
        luminanceScaleUniform = [_activeProgram uniformIndex:@"luminanceScale"];
        
        [context setContextShaderProgram:_activeProgram];
        
        glEnableVertexAttribArray(positionAttribute);
        glEnableVertexAttribArray(textureCoordinateAttribute);
    }else{
        [context setContextShaderProgram:nil];
    }
}

#pragma output buffer config

-(void) configOutputBuffer{
    if (outputFramebuffer == nil
        || outputFramebuffer.size.height != _outputHeight
        || outputFramebuffer.size.width != _outputWidth) {
        
        outputFramebuffer = [[DJILiveViewFrameBuffer alloc]
                             initWithContext:context
                             size:CGSizeMake(_outputWidth, _outputHeight)];
    }
}

#pragma mark texcoord help

-(const GLfloat*) currentYUVCoord{
    switch (_rotation) {
        case VideoStreamRotationDefault:
            return g_yuvQuadTexCoordsNormal;
            break;
        case VideoStreamRotationCW90:
            return g_yuvQuadTexCoords90CW;
            break;
        case VideoStreamRotationCW180:
            return g_yuvQuadTexCoords180CW;
            break;
        case VideoStreamRotationCW270:
            return g_yuvQuadTexCoords270CW;
            break;
        default:
            break;
    }
    
    return g_yuvQuadTexCoordsNormal;
}

#pragma mark targets notification help

- (void)informTargetsAboutNewFrameAtTime:(CMTime)frameTime;
{
    // Get all targets the framebuffer so they can grab a lock on it
    for (id<DJILiveViewRenderInput> currentTarget in targets)
    {
        if ([currentTarget enabled] == NO) {
            continue;
        }
        
        NSInteger indexOfObject = [targets indexOfObject:currentTarget];
        NSInteger textureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
        
        [self setInputFramebufferForTarget:currentTarget atIndex:textureIndex];
        [currentTarget setInputSize:outputFramebuffer.size atIndex:textureIndex];
    }
    
    // Trigger processing last, so that our unlock comes first in serial execution, avoiding the need for a callback
    for (id<DJILiveViewRenderInput> currentTarget in targets)
    {
        if ([currentTarget enabled] == NO) {
            continue;
        }
        
        NSInteger indexOfObject = [targets indexOfObject:currentTarget];
        NSInteger textureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
        [currentTarget newFrameReadyAtTime:frameTime atIndex:textureIndex];
    }
}


@end
