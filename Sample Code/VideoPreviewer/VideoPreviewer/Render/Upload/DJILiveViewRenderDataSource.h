//
//  DJILiveViewRenderDataSource.h
//  DJIWidget
//
//  Created by ai.chuyue on 2016/10/23.
//  Copyright © 2016年 Jerome.zhang. All rights reserved.
//

#import "DJIStreamCommon.h"
#import "DJILiveViewRenderPass.h"


//provide fast upload and YUV convert from decoder
@interface DJILiveViewRenderDataSource : DJILiveViewRenderPass

// rotation of the preview content
@property (assign, nonatomic) VideoStreamRotationType rotation;

//render the view with grayscale
@property (assign, nonatomic) BOOL grayScale;

//scale on output luminance
@property (assign, nonatomic) float luminanceScale;

-(id) initWithContext:(DJILiveViewRenderContext *)context;

-(void) loadFrame:(VideoFrameYUV*)frame;

-(void) renderPass;

-(void) renderBlack;

@end
