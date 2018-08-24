//
//  MovieGLView.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import "DJIMovieGLView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
//area helper
#import "DJIVideoPresentViewAdjustHelper.h"
//calibration helper
#import "DJIImageCalibrateHelper_Private.h"

//pipeline
#import "DJILiveViewRenderCommon.h"
#import "DJILiveViewRenderPass.h"
#import "DJILiveViewRenderDataSource.h"
#import "DJILiveViewRenderTexture.h"

//filters
#import "DJILiveViewRenderFocusWarningFilter.h"
#import "DJILiveViewRenderScaleFilter.h"
#import "DJIReverseDLogFilter.h"
#import "DJILiveViewRenderHSBFilter.h"
#import "DJILiveViewRenderHighlightShadowFilter.h"
#import "DJILiveViewColorMonitorFilter.h"
#import "DJIWidgetMacros.h"
#include <pthread.h>
#import "DJIImageCalibrateColorGPUConverter.h"

#define THUMBNAIL_IMAGE_WIDTH               (320)
#define THUMBNAIL_IMAGE_HIGHT               (180)

#define INFO(fmt, ...) //DJILog(@"[GLView]"fmt, ##__VA_ARGS__)
#define ERROR(fmt, ...) //DJILog(@"[GLView]"fmt, ##__VA_ARGS__)
//////////////////////////////////////////////////////////

#pragma mark - shaders

enum {
    ATTRIBUTE_VERTEX,
   	ATTRIBUTE_TEXCOORD,
};

typedef NS_ENUM(uint8_t, GLViewAdjustSizeStatus) {
    GLViewAdjustSizeStatusIdle,
    GLViewAdjustSizeStatusAdjusting,
};

//need a virticl flip to present
static const GLfloat g_postQuadTexCoords[] = {
    0.0f, 1.0f,
    1.0f, 1.0f,
    0.0f, 0.0f,
    1.0f, 0.0f,
};

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

#pragma mark - view for diaplay and post effects

@interface DJIMovieGLView ()<DJILiveViewRenderInput>
@property (nonatomic, assign) BOOL willRelease;
//will reset pipline
@property (nonatomic, assign) BOOL needUpdatePipline;
//sourec to convert yuv from decoder
@property (nonatomic, strong) DJILiveViewRenderDataSource* dataSource;
//focus warning filter
@property (nonatomic, strong) DJILiveViewRenderFocusWarningFilter* focusWarningFilter;
//scale filter for getting thumbnails
@property (nonatomic, strong) DJILiveViewRenderScaleFilter* scaleFilter;

//filter to convert a dlog colored live stream back to normal color system
//using a lookup table
@property (nonatomic, strong) DJIReverseDLogFilter* reverseDLogFilter;
//HSB filter
@property (nonatomic, strong) DJILiveViewRenderHSBFilter* hsbFilter;
//shadow and highlight adjust
@property (nonatomic, strong) DJILiveViewRenderHighlightShadowFilter* highlightFilter;
//lock for render;
@property (nonatomic, strong) NSLock* renderLock;

@property (nonatomic) GLViewAdjustSizeStatus adjustSizeStatus;

@property (nonatomic) dispatch_source_t superviewBoundsTimer;
@property (nonatomic) CGRect cachedSuperviewBounds;

@end

@implementation DJIMovieGLView {
    DJILiveViewRenderContext* context;
    
    //common
    CGRect          _targetLayerFrame;
    
    //input
    float _inputWidth;
    float _inputHeight;
    
    //output
    GLuint      _rgbOutputWidth;
    GLuint      _rgbOutputHeight;
    
    //3. screen render
    DJILiveViewRenderProgram* presentProgram;
    GLuint      _uniformPresentSampler;
    GLuint      _attrVertex;
    GLuint      _attrTexcoord;
    
    //over exposed control
    GLint       _over_exposed_param;
    GLint       _over_exposed_tex_uniform;
    DJILiveViewRenderTexture* _over_exposed_texture;
    
    //output
    DJILiveViewFrameBuffer* inputBuffer;
    GLuint      _framebuffer;
    GLuint      _renderbuffer;
    GLint       _backingWidth;
    GLint       _backingHeight;

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

- (void)dealloc {

}

+ (Class) layerClass
{
    return [CAEAGLLayer class];
}

- (id) initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame multiThreadSupported:NO];
}

