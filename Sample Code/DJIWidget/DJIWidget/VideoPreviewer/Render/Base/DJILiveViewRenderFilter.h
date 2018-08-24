//
//  DJILiveViewRenderFilter.h
//

#import "DJIStreamCommon.h"
#import "DJILiveViewRenderPass.h"

extern NSString *const kDJIImageVertexShaderString;
extern NSString *const kDJIImagePassthroughFragmentShaderString;

struct DJIGPUVector4 {
    GLfloat one;
    GLfloat two;
    GLfloat three;
    GLfloat four;
};
typedef struct DJIGPUVector4 DJIGPUVector4;

struct DJIGPUVector3 {
    GLfloat one;
    GLfloat two;
    GLfloat three;
};
typedef struct DJIGPUVector3 DJIGPUVector3;

struct DJIGPUMatrix4x4 {
    DJIGPUVector4 one;
    DJIGPUVector4 two;
    DJIGPUVector4 three;
    DJIGPUVector4 four;
};
typedef struct DJIGPUMatrix4x4 DJIGPUMatrix4x4;

struct DJIGPUMatrix3x3 {
    DJIGPUVector3 one;
    DJIGPUVector3 two;
    DJIGPUVector3 three;
};
typedef struct DJIGPUMatrix3x3 DJIGPUMatrix3x3;

//Copy from GPUImageFilter
/** GPUImage's base filter class
 
 Filters and other subsequent elements in the chain conform to the GPUImageInput protocol, which lets them take in the supplied or processed texture from the previous link in the chain and do something with it. Objects one step further down the chain are considered targets, and processing can be branched by adding multiple targets to a single output or filter.
 */
@interface DJILiveViewRenderFilter : DJILiveViewRenderPass <DJILiveViewRenderInput>
{
    DJILiveViewFrameBuffer *firstInputFramebuffer;
    DJILiveViewRenderProgram *filterProgram;
    
    GLint filterPositionAttribute, filterTextureCoordinateAttribute;
    GLint filterInputTextureUniform;
    GLfloat backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha;
    
    BOOL isEndProcessing;
    
    CGSize currentFilterSize;
    VideoStreamRotationType inputRotation;
    
    NSMutableDictionary *uniformStateRestorationBlocks;
}

@property(readonly) CVPixelBufferRef renderTarget;
@property(readwrite, nonatomic) BOOL preventRendering;

//need clear before render
@property(readwrite, nonatomic) BOOL needClear;

/// @name Initialization and teardown

- (id)initWithContext:(DJILiveViewRenderContext*)context;

/**
 Initialize with vertex and fragment shaders
 
 You make take advantage of the SHADER_STRING macro to write your shaders in-line.
 @param vertexShaderString Source code of the vertex shader to use
 @param fragmentShaderString Source code of the fragment shader to use
 */
- (id)initWithContext:(DJILiveViewRenderContext*)context
vertexShaderFromString:(NSString *)vertexShaderString
fragmentShaderFromString:(NSString *)fragmentShaderString;

/**
 Initialize with a fragment shader
 
 You may take advantage of the SHADER_STRING macro to write your shader in-line.
 @param fragmentShaderString Source code of fragment shader to use
 */
- (id)initWithContext:(DJILiveViewRenderContext*)context
fragmentShaderFromString:(NSString *)fragmentShaderString;

/**
 Initialize with a fragment shader
 @param fragmentShaderFilename Filename of fragment shader to load
 */
- (id)initWithContext:(DJILiveViewRenderContext*)context
fragmentShaderFromFile:(NSString *)fragmentShaderFilename;

- (void)initializeAttributes;
- (void)setupFilterForSize:(CGSize)filterFrameSize;
- (CGSize)rotatedSize:(CGSize)sizeToRotate forIndex:(NSInteger)textureIndex;
- (CGPoint)rotatedPoint:(CGPoint)pointToRotate forRotation:(VideoStreamRotationType)rotation;

/// @name Managing the display FBOs
/** Size of the frame buffer object
 */
- (CGSize)sizeOfFBO;

/// @name Rendering
+ (const GLfloat *)textureCoordinatesForRotation:(VideoStreamRotationType)rotationMode;
- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;
- (void)informTargetsAboutNewFrameAtTime:(CMTime)frameTime;
- (CGSize)outputFrameSize;

/// @name Input parameters
- (void)setBackgroundColorRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent alpha:(GLfloat)alphaComponent;
- (void)setInteger:(GLint)newInteger forUniformName:(NSString *)uniformName;
- (void)setFloat:(GLfloat)newFloat forUniformName:(NSString *)uniformName;
- (void)setSize:(CGSize)newSize forUniformName:(NSString *)uniformName;
- (void)setPoint:(CGPoint)newPoint forUniformName:(NSString *)uniformName;
- (void)setFloatVec3:(DJIGPUVector3)newVec3 forUniformName:(NSString *)uniformName;
- (void)setFloatVec4:(DJIGPUVector4)newVec4 forUniform:(NSString *)uniformName;
- (void)setFloatArray:(GLfloat *)array length:(GLsizei)count forUniform:(NSString*)uniformName;

- (void)setMatrix3f:(DJIGPUMatrix3x3)matrix forUniform:(GLint)uniform program:(DJILiveViewRenderProgram *)shaderProgram;
- (void)setMatrix4f:(DJIGPUMatrix4x4)matrix forUniform:(GLint)uniform program:(DJILiveViewRenderProgram *)shaderProgram;
- (void)setFloat:(GLfloat)floatValue forUniform:(GLint)uniform program:(DJILiveViewRenderProgram *)shaderProgram;
- (void)setPoint:(CGPoint)pointValue forUniform:(GLint)uniform program:(DJILiveViewRenderProgram *)shaderProgram;
- (void)setSize:(CGSize)sizeValue forUniform:(GLint)uniform program:(DJILiveViewRenderProgram *)shaderProgram;
- (void)setVec3:(DJIGPUVector3)vectorValue forUniform:(GLint)uniform program:(DJILiveViewRenderProgram *)shaderProgram;
- (void)setVec4:(DJIGPUVector4)vectorValue forUniform:(GLint)uniform program:(DJILiveViewRenderProgram *)shaderProgram;
- (void)setFloatArray:(GLfloat *)arrayValue length:(GLsizei)arrayLength forUniform:(GLint)uniform program:(DJILiveViewRenderProgram *)shaderProgram;
- (void)setInteger:(GLint)intValue forUniform:(GLint)uniform program:(DJILiveViewRenderProgram *)shaderProgram;

- (void)setAndExecuteUniformStateCallbackAtIndex:(GLint)uniform forProgram:(DJILiveViewRenderProgram *)shaderProgram toBlock:(dispatch_block_t)uniformStateBlock;
- (void)setUniformsForProgramAtIndex:(NSUInteger)programIndex;

@end

