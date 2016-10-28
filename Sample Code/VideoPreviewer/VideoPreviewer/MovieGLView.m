//
//  KxMovieGLView.m
//  kxmovie
//
//  Created by Kolyvan on 22.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/kxmovie
//  this file is part of KxMovie
//  KxMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import "MovieGLView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "DJIVideoPresentViewAdjustHelper.h"

#include <pthread.h>

#define INFO(fmt, ...) //DJILog(@"[GLView]"fmt, ##__VA_ARGS__)
#define ERROR(fmt, ...) //DJILog(@"[GLView]"fmt, ##__VA_ARGS__)
//////////////////////////////////////////////////////////

#pragma mark - shaders

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

GLfloat g_yuvTransformMatGray[16] = {
    1.0, 1.0, 1.0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 1
};

GLfloat g_yuvTransformMatRBG[16] = {
    1.0, 1.0, 1.0, 0,
    0, -0.344, 1.772, 0,
    1.402, -0.714, 0, 0,
    0, 0, 0, 1
};

GLfloat g_rgbTransformMatYUV[16] = {
    0.299, -0.169, 0.500, 0,
    0.587, -0.331, -0.419, 0,
    0.114, 0.500, -0.081, 0,
    0, 0.5, 0.5, 1
};

enum {
    ATTRIBUTE_VERTEX,
   	ATTRIBUTE_TEXCOORD,
};

static const GLfloat g_yuvQuadTexCoordsNormal[] = {
    0.0f, 1.0f,
    1.0f, 1.0f,
    0.0f, 0.0f,
    1.0f, 0.0f,
};

static const GLfloat g_yuvQuadTexCoords90CW[] = {
    0.0f, 0.0f,
    0.0f, 1.0f,
    1.0f, 0.0f,
    1.0f, 1.0f,
};

static const GLfloat g_yuvQuadTexCoords180CW[] = {
    1.0f, 0.0f,
    0.0f, 0.0f,
    1.0f, 1.0f,
    0.0f, 1.0f,
};

static const GLfloat g_yuvQuadTexCoords270CW[] = {
    1.0f, 1.0f,
    1.0f, 0.0f,
    0.0f, 1.0f,
    0.0f, 0.0f,
    
};

static const GLfloat g_postQuadTexCoords[] = {
    0.0f, 0.0f,
    1.0f, 0.0f,
    0.0f, 1.0f,
    1.0f, 1.0f,
};

NSString *const passThroughVS = SHADER_STRING
(
 //input
 attribute vec4 position;
 attribute vec2 texcoord;
 
 //to fragment shader
 varying vec2 v_texcoord;
 varying vec4 v_overexp_texcoord;
 
 void main()
 {
     gl_Position = position;
     v_texcoord = texcoord.xy;
 }
 );

//vs with overExp params
NSString *const overExpVS = SHADER_STRING
(
 //input
 attribute vec4 position;
 attribute vec2 texcoord;
 
//x:width in {0, 1}, y:height in {0, 1} z:offset in {0, 1}, w:blend factor
uniform vec4 overexp_texture_param;
 
 //to fragment shader
 varying vec2 v_texcoord;
 varying vec4 v_overexp_texcoord;
 
 void main()
 {
     gl_Position = position;
     v_texcoord = texcoord.xy;
     v_overexp_texcoord = vec4(v_texcoord.x * overexp_texture_param.x + overexp_texture_param.z,
                               v_texcoord.y * overexp_texture_param.y,
                               ceil(overexp_texture_param.w), overexp_texture_param.w*64.0);
 }
);

//passthrough FS
//render to screen with over explore warning
NSString *const passthroughFS = SHADER_STRING
(
 varying highp vec2 v_texcoord;
 varying highp vec4 v_overexp_texcoord;
 
 uniform sampler2D s_texture;

 void main()
 {
     //get rgb color
     highp vec4 rgb_color = texture2D(s_texture, v_texcoord);
     gl_FragColor = vec4(ret_color.xyz, 1.0);
 }
 );

//render to screen with over explore warning
NSString *const renderToScreenFS = SHADER_STRING
(
 varying highp vec2 v_texcoord;
 varying highp vec4 v_overexp_texcoord;
 
 uniform sampler2D s_texture;
 uniform sampler2D s_texture_overexp;
 
// use alpha channel to store lumaince
// const highp vec4 luminanceVec = vec4(0.2126, 0.7152, 0.0722, 1.0);
 
 void main()
 {
     //get rgb color
     highp vec4 rgb_color = texture2D(s_texture, v_texcoord);
     
     //get over exposed texture color
     highp vec4 over_exposed_tex_color = vec4(texture2D(s_texture_overexp, v_overexp_texcoord.xy).a);
//     highp float luminance = luminanceVec*rgb_color;
     highp float lumaince = rgb_color.a;
     //alpha is 1.0
     highp float blend_factor = clamp(lumaince*64.0 - v_overexp_texcoord.w, 0.0 ,1.0)*v_overexp_texcoord.z;
     //blend_factor = clamp(y_channel*6.4 - 5.4, 0.0 ,1.0)*v_overexp_texcoord.w;
     //blend_factor = 1.0;
     
     highp vec4 ret_color = mix(rgb_color, over_exposed_tex_color, blend_factor);
     gl_FragColor = vec4(ret_color.xyz, 1.0);
 }
);