- (id) initWithFrame:(CGRect)frame multiThreadSupported:(BOOL)multiThread
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _adjustHelper = [[DJIVideoPresentViewAdjustHelper alloc] init];
        _renderLock = [[NSLock alloc] init];
        
        _superviewBoundsTimer = nil;
        _cachedSuperviewBounds = CGRectZero;

        _adjustSizeStatus = GLViewAdjustSizeStatusIdle;
        
        //use a default input size
        _inputWidth   = 1280;
        _inputHeight  = 720;
        _needUpdatePipline = YES;
        
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
        
        context = [[DJILiveViewRenderContext alloc] initWithMultiThreadSupport:multiThread];
        
        if (!context) {
            
            ERROR(@"failed to setup EAGLContext");
            self = nil;
            return nil;
        }
        
        [context useAsCurrentContext];
        
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
        
        _luminanceScale = 1.0;
        _overExposedMark = 0.0;
        _focusWarningThreshold = 3.0;
        _grayScale = NO;
    }
    
    return self;
}

- (void)releaseResourece{
    
    if (self.superviewBoundsTimer) {
        [self stopObserveSuperviewBounds];
    }

    [self.renderLock lock];
    self.willRelease = YES;
    
    [context useAsCurrentContext];

    //release the first chain of retain cicle
    [self.dataSource removeAllTargets];
    [self.dataSource releaseResources];
    self.dataSource = nil;
    
    [self.calibrateFilter removeAllTargets];
    [self.calibrateFilter releaseResources];
    self.calibrateFilter = nil;
    
    self.colorConverter = nil;
    
    [self.scaleFilter removeAllTargets];
    [self.scaleFilter releaseResources];
    self.scaleFilter = nil;
    
    [self.focusWarningFilter removeAllTargets];
    [self.focusWarningFilter releaseResources];
    self.focusWarningFilter = nil;
    
    [self.reverseDLogFilter removeAllTargets];
    [self.reverseDLogFilter releaseResources];
    self.hsbFilter = nil;
    
    [self.highlightFilter removeAllTargets];
    [self.highlightFilter releaseResources];
    self.highlightFilter = nil;
    
    [self.colorMonitor releaseResources];
    self.colorMonitor = nil;
    
    if (_framebuffer) {
        glDeleteFramebuffers(1, &_framebuffer);
        _framebuffer = 0;
    }
    
    if (_renderbuffer) {
        glDeleteRenderbuffers(1, &_renderbuffer);
        _renderbuffer = 0;
    }
    
    [presentProgram destory];
    
    //release context
    [context releaseContext];
    context = nil;
    [self.renderLock unlock];
}


- (BOOL)adjustSize{
    NSAssert([NSThread isMainThread], @"adjustViewSize should be called in main thread only. ");
    if(self.superview == nil) return NO;
    
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
    }else {
        _targetLayerFrame = adjustFrame;
        [self setFrame:adjustFrame];
        [self notifyFrameChange];
        return YES;
    }
}

-(void) notifyFrameChange{
    //always on main thread
    if ([_delegate respondsToSelector:@selector(movieGlView:didChangedFrame:)]) {
        [_delegate movieGlView:self didChangedFrame:self.frame];
    }
}

-(BOOL)checkFrame:(CGRect)frame1
    equalsToFrame:(CGRect)frame2{
    if (CGRectEqualToRect(frame1, frame2)){
        return YES;
    }
    if (fabs(frame1.origin.x - frame2.origin.x) < 1.0e-3
        && fabs(frame1.origin.y - frame2.origin.y) < 1.0e-3
        && fabs(frame1.size.width - frame2.size.width) < 1.0e-3
        && fabs(frame1.size.height - frame2.size.height) < 1.0e-3){
        return YES;
    }
    return NO;
}

