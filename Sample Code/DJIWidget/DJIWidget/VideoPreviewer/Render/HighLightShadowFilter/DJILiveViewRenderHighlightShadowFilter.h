//
//  DJILiveViewRenderHighlightShadowFilter.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//


#import "DJILiveViewRenderFilter.h"

/*
 * Reduced highlights, shadow highlights
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
