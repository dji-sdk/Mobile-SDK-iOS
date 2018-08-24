//
//  DJILiveViewFrameBuffer.m
//

#import "DJILiveViewFrameBuffer_Private.h"
#import <libkern/OSAtomic.h>

DJILiveViewRenderTextureOptions defaultOptionsForTexture(){
    DJILiveViewRenderTextureOptions defaultTextureOptions = {0};
    defaultTextureOptions.minFilter = GL_LINEAR;
    defaultTextureOptions.magFilter = GL_LINEAR;
    defaultTextureOptions.wrapS = GL_CLAMP_TO_EDGE;
    defaultTextureOptions.wrapT = GL_CLAMP_TO_EDGE;
    defaultTextureOptions.internalFormat = GL_RGBA;
    defaultTextureOptions.format = GL_BGRA;
    defaultTextureOptions.type = GL_UNSIGNED_BYTE;
    
    return defaultTextureOptions;
};

void dji_dataProviderReleaseCallback (void *info, const void *data, size_t size);
void dji_dataProviderUnlockCallback (void *info, const void *data, size_t size);

@implementation DJILiveViewFrameBuffer

@synthesize size = _size;
@synthesize textureOptions = _textureOptions;
@synthesize texture = _texture;
@synthesize missingFramebuffer = _missingFramebuffer;


- (CVPixelBufferRef)pixelBuffer {
    return self.privateRenderTarget;
}


#pragma mark -
#pragma mark Initialization and teardown

-(id)init{
    return (self = [super init]);
}

- (id)initWithContext:(id)acontext
                 size:(CGSize)framebufferSize
       textureOptions:(DJILiveViewRenderTextureOptions)fboTextureOptions
          onlyTexture:(BOOL)onlyGenerateTexture;
{
    if (!(self = [self init]))
    {
        return nil;
    }
    
    _context = acontext;
    _textureOptions = fboTextureOptions;
    _size = framebufferSize;
    framebufferReferenceCount = 0;
    referenceCountingDisabled = NO;
    _missingFramebuffer = onlyGenerateTexture;
    
    if (_missingFramebuffer)
    {
        [self generateTexture];
        framebuffer = 0;
    }
    else
    {
        [self generateFramebuffer];
    }
    return self;
}

- (id)initWithContext:(id)acontext
                 size:(CGSize)framebufferSize
    overriddenTexture:(GLuint)inputTexture;
{
    if (!(self = [self init]))
    {
        return nil;
    }
    
    DJILiveViewRenderTextureOptions defaultTextureOptions;
    defaultTextureOptions.minFilter = GL_LINEAR;
    defaultTextureOptions.magFilter = GL_LINEAR;
    defaultTextureOptions.wrapS = GL_CLAMP_TO_EDGE;
    defaultTextureOptions.wrapT = GL_CLAMP_TO_EDGE;
    defaultTextureOptions.internalFormat = GL_RGBA;
    defaultTextureOptions.format = GL_BGRA;
    defaultTextureOptions.type = GL_UNSIGNED_BYTE;
    
    _context = acontext;
    _textureOptions = defaultTextureOptions;
    _size = framebufferSize;
    framebufferReferenceCount = 0;
    referenceCountingDisabled = YES;
    _texture = inputTexture;
    
    return self;
}

- (id)initWithContext:(id)acontext
                 size:(CGSize)framebufferSize;
{
    DJILiveViewRenderTextureOptions defaultTextureOptions;
    defaultTextureOptions.minFilter = GL_LINEAR;
    defaultTextureOptions.magFilter = GL_LINEAR;
    defaultTextureOptions.wrapS = GL_CLAMP_TO_EDGE;
    defaultTextureOptions.wrapT = GL_CLAMP_TO_EDGE;
    defaultTextureOptions.internalFormat = GL_RGBA;
    defaultTextureOptions.format = GL_BGRA;
    defaultTextureOptions.type = GL_UNSIGNED_BYTE;
    
    if (!(self = [self initWithContext:acontext
                                  size:framebufferSize
                        textureOptions:defaultTextureOptions
                           onlyTexture:NO]))
    {
        return nil;
    }
    
    return self;
}

- (void)dealloc
{
    [self destroyFramebuffer];
}

#pragma mark -
#pragma mark Internal

