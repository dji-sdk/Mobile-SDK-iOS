//
//  DJIReverseDLogFilter.h
//  DJIWidget
//
//  Created by ai.chuyue on 2016/10/27.
//  Copyright © 2016年 Jerome.zhang. All rights reserved.
//

#import "DJIStreamCommon.h"
#import "DJILiveViewRenderLookupFilter.h"

@interface DJIReverseDLogFilter : DJILiveViewRenderLookupFilter

-(id) initWithContext:(DJILiveViewRenderContext *)context;

/*
 * the type of lut, it may different on diffent platform
 */
@property (nonatomic, assign) DLogReverseLookupTableType lutType;

@end
