//
//  DJIImageCalibrateColorCPUConverter.h
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#ifndef DJIImageCalibrateColorCPUConverter_h
#define DJIImageCalibrateColorCPUConverter_h

#import "DJIImageCalibrateColorConverter.h"

//rgba->yuv
@interface DJIImageCalibrateColorCPUConverter : DJIImageCalibrateColorConverter

//FIXED ME:Need to optimize, this conversion will take up a higher CPU, please be cautious
-(void)convertFromRGBA:(uint8_t*)rgba
              withSize:(CGSize)size;

@end

#endif /* DJIImageCalibrateColorCPUConverter_h */
