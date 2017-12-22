//
//  DJILiveViewRenderDisplayView.h
//

#import <UIKit/UIKit.h>
#import "DJILiveViewRenderPass.h"

typedef NS_ENUM(NSUInteger, DJILiveViewRenderType) {
    kDJILiveViewRenderStretch,                       // Stretch to fill the full view, which may distort the image outside of its normal aspect ratio
    kDJILiveViewRenderPreserveAspectRatio,           // Maintains the aspect ratio of the source image, adding bars of the specified background color
    kDJILiveViewRenderPreserveAspectRatioAndFill     // Maintains the aspect ratio of the source image, zooming in on its center to fill the view
};


@interface DJILiveViewRenderDisplayView : UIView <DJILiveViewRenderInput>

- (id)initWithFrame:(CGRect)frame context:(DJILiveViewRenderContext*)context;

/** The fill mode dictates how images are fit in the view, with the default being kGPUImageFillModePreserveAspectRatio
 */
@property(readwrite, nonatomic) DJILiveViewRenderType fillMode;


/** This calculates the current display size, in pixels, taking into account Retina scaling factors
 */
@property(readonly, nonatomic) CGSize sizeInPixels;

@property(nonatomic) BOOL enabled;

@end
