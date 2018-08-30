//
//  DJIImageCalibrateHelper_Private.h
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#ifndef DJIImageCalibrateHelper_Private_h
#define DJIImageCalibrateHelper_Private_h

#import <DJIWidget/DJIImageCalibrateHelper.h>
//buffer
#import <DJIWidget/DJIDecodeImageCalibrateDataBuffer.h>
#import <DJIWidget/DJIImageCalibrationFrame.h>
#import <DJIWidget/DJIImageCalibrationFrameQueue.h>
#import <DJIWidget/DJIImageCacheQueue.h>

@interface DJIImageCalibrateHelper(){
    //output queue
    DJIImageCalibrationFrameQueue* _frameQueue;
    //input queue
    DJIImageCalibrationFrameQueue* _cacheQueue;
    //recycle queue
    DJIImageCalibrationFrameQueue* _recycleQueue;
    //memory cache queue
    DJIImageCacheQueue* _memQueue;
    //cvpixelbufferref cache
    DJIImageCacheQueue* _pixelRefQueue;
    //mutex for render
    pthread_mutex_t _render_mutex;
    //thread control
    BOOL _shouldCreateCalibrateThread;
    BOOL _shouldCreateRenderThread;
    //current process frame info
    VideoFrameYUV _frame;
}
//working queue
@property (nonatomic,strong) dispatch_queue_t workingQueue;
//render queue
@property (nonatomic,strong) dispatch_queue_t renderQueue;
//app state
@property (nonatomic,assign) BOOL isAppActive;
//frame ptr
-(VideoFrameYUV*)framePtr;
//calibration process
-(DJIImageCalibrationFastFrame*)processCalibrationForFrame:(DJIImageCalibrationFastFrame*)frame;
//reusable frame
-(DJIImageCalibrationFastFrame*)reusableFrame;
//memory pool
-(DJIImageCacheQueue*)memoryPool;
//cvpixelbufferref pool
-(DJIImageCacheQueue*)pixelPool;
//called when dealloc，or may cause memory leak
-(void)prepareToClean;
//override
-(void)initData;
-(void)syncData;
-(void)bindData;
-(void)unbindData;

@end

#endif /* DJIImageCalibrateHelper_Private_h */
