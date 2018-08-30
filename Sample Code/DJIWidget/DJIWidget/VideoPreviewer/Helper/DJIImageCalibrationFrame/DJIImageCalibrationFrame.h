//
//  DJIImageCalibrationFrame.h
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#ifndef DJIImageCalibrationFrame_h
#define DJIImageCalibrationFrame_h

#import <DJIWidget/DJIImageCalibrationFastFrame.h>

/*
 * do more memery deep copy for cache than DJIImageCalibrationFastFrame
 * may cause high cpu usage
 */

@interface DJIImageCalibrationFrame : DJIImageCalibrationFastFrame

-(instancetype)initWithFrame:(VideoFrameYUV*)frame
                  fastUpload:(BOOL)fastUpload
             pixelCacheQueue:(DJIImageCacheQueue*)pixelQueue
            andMemCacheQueue:(DJIImageCacheQueue*)cacheQueue;

@end

#endif /* DJIImageCalibrationFrame_h */
