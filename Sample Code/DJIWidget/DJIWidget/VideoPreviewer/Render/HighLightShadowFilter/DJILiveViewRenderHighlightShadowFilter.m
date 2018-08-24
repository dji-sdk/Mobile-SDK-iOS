//
//  DJILiveViewRenderHighlightShadowFilter.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//


#import "DJILiveViewRenderCommon.h"
#import "DJILiveViewRenderHighlightShadowFilter.h"

NSString *const kHighlightShadowFragmentShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 varying highp vec2 textureCoordinate;
 
 uniform lowp float shadows;
 uniform lowp float highlights;
 
 const mediump vec3 luminanceWeighting = vec3(0.3, 0.3, 0.3);
 
 void main()
{
    lowp vec4 source = texture2D(inputImageTexture, textureCoordinate);
    mediump float luminance = dot(source.rgb, luminanceWeighting);
    
    mediump float shadow = clamp((pow(luminance, 1.0/(shadows+1.0)) + (-0.76)*pow(luminance, 2.0/(shadows+1.0))) - luminance, 0.0, 1.0);
    mediump float highlight = clamp((1.0 - (pow(1.0-luminance, 1.0/(2.0-highlights)) + (-0.8)*pow(1.0-luminance, 2.0/(2.0-highlights)))) - luminance, -1.0, 0.0);
    lowp vec3 result = vec3(0.0, 0.0, 0.0) + ((luminance + shadow + highlight) - 0.0) * ((source.rgb - vec3(0.0, 0.0, 0.0))/(luminance - 0.0));
    
    gl_FragColor = vec4(result.rgb, source.a);
}
 );

@implementation DJILiveViewRenderHighlightShadowFilter

-(id) initWithContext:(DJILiveViewRenderContext *)acontext{
    self = [super initWithContext:acontext fragmentShaderFromString:kHighlightShadowFragmentShaderString];
    
    //set default value
    _highlightsDecrease = -1;
    _shadowsLighten = -1;
    
    self.highlightsDecrease = 0;
    self.shadowsLighten = 0;
    return self;
}

-(void) setShadowsLighten:(CGFloat)shadowsLighten{
    if (shadowsLighten == _shadowsLighten) {
        return;
    }
    
    _shadowsLighten = shadowsLighten;
    [self setFloat:_shadowsLighten forUniformName:@"shadows"];
}

-(void) setHighlightsDecrease:(CGFloat)highlightsDecrease{
    if (highlightsDecrease == _highlightsDecrease) {
        return;
    }
    
    _highlightsDecrease = highlightsDecrease;
    [self setFloat:(1.0 - _highlightsDecrease) forUniformName:@"highlights"];
}

@end
