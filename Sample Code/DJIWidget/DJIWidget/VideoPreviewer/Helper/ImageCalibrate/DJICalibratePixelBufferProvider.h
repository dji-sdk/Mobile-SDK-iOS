//
//  DJICalibratePixelBufferProvider.h
//  VideoPreviewer
//
//  Created by 刘微 on 2018/6/24.
//  Copyright © 2018 dji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJILiveViewRenderPass.h"
#import "DJIStreamCommon.h"


@protocol DJICalibratePixelBufferProviderDelegate <NSObject>

@required
- (void)calibratePixelBufferProviderDidOutputFrame:(VideoFrameYUV *)frame;

@end


@interface DJICalibratePixelBufferProvider : NSObject <DJILiveViewRenderInput>

@property (atomic, assign) BOOL providerEnabled;

@property (nonatomic, weak) id <DJICalibratePixelBufferProviderDelegate> delegate;

- (void)updateFrameInfoWithFrameYUV:(VideoFrameYUV *)frame;

- (BOOL)enabled;

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;

- (void)setInputFramebuffer:(DJILiveViewFrameBuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex;

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;

- (void)endProcessing;

@end