//yuv convert with lumance scale
NSString *const yuvConvertFS = SHADER_STRING
(
 varying highp vec2 v_texcoord;
 
 uniform sampler2D s_texture_y;
 uniform sampler2D s_texture_u;
 uniform sampler2D s_texture_v;

 //yuv full range convert matrix
 uniform highp mat4 yuvTransformMatrix;
 uniform highp float luminanceScale;
 
 void main()
 {
     //get rgb color
     highp vec4 yuv_color = vec4(texture2D(s_texture_y, v_texcoord).r,
                           texture2D(s_texture_u, v_texcoord).r - 0.5,
                           texture2D(s_texture_v, v_texcoord).r - 0.5,
                           1.0)*luminanceScale;
     highp vec4 rgb_color = yuvTransformMatrix * yuv_color;
     gl_FragColor = vec4(rgb_color.xyz, yuv_color.x);
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
 uniform highp float luminanceScale;
 
 void main()
 {
     //get rgb color
     highp vec4 crcb = texture2D(s_texture_u, v_texcoord);
     highp vec4 yuv_color = vec4(texture2D(s_texture_y, v_texcoord).r,
                                 crcb.r - 0.5,
                                 crcb.a - 0.5,
                                 1.0)*luminanceScale;
     highp vec4 rgb_color = yuvTransformMatrix * yuv_color;
     gl_FragColor = vec4(rgb_color.xyz, yuv_color.x);
 }
 );

//For RGB input form
NSString *const rgbaFS = SHADER_STRING
(
 varying highp vec2 v_texcoord;
 uniform sampler2D s_texture_y;
 
 uniform highp float luminanceScale;
 uniform highp mat4 yuvTransformMatrix;
 
 void main()
 {
     //get rgb color
     highp vec4 rgb = vec4((texture2D(s_texture_y, v_texcoord)*luminanceScale).xyz, 1.0);
     highp vec4 yuv_color = yuvTransformMatrix * rgb;
     gl_FragColor = vec4(rgb.xyz, yuv_color.x);
     //    gl_FragColor = vec4(yuv_color.x,yuv_color.x,yuv_color.x, yuv_color.x);
 }
 );

//sobel edge detect
NSString *const sobelFS = SHADER_STRING
(
 varying highp vec2 v_texcoord;
 varying highp vec4 v_overexp_texcoord;
 
 uniform sampler2D s_texture;
 uniform highp vec4 dxdy;

 //texcord of left right top bottom
 uniform highp vec4 range;
 
 const highp vec4 RED = vec4(1.0,0,0,1.0);
 const highp vec4 GREEN = vec4(0,1.0,0,1.0);
 const highp vec4 BLUE = vec4(0,0,1.0,1.0);
 
highp vec4 sample(highp float dx, highp float dy)
{
    highp vec2 dif = vec2(dx,dy);
    highp vec2 texcord = v_texcoord.st+dif;
    
    highp vec4 min_range = step(vec4(range.xz, texcord), vec4(texcord, range.yw));
    texcord = v_texcoord.st + min_range.x*min_range.y*min_range.z*min_range.w*dif;
    
    return texture2D(s_texture, texcord);
}
 
 highp vec4 sampleNoClamp(highp float dx, highp float dy)
{
    highp vec2 texcord = v_texcoord.st+vec2(dx,dy);
    return texture2D(s_texture, texcord);
}
 
highp float mag(highp vec4 p)
{
    return length(p.rgb);
}
 
 void main()
 {
     highp vec4 H = -sample(-dxdy.x,+dxdy.y) - 2.0*sample(0.0,+dxdy.y) - sample(+dxdy.x,+dxdy.y)
     +sample(-dxdy.x,-dxdy.y) + 2.0*sample(0.0,-dxdy.y) + sample(+dxdy.x,-dxdy.y);
     
     highp vec4 V =     sample(-dxdy.x,+dxdy.y)  -     sample(+dxdy.x,+dxdy.y)
     + 2.0*sample(-dxdy.x,0.0)  - 2.0*sample(+dxdy.x,0.0)
     +     sample(-dxdy.x,-dxdy.y)  -     sample(+dxdy.x,-dxdy.y);
     
     gl_FragColor = sampleNoClamp(0.0, 0.0);
     
     highp float MAG = mag(sqrt(H*H+V*V));
     if(MAG>sqrt(dxdy.z)) gl_FragColor = vec4(RED.xyz, gl_FragColor.a);
 }
);


static BOOL validateProgram(GLuint prog)
{
	GLint status;
	
    glValidateProgram(prog);
    
#ifdef DEBUG
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        ERROR(@"Program validate log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == GL_FALSE) {
		ERROR(@"Failed to validate program %d", prog);
        return NO;
    }
	
	return YES;
}

static GLuint compileShader(GLenum type, NSString *shaderString)
{
	GLint status;
	const GLchar *sources = (GLchar *)shaderString.UTF8String;
	
    GLuint shader = glCreateShader(type);
    if (shader == 0 || shader == GL_INVALID_ENUM) {
       ERROR(@"Failed to create shader %d", type);
        return 0;
    }
    
    glShaderSource(shader, 1, &sources, NULL);
    glCompileShader(shader);
	
#ifdef DEBUG
	GLint logLength;
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(shader, logLength, &logLength, log);
        ERROR(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    if (status == GL_FALSE) {
        glDeleteShader(shader);
		ERROR(@"Failed to compile shader:\n");
        return 0;
    }
    
	return shader;
}

#pragma mark - ogl helper methods

void glGenTextureFromFramebuffer(GLuint *t, GLuint *f, GLsizei w, GLsizei h)
{
    glGenFramebuffers(1, f);
    glGenTextures(1, t);
    
    glBindFramebuffer(GL_FRAMEBUFFER, *f);
    
    glBindTexture(GL_TEXTURE_2D, *t);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, *t, 0);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if(status != GL_FRAMEBUFFER_COMPLETE)
        ERROR(@"Framebuffer status: %x", (int)status);
}
//////////////////////////////////////////////////////////


#pragma mark - view for diaplay and post effects

@implementation MovieGLView {
    EAGLContext     *_context;
    
    //common
    CGRect          _targetLayerFrame;
    // vertexs for screen rect
    GLfloat         _vertices[8];
    
    //1. yuv convert
    VPFrameType _lastFrameType;
    GLuint     _programYUV;
    GLint      _uniformSamplersYUV[3];
    //yuv -> rgb matrix
    GLint      _uniformYUVMatrix;
    //luminance scale control
    GLint       _luminanceScale_uniform;
    
    //semiPlaner
    GLuint     _programBiYUV;
    GLint     _uniformSamplersBiYUV[3];
    GLint      _uniformBiYUVMatrix;
    GLint      _luminanceScaleBi_uniform;
    
    //rgba
    GLuint     _programRGBA;
    GLint     _uniformSamplersRGBA[3];
    GLint      _uniformRGBAYUVMatrix;
    GLint      _luminanceScaleRGBA_uniform;
    
    //common
    BOOL       _inputLoaded;
    GLuint     _texturesYUV[3];
    GLuint     _textureRGBA;
    
    //input
    float _inputWidth;
    float _inputHeight;
    GLuint _yuvInputHeight;
    GLuint _yuvInputWidth;
    GLuint _RGBInputWidth;
    GLuint _RGBInputHeight;
    
    //fast texture upload
    CVOpenGLESTextureCacheRef _textCache;
    CVOpenGLESTextureRef _fastupload_cvRef[3];
    GLuint _fastupload_textureYUV[3];
    
    
    //output
    GLuint      _rgbOutputWidth;
    GLuint      _rgbOutputHeight;
    GLuint      _rgbRenderBuffer;
    GLuint      _rgbFrameBuffer;
    
    //2. sobel process
    GLuint      _programSobel;
    GLint       _uniformSamplersSobel;
    GLint       _unifromDxDy;
    GLint       _uniformRange;
    //output
    GLuint      _sobelOutputWidth;
    GLuint      _sobelOutputHeight;
    GLuint      _sobelRenderBuffer;
    GLuint      _sobelFrameBuffer;
    
    //3. screen render
    GLuint      _programPresent;
    GLuint      _uniformPresentSampler;
    //over exposed control
    int         _over_exposed_tex_width;
    GLint       _over_exposed_param;
    GLint       _over_exposed_tex_uniform;
    GLuint      _over_exposed_tex;
    //output
    GLuint      _framebuffer;
    GLuint      _renderbuffer;
    GLint       _backingWidth;
    GLint       _backingHeight;
//    //current view
    GLint       _viewPointWidth; //View on the screen size of the corresponding logical width
    GLint       _viewPointHeight; //View on the screen size of the corresponding logical height
    
    //4. thumbnail
    //buffers for down scale
    GLuint _downsacle_renderbuffer;
    GLuint _downscale_framebuffer;
    GLfloat _downscale_quadTexCoords[8];
    
    DJIVideoPresentViewAdjustHelper* _adjustHelper;
}

#pragma mark - for UIKit

+ (Class) layerClass
{
    return [CAEAGLLayer class];
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _adjustHelper = [[DJIVideoPresentViewAdjustHelper alloc] init];
        
        //use a default input size
        _inputWidth   = 1280;
        _inputHeight  = 720;
        
        [self setBackgroundColor:[UIColor clearColor]];
        _type = VideoPresentContentModeAspectFit;
        self.contentClipRect = CGRectMake(0, 0, 1, 1);
        
        _adjustHelper.lastFrame = frame;
        _adjustHelper.videoSize = CGSizeMake(_inputWidth, _inputHeight);
        _adjustHelper.contentMode = VideoPresentContentModeAspectFit;
        _adjustHelper.rotation = VideoStreamRotationDefault;
        _adjustHelper.boundingFrame = self.bounds;
        _adjustHelper.contentClipRect = self.contentClipRect;
        
        CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
        eaglLayer.opaque = YES;
        eaglLayer.contentsScale = [UIScreen mainScreen].scale;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];
        
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        if (!_context ||
            ![EAGLContext setCurrentContext:_context]) {
            
            ERROR(@"failed to setup EAGLContext");
            self = nil;
            return nil;
        }
        
        //create render target
        [self rebindFrameBuffer];
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (status != GL_FRAMEBUFFER_COMPLETE) {
            
            ERROR(@"failed to make complete framebuffer object %x", status);
            self = nil;
            return nil;
        }
        
        GLenum glError = glGetError();
        if (GL_NO_ERROR != glError) {
            ERROR(@"failed to setup GL %x", glError);
            self = nil;
            return nil;
        }
        
        _vertices[0] = -1.0f;  // x0
        _vertices[1] = -1.0f;  // y0
        _vertices[2] =  1.0f;  // ..
        _vertices[3] = -1.0f;
        _vertices[4] = -1.0f;
        _vertices[5] =  1.0f;
        _vertices[6] =  1.0f;  // x3
        _vertices[7] =  1.0f;  // y3
        
        _luminanceScale = 1.0;
        _overExposedMark = 0.0;
        _focusWarningThreshold = 3.0;
        _grayScale = NO;
        _inputLoaded = NO;
    }
    
    return self;
}

