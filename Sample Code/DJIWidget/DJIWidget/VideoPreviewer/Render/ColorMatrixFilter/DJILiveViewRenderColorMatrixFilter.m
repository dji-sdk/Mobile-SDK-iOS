//
//  DJILiveViewRenderColorMatrixFilter.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//


#import "DJILiveViewRenderCommon.h"
#import "DJILiveViewRenderColorMatrixFilter.h"

NSString *const kDJIGPUImageColorMatrixFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform lowp mat4 colorMatrix;
 uniform lowp float intensity;
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 outputColor = textureColor * colorMatrix;
     
     gl_FragColor = (intensity * outputColor) + ((1.0 - intensity) * textureColor);
 }
 );


@implementation DJILiveViewRenderColorMatrixFilter

@synthesize intensity = _intensity;
@synthesize colorMatrix = _colorMatrix;

-(id) initWithContext:(DJILiveViewRenderContext *)acontext{
    if (self = [super initWithContext:acontext
             fragmentShaderFromString:kDJIGPUImageColorMatrixFragmentShaderString]) {
        
    }
    
    colorMatrixUniform = [filterProgram uniformIndex:@"colorMatrix"];
    intensityUniform = [filterProgram uniformIndex:@"intensity"];
    
    self.intensity = 1.f;
    self.colorMatrix = (DJIGPUMatrix4x4){
        {1.f, 0.f, 0.f, 0.f},
        {0.f, 1.f, 0.f, 0.f},
        {0.f, 0.f, 1.f, 0.f},
        {0.f, 0.f, 0.f, 1.f}
    };
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setIntensity:(CGFloat)newIntensity;
{
    _intensity = newIntensity;
    
    [self setFloat:_intensity forUniform:intensityUniform program:filterProgram];
}

- (void)setColorMatrix:(DJIGPUMatrix4x4)newColorMatrix;
{
    _colorMatrix = newColorMatrix;
    
    [self setMatrix4f:_colorMatrix forUniform:colorMatrixUniform program:filterProgram];
}
@end
