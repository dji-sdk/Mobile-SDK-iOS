//
//  DJIImageCalibrateColorGPUConverter.h
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#ifndef DJIImageCalibrateColorGPUConverter_h
#define DJIImageCalibrateColorGPUConverter_h

#import "DJIImageCalibrateColorConverter.h"
#import <DJIWidget/DJIStreamCommon.h>
#import <DJIWidget/DJILiveViewRenderPass.h>
#import "DJILiveViewRenderContext.h"

@interface DJIImageCalibrateColorGPUConverter : DJIImageCalibrateColorConverter

@property (nonatomic,weak) DJILiveViewRenderContext* context;
//default YES, for more effective
@property (nonatomic,assign) BOOL combinedChannel;

+(VPFrameType)proposedType;

@end

#endif /* DJIImageCalibrateColorGPUConverter_h */
