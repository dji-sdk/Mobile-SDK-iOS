//
//  DJILiveViewRenderFocusWarningFilter.h
//  DJIWidget
//
//  Created by ai.chuyue on 2016/10/24.
//  Copyright © 2016年 Jerome.zhang. All rights reserved.
//

#import "DJILiveViewRenderFilter.h"

@interface DJILiveViewRenderFocusWarningFilter : DJILiveViewRenderFilter

-(id) initWithContext:(id)context;

@property (nonatomic, assign) CGFloat focusWarningThreshold;

@end