-(void) setFrame:(CGRect)frame{
    NSAssert([NSThread isMainThread], @"setFrame should be called in main thread only. ");
    if ([self checkFrame:self.frame
           equalsToFrame:frame]) {
        return;
    }
    [super setFrame:frame];
    _targetLayerFrame = frame;
    [self rebindFrameBuffer];
}

// WORKAROUND: The prevoius design make the movie gl view observe the change of superview in the rendering thread.
// This will cause the complain of Main Thread Checker. Therefore, a timer in main queue is created to keep
// fetching the latest frame of superview.
-(void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview) {
        [self startObserveSuperviewBounds];
    }
    else {
        [self stopObserveSuperviewBounds];
    }
}

-(void)startObserveSuperviewBounds {
    if (self.superviewBoundsTimer) {
        return;
    }
    self.superviewBoundsTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.superviewBoundsTimer, DISPATCH_TIME_NOW, (1.0 / 60.0) * NSEC_PER_SEC, (1.0 / 60.0) * NSEC_PER_SEC);
    weakSelf(target);
    dispatch_source_set_event_handler(self.superviewBoundsTimer, ^{
        weakReturn(target);
        if (target.superview == nil) {
            return;
        }
        if (!CGRectEqualToRect(target.cachedSuperviewBounds, target.superview.bounds)) {
            [target adjustSize];
        }
    });
    dispatch_resume(self.superviewBoundsTimer);
}

-(void)stopObserveSuperviewBounds {
    if (self.superviewBoundsTimer == nil) {
        return;
    }
    dispatch_source_cancel(self.superviewBoundsTimer);
    self.superviewBoundsTimer = nil;
}

#pragma mark - gl render