- (void)generateTexture;
{
    glActiveTexture(GL_TEXTURE1);
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, _textureOptions.minFilter);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, _textureOptions.magFilter);
    // This is necessary for non-power-of-two textures
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, _textureOptions.wrapS);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, _textureOptions.wrapT);
    
    // TODO: Handle mipmaps
}

- (void)generateFramebuffer;
{
     [_context useAsCurrentContext];
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    

    if ([DJILiveViewRenderContext supportsFastTextureUpload])
    {
        CVOpenGLESTextureCacheRef coreVideoTextureCache = [_context coreVideoTextureCache];
        // Code originally sourced from http://allmybrain.com/2011/12/08/rendering-to-a-texture-with-ios-5-texture-cache-api/
        
        CFDictionaryRef empty; // empty value for attr value.
        CFMutableDictionaryRef attrs;
        empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks); // our empty IOSurface properties dictionary
        attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
        
        CVReturn err = CVPixelBufferCreate(kCFAllocatorDefault, (int)_size.width, (int)_size.height, kCVPixelFormatType_32BGRA, attrs, &renderTarget);
        if (err)
        {
            NSLog(@"FBO size: %f, %f", _size.width, _size.height);
            NSAssert(NO, @"Error at CVPixelBufferCreate %d", err);
        }
        
        err = CVOpenGLESTextureCacheCreateTextureFromImage (kCFAllocatorDefault, coreVideoTextureCache, renderTarget,
                                                            NULL, // texture attributes
                                                            GL_TEXTURE_2D,
                                                            _textureOptions.internalFormat, // opengl format
                                                            (int)_size.width,
                                                            (int)_size.height,
                                                            _textureOptions.format, // native iOS format
                                                            _textureOptions.type,
                                                            0,
                                                            &renderTexture);
        if (err)
        {
            NSAssert(NO, @"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
        }
        
        CFRelease(attrs);
        CFRelease(empty);
        
        glBindTexture(CVOpenGLESTextureGetTarget(renderTexture), CVOpenGLESTextureGetName(renderTexture));
        _texture = CVOpenGLESTextureGetName(renderTexture);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, _textureOptions.wrapS);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, _textureOptions.wrapT);
        
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, CVOpenGLESTextureGetName(renderTexture), 0);
    }
    else
    {
        [self generateTexture];
        
        glBindTexture(GL_TEXTURE_2D, _texture);
        
        glTexImage2D(GL_TEXTURE_2D, 0, _textureOptions.internalFormat, (int)_size.width, (int)_size.height, 0, _textureOptions.format, _textureOptions.type, 0);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _texture, 0);
    }
    
#ifndef NS_BLOCK_ASSERTIONS
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"Incomplete filter FBO: %d", status);
#endif
    
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)destroyFramebuffer;
{
    [_context useAsCurrentContext];
    
    if (framebuffer)
    {
        glDeleteFramebuffers(1, &framebuffer);
        framebuffer = 0;
    }
    
    
    if ([DJILiveViewRenderContext supportsFastTextureUpload] && (!_missingFramebuffer))
    {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        if (renderTarget)
        {
            CFRelease(renderTarget);
            renderTarget = NULL;
        }
        
        if (renderTexture)
        {
            CFRelease(renderTexture);
            renderTexture = NULL;
        }
#endif
    }
    else
    {
        glDeleteTextures(1, &_texture);
    }
    
    _released = YES;
}

#pragma mark -
#pragma mark Usage

- (void)activateFramebuffer;
{
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glViewport(0, 0, (int)_size.width, (int)_size.height);
}

#pragma mark -
#pragma mark Image capture
    
void dji_dataProviderReleaseCallback (void *info, const void *data, size_t size)
{
    free((void *)data);
}

void dji_dataProviderUnlockCallback (void *info, const void *data, size_t size)
{
    DJILiveViewFrameBuffer *framebuffer = (__bridge_transfer DJILiveViewFrameBuffer*)info;
    
    [framebuffer restoreRenderTarget];
}

