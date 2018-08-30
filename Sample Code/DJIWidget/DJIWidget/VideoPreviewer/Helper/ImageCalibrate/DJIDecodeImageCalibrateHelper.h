//
//  DJIDecodeImageCalibrateHelper.h
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#ifndef DJIDecodeImageCalibrateHelper_h
#define DJIDecodeImageCalibrateHelper_h

#import <DJIWidget/DJIImageCalibrateHelper.h>
//filter
#import <DJIWidget/DJILiveViewCalibrateFilter.h>

/*
 * flow:
 * new yuv frame -> update frame info -> <this helper> -> output calibrated yuv frame -> render -> other processer
 *
 * detail flow of this helper:
 * new yuv frame -> calibration filters -> calibrated rgba frame -> color converter -> yuv calibrated queue -> output frame queue
 *
 */

@interface DJIDecodeImageCalibrateHelper : DJIImageCalibrateHelper

-(DJILiveViewCalibrateFilter*)calibrateFilter;

//enabled color converter: rgba->yuv, default NO
@property (nonatomic,assign) BOOL enabledColorSpaceConverter;

@end

#endif /* DJIDecodeImageCalibrateHelper_h */