-(void) setupPipLine{
    //Create the necessary pipeline
    if (_needUpdatePipline == NO
        && _dataSource != nil) {
        return;
    }
    
    if (_willRelease) {
        return;
    }
    
    //Basic pipeline
    if (!_dataSource) {
        _dataSource = [[DJILiveViewRenderDataSource alloc] initWithContext:context];
        
        // Thumbnail capture
        _scaleFilter = [[DJILiveViewRenderScaleFilter alloc] initWithContext:context];
        _scaleFilter.targetSize = CGSizeMake(THUMBNAIL_IMAGE_WIDTH, THUMBNAIL_IMAGE_HIGHT);
        _scaleFilter.enabled = NO;
    }
    [_dataSource removeAllTargets];
	
	// follow step
    [_dataSource addTarget:_scaleFilter atTextureLocation:0];
	DJILiveViewRenderPass* lastPass = _dataSource;
    
    if (_calibrateEnabled){
        if (_calibrateFilter == nil){
            //图像校正
            _calibrateFilter = [[DJILiveViewCalibrateFilter alloc] initWithContext:context];
            _calibrateFilter.idx = 0;
            _calibrateFilter.enabled = YES;
        }
#if __USE_PIXELBUFFER_PROVIDER__
        if (self.calibratePixelBufferProvider == nil) {
            self.calibratePixelBufferProvider = [[DJICalibratePixelBufferProvider alloc] init];
        }
#else
        if (_colorConverter == nil){
            VPFrameType outputFrameType = [DJIImageCalibrateColorGPUConverter proposedType];
            _colorConverter = [[DJIImageCalibrateColorGPUConverter alloc] initWithFrameType:outputFrameType];
            [(DJIImageCalibrateColorGPUConverter*)_colorConverter setContext:context];
        }
#endif
        [_calibrateFilter removeAllTargets];
        [lastPass addTarget:_calibrateFilter atTextureLocation:0];
        lastPass = _calibrateFilter;
#if __USE_PIXELBUFFER_PROVIDER__
        [lastPass addTarget:self.calibratePixelBufferProvider atTextureLocation:0];
#else
        [lastPass addTarget:[_colorConverter holder] atTextureLocation:0];
#endif
    }
    else {
        
        if (_calibrateFilter != nil){
            [self.calibrateFilter removeAllTargets];
            [self.calibrateFilter releaseResources];
            self.calibrateFilter = nil;
        }
#if !__USE_PIXELBUFFER_PROVIDER__
        _colorConverter = nil;
#else
        self.calibratePixelBufferProvider = nil;
#endif
    }
    
    
    [lastPass addTarget:_scaleFilter
      atTextureLocation:0];
    
    //color monitor
    if (_enableColorMonitor) {
        if (self.colorMonitor == nil) {
            self.colorMonitor = [[DJILiveViewColorMonitorFilter alloc] initWithContext:context];
        }
        [lastPass addTarget:self.colorMonitor atTextureLocation:0];
    }else{
        self.colorMonitor = nil;
    }
    
    //anti - dlog
    if (_dLogReverse != DLogReverseLookupTableTypeNone) {
        if (!_reverseDLogFilter) {
            _reverseDLogFilter = [[DJIReverseDLogFilter alloc] initWithContext:context];
            _reverseDLogFilter.lutType = _dLogReverse;
        }
        
        [_reverseDLogFilter removeAllTargets];
        [lastPass addTarget:_reverseDLogFilter
          atTextureLocation:0];
        lastPass = _reverseDLogFilter;
    }
    
    if (_enableHSB) {
        if (!_hsbFilter) {
            _hsbFilter = [[DJILiveViewRenderHSBFilter alloc] initWithContext:context];
        }
        
        [_hsbFilter removeAllTargets];
        [lastPass addTarget:_hsbFilter
          atTextureLocation:0];
        lastPass = _hsbFilter;
    }
    
    if(_enableShadowAndHighLightenhancement){
        if (!_highlightFilter) {
            _highlightFilter = [[DJILiveViewRenderHighlightShadowFilter alloc] initWithContext:context];
        }
        
        [_highlightFilter removeAllTargets];
        [lastPass addTarget:_highlightFilter
          atTextureLocation:0];
        lastPass = _highlightFilter;
    }
    
    //peak focus
    if (_enableFocusWarning) {
        if (!_focusWarningFilter) {
            _focusWarningFilter = [[DJILiveViewRenderFocusWarningFilter alloc] initWithContext:context];
        }
        
        [lastPass addTarget:_focusWarningFilter
          atTextureLocation:0];
        [_focusWarningFilter removeAllTargets];
        lastPass = _focusWarningFilter;
    }
    
    //final step to screen
    [lastPass addTarget:self
      atTextureLocation:0];
    
    _needUpdatePipline = NO;
    
}

-(void) clear{
    [_dataSource renderBlack];
}

