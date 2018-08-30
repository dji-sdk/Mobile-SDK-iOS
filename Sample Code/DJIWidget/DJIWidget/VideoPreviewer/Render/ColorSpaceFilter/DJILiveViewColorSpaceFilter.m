//
//  DJILiveViewColorSpaceFilter.m
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJILiveViewColorSpaceFilter.h"
//header
#import "DJILiveViewRenderCommon.h"
//buffer
#import "DJIDecodeImageCalibrateDataBuffer.h"

/*
 * rgb->yuv,matrix provided by nan.wang
 *
 *  0.29899963       0.58699855       0.11400182
 *  -0.16899977      -0.33099931      0.49999908
 *  0.49999979       -0.41899966      -0.08100013
 *
 */

//vertex
NSString *const kDJIImageVertexColorFilterShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 varying vec2 textureCoordinate;
 
 void main()
 {
     gl_Position = position;
     gl_PointSize = 1.0;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );

//rgba
NSString *const kDJIImagePassthroughFragmentRGBAShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
 }
 );

//y
NSString *const kDJIImagePassthroughFragmentYUV_YShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform highp float texture_width;
 uniform highp float texture_height;
 
 lowp float yFromRGB(lowp vec4 rgba){
     return (0.299 * rgba.r + 0.587 * rgba.g + 0.114 * rgba.b);
 }
 
 void main()
 {
     highp float xOffset = textureCoordinate.s;
     highp float yOffset = textureCoordinate.t;
     
     highp vec2 pos1 = vec2(xOffset,
                            yOffset);
     highp vec2 pos2 = vec2(xOffset + 1.0 / texture_width,
                            yOffset);
     highp vec2 pos3 = vec2(xOffset + 2.0 / texture_width,
                            yOffset);
     highp vec2 pos4 = vec2(xOffset + 3.0 / texture_width,
                            yOffset);
     
     lowp vec4 rgba1 = texture2D(inputImageTexture, pos1.xy);
     lowp vec4 rgba2 = texture2D(inputImageTexture, pos2.xy);
     lowp vec4 rgba3 = texture2D(inputImageTexture, pos3.xy);
     lowp vec4 rgba4 = texture2D(inputImageTexture, pos4.xy);
     
     //bgra->rgba
     gl_FragColor = vec4(yFromRGB(rgba3),
                         yFromRGB(rgba2),
                         yFromRGB(rgba1),
                         yFromRGB(rgba4));
 }
 );

//u
NSString *const kDJIImagePassthroughFragmentYUV_UShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform highp float texture_width;
 uniform highp float texture_height;
 
 lowp float uFromRGB(lowp vec4 rgba){
     return (-0.169 * rgba.r - 0.331 * rgba.g + 0.5 * rgba.b + 0.5);
 }
 
 void main()
 {
     highp float xOffset = textureCoordinate.s;
     highp float yOffset = textureCoordinate.t;
     
     highp vec2 pos1 = vec2(xOffset + 1.0 / texture_width,
                            yOffset);
     highp vec2 pos2 = vec2(xOffset + 3.0 / texture_width,
                            yOffset);
     highp vec2 pos3 = vec2(xOffset + 5.0 / texture_width,
                            yOffset);
     highp vec2 pos4 = vec2(xOffset + 7.0 / texture_width,
                            yOffset);
     
     lowp vec4 rgba1 = texture2D(inputImageTexture, pos1.xy);
     lowp vec4 rgba2 = texture2D(inputImageTexture, pos2.xy);
     lowp vec4 rgba3 = texture2D(inputImageTexture, pos3.xy);
     lowp vec4 rgba4 = texture2D(inputImageTexture, pos4.xy);
     
     gl_FragColor = vec4(uFromRGB(rgba3),
                         uFromRGB(rgba2),
                         uFromRGB(rgba1),
                         uFromRGB(rgba4));
 }
 );

