//
//  DJIMavic2ZoomCameraImageCalibrateFilterDataSource.m
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIMavic2ZoomCameraImageCalibrateFilterDataSource.h"


@implementation DJIMavic2ZoomCameraImageCalibrateFilterDataSource

#pragma mark - files info overrided
-(NSString*)sensorType{
    return @"imx477";
}

-(NSString*)fileNameFormatWithResolution:(CGSize)resolution
                                 zoomIdx:(int)zoomIdx
                                focusIdx:(int)focusIdx
                                splitIdx:(int)splitIdx
                  andFileDiscriptionInfo:(NSString*)desc{
    NSString* sensor = [self sensorType];
    int width = (int)(resolution.width + 0.5);
    int height = (int)(resolution.height + 0.5);
    //example:[sesor name]_[intput resolution]_to_[output resolution]_[zoom index]_[focus index]_[split index]_[desc].bin
    return [NSString stringWithFormat:@"%@_%dx%d_to_%dx%d_%d_%d_%d_%@",
            sensor,
            width,height,
            width,height,
            zoomIdx,focusIdx,splitIdx,
            desc];
}

@end
