//
//  DJILiveViewRenderContext.h
//

#import <UIKit/UIKit.h>
#import "DJILiveViewRenderProgram.h"
#import <CoreMedia/CoreMedia.h>

//Copy from GPUImageContext, reomove frame buffer cache and queue managing
@interface DJILiveViewRenderContext : NSObject

-(id) init;
-(id) initWithMultiThreadSupport:(BOOL)multiThread;


@property (nonatomic) CMMemoryPoolRef memoryPool;
@property(readonly, retain, nonatomic) DJILiveViewRenderProgram *currentShaderProgram;
@property(readonly, retain, nonatomic) EAGLContext *context;
@property(readonly) CVOpenGLESTextureCacheRef coreVideoTextureCache;
//yes if context is already released
@property (readonly) BOOL released;
//release
-(void) releaseContext;

- (void)useAsCurrentContext;
- (void)setContextShaderProgram:(DJILiveViewRenderProgram *)shaderProgram;

- (void)presentBufferForDisplay;
- (DJILiveViewRenderProgram *)programForVertexShaderString:(NSString *)vertexShaderString
                       fragmentShaderString:(NSString *)fragmentShaderString;

// Manage fast texture upload
+ (BOOL)supportsFastTextureUpload;
+ (CGSize)sizeThatFitsWithinATextureForSize:(CGSize)inputSize;
+ (GLint)maximumTextureSizeForThisDevice;
@end