- (BOOL)adjustSize{
    //May enter from the non-threaded rendering, here do not call any GL codes
    
    if(self.superview==nil)return NO;
    
    _adjustHelper.videoSize = CGSizeMake(_inputWidth, _inputHeight);
    _adjustHelper.contentMode = self.type;
    _adjustHelper.rotation = self.rotation;
    _adjustHelper.boundingFrame = self.superview.bounds;
    _adjustHelper.contentClipRect = self.contentClipRect;
    
    //adjust frame is the final target frame
    CGRect adjustFrame = [_adjustHelper getFinalFrame];
    _adjustHelper.lastFrame = adjustFrame;
    
    
    if(CGRectEqualToRect(adjustFrame, _targetLayerFrame)){
        return NO;
    }else{
        _targetLayerFrame = adjustFrame;
        if([NSThread isMainThread]){
            [self setFrame:adjustFrame];
            [self notifyFrameChange];
        }
        else{
            
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self setFrame:adjustFrame];
                [self notifyFrameChange];
                dispatch_semaphore_signal(semaphore);
            });
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
        }
        return YES;
    }
}

-(void) notifyFrameChange{
    if ([_delegate respondsToSelector:@selector(movieGlView:didChangedFrame:)]) {
        [_delegate movieGlView:self didChangedFrame:self.frame];
    }
}

-(void) setFrame:(CGRect)frame{
    //Non-GL thread protection, do not call any GL codes
    [super setFrame:frame];
    _targetLayerFrame = frame;
    //After the view frame changes in the need to re-bind buffer, or size may be abnormal
    //However, we should do this thing in the render thread inside
}

- (void)dealloc
{
    @synchronized(self) {
        if (_framebuffer) {
            glDeleteFramebuffers(1, &_framebuffer);
            _framebuffer = 0;
        }
        
        if (_renderbuffer) {
            glDeleteRenderbuffers(1, &_renderbuffer);
            _renderbuffer = 0;
        }
        
        [self releaseYUV];
        [self releasePresent];
        [self releaseThumbnail];
        [self releaseSobel];
        
        if ([EAGLContext currentContext] == _context) {
            [EAGLContext setCurrentContext:nil];
        }
        
        _context = nil;
    }
}

#pragma mark - gl render

- (void)render: (VideoFrameYUV *) frame
{
    @synchronized(self){
        [EAGLContext setCurrentContext:_context];
        
        //update frame
        if (frame){
            if(frame->width > 2000 || frame->height > 2000){
                ERROR(@"size error %f %f", frame->width, frame->height);
                return;
            }
            
            _inputWidth = frame->width;
            _inputHeight = frame->height;
        }
        
        //resize self
        [self adjustSize];
        
        //check framebuffer
        if (_viewPointWidth != (GLint)self.frame.size.width
            || _viewPointHeight != (GLint)self.frame.size.height) {
            [self rebindFrameBuffer];
        }
        
        //1. yuv convert
        [self loadShadersYUV];
        [self configureOutputYUV];
        glBindFramebuffer(GL_FRAMEBUFFER, _rgbFrameBuffer);
        glViewport(0, 0, _rgbOutputWidth, _rgbOutputHeight);
        [self renderYUV:frame];
        
        //snapshot full
        if (_snapshotCallback) {
            __block UIImage* image = [self snapshotUImageFull];
            __block snapshotBlock _block_copy = self.snapshotCallback;
            dispatch_async(dispatch_get_main_queue(), ^{
                _block_copy(image);
            });
            _snapshotCallback = nil;
        }

        GLuint texture_to_screen = _rgbRenderBuffer;
        if (_useSobelProcess) {
            [self loadShadersSobel];
            [self configureOutputSobel];
            glBindFramebuffer(GL_FRAMEBUFFER, _sobelFrameBuffer);
            glViewport(0, 0, _sobelOutputWidth, _sobelOutputHeight);
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, texture_to_screen);
            [self renderToSobel];
            texture_to_screen = _sobelRenderBuffer;
        }
        
        //3. screen present
        [self loadShadersPresent];
        glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
        glViewport(0, 0, _backingWidth, _backingHeight);
        glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, texture_to_screen);
        [self renderToScreen];
        
        //snapshot thumbnail
        if (_snapshotThumbnailCallback) {
            __block UIImage* image = [self snapshotThumbnail];
            __block snapshotBlock _block_copy = self.snapshotThumbnailCallback;
            dispatch_async(dispatch_get_main_queue(), ^{
                _block_copy(image);
            });
            _snapshotThumbnailCallback = nil;
        }
        
        glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
        [_context presentRenderbuffer:GL_RENDERBUFFER];
        [self frameRenderFinished];
    }
}

