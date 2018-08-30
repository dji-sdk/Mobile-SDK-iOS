//
//  DJIDecodeImageCalibrateHelper.m
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIDecodeImageCalibrateHelper.h"
#import "DJIImageCalibrateHelper_Private.h"
//buffer
#import "DJIDecodeImageCalibrateDataBuffer.h"
//data source
#import "DJIDecodeImageCalibrateDataSource.h"
//context
#import "DJILiveViewRenderContext.h"
//color converter
#import "DJIImageCalibrateColorGPUConverter.h"
//header
#import <DJIWidget/DJIWidget.h>
#import <pthread.h>

#define DJIImageCalibrationFrameCacheCapacity           (10)
#define DJIImageCalibrationFPSCalculationCount          (30)

@interface DJIDecodeImageCalibrateHelper(){
    CGSize _frameSize;
    //context
    DJILiveViewRenderContext* _context;
    //data source
    DJIDecodeImageCalibrateDataSource* _renderSource;
    //image cache queue
    DJIImageCalibrationFrameQueue* _calibrateCacheQueue;
    //filter
    DJILiveViewCalibrateFilter* _calibrateFilter;
    //color converter
    DJIImageCalibrateColorConverter* _internalColorConverter;
    //protect mutex
    pthread_mutex_t _calibrateMutex;
}
@end

@implementation DJIDecodeImageCalibrateHelper

#pragma mark - initialization
-(void)initData{
    [super initData];
    BOOL threadSafe = [self hasExtraThread];
    _calibrateCacheQueue = [[DJIImageCalibrationFrameQueue alloc] initWithQueueCapacity:DJIImageCalibrationFrameCacheCapacity
                                                                          andThreadSafe:threadSafe];
    _context = [[DJILiveViewRenderContext alloc] initWithMultiThreadSupport:threadSafe];
    if (!_context) {
        return;
    }
    [_context useAsCurrentContext];
    pthread_mutex_init(&_calibrateMutex,NULL);
    VPFrameType outputFrameType = VPFrameTypeYUV420Planer;
    if ([DJILiveViewRenderContext supportsFastTextureUpload]){
        outputFrameType = VPFrameTypeYUV420SemiPlaner;
    }
    _enabledColorSpaceConverter = NO;
    _internalColorConverter = [[DJIImageCalibrateColorGPUConverter alloc] initWithFrameType:outputFrameType];
    [(DJIImageCalibrateColorGPUConverter*)_internalColorConverter setContext:_context];
    _internalColorConverter.delegate = self;
    _internalColorConverter.enabledConverter = _enabledColorSpaceConverter;
    _renderSource = [[DJIDecodeImageCalibrateDataSource alloc] initWithContext:_context];
    _calibrateFilter = [[DJILiveViewCalibrateFilter alloc] initWithContext:_context];
    _calibrateFilter.enabled = YES;
    [_renderSource addTarget:_calibrateFilter
           atTextureLocation:0];
    [_calibrateFilter addTarget:[_internalColorConverter holder]
              atTextureLocation:0];
}

#pragma mark - public interface
-(DJILiveViewCalibrateFilter*)calibrateFilter{
    return _calibrateFilter;
}

#pragma mark - override
-(void)prepareToClean{
    [super prepareToClean];
    pthread_mutex_lock(&_calibrateMutex);
    [_context useAsCurrentContext];
    [_calibrateFilter removeAllTargets];
    [_calibrateFilter releaseResources];
    [_renderSource removeAllTargets];
    [_renderSource releaseResources];
    [_context releaseContext];
    _context = nil;
    _renderSource = nil;
    _calibrateFilter = nil;
    pthread_mutex_unlock(&_calibrateMutex);
}

-(BOOL)independancyWithReander{
    return YES;
}

-(void)convertedYUVFrameArrivalFrom:(id)source{
    if (!source){
        return;
    }
    DJIImageCalibrationFrame* calibrateFrame = (DJIImageCalibrationFrame*)[self reusableFrame];
    if (!calibrateFrame){
        calibrateFrame = [[DJIImageCalibrationFrame alloc] initWithFrame:[self framePtr]
                                                              fastUpload:[DJILiveViewRenderContext supportsFastTextureUpload]
                                                         pixelCacheQueue:[self pixelPool]
                                                        andMemCacheQueue:[self memoryPool]];
    }
    else{
        [calibrateFrame loadFrame:[self framePtr]
                       fastUpload:[DJILiveViewRenderContext supportsFastTextureUpload]];
    }
    calibrateFrame.sourceTag = source;
    [_calibrateCacheQueue push:calibrateFrame];
}

-(DJIImageCalibrationFastFrame*)createCalibrateFrameForYUVFrame:(VideoFrameYUV*)frame{
    DJIImageCalibrationFrame* frameObject = (DJIImageCalibrationFrame*)[self reusableFrame];
    if (!frameObject
        || ![frameObject isKindOfClass:[DJIImageCalibrationFrame class]]){
        frameObject = [[DJIImageCalibrationFrame alloc] initWithFrame:frame
                                                           fastUpload:(frame->cv_pixelbuffer_fastupload != NULL)
                                                      pixelCacheQueue:[self pixelPool]
                                                     andMemCacheQueue:[self memoryPool]];
    }
    else{
        [frameObject loadFrame:frame
                    fastUpload:(frame->cv_pixelbuffer_fastupload != NULL)];
    }
    return frameObject;
}

-(DJIImageCalibrationFastFrame*)processCalibrationForFrame:(DJIImageCalibrationFastFrame*)frame{
    if (![super processCalibrationForFrame:frame]){
        return nil;
    }
    pthread_mutex_lock(&_calibrateMutex);
    [_context useAsCurrentContext];
    [frame prepareBeforeUsing];
    [_renderSource loadFrame:[frame frame]];
    [_renderSource renderPass];
    pthread_mutex_unlock(&_calibrateMutex);
    DJIImageCalibrationFrame* newFrame = (DJIImageCalibrationFrame*)[_calibrateCacheQueue pull];
    if (!newFrame
        || ![newFrame isKindOfClass:[DJIImageCalibrationFrame class]]){
        return nil;
    }
    return newFrame;
}

#pragma mark - colorspace control
-(void)setEnabledColorSpaceConverter:(BOOL)enabledColorSpaceConverter{
    if (_enabledColorSpaceConverter == enabledColorSpaceConverter){
        return;
    }
    _enabledColorSpaceConverter = enabledColorSpaceConverter;
    if (_internalColorConverter != nil){
        _internalColorConverter.enabledConverter = enabledColorSpaceConverter;
    }
}

@end
