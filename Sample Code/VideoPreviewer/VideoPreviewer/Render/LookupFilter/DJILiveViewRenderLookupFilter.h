//
//  DJILiveViewRenderLookupFilter.h
//  DJIWidget
//
//  Created by ai.chuyue on 2016/10/26.
//  Copyright © 2016年 Jerome.zhang. All rights reserved.
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