-(void) frameRenderFinished{
    for (int i=0; i<3; i++) {
        if (_fastupload_cvRef[i]) {
            CFRelease(_fastupload_cvRef[i]);
            _fastupload_cvRef[i] = NULL;
        }
    }
}

#pragma mark - yuv convert

- (BOOL)loadShadersYUV
{
    [self loadShadersBiYUV];
    [self loadShadersRGBA];
    
    if (_programYUV) {
        return YES;
    }
    
    BOOL result = NO;
    GLuint vertShader = 0, fragShader = 0;
    
    //create yuv program
    _programYUV = glCreateProgram();
    
    vertShader = compileShader(GL_VERTEX_SHADER, passThroughVS);
    if (!vertShader){
        goto exit;
    }
    
    fragShader = compileShader(GL_FRAGMENT_SHADER, yuvConvertFS);
    if (!fragShader){
        
        goto exit;
    }
    
    glAttachShader(_programYUV, vertShader);
    glAttachShader(_programYUV, fragShader);
    glBindAttribLocation(_programYUV, ATTRIBUTE_VERTEX, "position");
    glBindAttribLocation(_programYUV, ATTRIBUTE_TEXCOORD, "texcoord");
    glLinkProgram(_programYUV);
    
    GLint status;
    glGetProgramiv(_programYUV, GL_LINK_STATUS, &status);
    if (status == GL_FALSE) {
        ERROR(@"Failed to link program YUV");
        goto exit;
    }
    result = validateProgram(_programYUV);
    
    //[self resolveUniformsYUV:_programYUV];
    GLuint program = _programYUV;
    _uniformSamplersYUV[0] = glGetUniformLocation(program, "s_texture_y");
    _uniformSamplersYUV[1] = glGetUniformLocation(program, "s_texture_u");
    _uniformSamplersYUV[2] = glGetUniformLocation(program, "s_texture_v");
    _uniformYUVMatrix = glGetUniformLocation(program, "yuvTransformMatrix");
    _luminanceScale_uniform = glGetUniformLocation(program, "luminanceScale");
exit:
    
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
    
    if (result) {
        
        ERROR(@"OK setup GL programm");
        
    } else {
        
        glDeleteProgram(_programYUV);
        _programYUV = 0;
    }
    
    return result;
}

- (BOOL)loadShadersBiYUV
{
    if (_programBiYUV) {
        return YES;
    }
    
    BOOL result = NO;
    GLuint vertShader = 0, fragShader = 0;
    
    //create yuv program
    _programBiYUV = glCreateProgram();
    
    vertShader = compileShader(GL_VERTEX_SHADER, passThroughVS);
    if (!vertShader){
        goto exit;
    }
    
    fragShader = compileShader(GL_FRAGMENT_SHADER, yuvBiConvertFS);
    if (!fragShader){
        
        goto exit;
    }
    
    glAttachShader(_programBiYUV, vertShader);
    glAttachShader(_programBiYUV, fragShader);
    glBindAttribLocation(_programBiYUV, ATTRIBUTE_VERTEX, "position");
    glBindAttribLocation(_programBiYUV, ATTRIBUTE_TEXCOORD, "texcoord");
    glLinkProgram(_programBiYUV);
    
    GLint status;
    glGetProgramiv(_programBiYUV, GL_LINK_STATUS, &status);
    if (status == GL_FALSE) {
        ERROR(@"Failed to link program YUV");
        goto exit;
    }
    result = validateProgram(_programBiYUV);
    
    GLuint program = _programBiYUV;
    _uniformSamplersBiYUV[0] = glGetUniformLocation(program, "s_texture_y");
    _uniformSamplersBiYUV[1] = glGetUniformLocation(program, "s_texture_u");
    _uniformSamplersBiYUV[2] = -1;
    _uniformBiYUVMatrix = glGetUniformLocation(program, "yuvTransformMatrix");
    _luminanceScaleBi_uniform = glGetUniformLocation(program, "luminanceScale");
    
exit:
    
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
    
    if (result) {
        
        ERROR(@"OK setup GL programm");
        
    } else {
        
        glDeleteProgram(_programBiYUV);
        _programBiYUV = 0;
    }
    
    return result;
}

- (BOOL)loadShadersRGBA
{
    if (_programRGBA) {
        return YES;
    }
    
    BOOL result = NO;
    GLuint vertShader = 0, fragShader = 0;
    
    //create yuv program
    _programRGBA = glCreateProgram();
    
    vertShader = compileShader(GL_VERTEX_SHADER, passThroughVS);
    if (!vertShader){
        goto exit;
    }
    
    fragShader = compileShader(GL_FRAGMENT_SHADER, rgbaFS);
    if (!fragShader){
        
        goto exit;
    }
    
    glAttachShader(_programRGBA, vertShader);
    glAttachShader(_programRGBA, fragShader);
    glBindAttribLocation(_programRGBA, ATTRIBUTE_VERTEX, "position");
    glBindAttribLocation(_programRGBA, ATTRIBUTE_TEXCOORD, "texcoord");
    glLinkProgram(_programRGBA);
    
    GLint status;
    glGetProgramiv(_programRGBA, GL_LINK_STATUS, &status);
    if (status == GL_FALSE) {
        ERROR(@"Failed to link program YUV");
        goto exit;
    }
    result = validateProgram(_programRGBA);
    
    GLuint program = _programRGBA;
    _uniformSamplersRGBA[0] = glGetUniformLocation(program, "s_texture_y");
    _uniformSamplersRGBA[1] = -1;
    _uniformSamplersRGBA[2] = -1;
    _uniformRGBAYUVMatrix = glGetUniformLocation(program, "yuvTransformMatrix");
    _luminanceScaleRGBA_uniform = glGetUniformLocation(program, "luminanceScale");
    
exit:
    
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
    
    if (result) {
        
        ERROR(@"OK setup GL programm");
        
    } else {
        
        glDeleteProgram(_programRGBA);
        _programRGBA = 0;
    }
    
    return result;
}

