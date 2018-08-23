//
//  DJILiveViewRenderFocusWarningFilter.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//


#import "DJILiveViewRenderFilter.h"

@interface DJILiveViewRenderFocusWarningFilter : DJILiveViewRenderFilter

-(id) initWithContext:(id)context;

@property (nonatomic, assign) CGFloat focusWarningThreshold;

@end
