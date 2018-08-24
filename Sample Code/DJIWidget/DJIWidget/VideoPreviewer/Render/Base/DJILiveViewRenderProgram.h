//
//  DJILiveViewRenderProgram.h
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class  DJILiveViewRenderContext;

//Just copy from GPUImage GLProgram, rename it to avoid duplicated symbols
@interface DJILiveViewRenderProgram : NSObject
{
    NSMutableArray  *attributes;
    NSMutableArray  *uniforms;
    GLuint          program,
    vertShader,
    fragShader;
}

@property(readwrite, nonatomic) BOOL initialized;
@property(readonly, nonatomic) BOOL released;
@property(readonly, nonatomic) DJILiveViewRenderContext* context;
@property(readwrite, copy, nonatomic) NSString *vertexShaderLog;
@property(readwrite, copy, nonatomic) NSString *fragmentShaderLog;
@property(readwrite, copy, nonatomic) NSString *programLog;

- (id)initWithContext:(DJILiveViewRenderContext*)ctx
   vertexShaderString:(NSString *)vShaderString
 fragmentShaderString:(NSString *)fShaderString;

- (void)addAttribute:(NSString *)attributeName;
- (GLuint)attributeIndex:(NSString *)attributeName;
- (GLuint)uniformIndex:(NSString *)uniformName;
- (BOOL)link;
- (void)use;
- (void)validate;
- (void)destory;
@end
