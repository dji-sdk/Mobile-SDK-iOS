//
//  DJILiveViewRenderScaleFilter.h
//

#import <UIKit/UIKit.h>
#import "DJILiveViewRenderFilter.h"

/*
 * a filter to upscale or downscale image in aspect fit mode
 * rotation is not supported
 */
@interface DJILiveViewRenderScaleFilter : DJILiveViewRenderFilter

//the size that need capture data
@property (nonatomic, assign) CGSize targetSize;
@end
