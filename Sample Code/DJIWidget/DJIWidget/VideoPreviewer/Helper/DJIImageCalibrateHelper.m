//
//  DJIImageCalibrateHelper.m
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIImageCalibrateHelper_Private.h"
#import <pthread.h>
//frame
#import "DJIImageCalibrationFastFrame.h"
//cache queue size
#define DJICalibrateImageQueueSize                  (10)

@implementation DJIImageCalibrateHelper

#pragma mark - dealloc and initialization
-(void)dealloc{
    [self unbindBaseData];
    [self prepareToClean];
}

-(instancetype)init{
    return [self initShouldCreateCalibrateThread:NO
                                 andRenderThread:NO];
}

-(instancetype)initShouldCreateCalibrateThread:(BOOL)enabledCalibrateThread
                               andRenderThread:(BOOL)enabledRenderThread{
    if (self = [super init]){
        _shouldCreateRenderThread = enabledRenderThread;
        _shouldCreateCalibrateThread = enabledCalibrateThread;
        [self initBaseData];
        [self bindBaseData];
        [self syncBaseData];
    }
    return self;
}

-(void)syncBaseData{
    [self syncData];
}

-(void)bindBaseData{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appActiveStateChanged:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appActiveStateChanged:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [self bindData];
}

-(void)unbindBaseData{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unbindData];
}

-(void)appActiveStateChanged:(NSNotification*)notification{
    if (notification == nil
        || ![notification isKindOfClass:[NSString class]]){
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification]){
        __strong typeof(weakSelf) target = weakSelf;
        if (_shouldCreateCalibrateThread){
            dispatch_async(_workingQueue, ^{
                target.isAppActive = YES;
            });
        }
        else{
            target.isAppActive = YES;
        }
    }
    else if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]){
        __strong typeof(weakSelf) target = weakSelf;
        if (_shouldCreateCalibrateThread){
            dispatch_async(_workingQueue, ^{
                target.isAppActive = NO;
            });
        }
        else{
            target.isAppActive = NO;
        }
    }
}

-(void)initBaseData{
    _isAppActive = YES;
    _handler = nil;
    memset(&_frame,0,sizeof(_frame));
    //queue
    BOOL threadSafe = [self hasExtraThread];
    _frameQueue = [[DJIImageCalibrationFrameQueue alloc] initWithQueueCapacity:DJICalibrateImageQueueSize
                                                                 andThreadSafe:threadSafe];
    _cacheQueue = [[DJIImageCalibrationFrameQueue alloc] initWithQueueCapacity:DJICalibrateImageQueueSize
                                                                 andThreadSafe:threadSafe];
    _recycleQueue = [[DJIImageCalibrationFrameQueue alloc] initWithQueueCapacity:DJICalibrateImageQueueSize
                                                                   andThreadSafe:threadSafe];
    _memQueue = [[DJIImageCacheQueue alloc] initWithThreadSafe:threadSafe];
    _pixelRefQueue = [[DJIImageCacheQueue alloc] initWithThreadSafe:threadSafe];
    if (_shouldCreateCalibrateThread){
        //dispatcher
        dispatch_queue_attr_t workingAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL,
                                                                                    QOS_CLASS_UTILITY,
                                                                                    0);
        NSString* workHash = [NSString stringWithFormat:@"image.calibrate(%ld).working.queue",self.hash];
        _workingQueue = dispatch_queue_create(workHash.UTF8String,
                                              workingAttr);
    }
    if (_shouldCreateRenderThread){
        pthread_mutex_init(&_render_mutex, NULL);
        //render queue
        dispatch_queue_attr_t renderAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL,
                                                                                   QOS_CLASS_UTILITY,
                                                                                   0);
        NSString* rendHash = [NSString stringWithFormat:@"image.calibrate(%ld).render.queue",self.hash];
        _renderQueue = dispatch_queue_create(rendHash.UTF8String,
                                             renderAttr);
    }
    [self initData];
}

