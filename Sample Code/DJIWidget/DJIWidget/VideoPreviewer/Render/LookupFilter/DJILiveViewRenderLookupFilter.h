//
//  DJILiveViewRenderLookupFilter.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//


#import "DJILiveViewRenderTexture.h"
#import "DJILiveViewRenderFilter.h"

//from GPUImage lookup filter
@interface DJILiveViewRenderLookupFilter : DJILiveViewRenderFilter

-(id) initWithContext:(DJILiveViewRenderContext *)context
        lookupTexture:(DJILiveViewRenderTexture *)texture;

@property (nonatomic, assign) CGFloat intensity;
@property (nonatomic, strong) DJILiveViewRenderTexture* lookupTexture;

@end