-(void) deleteOutputYUV{
    if (_rgbFrameBuffer) {
        glDeleteFramebuffers(1, &_rgbFrameBuffer);
        _rgbFrameBuffer = 0;
    }
    
    if (_rgbRenderBuffer) {
        glDeleteTextures(1, &_rgbRenderBuffer);
        _rgbRenderBuffer = 0;
    }
}

-(void) configureOutputYUV{
    //same size as input
    if (_rgbOutputWidth != (int)_inputWidth
        || _rgbOutputHeight != (int)_inputHeight) {
        [self deleteOutputYUV];
    }
    
    if (!_rgbRenderBuffer && _inputWidth && _inputHeight) {
        glGenTextureFromFramebuffer(&_rgbRenderBuffer, &_rgbFrameBuffer, _inputWidth, _inputHeight);
        _rgbOutputWidth = _inputWidth;
        _rgbOutputHeight = _inputHeight;
    }
}

-(void) renderYUV:(VideoFrameYUV*)frame{
    
    if (!_programYUV || !_programBiYUV || !_programRGBA) {
        return;
    }
    
    if (frame) {
        if (frame->frameType == VPFrameTypeYUV420Planer) {
            _lastFrameType = frame->frameType;
        }else if (frame->frameType == VPFrameTypeYUV420SemiPlaner){
            _lastFrameType = frame->frameType;
        }
        else if(frame->frameType == VPFrameTypeRGBA){
            _lastFrameType = frame->frameType;
        }
        
        if ([MovieGLView supportsFastTextureUpload] && frame->cv_pixelbuffer_fastupload) {
            //support yuv semiplaner now
            [self loadFrameFastUpload:frame];
        }else{
            _fastupload_textureYUV[0] = 0;
            _fastupload_textureYUV[1] = 0;
            _fastupload_textureYUV[2] = 0;
            
            //support rgb，yuvplaner
            [self loadFrame:frame];
        }
    }
    
    if (!_inputLoaded) {
        //just clean
        glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        return;
    }

    //switch input type, set default
    int textureCount = 3;
    GLint* samplers = _uniformSamplersYUV;
    GLint uniformColorMatrix = _uniformYUVMatrix;
    GLint uniformLumianceScale = _luminanceScale_uniform;
    GLfloat* colorTransformMat = g_yuvTransformMatRBG;
    
    
    //load shader
    if (_lastFrameType == VPFrameTypeYUV420Planer) {
        glUseProgram(_programYUV);
        
        //set color transform mat
        if (_grayScale) {
            colorTransformMat = g_yuvTransformMatGray;
        }
        
    }else if(_lastFrameType == VPFrameTypeYUV420SemiPlaner){
        glUseProgram(_programBiYUV);
        samplers = _uniformSamplersBiYUV;
        uniformColorMatrix = _uniformBiYUVMatrix;
        uniformLumianceScale = _luminanceScaleBi_uniform;
        textureCount = 2;
        
        //set color transform mat
        if (_grayScale) {
            colorTransformMat = g_yuvTransformMatGray;
        }
        
    }else if(_lastFrameType == VPFrameTypeRGBA){
        glUseProgram(_programRGBA);
        samplers = _uniformSamplersRGBA;
        uniformColorMatrix = _uniformRGBAYUVMatrix;
        uniformLumianceScale = _luminanceScaleRGBA_uniform;
        colorTransformMat = g_rgbTransformMatYUV;
        textureCount = 1;
    }
    
    //select input texture
    GLuint* textures = _texturesYUV;
    if (_fastupload_textureYUV[0] != 0) {
        textures = _fastupload_textureYUV;
    }
    if (_lastFrameType == VPFrameTypeRGBA) {
        textures = &_textureRGBA;
        textureCount = 1;
    }
    
    for (int i = 0; i < textureCount; ++i) {
        glActiveTexture(GL_TEXTURE0 + i);
        glBindTexture(GL_TEXTURE_2D, textures[i]);
        glUniform1i(samplers[i], i);
    }
    
    glUniformMatrix4fv(uniformColorMatrix, 1, false, colorTransformMat);
    
    //set luminance scale
    glUniform1f(uniformLumianceScale, _luminanceScale);
        
    glVertexAttribPointer(ATTRIBUTE_VERTEX, 2, GL_FLOAT, 0, 0, _vertices);
    glEnableVertexAttribArray(ATTRIBUTE_VERTEX);
    glVertexAttribPointer(ATTRIBUTE_TEXCOORD, 2, GL_FLOAT, 0, 0, [self currentYUVCoord]);
    glEnableVertexAttribArray(ATTRIBUTE_TEXCOORD);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

-(const GLfloat*) currentYUVCoord{
    switch (_rotation) {
        case VideoStreamRotationDefault:
            return g_yuvQuadTexCoordsNormal;
            break;
        case VideoStreamRotationCW90:
            return g_yuvQuadTexCoords270CW;
            break;
        case VideoStreamRotationCW180:
            return g_yuvQuadTexCoords180CW;
            break;
        case VideoStreamRotationCW270:
            return g_yuvQuadTexCoords90CW;
            break;
        default:
            break;
    }
    
    return g_yuvQuadTexCoordsNormal;
}

-(void) releaseYUV{
    [self deleteOutputYUV];
    
    if (_programYUV) {
        glDeleteProgram(_programYUV);
        _programYUV = 0;
    }
    
    if (_programBiYUV) {
        glDeleteProgram(_programBiYUV);
        _programBiYUV = 0;
    }
    
    if (_programRGBA) {
        glDeleteProgram(_programRGBA);
        _programRGBA = 0;
    }
    
    if (_textCache) {
        CFRelease(_textCache);
        _textCache = nil;
    }
    
    if (_texturesYUV[0]){
        glDeleteTextures(3, _texturesYUV);
        _texturesYUV[0] = 0;
    }
    
    if (_textureRGBA) {
        glDeleteTextures(1, &_textureRGBA);
        _textureRGBA = 0;
    }
}

- (void)loadFrame: (VideoFrameYUV *) yuvFrame
{
    if (!yuvFrame || !yuvFrame->luma) {
        return;
    }
    
    GLuint frameWidth = yuvFrame->width;
    GLuint frameHeight = yuvFrame->height;
    
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    
    if (yuvFrame->frameType == VPFrameTypeYUV420Planer) {
        if (0 == _texturesYUV[0])
            glGenTextures(3, _texturesYUV);
        
        UInt8 *pixels[3] = { yuvFrame->luma, yuvFrame->chromaB, yuvFrame->chromaR };
        int widths[3]  = { frameWidth, frameWidth / 2, frameWidth / 2 };
        int heights[3] = { frameHeight, frameHeight / 2, frameHeight / 2 };
        
        if (frameHeight != _yuvInputHeight
            || frameWidth != _yuvInputWidth) {
            
            _yuvInputWidth = frameWidth;
            _yuvInputHeight = frameHeight;
            
            for (int i = 0; i < 3; ++i) { //create texture storage
                glBindTexture(GL_TEXTURE_2D, _texturesYUV[i]);
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
        }else{//update texture
            for (int i = 0; i < 3; ++i) {
                glBindTexture(GL_TEXTURE_2D, _texturesYUV[i]);
                glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, widths[i], heights[i], GL_LUMINANCE, GL_UNSIGNED_BYTE, pixels[i]);
            }
        }
    }else if(yuvFrame->frameType == VPFrameTypeRGBA){
        if (0 == _textureRGBA) {
            glGenTextures(1, &_textureRGBA);
        }
        
        if (frameWidth != _RGBInputWidth
            || frameHeight != _RGBInputHeight) {
            
            _RGBInputWidth = frameWidth;
            _RGBInputHeight = frameHeight;
            
           
            glBindTexture(GL_TEXTURE_2D, _textureRGBA);
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
        }else{//update texture
                glBindTexture(GL_TEXTURE_2D, _textureRGBA);
                glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, frameWidth, frameHeight, GL_RGBA, GL_UNSIGNED_BYTE, yuvFrame->luma);
        }
    }
    _inputLoaded = YES;
}

