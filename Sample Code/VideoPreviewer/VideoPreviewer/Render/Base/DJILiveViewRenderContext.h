//
//  DJILiveViewRenderContext.h
//  DJIWidget
//
//  Created by ai.chuyue on 2016/10/23.
//  Copyright © 2016年 Jerome.zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DJILiveViewRenderProgram.h"

//Copy from GPUImageContext, reomove frame buffer cache and queue managing
@interface DJILiveViewRenderContext : NSObject

-(id) init;
-(id) initWithMultiThreadSupport:(BOOL)multiThread;

@property(readonly, retain, nonatomic) DJILiveViewRenderProgram *currentShaderProgram;
@property(readonly, retain, nonatomic) EAGLContext *context;
@property(readonly) CVOpenGLESTextureCacheRef coreVideoTextureCache;

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