#pragma mark - public interface
-(void)updateFrame:(VideoFrameYUV*)frame{
    if (frame == NULL){
        memcpy(&_frame,0,sizeof(_frame));
    }
    else{
        memcpy(&_frame,frame,sizeof(_frame));
        _frame.frameType = VPFrameTypeRGBA;
        _frame.luma = NULL;
        _frame.chromaR = NULL;
        _frame.chromaB = NULL;
        _frame.chromaBSlice = 0;
        _frame.chromaRSlice = 0;
        _frame.lumaSlice = 0;
        _frame.cv_pixelbuffer_fastupload = NULL;
    }
}

//push the new frame to the processing queue
-(BOOL)pushFrame:(VideoFrameYUV*)frame{
    [self updateFrame:frame];
    return [self enqueueFrame:frame];
}

//enqueue frame into the processing queue
-(BOOL)enqueueFrame:(VideoFrameYUV*)frame{
    if (!_isAppActive
        || frame == NULL){
        return NO;
    }
    DJIImageCalibrationFastFrame* frameObject = [self createCalibrateFrameForYUVFrame:frame];
    if (!frameObject){
        return NO;
    }
    if (![_cacheQueue push:frameObject]){
        return NO;
    }
    if (_shouldCreateCalibrateThread){
        __weak typeof(self) weakSelf = self;
        dispatch_async(_workingQueue, ^{
        __strong typeof(weakSelf) target = weakSelf;
            if (!target.isAppActive){
                return;
            }
            [target processCalibration];
        });
    }
    else{
        [self processCalibration];
    }
    return YES;
}

//no need to process any more and push into the output queue
-(BOOL)pushFastAndSimpleFrame:(VideoFrameYUV*)frame
                   withSource:(id)source{
    //add source label to avoid using invalid memory address
    if (!_isAppActive
        || frame == NULL
        || source == nil){
        return NO;
    }
    DJIImageCalibrationFastFrame* frameObject = [self reusableFrame];
    if (!frameObject){
        frameObject = [[DJIImageCalibrationFastFrame alloc] initWithFastFrame:frame
                                                                   fastUpload:[DJILiveViewRenderContext supportsFastTextureUpload]
                                                               andPixelBuffer:[self pixelPool]];
    }
    else{
        [frameObject loadFrame:frame
                    fastUpload:[DJILiveViewRenderContext supportsFastTextureUpload]];
    }
    frameObject.sourceTag = source;
    [frameObject prepareBeforeUsing];
    if (![_frameQueue push:frameObject]){
        return NO;
    }
    if (_shouldCreateRenderThread){
        __weak typeof(self) weakSelf = self;
        dispatch_async(_renderQueue, ^{
            __strong typeof(weakSelf) target = weakSelf;
            if (!target.isAppActive){
                return;
            }
            [target handleLatestFrame];
        });
    }
    return YES;
}

-(void)handlePullFrame{
    if (!_shouldCreateRenderThread){
        [self handleLatestFrame];
    }
}

//handle the frame from the output queue
-(void)handleLatestFrame{
    DJIImageCalibrationFastFrame* frameObject = [_frameQueue pull];
    if (frameObject == nil){
        return;
    }
    id frameSource = frameObject.sourceTag;
    if (!frameSource){//valid frame has nonnull source
        [_recycleQueue push:frameObject];
        return;
    }
    id<DJIImageCalibrateResultHandlerDelegate> handler = _handler;
    if (handler != nil){
        [handler newFrame:[frameObject frame]
        arrivalFromHelper:self];
    }
    [_recycleQueue push:frameObject];
}

//process current frame and push processed frame into the output queue
-(void)processCalibration{
    DJIImageCalibrationFastFrame* frameObject = [_cacheQueue pull];
    if (![frameObject isKindOfClass:[DJIImageCalibrationFastFrame class]]){
        return;
    }
    DJIImageCalibrationFastFrame* newFrameObject = [self processCalibrationForFrame:frameObject];
    if (newFrameObject != frameObject){
        [_recycleQueue push:frameObject];
    }
    [newFrameObject prepareBeforeUsing];
    [_frameQueue push:newFrameObject];
    if (_shouldCreateRenderThread){
        __weak typeof(self) weakSelf = self;
        dispatch_async(_renderQueue, ^{
            __strong typeof(weakSelf) target = weakSelf;
            if (!target.isAppActive){
                return;
            }
            [target handleLatestFrame];
        });
    }
}