-(void) loadFrameFastUpload:(VideoFrameYUV *)yuvFrame{
    
    CVPixelBufferRef frame = yuvFrame->cv_pixelbuffer_fastupload;
    if (frame == NULL) {
        return;
    }
    
    if (_textCache == NULL) {
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _context, NULL, &_textCache);
        
        if (err)
        {
            NSAssert(NO, @"Error at CVOpenGLESTextureCacheCreate %d", err);
            return;
        }
    }
    
    if (CVPixelBufferGetPlaneCount(frame) == 3)
    {
        //y-cr-cb
        const int frameWidth = yuvFrame->width;
        const int frameHeight = yuvFrame->height;
        int widths[3]  = { frameWidth, frameWidth / 2, frameWidth / 2 };
        int heights[3] = { frameHeight, frameHeight / 2, frameHeight / 2 };
        int byteTypes[3] = {GL_LUMINANCE, GL_LUMINANCE, GL_LUMINANCE};
        
        for (int i=0; i<3; i++) {
            glActiveTexture(GL_TEXTURE0 + i);
            
            CVReturn err;
            // Y-plane
            err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textCache, frame, NULL, GL_TEXTURE_2D, byteTypes[i], widths[i], heights[i], byteTypes[i], GL_UNSIGNED_BYTE, i, &_fastupload_cvRef[i]);
            
            if (err)
            {
                ERROR(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
                return;
            }
            
            _fastupload_textureYUV[i] = CVOpenGLESTextureGetName(_fastupload_cvRef[i]);
            glBindTexture(GL_TEXTURE_2D, _fastupload_textureYUV[i]);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        }
    }
    else if(CVPixelBufferGetPlaneCount(frame) == 2){
        //y-cr-cb-bi
        const int frameWidth = yuvFrame->width;
        const int frameHeight = yuvFrame->height;
        int widths[2]  = { frameWidth, frameWidth / 2};
        int heights[2] = { frameHeight, frameHeight / 2,};
        int byteTypes[2] = {GL_LUMINANCE, GL_LUMINANCE_ALPHA};
        
        for (int i=0; i<2; i++) {
            glActiveTexture(GL_TEXTURE0 + i);
            
            CVReturn err;
            // Y-plane
            err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textCache, frame, NULL, GL_TEXTURE_2D, byteTypes[i], widths[i], heights[i], byteTypes[i], GL_UNSIGNED_BYTE, i, &_fastupload_cvRef[i]);
            
            if (err)
            {
                ERROR(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
                return;
            }
            
            _fastupload_textureYUV[i] = CVOpenGLESTextureGetName(_fastupload_cvRef[i]);
            glBindTexture(GL_TEXTURE_2D, _fastupload_textureYUV[i]);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        }
        _fastupload_textureYUV[2] = 0;
    }
    
    _inputLoaded = YES;
}

#pragma mark - sobel render

- (BOOL)loadShadersSobel
{
    if (_programSobel) {
        return YES;
    }
    
    BOOL result = NO;
    GLuint vertShader = 0, fragShader = 0;

    //create yuv program
    _programSobel = glCreateProgram();

    vertShader = compileShader(GL_VERTEX_SHADER, passThroughVS);
    if (!vertShader){
        goto exit;
    }

    fragShader = compileShader(GL_FRAGMENT_SHADER, sobelFS);
    if (!fragShader){
        goto exit;
    }

    glAttachShader(_programSobel, vertShader);
    glAttachShader(_programSobel, fragShader);
    glBindAttribLocation(_programSobel, ATTRIBUTE_VERTEX, "position");
    glBindAttribLocation(_programSobel, ATTRIBUTE_TEXCOORD, "texcoord");

    glLinkProgram(_programSobel);

    GLint status;
    glGetProgramiv(_programSobel, GL_LINK_STATUS, &status);
    if (status == GL_FALSE) {
        ERROR(@"Failed to link program Sobel");
        goto exit;
    }

    //uniform
    _uniformSamplersSobel = glGetUniformLocation(_programSobel, "s_texture");
    _unifromDxDy = glGetUniformLocation(_programSobel, "dxdy");
    _uniformRange = glGetUniformLocation(_programSobel, "range");
    result = validateProgram(_programSobel);
exit:

    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);

    if (result) {

        INFO(@"OK setup GL programm");

    } else {
        glDeleteProgram(_programSobel);
        _programSobel = 0;
    }
    return result;
}

-(void) deleteOutputSobel{
    if (_sobelFrameBuffer) {
        glDeleteFramebuffers(1, &_sobelFrameBuffer);
        _sobelFrameBuffer = 0;
    }

    if (_sobelRenderBuffer) {
        glDeleteTextures(1, &_sobelRenderBuffer);
        _sobelRenderBuffer = 0;
    }
}

-(void) configureOutputSobel{
    //same size as input
    if (_sobelOutputWidth != (int)_inputWidth
        || _sobelOutputHeight != (int)_inputHeight) {
        [self deleteOutputSobel];
    }
    
    if (!_sobelFrameBuffer && _inputWidth && _inputHeight) {
        glGenTextureFromFramebuffer(&_sobelRenderBuffer, &_sobelFrameBuffer, _inputWidth, _inputHeight);
        _sobelOutputWidth = _inputWidth;
        _sobelOutputHeight = _inputHeight;
    }
}

-(void) releaseSobel{
    [self deleteOutputSobel];
    
    if(_programSobel){
        glDeleteProgram(_programSobel);
        _programSobel = 0;
    }
}