//v
NSString *const kDJIImagePassthroughFragmentYUV_VShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform highp float texture_width;
 uniform highp float texture_height;
 
 lowp float vFromRGB(lowp vec4 rgba){
     return (0.5 * rgba.r - 0.419 * rgba.g - 0.081 * rgba.b + 0.5);
 }
 
 void main()
 {
     highp float xOffset = textureCoordinate.s;
     highp float yOffset = textureCoordinate.t;
     
     highp vec2 pos1 = vec2(xOffset,
                            yOffset + 1.0 / texture_height);
     highp vec2 pos2 = vec2(xOffset + 2.0 / texture_width,
                            yOffset + 1.0 / texture_height);
     highp vec2 pos3 = vec2(xOffset + 4.0 / texture_width,
                            yOffset + 1.0 / texture_height);
     highp vec2 pos4 = vec2(xOffset + 6.0 / texture_width,
                            yOffset + 1.0 / texture_height);
     
     lowp vec4 rgba1 = texture2D(inputImageTexture, pos1.xy);
     lowp vec4 rgba2 = texture2D(inputImageTexture, pos2.xy);
     lowp vec4 rgba3 = texture2D(inputImageTexture, pos3.xy);
     lowp vec4 rgba4 = texture2D(inputImageTexture, pos4.xy);
     
     gl_FragColor = vec4(vFromRGB(rgba3),
                         vFromRGB(rgba2),
                         vFromRGB(rgba1),
                         vFromRGB(rgba4));
 }
 );

//uv
NSString *const kDJIImagePassthroughFragmentYUV_UVShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform highp float texture_width;
 uniform highp float texture_height;
 
 lowp float uFromRGB(lowp vec4 rgba){
     return (-0.169 * rgba.r - 0.331 * rgba.g + 0.5 * rgba.b + 0.5);
 }
 
 lowp float vFromRGB(lowp vec4 rgba){
     return (0.5 * rgba.r - 0.419 * rgba.g - 0.081 * rgba.b + 0.5);
 }
 
 void main()
 {
     highp float xOffset = textureCoordinate.s;
     highp float yOffset = textureCoordinate.t;
     
     highp vec2 pos1 = vec2(xOffset,
                            yOffset);
     highp vec2 pos2 = vec2(xOffset + 1.0 / texture_width,
                            yOffset + 1.0 / texture_height);
     
     lowp vec4 rgba1 = texture2D(inputImageTexture, pos1.xy);
     lowp vec4 rgba2 = texture2D(inputImageTexture, pos2.xy);
     
     gl_FragColor = vec4(uFromRGB(rgba2),
                         vFromRGB(rgba1),
                         uFromRGB(rgba1),
                         vFromRGB(rgba2));
 }
 );

//yuv420p
NSString *const kDJIImagePassthroughFragmentYUV_YUVShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform highp float texture_width;
 uniform highp float texture_height;
 
 lowp float yFromRGB(lowp vec4 rgba){
     return (0.299 * rgba.r + 0.587 * rgba.g + 0.114 * rgba.b);
 }
 
 lowp float uFromRGB(lowp vec4 rgba){
     return (-0.169 * rgba.r - 0.331 * rgba.g + 0.5 * rgba.b + 0.5);
 }
 
 lowp float vFromRGB(lowp vec4 rgba){
     return (0.5 * rgba.r - 0.419 * rgba.g - 0.081 * rgba.b + 0.5);
 }
 
 void main()
 {
     highp float xOffset = textureCoordinate.s;
     highp float yOffset = textureCoordinate.t;
     highp float yRate = 1.0;
     
     if (yOffset < 0.5){//y
         yOffset = yOffset * 2.0;
         highp vec2 pos1 = vec2(xOffset,
                                yOffset);
         highp vec2 pos2 = vec2(xOffset + 1.0 / texture_width,
                                yOffset);
         highp vec2 pos3 = vec2(xOffset + 2.0 / texture_width,
                                yOffset);
         highp vec2 pos4 = vec2(xOffset + 3.0 / texture_width,
                                yOffset);
         
         lowp vec4 rgba1 = texture2D(inputImageTexture, pos1.xy);
         lowp vec4 rgba2 = texture2D(inputImageTexture, pos2.xy);
         lowp vec4 rgba3 = texture2D(inputImageTexture, pos3.xy);
         lowp vec4 rgba4 = texture2D(inputImageTexture, pos4.xy);
         
         //bgra->rgba
         gl_FragColor = vec4(yFromRGB(rgba3),
                             yFromRGB(rgba2),
                             yFromRGB(rgba1),
                             yFromRGB(rgba4));
     }
     else if (yOffset < 0.625){//u
         if (xOffset < 0.5){
             xOffset = 2.0 * xOffset;
         }
         else{
             xOffset = 2.0 * (xOffset - 0.5);
             yRate = 2.0;
         }
         yOffset = 8.0 * (yOffset - 0.5) + (yRate - 1.0) * 2.0 / texture_height;
         highp vec2 pos1 = vec2(xOffset + 1.0 / texture_width,
                                yOffset);
         highp vec2 pos2 = vec2(xOffset + 3.0 / texture_width,
                                yOffset);
         highp vec2 pos3 = vec2(xOffset + 5.0 / texture_width,
                                yOffset);
         highp vec2 pos4 = vec2(xOffset + 7.0 / texture_width,
                                yOffset);
         
         lowp vec4 rgba1 = texture2D(inputImageTexture, pos1.xy);
         lowp vec4 rgba2 = texture2D(inputImageTexture, pos2.xy);
         lowp vec4 rgba3 = texture2D(inputImageTexture, pos3.xy);
         lowp vec4 rgba4 = texture2D(inputImageTexture, pos4.xy);
         
         gl_FragColor = vec4(uFromRGB(rgba3),
                             uFromRGB(rgba2),
                             uFromRGB(rgba1),
                             uFromRGB(rgba4));
     }
     else if (yOffset < 0.75){//v
         if (xOffset < 0.5){
             xOffset = 2.0 * xOffset;
         }
         else{
             xOffset = 2.0 * (xOffset - 0.5);
             yRate = 2.0;
         }
         yOffset = 8.0 * (yOffset - 0.625) + (yRate - 1.0) * 2.0 / texture_height;
         highp vec2 pos1 = vec2(xOffset,
                                yOffset + 1.0 / texture_height);
         highp vec2 pos2 = vec2(xOffset + 2.0 / texture_width,
                                yOffset + 1.0 / texture_height);
         highp vec2 pos3 = vec2(xOffset + 4.0 / texture_width,
                                yOffset + 1.0 / texture_height);
         highp vec2 pos4 = vec2(xOffset + 6.0 / texture_width,
                                yOffset + 1.0 / texture_height);
         
         lowp vec4 rgba1 = texture2D(inputImageTexture, pos1.xy);
         lowp vec4 rgba2 = texture2D(inputImageTexture, pos2.xy);
         lowp vec4 rgba3 = texture2D(inputImageTexture, pos3.xy);
         lowp vec4 rgba4 = texture2D(inputImageTexture, pos4.xy);
         
         gl_FragColor = vec4(vFromRGB(rgba3),
                             vFromRGB(rgba2),
                             vFromRGB(rgba1),
                             vFromRGB(rgba4));
     }
     else{
         gl_FragColor = vec4(0.5,
                             0.5,
                             0,
                             0);
     }
 }
 );