- (void)render: (VideoFrameYUV *) frame
{

    if (!frame) {
        return;
    }
    
    [self.renderLock lock];
    
    //context check
    if(context == nil || self.willRelease){
        [self.renderLock unlock];
        return;
    }
    
    [context useAsCurrentContext];
    //update frame
    if (frame){
        if(frame->width > 2000 || frame->height > 2000){
            ERROR(@"size error %f %f", frame->width, frame->height);
            [self.renderLock unlock];
            return;
        }

        if (_inputWidth != frame->width ||
            _inputHeight != frame->height) {

            if (self.adjustSizeStatus != GLViewAdjustSizeStatusAdjusting) {
                self.adjustSizeStatus = GLViewAdjustSizeStatusAdjusting;
                weakSelf(target);
                int width = frame->width;
                int height = frame->height;
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakReturn(target);
                    DJIMovieGLView *strongView = target;
                    strongView->_inputWidth = width;
                    strongView->_inputHeight = height;
                    [target adjustSize];
                    target.adjustSizeStatus = GLViewAdjustSizeStatusIdle;
                });
            }
            [self.renderLock unlock];
            return;
        }
    }

    //pipeline
    [self setupPipLine];

    //config data source
    _dataSource.grayScale = self.grayScale;
    _dataSource.luminanceScale = self.luminanceScale;
    _dataSource.rotation =  _adjustHelper.rotation;
    
    //config focuswarning
    _focusWarningFilter.focusWarningThreshold = _focusWarningThreshold;
    
    //config hsb
    _hsbFilter.rotateHue = self.hsbConfig.hue;
    _hsbFilter.brightness = self.hsbConfig.brightness;
    _hsbFilter.saturation = self.hsbConfig.saturation;
    
    //config dlog
    if (_dLogReverse != DLogReverseLookupTableTypeNone) {
        _reverseDLogFilter.lutType = self.dLogReverse;
    }
    
    //config highlights and shadow
    _highlightFilter.highlightsDecrease = self.highlightsDecrease;
    _highlightFilter.shadowsLighten = self.shadowsLighten;
    
    //image calibration
    if (_calibrateFilter != nil){
        _calibrateFilter.idx = self.lutIndex;
        _calibrateFilter.fovState = self.fovState;
    }
    
    //upload texture
    [_dataSource loadFrame:frame];
    
    //only enable scale filter when need thumbnail
    if (_snapshotThumbnailCallback) {
        _scaleFilter.enabled = YES;
    }else{
        _scaleFilter.enabled = NO;
    }
    
    [_dataSource renderPass];

    [self.renderLock unlock];
    
    //snapshot full
    if (_snapshotCallback) {
        UIImage* image = [_dataSource imageFromCurrentFramebuffer];
        __block snapshotBlock _block_copy = self.snapshotCallback;
        dispatch_async(dispatch_get_main_queue(), ^{
            if(_block_copy){
                _block_copy(image);
            }
        });
        _snapshotCallback = nil;
    }
    
    //snapshot thumbnail
    if (_snapshotThumbnailCallback) {
        __block UIImage* image = [_scaleFilter imageFromCurrentFramebuffer];
        __block snapshotBlock _block_copy = self.snapshotThumbnailCallback;
        dispatch_async(dispatch_get_main_queue(), ^{
            _block_copy(image);
        });
        _snapshotThumbnailCallback = nil;
    }
}

#pragma mark - Input interface

- (BOOL)enabled{
    return YES;
}

- (void)setInputSize:(CGSize)newSize
             atIndex:(NSInteger)textureIndex{

}

- (void)setInputFramebuffer:(DJILiveViewFrameBuffer *)newInputFramebuffer
                    atIndex:(NSInteger)textureIndex{
    inputBuffer = newInputFramebuffer;
}

- (void)newFrameReadyAtTime:(CMTime)frameTime
                    atIndex:(NSInteger)textureIndex{
    [self renderToScreen];
    [context presentBufferForDisplay];
    CVOpenGLESTextureCacheFlush([context coreVideoTextureCache], 0);
}

- (void)endProcessing{

}

#pragma mark - render to screen

