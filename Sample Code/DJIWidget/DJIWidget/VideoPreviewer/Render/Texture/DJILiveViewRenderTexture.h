//
//  DJILiveViewRenderTexture.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "DJILiveViewFrameBuffer.h"

// single texture object
@interface DJILiveViewRenderTexture : NSObject
-(id) initWithContext:(id)context
                image:(UIImage*)image;

-(id) initWithContext:(id)context
              cgImage:(CGImageRef)image;

-(id) initWithContext:(id)context
              cgImage:(CGImageRef)image
               option:(DJILiveViewRenderTextureOptions)option;

//output
-(GLuint) texture;

//info
@property (nonatomic, readonly) CGSize pixelSizeOfImage;
@property (nonatomic, readonly) DJILiveViewRenderTextureOptions textureOptions;
@end