//nv12
NSString *const kDJIImagePassthroughFragmentYUV_Y_UVShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform highp float texture_width;
 uniform highp float texture_height;
 
 lowp float yFromRGB(lowp vec4 rgba){
     return (0.299 * rgba.r + 0.587 * rgba.g + 0.114 * rgba.b);
 }
 
 lowp float uFromRGB(lowp vec4 rgba){
     return (-0.169 * rgba.r - 0.331 * rgba.g + 0.5 * rgba.b + 0.5);
 }
 
 lowp float vFromRGB(lowp vec4 rgba){
     return (0.5 * rgba.r - 0.419 * rgba.g - 0.081 * rgba.b + 0.5);
 }
 
 void main()
 {
     highp float xOffset = textureCoordinate.s;
     highp float yOffset = textureCoordinate.t;
     highp float yRate = 1.0;
     
     if (yOffset < 0.5){//y
         yOffset = yOffset * 2.0;
         highp vec2 pos1 = vec2(xOffset,
                                yOffset);
         highp vec2 pos2 = vec2(xOffset + 1.0 / texture_width,
                                yOffset);
         highp vec2 pos3 = vec2(xOffset + 2.0 / texture_width,
                                yOffset);
         highp vec2 pos4 = vec2(xOffset + 3.0 / texture_width,
                                yOffset);
         
         lowp vec4 rgba1 = texture2D(inputImageTexture, pos1.xy);
         lowp vec4 rgba2 = texture2D(inputImageTexture, pos2.xy);
         lowp vec4 rgba3 = texture2D(inputImageTexture, pos3.xy);
         lowp vec4 rgba4 = texture2D(inputImageTexture, pos4.xy);
         
         //bgra->rgba
         gl_FragColor = vec4(yFromRGB(rgba3),
                             yFromRGB(rgba2),
                             yFromRGB(rgba1),
                             yFromRGB(rgba4));
     }
     else if (yOffset < 0.75){//uv
         yOffset = 4.0 * (yOffset - 0.5);
         highp vec2 pos1 = vec2(xOffset,
                                yOffset);
         highp vec2 pos2 = vec2(xOffset + 2.0 / texture_width,
                                yOffset + 1.0 / texture_height);
         
         lowp vec4 rgba1 = texture2D(inputImageTexture, pos1.xy);
         lowp vec4 rgba2 = texture2D(inputImageTexture, pos2.xy);
         
         gl_FragColor = vec4(uFromRGB(rgba2),
                             vFromRGB(rgba1),
                             uFromRGB(rgba1),
                             vFromRGB(rgba2));
     }
     else{
         gl_FragColor = vec4(0.5,
                             0.5,
                             0,
                             0);
     }
 }
 );

