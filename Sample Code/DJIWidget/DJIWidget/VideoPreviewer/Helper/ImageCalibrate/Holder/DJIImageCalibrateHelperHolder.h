//
//  DJIImageCalibrateHelperHolder.h
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//




#ifndef DJIImageCalibrateHelperHolder_h
#define DJIImageCalibrateHelperHolder_h

#import <DJIWidget/DJILiveViewRenderPass.h>

@interface DJIImageCalibrateHelperHolder : NSObject<DJILiveViewRenderInput>

@property (nonatomic,weak) id<DJILiveViewRenderInput> target;

@end

#endif /* DJIImageCalibrateHelperHolder_h */
