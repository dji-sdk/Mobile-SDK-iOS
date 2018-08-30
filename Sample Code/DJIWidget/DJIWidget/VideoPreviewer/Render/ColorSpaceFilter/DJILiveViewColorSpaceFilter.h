//
//  DJILiveViewColorSpaceFilter.h
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#ifndef DJILiveViewColorSpaceFilter_h
#define DJILiveViewColorSpaceFilter_h

#import <DJIWidget/DJILiveViewRenderFilter.h>

typedef NS_ENUM(NSUInteger,DJILiveViewColorSpaceFilterType){
    DJILiveViewColorSpaceFilterType_Y = 1 << 0,
    DJILiveViewColorSpaceFilterType_U = 1 << 1,
    DJILiveViewColorSpaceFilterType_V = 1 << 2,
    DJILiveViewColorSpaceFilterType_UV = 1 << 3,
    DJILiveViewColorSpaceFilterType_RGBA = 1 << 4,
};

enum{
    DJIColorSpace420PCombinedType = (DJILiveViewColorSpaceFilterType_Y | DJILiveViewColorSpaceFilterType_U | DJILiveViewColorSpaceFilterType_V),
    DJIColorSpace420PBiCombinedType = (DJILiveViewColorSpaceFilterType_Y | DJILiveViewColorSpaceFilterType_UV),
};

@interface DJILiveViewColorSpaceFilter : DJILiveViewRenderFilter

- (id)initWithContext:(DJILiveViewRenderContext*)context
andColorSpaceType:(DJILiveViewColorSpaceFilterType)type;

@end

#endif /* DJILiveViewColorSpaceFilter_h */