-(void) renderToSobel{
    if (!_programSobel || 0==_sobelOutputWidth || 0==_sobelOutputHeight) {
        return;
    }
    glUseProgram(_programSobel);
    
    //input texture
    glUniform1i(_uniformSamplersSobel, 0);
    
    //set over exposed texture
    GLfloat range[4] = {0, 1, 0, 1};
    if(!CGRectEqualToRect(_sobelRange, CGRectZero)){
        //sobel range
        range[0] = _sobelRange.origin.x;
        range[2] = 1.0 -(_sobelRange.origin.y+_sobelRange.size.height);
        range[1] = (_sobelRange.origin.x+_sobelRange.size.width);
        range[3] = 1.0 - _sobelRange.origin.y;
    }
    glUniform4fv(_uniformRange, 1, range);
    
    //dx dy
    GLfloat dxdy[] = {1.0, 1.0, 0, 0};
    dxdy[0] = dxdy[0]/_sobelOutputWidth;
    dxdy[1] = dxdy[1]/_sobelOutputHeight;
    
    //threshold
    dxdy[2] = _focusWarningThreshold;
    glUniform4fv(_unifromDxDy, 1, dxdy);
    
    glVertexAttribPointer(ATTRIBUTE_VERTEX, 2, GL_FLOAT, 0, 0, _vertices);
    glEnableVertexAttribArray(ATTRIBUTE_VERTEX);
    glVertexAttribPointer(ATTRIBUTE_TEXCOORD, 2, GL_FLOAT, 0, 0, g_postQuadTexCoords);
    glEnableVertexAttribArray(ATTRIBUTE_TEXCOORD);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

#pragma mark - render to screen

- (BOOL)loadShadersPresent
{
    if (_programPresent) {
        return YES;
    }
    BOOL result = NO;
    GLuint vertShader = 0, fragShader = 0;
    
    //create yuv program
    _programPresent = glCreateProgram();
    
    vertShader = compileShader(GL_VERTEX_SHADER, overExpVS);
    if (!vertShader){
        goto exit;
    }
    
    fragShader = compileShader(GL_FRAGMENT_SHADER, renderToScreenFS);
    if (!fragShader){
        goto exit;
    }
    
    glAttachShader(_programPresent, vertShader);
    glAttachShader(_programPresent, fragShader);
    glBindAttribLocation(_programPresent, ATTRIBUTE_VERTEX, "position");
    glBindAttribLocation(_programPresent, ATTRIBUTE_TEXCOORD, "texcoord");
    
    glLinkProgram(_programPresent);
    
    GLint status;
    glGetProgramiv(_programPresent, GL_LINK_STATUS, &status);
    if (status == GL_FALSE) {
        ERROR(@"Failed to link program Present");
        goto exit;
    }
    
    //uniform
    _uniformPresentSampler = glGetUniformLocation(_programPresent, "s_texture");
    _over_exposed_param = glGetUniformLocation(_programPresent, "overexp_texture_param");
    _over_exposed_tex_uniform = glGetUniformLocation(_programPresent, "s_texture_overexp");
    
    //load over exposed texture
    //use gl_repeat on this texture, the size of this texture must be pow of 2
    {
        UIImage* image = [UIImage imageNamed:@"overExposedTexture"];
        _over_exposed_tex = [self LoadTextureWithUIImage:image];
        //get scaled size
        _over_exposed_tex_width = image.size.width;
        if (image.scale != 0) {
            _over_exposed_tex_width = _over_exposed_tex_width*image.scale;
        }
    }
    
    result = validateProgram(_programPresent);
exit:
    
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
    
    if (result) {
        
        INFO(@"OK setup GL programm");
        
    } else {
        
        glDeleteProgram(_programPresent);
        _programPresent = 0;
    }
    return result;
}

-(void) renderToScreen{
    if (!_programPresent) {
        return;
    }
    glUseProgram(_programPresent);
    
    //input texture
    glUniform1i(_uniformPresentSampler, 0);
    
    //set over exposed texture
    GLfloat over_exposed_param[4] = {1, 1, 0, 0};
    if(_overExposedMark > 0 && _over_exposed_tex){
        glActiveTexture(GL_TEXTURE0 + 3);
        glBindTexture(GL_TEXTURE_2D, _over_exposed_tex);
        glUniform1i(_over_exposed_tex_uniform, 3);
        
        if(_over_exposed_tex_width){
            over_exposed_param[0] = _backingWidth/_over_exposed_tex_width;
            over_exposed_param[1] = _backingHeight/_over_exposed_tex_width;
        }
        
        static float offset = 0.0;
        float delta_time = [self getCurrentTimeDiff]/1000.0;
        offset += delta_time*0.5;
        offset -= floorf(offset);
        over_exposed_param[2] = offset;
        
        //enable blend
        over_exposed_param[3] = _overExposedMark;
    }
    glUniform4fv(_over_exposed_param, 1, over_exposed_param);

    glVertexAttribPointer(ATTRIBUTE_VERTEX, 2, GL_FLOAT, 0, 0, _vertices);
    glEnableVertexAttribArray(ATTRIBUTE_VERTEX);
    glVertexAttribPointer(ATTRIBUTE_TEXCOORD, 2, GL_FLOAT, 0, 0, g_postQuadTexCoords);
    glEnableVertexAttribArray(ATTRIBUTE_TEXCOORD);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

-(void) releasePresent{
    if(_over_exposed_tex){
        glDeleteTextures(1, &_over_exposed_tex);
        _over_exposed_tex = 0;
    }
    
    if (_programPresent) {
        glDeleteProgram(_programPresent);
        _programPresent = 0;
    }
}

#pragma mark - gl helper

+ (BOOL)supportsFastTextureUpload;
{
#if TARGET_IPHONE_SIMULATOR
    return NO;
#else
    return (&CVOpenGLESTextureCacheCreate != NULL);
#endif
}

-(GLuint)LoadTextureWithUIImage:(UIImage*)image{
    // 1
    CGImageRef spriteImage = image.CGImage;
    if (!spriteImage) {
        ERROR(@"Failed to load image");
        return 0;
    }
    
    // 2
    int width = (int)CGImageGetWidth(spriteImage);
    int height = (int)CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(spriteImage), (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    // 3
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    CGContextRelease(spriteContext);
    
    // 4
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    //memset(spriteData, 0, width*height*4);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
    return texName;
}
    
-(GLuint)LoadTexture:(NSString *)fileName{
    return [self LoadTextureWithUIImage:[UIImage imageNamed:fileName]];
}

-(uint32_t) getCurrentTimeDiff{
    //get timetag in msec
    static NSDate* baseDate = NULL;
    
    if (!baseDate) {
        baseDate = [NSDate date];
    }
    
    uint32_t diff = (unsigned int)(1000*(-[baseDate timeIntervalSinceNow]));
    baseDate = [NSDate date];
    return diff;
}

//called when output changes
-(void) rebindFrameBuffer{
    [EAGLContext setCurrentContext:_context];
    
    if (_framebuffer) {
        glDeleteFramebuffers(1, &_framebuffer);
    }
    
    if (_renderbuffer) {
        glDeleteRenderbuffers(1, &_renderbuffer);
    }
    
    //When the screen size changes, we need to re-create a rendering surface
    glGenFramebuffers(1, &_framebuffer);
    glGenRenderbuffers(1, &_renderbuffer);

    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderbuffer);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        ERROR(@"failed to make complete framebuffer object %x", status);
    }
    
    _viewPointWidth = self.frame.size.width;
    _viewPointHeight = self.frame.size.height;
}

#pragma mark - snapshot and thumbnail rending

- (void) setSnapshotCallback:(snapshotBlock)snapshotCallback{
    if (snapshotCallback == _snapshotCallback) {
        return;
    }
    
    if (_snapshotCallback) {
        _snapshotCallback(nil);
    }
    
    _snapshotCallback = snapshotCallback;
}

-(void) setSnapshotThumbnailCallback:(snapshotBlock)snapshotThumbnailCallback{
    if (snapshotThumbnailCallback == _snapshotThumbnailCallback) {
        return;
    }
    
    if (_snapshotThumbnailCallback) {
        _snapshotThumbnailCallback(nil);
    }
    
    _snapshotThumbnailCallback = snapshotThumbnailCallback;
}

//The image size of the thumbnail to adjust the texture coordinates, geometric filling
-(void) updateThumbnailTexcoord{
//    0.0f, 1.0f,
//    1.0f, 1.0f,
//    0.0f, 0.0f,
//    1.0f, 0.0f,
    
    float x_scale = _inputWidth/THUMBNAIL_IMAGE_WIDTH;
    float y_scale = _inputHeight/THUMBNAIL_IMAGE_HIGHT;
    float over_all_content_scale = MIN(x_scale, y_scale);
    
    float x_texcord_width = (THUMBNAIL_IMAGE_WIDTH * over_all_content_scale)/(_inputWidth);
    float y_texcord_hight = (THUMBNAIL_IMAGE_HIGHT * over_all_content_scale)/(_inputHeight);
    
    float x_min = 0.5 - 0.5*x_texcord_width;
    float x_max = 0.5 + 0.5*x_texcord_width;
    float y_min = 0.5 - 0.5*y_texcord_hight;
    float y_max = 0.5 + 0.5*y_texcord_hight;
    
    _downscale_quadTexCoords[0] = x_min;
    _downscale_quadTexCoords[1] = y_max;
    
    _downscale_quadTexCoords[2] = x_max;
    _downscale_quadTexCoords[3] = y_max;
    
    _downscale_quadTexCoords[4] = x_min;
    _downscale_quadTexCoords[5] = y_min;
    
    _downscale_quadTexCoords[6] = x_max;
    _downscale_quadTexCoords[7] = y_min;
}

-(UIImage*) snapshotThumbnail{
    if (!THUMBNAIL_IMAGE_HIGHT || !THUMBNAIL_IMAGE_WIDTH
        || !_inputWidth || !_inputHeight) {
        return nil;
    }
    
    [self configureThumbnail];
    glBindFramebuffer(GL_FRAMEBUFFER, _downscale_framebuffer);
    glViewport(0, 0, THUMBNAIL_IMAGE_WIDTH, THUMBNAIL_IMAGE_HIGHT);
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    //TODO: Use a simpler sharder thumbnails to improve performance
    BOOL temp_grapScale = _grayScale;
    float temp_overExp = _overExposedMark;
    float temp_luminance = _luminanceScale;
    
    _grayScale = NO;
    _overExposedMark = 0;
    _luminanceScale = 1.0;
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _rgbRenderBuffer);
    [self renderToScreen];
    
    UIImage* image = [self snapshotWithTextureW:THUMBNAIL_IMAGE_WIDTH h:THUMBNAIL_IMAGE_HIGHT ];
    
    _grayScale = temp_grapScale;
    _overExposedMark = temp_overExp;
    _luminanceScale = temp_luminance;
    
    return image;
}

