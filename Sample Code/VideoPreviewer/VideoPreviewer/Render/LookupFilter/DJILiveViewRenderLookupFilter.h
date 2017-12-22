//
//  DJILiveViewRenderLookupFilter.h
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
