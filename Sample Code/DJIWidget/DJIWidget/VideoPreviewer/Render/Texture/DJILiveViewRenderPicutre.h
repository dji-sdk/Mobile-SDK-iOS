//
//  DJILiveViewRenderPicutre.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//


#import "DJILiveViewRenderFilter.h"

@interface DJILiveViewRenderPicutre : DJILiveViewRenderFilter

-(id) initWithContext:(DJILiveViewRenderContext *)context
              picture:(UIImage*)image;

-(void) render;

@end
