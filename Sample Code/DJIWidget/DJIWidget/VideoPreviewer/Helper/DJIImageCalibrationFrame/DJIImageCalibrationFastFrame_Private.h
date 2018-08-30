//
//  DJIImageCalibrationFastFrame_Private.h
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#ifndef DJIImageCalibrationFastFrame_Private_h
#define DJIImageCalibrationFastFrame_Private_h

#import "DJIImageCalibrationFastFrame.h"
#import "DJIImageCache.h"
#import "DJIPixelCache.h"

@interface DJIImageCalibrationFastFrame(){
    //cache frame
    VideoFrameYUV _internalFrame;
}
//fast-upload
@property (nonatomic,assign) BOOL fastUploadEnabled;
//frame
@property (nonatomic,readonly) VideoFrameYUV* frame;
//pixel cache manager queue, passed from outside
@property (nonatomic,weak) DJIImageCacheQueue* pixelQueue;
//pixel mem cache
@property (nonatomic,strong) DJIPixelCache* pixel;
//frame cache manager queue, passed from outside
@property (nonatomic,weak) DJIImageCacheQueue* cacheQueue;
//frame mem cache
@property (nonatomic,strong) DJIImageCache* cache;
//fastupload type
@property (nonatomic,assign) OSType fastUploadType;

//reconstruct CVPixelBufferRef for fast-upload frame
-(void)reconstructFastUploadFrame;

//operation beform reload or dealloc
-(void)prepareToClean;

@end

#endif /* DJIImageCalibrationFastFrame_Private_h */
