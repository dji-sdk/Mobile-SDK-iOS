//
//  DJIReverseDLogFilter.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
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
