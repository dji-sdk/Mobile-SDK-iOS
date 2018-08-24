//
//  DJILiveViewRenderFocusWarningFilter.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//


#import "DJILiveViewRenderCommon.h"
#import "DJILiveViewRenderFocusWarningFilter.h"

//sobel edge detect
NSString *const sobelFS = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 uniform highp vec4 dxdy;
 //texcord of left right top bottom
 uniform highp vec4 range;
 
 const highp vec4 RED = vec4(1.0,0,0,1.0);
 const highp vec4 GREEN = vec4(0,1.0,0,1.0);
 const highp vec4 BLUE = vec4(0,0,1.0,1.0);
 
 highp vec4 sample(highp float dx, highp float dy)
{
    highp vec2 dif = vec2(dx,dy);
    highp vec2 texcord = textureCoordinate.st+dif;
    
    highp vec4 min_range = step(vec4(range.xz, texcord), vec4(texcord, range.yw));
    texcord = textureCoordinate.st + min_range.x*min_range.y*min_range.z*min_range.w*dif;
    texcord = clamp(texcord, 0.0, 1.0);
    return texture2D(inputImageTexture, texcord);
}
 
 highp vec4 sampleNoClamp(highp float dx, highp float dy)
{
    highp vec2 texcord = textureCoordinate.st+vec2(dx,dy);
    return texture2D(inputImageTexture, texcord);
}
 
 highp float mag(highp vec4 p)
{
    return length(p.rgb);
}
 
 void main()
 {
     gl_FragColor = sampleNoClamp(0.0, 0.0);

     
     highp float MAG = abs(-6.834 * sample(-dxdy.x, -dxdy.y)
                        + 2.142 * sample(0.0, -dxdy.y)
                        - 6.834 * sample(dxdy.x, -dxdy.y)
                        + 2.142 * sample(-dxdy.x, 0.0)
                        + 18.717 * sample(0.0, 0.0)
                        + 2.142 * sample(dxdy.x, 0.0)
                        - 6.834 * sample(-dxdy.x, dxdy.y)
                        + 2.142 * sample(0.0, dxdy.y)
                        - 6.834 * sample(dxdy.x, dxdy.y)).a;
     

     
     if(MAG>dxdy.z) gl_FragColor = vec4(RED.xyz, gl_FragColor.a);
 }
 );

@interface DJILiveViewRenderFocusWarningFilter ()
@property (nonatomic, assign) CGSize lastFBOSize;
@end

@implementation DJILiveViewRenderFocusWarningFilter

-(id) initWithContext:(id)acontext{
    if (self = [super initWithContext:acontext
             fragmentShaderFromString:sobelFS]) {
        
        _focusWarningThreshold = 0.5;
        
        [self updateUniform];
    }
    
    return self;
}

-(void) setFocusWarningThreshold:(CGFloat)focusWarningThreshold{
    if (focusWarningThreshold == _focusWarningThreshold) {
        return;
    }
    
    _focusWarningThreshold = focusWarningThreshold;
    [self updateUniform];
}

-(CGSize) sizeOfFBO{
    CGSize current = [super sizeOfFBO];
    if (NO == CGSizeEqualToSize(current, _lastFBOSize)) {
        _lastFBOSize = current;
        [self updateUniform];
    }
    
    return current;
}

-(void) updateUniform{
    DJIGPUVector4 lrtb = {0, 1.0, 0, 1.0};
    GLuint rangeUniform = [filterProgram uniformIndex:@"range"];
    
    [self setVec4:lrtb
       forUniform:rangeUniform
          program:filterProgram];
    
    DJIGPUVector4 dxdy = {1.0, 1.0, 0, 0};
    CGSize FBOSize = _lastFBOSize;
    if (FBOSize.width > 0.0000001
        && FBOSize.height > 0.0000001) {
        dxdy.one = 1.0/FBOSize.width;
        dxdy.two = 1.0/FBOSize.height;
    }
    
    //threshold
    dxdy.three = _focusWarningThreshold;
    GLuint dxUniform = [filterProgram uniformIndex:@"dxdy"];
    [self setVec4:dxdy
       forUniform:dxUniform
          program:filterProgram];
}

@end