#pragma mark - private
-(BOOL)hasExtraThread{
    return (_shouldCreateCalibrateThread || _shouldCreateRenderThread);
}

-(VideoFrameYUV*)framePtr{
    return &_frame;
}

-(void)renderLockStatus:(BOOL)locked{
    if (!_shouldCreateRenderThread){
        return;
    }
    if (locked){
        pthread_mutex_lock(&_render_mutex);
    }
    else{
        pthread_mutex_unlock(&_render_mutex);
    }
}

#pragma mark - override for inititialization
-(void)initData{
}

-(void)syncData{
}

-(void)bindData{
}

-(void)unbindData{
}

#pragma mark - color converter
-(void)colorConverter:(DJIImageCalibrateColorConverter*)converter
          passYUVData:(uint8_t**)yuvData
             yuvSlice:(int*)yuvSlice
         withFastload:(CVPixelBufferRef)fastload{
    DJIImageCalibrateColorConverter* colorConverter = converter;
    if (yuvData == NULL
        || yuvSlice == NULL
        || colorConverter == nil){
        return;
    }
    uint8_t* y = yuvData[0];
    uint8_t* u = yuvData[1];
    uint8_t* v = yuvData[2];
    int ySlice = yuvSlice[0];
    int uSlice = yuvSlice[1];
    int vSlice = yuvSlice[2];
    if ([converter type] == VPFrameTypeYUV420Planer//yuv420P y->y,u->u,v->v
        && (y == NULL
            || u == NULL
            || v == NULL
            || ySlice <= 0
            || uSlice <= 0
            || vSlice <= 0)){
            return;
        }
    else if ([converter type] == VPFrameTypeYUV420SemiPlaner//yuv420PSemi y->y,u->uv
             && (y == NULL
                 || u == NULL
                 || ySlice <= 0
                 || uSlice <= 0)){
                 return;
             }
    else if ([converter type] == VPFrameTypeRGBA//rgba y->rgba
             && (y == NULL
                 || ySlice <= 0)){
                 return;
             }
    else if ([converter type] != VPFrameTypeYUV420Planer
             && [converter type] != VPFrameTypeYUV420SemiPlaner
             && [converter type] != VPFrameTypeRGBA){
        return;
    }
    [self framePtr]->luma = y;
    [self framePtr]->chromaB = u;
    [self framePtr]->chromaR = v;
    [self framePtr]->lumaSlice = ySlice;
    [self framePtr]->chromaBSlice = uSlice;
    [self framePtr]->chromaRSlice = vSlice;
    [self framePtr]->frameType = [converter type];
    [self framePtr]->cv_pixelbuffer_fastupload = fastload;
    [self convertedYUVFrameArrivalFrom:colorConverter];
}

#pragma mark - override for frame process
-(void)convertedYUVFrameArrivalFrom:(id)source{
    //direct push into the output queue
    [self pushFastAndSimpleFrame:[self framePtr]
                      withSource:source];
}

-(DJIImageCalibrationFastFrame*)createCalibrateFrameForYUVFrame:(VideoFrameYUV*)frame{
    return nil;
}

-(void)prepareToClean{
}

-(BOOL)independancyWithReander{
    return NO;
}

-(DJIImageCalibrationFastFrame*)processCalibrationForFrame:(DJIImageCalibrationFastFrame*)frame{
    if (!frame
        || ![frame isKindOfClass:[DJIImageCalibrationFastFrame class]]
        || [frame frame] == NULL
        || !_isAppActive){
        return nil;
    }
    return frame;
}

#pragma mark - internal
-(DJIImageCalibrationFastFrame*)reusableFrame{
    DJIImageCalibrationFastFrame* reusableFrame = [_recycleQueue pull];
    if ([reusableFrame isKindOfClass:[DJIImageCalibrationFastFrame class]]){
        reusableFrame.sourceTag = nil;
    }
    return reusableFrame;
}

-(DJIImageCacheQueue*)memoryPool{
    return _memQueue;
}

-(DJIImageCacheQueue*)pixelPool{
    return _pixelRefQueue;
}

@end