@interface DJILiveViewColorSpaceFilter(){
    CGSize _preferredSize;//range:[0 1];
    DJILiveViewColorSpaceFilterType _filterInternalType;
}

@end

@implementation DJILiveViewColorSpaceFilter

- (id)initWithContext:(DJILiveViewRenderContext*)context
    andColorSpaceType:(DJILiveViewColorSpaceFilterType)type{
    NSString* fragmentShader = nil;
    CGSize preferredSize = CGSizeZero;
    switch (type){
        case DJILiveViewColorSpaceFilterType_Y:{
            preferredSize = CGSizeMake(0.25, 1.0);
            fragmentShader = kDJIImagePassthroughFragmentYUV_YShaderString;
        }
            break;
        case DJILiveViewColorSpaceFilterType_U:{
            preferredSize = CGSizeMake(0.125, 0.5);
            fragmentShader = kDJIImagePassthroughFragmentYUV_UShaderString;
        }
            break;
        case DJILiveViewColorSpaceFilterType_V:{
            preferredSize = CGSizeMake(0.125, 0.5);
            fragmentShader = kDJIImagePassthroughFragmentYUV_VShaderString;
        }
            break;
        case DJILiveViewColorSpaceFilterType_UV:{
            preferredSize = CGSizeMake(0.25, 0.5);
            fragmentShader = kDJIImagePassthroughFragmentYUV_UVShaderString;
        }
            break;
        case DJILiveViewColorSpaceFilterType_RGBA:{
            preferredSize = CGSizeMake(1.0, 1.0);
            fragmentShader = kDJIImagePassthroughFragmentRGBAShaderString;
        }
        case DJIColorSpace420PCombinedType:{
            preferredSize = CGSizeMake(0.25, 2.0);
            fragmentShader = kDJIImagePassthroughFragmentYUV_YUVShaderString;
        }
            break;
        case DJIColorSpace420PBiCombinedType:{
            preferredSize = CGSizeMake(0.25, 2.0);
            fragmentShader = kDJIImagePassthroughFragmentYUV_Y_UVShaderString;
        }
            break;
        default:
            break;
    }
    if (fragmentShader == nil
        || preferredSize.width < 1.0e-3
        || preferredSize.height < 1.0e-3){
        return nil;
    }
    if (self = [super initWithContext:context
               vertexShaderFromString:kDJIImageVertexColorFilterShaderString
             fragmentShaderFromString:fragmentShader]){
        _preferredSize = preferredSize;
        _filterInternalType = type;
    }
    return self;
}

-(CGSize)sizeOfFBO{
    return CGSizeMake((float)((int)(inputTextureSize.width * _preferredSize.width + 0.5)),
                      (float)((int)(inputTextureSize.height * _preferredSize.height + 0.5)));
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices
                 textureCoordinates:(const GLfloat *)textureCoordinates{
    if (self.preventRendering){
        return;
    }
    
    [context setContextShaderProgram:filterProgram];
    CGSize FBOSize = [self sizeOfFBO];
    
    if (outputFramebuffer == nil
        || NO == CGSizeEqualToSize(FBOSize, self.framebufferForOutput.size)){
        DJILiveViewRenderTextureOptions options = self.outputTextureOptions;
        options.minFilter = GL_NEAREST;
        options.magFilter = GL_NEAREST;
        outputFramebuffer = [[DJIDecodeImageCalibrateDataBuffer alloc] initWithContext:context
                                                                                  size:FBOSize
                                                                        textureOptions:options
                                                                           onlyTexture:NO];
        [(DJIDecodeImageCalibrateDataBuffer*)outputFramebuffer setBufferFlag:_filterInternalType];
    }
    
    [outputFramebuffer activateFramebuffer];
    
    [self setUniformsForProgramAtIndex:0];
    glClearColor(backgroundColorRed,
                 backgroundColorGreen,
                 backgroundColorBlue,
                 backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    
    GLuint textureWidth = [filterProgram uniformIndex:@"texture_width"];
    GLuint textureHeight = [filterProgram uniformIndex:@"texture_height"];
    
    glUniform1f(textureWidth, inputTextureSize.width);
    glUniform1f(textureHeight, inputTextureSize.height);
    
    glUniform1i(filterInputTextureUniform, 2);
    
    glEnableVertexAttribArray(filterPositionAttribute);
    glEnableVertexAttribArray(filterTextureCoordinateAttribute);
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