- (UIImage*)snapshotWithTextureW:(int)w h:(int)h{
    
    if (!w || !h) {
        return nil;
    }
    
    int x = 0, y = 0, width = w, height = h;
    int dataLength = width * height * 4;
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    
    // Read pixel data from the framebuffer
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,
                                    ref, NULL, true, kCGRenderingIntentDefault);
    

    NSInteger widthInPoints, heightInPoints;
    if (NULL != &UIGraphicsBeginImageContextWithOptions) {
        CGFloat scale = self.contentScaleFactor;
        widthInPoints = width / scale;
        heightInPoints = height / scale;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
        
    }
    
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Clean up
    free(data);
    CFRelease(ref);
    CFRelease(colorspace);
    CGImageRelease(iref);
    return image;
}

- (UIImage*) snapshotUImageFull{
    
    int x = 0, y = 0, width = _rgbOutputWidth, height = _rgbOutputHeight;
    int dataLength = width * height * 4;
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    
    // Read pixel data from the framebuffer
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    
    // Create a CGImage with the pixel data
    // If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
    // otherwise, use kCGImageAlphaPremultipliedLast
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaNone,
                                    ref, NULL, true, kCGRenderingIntentDefault);
    
    // OpenGL ES measures data in PIXELS
    // Create a graphics context with the target size measured in POINTS
    NSInteger widthInPoints, heightInPoints;

    if (NULL != &UIGraphicsBeginImageContextWithOptions) {
        // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
        // Set the scale parameter to your OpenGL ES view's contentScaleFactor
        // so that you get a high-resolution snapshot when its value is greater than 1.0
        CGFloat scale = self.contentScaleFactor;
        widthInPoints = _inputWidth / scale;
        heightInPoints = _inputHeight / scale;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);

    }
    
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();

    // UIKit coordinate system is upside down to GL/Quartz coordinate system
    // Flip the CGImage by rendering it to the flipped bitmap context
    // The size of the destination area is measured in POINTS
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);



    // Retrieve the UIImage from the current context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Clean up
    free(data);
    CFRelease(ref);
    CFRelease(colorspace);
    CGImageRelease(iref);

    return image;
}

-(void) configureThumbnail{
    if (!_downsacle_renderbuffer) {
        glGenTextureFromFramebuffer(&_downsacle_renderbuffer, &_downscale_framebuffer, THUMBNAIL_IMAGE_WIDTH, THUMBNAIL_IMAGE_HIGHT);
    }
}

-(void) releaseThumbnail{
    if (_downsacle_renderbuffer) {
        glDeleteTextures(1, &_downsacle_renderbuffer);
        _downsacle_renderbuffer = 0;
    }
    
    if (_downscale_framebuffer) {
        glDeleteFramebuffers(1, &_downscale_framebuffer);
        _downscale_framebuffer = 0;
    }
}

@end
