//
//  DJIImageCalibrateHelper.h
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#ifndef DJIImageCalibrateHelper_h
#define DJIImageCalibrateHelper_h

/*
 * flow:
 * new yuv frame -> update frame info -> render -> calibrated rgba frame -> <this helper> -> output calibrated yuv frame -> other processer
 *
 * detail flow of this helper:
 * calibrated rgba frame -> pass frame to color converter in render -> combined data to create yuv calibrated frame -> output frame queue
 *
 */

#import <DJIWidget/DJIStreamCommon.h>
#import <DJIWidget/DJILiveViewRenderPass.h>
#import <DJIWidget/DJIImageCalibrateFilterDataSource.h>
//color converter
#import <DJIWidget/DJIImageCalibrateColorConverter.h>

@class DJIImageCalibrateHelper;

//calibrate helper lift time control delegate
@protocol DJIImageCalibrateDelegate<NSObject>

@required
//ask delegate to check
-(BOOL)shouldCreateHelper;
//return created helper if needed
-(DJIImageCalibrateHelper*)helperCreated;
//destroy current helper if no needed any mode
-(void)destroyHelper;
//return filter data source for calibration
-(DJIImageCalibrateFilterDataSource*)calibrateDataSource;

@end

@protocol DJIImageCalibrateResultHandlerDelegate<NSObject>

@required
//new frame arrival
-(void)newFrame:(VideoFrameYUV*)frame
arrivalFromHelper:(DJIImageCalibrateHelper*)helper;

@end

@interface DJIImageCalibrateHelper : NSObject<DJIImageCalibrateColorConverterHandlerProtocol>

//update info from new frame
-(void)updateFrame:(VideoFrameYUV*)frame;
//push frame to calibrate
-(BOOL)pushFrame:(VideoFrameYUV*)frame;
//process new frame and call handler
-(void)handlePullFrame;
//lock/unlock when render thread created
-(void)renderLockStatus:(BOOL)locked;
//has created calibration thread or render thread
-(BOOL)hasExtraThread;
//stand-alone calibration process
-(BOOL)independancyWithReander;

//new yuvframe notification
@property (nonatomic,weak) id<DJIImageCalibrateResultHandlerDelegate> handler;

-(instancetype)initShouldCreateCalibrateThread:(BOOL)enabledCalibrateThread
                               andRenderThread:(BOOL)enabledRenderThread;

@end

#endif /* DJIImageCalibrateHelper_h */
