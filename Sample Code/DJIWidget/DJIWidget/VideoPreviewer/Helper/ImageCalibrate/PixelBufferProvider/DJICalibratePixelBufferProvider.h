//
//  DJICalibratePixelBufferProvider.h
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
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
