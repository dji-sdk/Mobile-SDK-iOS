//
//  DJILiveViewRenderDataSource_Private.h
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#ifndef DJILiveViewRenderDataSource_Private_h
#define DJILiveViewRenderDataSource_Private_h

#import <DJIWidget/DJILiveViewRenderDataSource.h>

@interface DJILiveViewRenderDataSource (){
    
    BOOL       _inputLoaded;
    VPFrameType _lastFrameType;
    
    GLuint     _inputWidth;
    GLuint     _inputHeight;
    GLuint     _inputWidthRGB;
    GLuint     _inputHeightRGB;
    
    GLuint     _outputWidth;
    GLuint     _outputHeight;
    
    GLuint positionAttribute;
    GLuint textureCoordinateAttribute;
    
    GLuint textureUniforms[3];
    GLuint uniformYUVMatrix;
    GLuint luminanceScaleUniform;
    
    GLuint textureInputRGB;
    GLuint textureInput[3];
    GLuint textureInputFastupload[3];
    CVOpenGLESTextureRef fastuploadCVRef[3];
    
    BOOL   isFullRange;
}

@property (nonatomic, strong) DJILiveViewRenderProgram* programBiYUV;
@property (nonatomic, strong) DJILiveViewRenderProgram* programYUV;
@property (nonatomic, strong) DJILiveViewRenderProgram* programRGBA;
@property (nonatomic, strong) DJILiveViewRenderProgram* activeProgram;

@end

#endif /* DJILiveViewRenderDataSource_Private_h */
