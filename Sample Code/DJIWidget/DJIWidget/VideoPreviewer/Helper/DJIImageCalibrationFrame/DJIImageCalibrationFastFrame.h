//
//  DJIImageCalibrationFastFrame.h
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#ifndef DJIImageCalibrationFastFrame_h
#define DJIImageCalibrationFastFrame_h

#import <DJIWidget/DJIStreamCommon.h>
#import <DJIWidget/DJIImageCacheQueue.h>

/*
 * do less memery deep copy for cache
 * try to reduce cpu usage
 */


@interface DJIImageCalibrationFastFrame : NSObject

//for queue
@property (nonatomic,strong) DJIImageCalibrationFastFrame* nextFrame;

@property (nonatomic,readonly) BOOL fastUploadEnabled;

//to tell the frame data source
@property (nonatomic,weak) id sourceTag;

-(VideoFrameYUV*)frame;

-(void)loadFrame:(VideoFrameYUV*)frame
      fastUpload:(BOOL)fastUpload;

-(void)prepareBeforeUsing;

-(instancetype)initWithFastFrame:(VideoFrameYUV*)frame
                      fastUpload:(BOOL)fastUpload
                  andPixelBuffer:(DJIImageCacheQueue*)pixelCache;

@end

#endif /* DJIImageCalibrationFastFrame_h */