- (CGImageRef)newCGImageFromFramebufferContents;
{
    // a CGImage can only be created from a 'normal' color texture
    NSAssert(self.textureOptions.internalFormat == GL_RGBA, @"For conversion to a CGImage the output texture format for this filter must be GL_RGBA.");
    NSAssert(self.textureOptions.type == GL_UNSIGNED_BYTE, @"For conversion to a CGImage the type of the output texture of this filter must be GL_UNSIGNED_BYTE.");
    
    __block CGImageRef cgImageFromBytes;

    [_context useAsCurrentContext];
    
    NSUInteger totalBytesForImage = (int)_size.width * (int)_size.height * 4;
    // It appears that the width of a texture must be padded out to be a multiple of 8 (32 bytes) if reading from it using a texture cache
    
    GLubyte *rawImagePixels;
    
    CGDataProviderRef dataProvider = NULL;
    if ((false))//[DJILiveViewRenderContext supportsFastTextureUpload])
    {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        NSUInteger paddedWidthOfImage = CVPixelBufferGetBytesPerRow(renderTarget) / 4.0;
        NSUInteger paddedBytesForImage = paddedWidthOfImage * (int)_size.height * 4;
        
        glFinish();
        CFRetain(renderTarget); // I need to retain the pixel buffer here and release in the data source callback to prevent its bytes from being prematurely deallocated during a photo write operation
        [self lockForReading];
        rawImagePixels = (GLubyte *)CVPixelBufferGetBaseAddress(renderTarget);
        dataProvider = CGDataProviderCreateWithData((__bridge_retained void*)self, rawImagePixels, paddedBytesForImage, dji_dataProviderUnlockCallback);
#else
#endif
    }
    else
    {
        [self activateFramebuffer];
        rawImagePixels = (GLubyte *)malloc(totalBytesForImage);
        glReadPixels(0, 0, (int)_size.width, (int)_size.height, GL_RGBA, GL_UNSIGNED_BYTE, rawImagePixels);
        dataProvider = CGDataProviderCreateWithData(NULL, rawImagePixels, totalBytesForImage, dji_dataProviderReleaseCallback);
    }
    
    CGColorSpaceRef defaultRGBColorSpace = CGColorSpaceCreateDeviceRGB();
    
    if ((false))
    {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        cgImageFromBytes = CGImageCreate((int)_size.width, (int)_size.height, 8, 32, CVPixelBufferGetBytesPerRow(renderTarget), defaultRGBColorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst, dataProvider, NULL, NO, kCGRenderingIntentDefault);
#else
#endif
    }
    else
    {
        cgImageFromBytes = CGImageCreate((int)_size.width, (int)_size.height, 8, 32, 4 * (int)_size.width, defaultRGBColorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaNoneSkipLast, dataProvider, NULL, NO, kCGRenderingIntentDefault);
    }
    
    // Capture image with current device orientation
    CGDataProviderRelease(dataProvider);
    CGColorSpaceRelease(defaultRGBColorSpace);
    
    return cgImageFromBytes;
}

- (void)restoreRenderTarget;
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    [self unlockAfterReading];
    CFRelease(renderTarget);
#else
#endif
}
    
#pragma mark -
#pragma mark Raw data bytes

- (void)lockForReading
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    if ([DJILiveViewRenderContext supportsFastTextureUpload])
    {
        if (readLockCount == 0)
        {
            CVPixelBufferLockBaseAddress(renderTarget, 0);
        }
        readLockCount++;
    }
#endif
}

- (void)unlockAfterReading
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    if ([DJILiveViewRenderContext supportsFastTextureUpload])
    {
        NSAssert(readLockCount > 0, @"Unbalanced call to -[GPUImageFramebuffer unlockAfterReading]");
        readLockCount--;
        if (readLockCount == 0)
        {
            CVPixelBufferUnlockBaseAddress(renderTarget, 0);
        }
    }
#endif
}

- (NSUInteger)bytesPerRow;
{
    if ([DJILiveViewRenderContext supportsFastTextureUpload])
    {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        return CVPixelBufferGetBytesPerRow(renderTarget);
#else
        return _size.width * 4; // TODO: do more with this on the non-texture-cache side
#endif
    }
    else
    {
        return _size.width * 4;
    }
}

- (GLubyte *)byteBuffer;
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    [self lockForReading];
    GLubyte * bufferBytes = (GLubyte *)CVPixelBufferGetBaseAddress(renderTarget);
    [self unlockAfterReading];
    return bufferBytes;
#else
    return NULL; // TODO: do more with this on the non-texture-cache side
#endif
}

- (GLuint)texture;
{
    //    NSLog(@"Accessing texture: %d from FB: %@", _texture, self);
    return _texture;
}

- (CVPixelBufferRef)privateRenderTarget{
    if (![DJILiveViewRenderContext supportsFastTextureUpload]){
        return NULL;
    }
    return renderTarget;
}

@end
