//
//  DJILiveViewRenderHighlightShadowFilter.h
//

#import "DJILiveViewRenderFilter.h"

/*
 * 高光减弱，阴影加亮
 */
@interface DJILiveViewRenderHighlightShadowFilter : DJILiveViewRenderFilter

/**
 * 0 - 1, increase to lighten shadows.
 * @default 0
 */
@property(readwrite, nonatomic) CGFloat shadowsLighten;

/**
 * 0 - 1, increase to darken highlights.
 * @default 0
 */
@property(readwrite, nonatomic) CGFloat highlightsDecrease;

@end