- (BOOL)loadShadersPresent
{
    [context useAsCurrentContext];
    
    if (presentProgram) {
        [context setContextShaderProgram:presentProgram];
        glEnableVertexAttribArray(_attrVertex);
        glEnableVertexAttribArray(_attrTexcoord);
        return YES;
    }
    
    presentProgram = [[DJILiveViewRenderProgram alloc]
                      initWithContext:context
                      vertexShaderString:overExpVS
                      fragmentShaderString:renderToScreenFS];
    
    if (!presentProgram.initialized)
    {
        [presentProgram addAttribute:@"position"];
        [presentProgram addAttribute:@"texcoord"];
        
        
        if (![presentProgram link])
        {
            NSString *progLog = [presentProgram programLog];
            NSLog(@"Program link log: %@", progLog);
            NSString *fragLog = [presentProgram fragmentShaderLog];
            NSLog(@"Fragment shader compile log: %@", fragLog);
            NSString *vertLog = [presentProgram vertexShaderLog];
            NSLog(@"Vertex shader compile log: %@", vertLog);
            NSAssert(NO, @"Filter shader link failed");
            return NO;
        }
    }
    
    _attrVertex = [presentProgram attributeIndex:@"position"];
    _attrTexcoord = [presentProgram attributeIndex:@"texcoord"];
    
    glEnableVertexAttribArray(_attrVertex);
    glEnableVertexAttribArray(_attrTexcoord);
    
    _uniformPresentSampler = [presentProgram uniformIndex:@"s_texture"];
    _over_exposed_param = [presentProgram uniformIndex:@"overexp_texture_param"];
    _over_exposed_tex_uniform = [presentProgram uniformIndex:@"s_texture_overexp"];
    
    //load over exposed texture
    //use gl_repeat on this texture, the size of this texture must be pow of 2
    {
        UIImage* image = [UIImage imageNamed:@"overExposedTexture"];
        DJILiveViewRenderTextureOptions options = defaultOptionsForTexture();
        options.wrapS = GL_REPEAT;
        options.wrapT = GL_REPEAT;
        _over_exposed_texture = [[DJILiveViewRenderTexture alloc] initWithContext:context
                                                                          cgImage:[image CGImage]
                                                                           option:options];
    }
    
    return YES;
}

