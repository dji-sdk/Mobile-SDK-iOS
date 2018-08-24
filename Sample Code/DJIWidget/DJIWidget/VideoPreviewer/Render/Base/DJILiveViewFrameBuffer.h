//
//  DJILiveViewFrameBuffer.h
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMedia/CoreMedia.h>


typedef struct DJILiveViewRenderTextureOptions {
    GLenum minFilter;
    GLenum magFilter;
    GLenum wrapS;
    GLenum wrapT;
    GLenum internalFormat;
    GLenum format;
    GLenum type;
} DJILiveViewRenderTextureOptions;

DJILiveViewRenderTextureOptions defaultOptionsForTexture(void);

@interface DJILiveViewFrameBuffer : NSObject

@property(readonly) CGSize size;
@property(readonly) DJILiveViewRenderTextureOptions textureOptions;
@property(readonly) GLuint texture;
@property(readonly) BOOL missingFramebuffer;
@property(readonly) BOOL released;
@property(readonly) id context;

// Initialization and teardown
- (id)initWithContext:(id)context
                 size:(CGSize)framebufferSize;

- (id)initWithContext:(id)context
                 size:(CGSize)framebufferSize
       textureOptions:(DJILiveViewRenderTextureOptions)fboTextureOptions
          onlyTexture:(BOOL)onlyGenerateTexture;

- (id)initWithContext:(id)context
                 size:(CGSize)framebufferSize
    overriddenTexture:(GLuint)inputTexture;

// Usage
- (void)activateFramebuffer;
- (void)destroyFramebuffer;

// Image capture
- (CGImageRef)newCGImageFromFramebufferContents;
- (void)restoreRenderTarget;

// Raw data bytes
- (void)lockForReading;
- (void)unlockAfterReading;
- (NSUInteger)bytesPerRow;
- (GLubyte *)byteBuffer;
- (CVPixelBufferRef)pixelBuffer;
@end
