//
//  DJILiveViewRenderTexture.h
//  DJIWidget
//
//  Created by ai.chuyue on 2016/10/23.
//  Copyright © 2016年 Jerome.zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
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
