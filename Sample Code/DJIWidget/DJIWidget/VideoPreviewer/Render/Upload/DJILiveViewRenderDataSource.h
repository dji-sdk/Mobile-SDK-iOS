//
//  DJILiveViewRenderDataSource.h
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
