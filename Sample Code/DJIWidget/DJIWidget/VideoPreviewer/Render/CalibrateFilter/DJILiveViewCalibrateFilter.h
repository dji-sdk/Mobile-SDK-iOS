//
//  DJILiveViewCalibrateFilter.h
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#ifndef DJILiveViewCalibrateFilter_h
#define DJILiveViewCalibrateFilter_h

#import <DJIWidget/DJILiveViewRenderFilter.h>
#import <DJIWidget/DJIImageCalibrateFilterDataSource.h>

@interface DJILiveViewCalibrateFilter : DJILiveViewRenderFilter

@property (nonatomic,assign) NSUInteger idx;

@property (nonatomic,assign) DJISEIInfoLiveViewFOVState fovState;

@property (nonatomic,weak) DJIImageCalibrateFilterDataSource* dataSource;

@end

#endif /* DJILiveViewCalibrateFilter_h */