-(void) renderToScreen{
    
    //3. screen present
    [self loadShadersPresent];
    
    if (!presentProgram) {
        return;
    }
    
    //bind output
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glViewport(0, 0, _backingWidth, _backingHeight);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    //bind input
    if(inputBuffer.texture)
    {
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, inputBuffer.texture);
        glUniform1i(_uniformPresentSampler, 0);
    }
    
    //set over exposed texture
    GLfloat over_exposed_param[4] = {1, 1, 0, 0};
    
    if(_overExposedMark > 0 && _over_exposed_texture){
        glActiveTexture(GL_TEXTURE0 + 3);
        glBindTexture(GL_TEXTURE_2D, _over_exposed_texture.texture);
        glUniform1i(_over_exposed_tex_uniform, 3);
        
        double over_exposed_tex_width = _over_exposed_texture.pixelSizeOfImage.width;
        if(over_exposed_tex_width > 0.0000001) {
            over_exposed_param[0] = _backingWidth/over_exposed_tex_width;
            over_exposed_param[1] = _backingHeight/over_exposed_tex_width;
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
    glVertexAttribPointer(ATTRIBUTE_VERTEX, 2, GL_FLOAT, 0, 0, g_defaultVertexs);
    glEnableVertexAttribArray(ATTRIBUTE_VERTEX);
    glVertexAttribPointer(ATTRIBUTE_TEXCOORD, 2, GL_FLOAT, 0, 0, g_postQuadTexCoords);
    glEnableVertexAttribArray(ATTRIBUTE_TEXCOORD);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

#pragma mark - gl helper

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
    [self.renderLock lock];

    [context useAsCurrentContext];
    
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
    [[context context] renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderbuffer);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        ERROR(@"failed to make complete framebuffer object %x", status);
    }
    
    _viewPointWidth = self.frame.size.width;
    _viewPointHeight = self.frame.size.height;

    [self.renderLock unlock];
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

#pragma mark - interface poperty

-(void) setEnableFocusWarning:(BOOL)enableFocusWarning{
    if (enableFocusWarning == _enableFocusWarning) {
        return;
    }
    
    _enableFocusWarning = enableFocusWarning;
    _needUpdatePipline = YES;
}

-(void) setDLogReverse:(DLogReverseLookupTableType)dLogReverse{
    if (dLogReverse == _dLogReverse) {
        return;
    }
    
    _dLogReverse = dLogReverse;
    _needUpdatePipline = YES;
}

-(void) setEnableHSB:(BOOL)enableHSB{
    if (_enableHSB == enableHSB) {
        return;
    }
    
    _enableHSB = enableHSB;
    _needUpdatePipline = YES;
}

-(void) setEnableShadowAndHighLightenhancement:(BOOL)enableShadowAndHighLightenhancement{
    if (_enableShadowAndHighLightenhancement == enableShadowAndHighLightenhancement) {
        return;
    }
    
    _enableShadowAndHighLightenhancement = enableShadowAndHighLightenhancement;
    _needUpdatePipline = YES;
}

-(void) setEnableColorMonitor:(BOOL)enableColorMonitor{
    if (_enableColorMonitor == enableColorMonitor) {
        return;
    }
    
    _enableColorMonitor = enableColorMonitor;
    _needUpdatePipline = YES;
}

-(void)setType:(VideoPresentContentMode)type {
    NSAssert([NSThread isMainThread], @"setType should be called in main thread only. ");
    if (_type == type) {
        return;
    }
    _type = type;
    [self adjustSize];
}

-(void)setRotation:(VideoStreamRotationType)rotation {
    NSAssert([NSThread isMainThread], @"setRotation should be called in main thread only. ");
    if (_rotation == rotation) {
        return;
    }
    _rotation = rotation;
    [self adjustSize];
}

-(void)setContentClipRect:(CGRect)contentClipRect {
    NSAssert([NSThread isMainThread], @"setContentClipRect should be called in main thread only. ");
    if (CGRectEqualToRect(contentClipRect, _contentClipRect)) {
        return;
    }
    _contentClipRect = contentClipRect;
    [self adjustSize];
}

-(void)setCalibrateEnabled:(BOOL)calibrateEnabled{
    if (_calibrateEnabled == calibrateEnabled){
        return;
    }
    _calibrateEnabled = calibrateEnabled;
    _needUpdatePipline = YES;
}

@end



//	dump frame
//        static int counter = 0;
//        if (false && counter%100 == 0 && frame && frame->cv_pixelbuffer_fastupload) {
//            //snapshoot
//            int index = counter;
//            UIImage* image = [_dataSource imageFromCurrentFramebuffer];
//
//            //dump data
//            void* y = CVPixelBufferGetBaseAddressOfPlane(frame->cv_pixelbuffer_fastupload,
//                                                         0);
//            size_t y_size_stride = CVPixelBufferGetBytesPerRowOfPlane(frame->cv_pixelbuffer_fastupload,
//                                                                      0);
//            size_t y_height = CVPixelBufferGetHeightOfPlane(frame->cv_pixelbuffer_fastupload,
//                                                            0);
//            size_t y_size = y_size_stride*y_height;
//            NSData* y_data = [NSData dataWithBytes:y length:y_size];
//
//            void* rb = CVPixelBufferGetBaseAddressOfPlane(frame->cv_pixelbuffer_fastupload,
//                                                          1);
//            size_t rb_size_stride = CVPixelBufferGetBytesPerRowOfPlane(frame->cv_pixelbuffer_fastupload,
//                                                                       1);
//            size_t rb_height = CVPixelBufferGetHeightOfPlane(frame->cv_pixelbuffer_fastupload,
//                                                             1);
//            size_t rb_size = rb_size_stride * rb_height;
//            NSData* rb_data = [NSData dataWithBytes:rb length:rb_size];
//
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//
//                NSData* data = UIImagePNGRepresentation(image);
//                NSArray* doucuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//                NSString* filePath = [doucuments objectAtIndex:0];
//                NSString* filename =  [filePath stringByAppendingPathComponent:
//                [NSString stringWithFormat:@"dump_image_%d", index]];
//
//                if (data) {
//                    [data writeToFile:[filename stringByAppendingString:@".png"]
//                           atomically:YES];
//
//                    [y_data writeToFile:[filename stringByAppendingString:@"_y"] atomically:YES];
//                    [rb_data writeToFile:[filename stringByAppendingString:@"_crcb"] atomically:YES];
//                }
//            });
//        }
//        counter++;
