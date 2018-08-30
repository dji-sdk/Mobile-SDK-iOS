//
//  DJIVideoPreviewer.m
//
//  Copyright (c) 2013 DJI. All rights reserved.
//


#import <sys/time.h>
#include <OpenGLES/ES2/gl.h>

#import "DJIVideoPreviewer.h"
#import "DJIVideoPreviewerH264Parser.h"
#import "DJILB2AUDRemoveParser.h"
#import "DJIH264PocQueue.h"
#import "DJIWidgetLinkQueue.h"
#import "DJIWidgetAsyncCommandQueue.h"
#import "DJIH264FrameRawLayerDumper.h"
#import "DJIWidgetMacros.h"
#import "DJIVideoPreviewSmoothHelper.h"


//cache
#import "DJIImageCache.h"
#import "DJIImageCacheQueue.h"

//helper
#import "DJIDecodeImageCalibrateHelper.h"
#import "DJIDecodeFrameRateMonitor.h"


#define __TEST_VIDEO_DELAY__  (0)
#define __TEST_QUEUE_PULL__   (0) //Pull debug from 264 stream file
#define __TEST_FRAME_PULL__   (0) //Pull debug from frame file
#define __TEST_PACK_PULL__    (0) //Pull debug from subpackage file

#define __TEST_PACK_DUMP__    (0) //Save the package file
#define __TEST_FRAME_DUMP__   (0) //Save the framing file
#define __TEST_FRAME_LOST__   (0) //Test dropped frame bad frame
#define __LB2_PARSER_DUMP__   (0) //Save lb2AUD output

#define __ENABLE_DEBUG_TOOLS__ (0) //Enable debug tool
#define __TEST_REORDER__       (0) //Debug Cache

#define FRAME_DROP_THRESHOLD  (70)
#define RENDER_DROP_THRESHOLD (5)

#if __TEST_VIDEO_DELAY__
#import "DJITestDelayLogic.h"
#endif

#if __TEST_VIDEO_STUCK__
#import "DJIVideoStuckTester.h"
#endif

#if __ENABLE_DEBUG_TOOLS__
#import "DJIDataDumper.h"
#endif


@interface DJIVideoPreviewer () <
H264DecoderOutput,
DJIMovieGLViewDelegate,
DJILB2AUDRemoveParserDelegate,
DJIImageCalibrateResultHandlerDelegate,
DJICalibratePixelBufferProviderDelegate,
DJIVideoDataFrameControlDelegate>{
    
    NSThread *_decodeThread;    //decode thread
    DJIMovieGLView *_glView;   //OpenGL render
    
    BOOL videoDecoderCanReset;
    int videoDecoderFailedCount;
    int glViewRenderFrameCount; //GLView render input frame count
    int safe_resume_skip_count; //hardware decode under the safe_resume should skip frame count
    
    DJIVideoStreamBasicInfo _stream_basic_info;
    pthread_mutex_t _processor_mutex;
    
    long long _lastDataInputTime; //Last received time data
    long long _lastFrameDecodedTime; //Last time available to decode
    
#if __TEST_FRAME_DUMP__ || __LB2_PARSER_DUMP__
    /**
     *  dumper for frame
     */
    DJIH264FrameRawLayerDumper* frameLayerDumper;
    DJIDataDumper* lb2Dumper;
#endif
    
#if __TEST_PACK_DUMP__
    DJIDataDumper* packLayerDumper;
#endif
}

@property (nonatomic, assign, readwrite) NSUInteger realTimeFrameRate;

@property (nonatomic, strong, readwrite) DJIDecodeFrameRateMonitor* frameRateMonitor;

@property (nonatomic, assign, readwrite) uint32_t globalTimeStamp;

/**
 *  YES if this is the first instance
 */
@property (nonatomic, assign) BOOL isDefaultPreviewer;

/**
 *  frame buffer queue
 */
@property(nonatomic, strong) DJIWidgetLinkQueue *dataQueue;
//gl view
@property (nonatomic, strong) DJIMovieGLView* internalGLView;

//basic status
@property (assign, nonatomic) DJIVideoPreviewerStatus status;
//ffmpeg warpper
@property (strong, nonatomic) DJICustomVideoFrameExtractor *videoExtractor;

//hardware decode use videotool box on ios8
@property (strong, nonatomic) DJIH264VTDecode *hw_decoder;
//software decoder use ffmpeg
@property (strong, nonatomic) DJISoftwareDecodeProcessor* soft_decoder;

//decoder current state
@property (assign, nonatomic) DJIVideoDecoderStatus decoderStatus;
//frame output type
@property (assign, nonatomic) VPFrameType frameOutputType;
//stream processor list
@property (assign, nonatomic) DJIVideoStreamBasicInfo currentStreamInfo;

//processor list
@property (strong, nonatomic) NSMutableArray* stream_processor_list;
@property (strong, nonatomic) NSMutableArray* frame_processor_list;

//need gray scale image when pause
@property (assign, nonatomic) BOOL grayOutPause;

//current frame
@property (assign, nonatomic) CGRect frame;

//remove the redundant aud in LB2's stream
@property (strong, nonatomic) DJILB2AUDRemoveParser* lb2AUDRemove;

//a queue for re-ordering frames after decode (处理B帧时使用)
@property (strong, nonatomic) DJIH264PocQueue* pocQueue;
//内存池，避免不断分配内存
@property (strong, nonatomic) DJIH264PocQueue* pocMemCache;

//
@property (assign, nonatomic) uint32_t pocBufferSize;

//command queue to handle commands send to render queue
@property (strong, nonatomic) DJIWidgetAsyncCommandQueue* cmdQueue;

@property (nonatomic) NSCondition *renderCond;
@property (nonatomic) BOOL isRendering;

@property (nonatomic) NSLock *decodeRunloopBlocker;

#if __ENABLE_DEBUG_TOOLS__
@property (nonatomic, strong) DJIDataDumper *videoDumper;
#endif

@end

@implementation DJIVideoPreviewer

-(id)init
{
    self= [super init];
    
    _performanceCountEnabled      = NO;
    _decodeThread          = nil;
    _glView                = nil;
    _type                  = DJIVideoPreviewerTypeAutoAdapt;
	
    _decoderStatus         = DJIVideoDecoderStatus_Normal;
    // Changed in SDK
    _dataQueue             = [[DJIWidgetLinkQueue alloc] initWithSize:100];
    
    _stream_processor_list = [[NSMutableArray alloc] init];
    _frame_processor_list  = [[NSMutableArray alloc] init];
    _luminanceScale        = 1.0;
    _enableFastUpload      = YES; //default use fast upload
    safe_resume_skip_count = 0;
    _customizedFramerate   = 0;
    
    _renderCond = [NSCondition new];
    _isRendering = NO;
    
    _decodeRunloopBlocker = [NSLock new];
    
    //command queue
    self.cmdQueue = [[DJIWidgetAsyncCommandQueue alloc] initWithThreadSafe:YES];
    
    _videoExtractor = [[DJICustomVideoFrameExtractor alloc] initExtractor];
    [_videoExtractor setShouldVerifyVideoStream:YES];
	_videoExtractor.delegate = self;
    pthread_mutex_init(&_processor_mutex, nil);
    
    memset(&_status, 0, sizeof(DJIVideoPreviewerStatus));
    _status.isInit    = YES;
    _status.isRunning = NO;
    
    memset(&_stream_basic_info, 0, sizeof(_stream_basic_info));
    //default is inspire frame rate
    _stream_basic_info.frameRate   = 30;
    _stream_basic_info.encoderType = H264EncoderType_DM368_inspire;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeGround:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    
    //soft decoder
    _soft_decoder = [[DJISoftwareDecodeProcessor alloc] initWithExtractor:_videoExtractor];
    _soft_decoder.frameProcessor = self;
    
    //Simulator hardware decoding will be stuck in callback
#if !TARGET_IPHONE_SIMULATOR
    
    if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
        //use hardware decode on ios8
        _hw_decoder = [[DJIH264VTDecode alloc] init];
        _hw_decoder.delegate = self;
    }
#endif
    
    [self registStreamProcessor:_soft_decoder];
    [self registStreamProcessor:_hw_decoder];
    
    //default is inspire
    self.encoderType = H264EncoderType_DM368_inspire;
    
    //lb2 workaround
    self.lb2AUDRemove = [[DJILB2AUDRemoveParser alloc] init];
    self.lb2AUDRemove.delegate = self;
    
    return self;
}

-(void) dealloc
{
    if (_videoExtractor) {
        _videoExtractor.processDelegate = nil;
        _videoExtractor.delegate = nil;
    }
    
    [_videoExtractor freeExtractor];
    [_glView releaseResourece];
    [self privateClose];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) appDidEnterBackground:(NSNotification*)notify
{
    [self enterBackground];
}

-(void) appWillEnterForeGround:(NSNotification *)notify
{
    [self enterForegournd];
}

#pragma mark - public

static DJIVideoPreviewer* previewer = nil;

+(DJIVideoPreviewer*) instance
{
    if(previewer == nil)
    {
        @synchronized (self) {
            if (previewer == nil) {
                previewer = [[DJIVideoPreviewer alloc] init];
                previewer.isDefaultPreviewer = YES;
            }
        }
    }
    return previewer;
}

// SDK
+(void) releaseInstance {
    @synchronized (self) {
        previewer = nil;
    }
}

-(void) push:(uint8_t*)videoData length:(int)len
{
#if __TEST_VIDEO_DELAY__
    if ([DJITestDelayLogic sharedInstance].hasSynced && ![DJITestDelayLogic sharedInstance].isSyncing) {
        [[DJITestDelayLogic sharedInstance] startSyncTime];
        return;
    }
    if ([DJITestDelayLogic sharedInstance].hasSynced) {
        NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate];
        [[DJITestDelayLogic sharedInstance] logPackSize:len time:currentTimeInterval];
        return;
    }
#endif
    
#if __TEST_PACK_DUMP__
    if (!packLayerDumper) {
        packLayerDumper = [[DJIDataDumper alloc] init];
        packLayerDumper.namePerfix = @"videoPack";
        packLayerDumper.packAlignMode = YES;
    }
    
    if (packLayerDumper) {
        [packLayerDumper dumpData:videoData length:len];
    }
#endif
    
#if __ENABLE_DEBUG_TOOLS__
    if (self.videoDumper)
    {
        [self.videoDumper dumpData:videoData length:len];
    }
#endif
    
    _lastDataInputTime = [self getTickCount];
    if (_status.isRunning) {
        if (_encoderType == H264EncoderType_LightBridge2) {
            ////Remove the extra aud in lb2
            [_lb2AUDRemove parse:videoData inSize:len];
        }else{
            [_videoExtractor parseVideo:videoData length:len withFrame:^(VideoFrameH264Raw *frame) {
                if (!frame) {
                    return;
                }
                
                if (self.dataQueue.count > FRAME_DROP_THRESHOLD) {
                    DJILOG(@"decode dataqueue drop %d", FRAME_DROP_THRESHOLD);
                    [self.dataQueue clear];
                    [self.smoothDecode resetSmooth];
                }
#if __TEST_VIDEO_STUCK__
                [DJIVideoStuckTester parseFrameWithIndex:frame->frame_info.frame_index];
#endif
                frame->time_tag = [self getTickCount];
                [self.dataQueue push:(uint8_t*)frame length:sizeof(VideoFrameH264Raw) + frame->frame_size];
            }];
        }
    }
    else
    {
        [self.dataQueue clear];
    }
}

-(void) clearVideoData
{
    [self.dataQueue clear];
    [_glView clear];
}

-(void) snapshotPreview:(void(^)(UIImage* snapshot))block{
    if (!_glView || _status.isPause || safe_resume_skip_count) {
        if (block) {
            block(nil);
        };
        return;
    }
    
    _glView.snapshotCallback = block;
}

-(void) snapshotThumnnail:(void(^)(UIImage* snapshot))block{
    if (!_glView || _status.isPause || safe_resume_skip_count) {
        if (block) {
            block(nil);
        };
        return;
    }
    
    _glView.snapshotThumbnailCallback = block;
}


-(BOOL)setView:(UIView *)view
{
    BEGIN_MAIN_DISPATCH_QUEUE
    if(_glView == nil){
        //generate
        _glView = [[DJIMovieGLView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, view.frame.size.width, view.frame.size.height)];
        _glView.delegate = self;
        _glView.rotation = self.rotation;
        _glView.contentClipRect = self.contentClipRect;
    }
    
    
    if(_glView.superview != view){
        [view addSubview:_glView];
    }
    [view sendSubviewToBack:_glView];
    [_glView adjustSize];
    _status.isGLViewInit = YES;
    
    //set self frame property
    [self movieGlView:_glView didChangedFrame:_glView.frame];
    self.internalGLView = _glView;
    END_DISPATCH_QUEUE
    return NO;
}

-(void)unSetView
{
    BEGIN_MAIN_DISPATCH_QUEUE
    if(_glView != nil && _glView.superview !=nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_glView removeFromSuperview];
            //_glView = nil; // Deliberately not release dglView, Avoid each entry view flickering。
            _status.isGLViewInit = NO;
            self.internalGLView = nil;
        });
    }
    END_DISPATCH_QUEUE
}

-(void)adjustViewSize{
    NSAssert([NSThread isMainThread], @"adjustViewSize should be called in main thread only. ");
    [_glView adjustSize];
}

-(CGPoint) convertPoint:(CGPoint)point toVideoViewFromView:(UIView*)view{
    if (!_glView) {
        return CGPointZero;
    }
    
    return [_glView convertPoint:point fromView:view];
}

-(CGPoint) convertPoint:(CGPoint)point fromVideoViewToView:(UIView *)view{
    if (!_glView) {
        return CGPointZero;
    }
    
    return [_glView convertPoint:point toView:view];
}

- (BOOL)start
{
    BEGIN_MAIN_DISPATCH_QUEUE
    if(_decodeThread == nil && !_status.isRunning)
    {
        _decodeThread = [[NSThread alloc] initWithTarget:self selector:@selector(decodeRunloop) object:nil];
        _decodeThread.name = @"com.dji.videoPreviewer.decodeThread";
        _decodeThread.qualityOfService = NSQualityOfServiceUserInteractive;
        [_decodeThread start];
    }
    END_DISPATCH_QUEUE
    return YES;
}

-(void) reset
{
    BEGIN_MAIN_DISPATCH_QUEUE
    if(_decodeThread && _status.isRunning)
    {
        safe_resume_skip_count = 0;
        _status.isRunning = NO;
        [_decodeThread cancel];
        
        [self.dataQueue wakeupReader];
        while (!_decodeThread.isFinished) {
            usleep(10000);
        }
        _decodeThread = nil;
        [_videoExtractor clearExtractorBuffer];
        [_dataQueue clear];
        
        if (_hw_decoder) {
            [_hw_decoder resetLater];
        }
        
        [self.smoothDecode resetSmooth];
        
        for (id<VideoStreamProcessor> processor in _stream_processor_list) {
            if ([processor respondsToSelector:@selector(streamProcessorReset)]) {
                [processor streamProcessorReset];
            }
        }
        
        [self start];
    }
    END_DISPATCH_QUEUE
}

- (void)resume{
    BEGIN_MAIN_DISPATCH_QUEUE
    _status.isPause = NO;
    DJILOG(@"Resume the decoding");
    END_DISPATCH_QUEUE
}

- (void)safeResume{
    DJILOG(@"begin Try safe resuming");
    safe_resume_skip_count = 25;
    [self resume];
}

- (void)pause{
    [self pauseWithGrayout:YES];
}

- (void)pauseWithGrayout:(BOOL)isGrayout{
    BEGIN_MAIN_DISPATCH_QUEUE
    _status.isPause = YES;
    _grayOutPause = isGrayout;
    DJILOG(@"Pause decoding");
    //Wake up waiting threads will immediately render a black white image
    [self.dataQueue wakeupReader];
    
    for (id<VideoStreamProcessor> processor in _stream_processor_list) {
        if ([processor respondsToSelector:@selector(streamProcessorPause)]) {
            [processor streamProcessorPause];
        }
    }
    END_DISPATCH_QUEUE
}

- (void)close{
    BEGIN_MAIN_DISPATCH_QUEUE
    [self privateClose];
    END_DISPATCH_QUEUE
}

-(void) clearRender
{
    BEGIN_MAIN_DISPATCH_QUEUE
    [_glView clear];
    [self.dataQueue wakeupReader];
    END_DISPATCH_QUEUE
}

- (void)privateClose
{
    [_dataQueue clear];
    if(_decodeThread!=nil){
        [_decodeThread cancel];
        _decodeThread = nil;
    }
    _status.isRunning = NO;
}

- (void)setType:(DJIVideoPreviewerType)type{
    NSAssert([NSThread isMainThread], @"setType should be called in main thread only. ");
    if(_type == type)return;
    if(_glView == nil)return;
    
    _type = type;
    switch (_type) {
        case DJIVideoPreviewerTypeFullWindow:
            [_glView setType:VideoPresentContentModeAspectFill];
            break;
        case DJIVideoPreviewerTypeAutoAdapt:
            [_glView setType:VideoPresentContentModeAspectFit];
            break;
        default:
            break;
    }
    if (_type != VideoPresentContentModeNone) {
        weakSelf(target);
        [self workInRenderQueue:^{
            weakReturn(target);
            [target tryRenderAction:^{
                [_glView render:nil];
            }];
        }];
    }
}

-(void) setRotation:(VideoStreamRotationType)rotation {
    NSAssert([NSThread isMainThread], @"setRotation should be called in main thread only. ");
    if (_rotation == rotation) {
        return;
    }
    
    _rotation = rotation;
    [_glView setRotation:rotation];
}

-(void) setContentClipRect:(CGRect)rect{
    NSAssert([NSThread isMainThread], @"setContentClipRect should be called in main thread only. ");
    if (CGRectEqualToRect(rect, _contentClipRect)) {
        return;
    }
    
    _contentClipRect = rect;
    [_glView setContentClipRect:rect];
}

-(BOOL) glviewCanRender{
    return !_status.isBackground && _status.isGLViewInit;
}

-(void) setOverExposedWarningThreshold:(float)overExposedWarningThreshold
{
    _overExposedWarningThreshold = overExposedWarningThreshold;
    _glView.overExposedMark = overExposedWarningThreshold;
}

-(void) setEnableFocusWarning:(BOOL)enableFocusWarning
{
    _enableFocusWarning = enableFocusWarning;
    _glView.enableFocusWarning  = enableFocusWarning;
}

- (void) setFocusWarningThreshold:(float)focusWarningThreshold{
    
    _focusWarningThreshold = focusWarningThreshold;
    _glView.focusWarningThreshold = focusWarningThreshold;
}

-(void) setLuminanceScale:(float)luminanceScale{
    _luminanceScale = luminanceScale;
    _glView.luminanceScale = luminanceScale;
}

-(void) setEnableHSB:(BOOL)enableHSB{
    _enableHSB = enableHSB;
    _glView.enableHSB = enableHSB;
}

-(void) setHsbConfig:(DJILiveViewRenderHSBConfig)hsbConfig{
    _hsbConfig = hsbConfig;
    _glView.hsbConfig = hsbConfig;
}

-(void) setEncoderType:(H264EncoderType)encoderType{
    if (_encoderType == encoderType) {
        return;
    }
    
    _encoderType = encoderType;
    _stream_basic_info.encoderType = encoderType;
    
    
    //enable poc buffer for wm230
    if (_encoderType == H264EncoderType_MavicAir) {
        self.pocBufferSize = 2;
    }
    else{
        self.pocBufferSize = 0;
    }
}

-(void) setEnableShadowAndHighLightenhancement:(BOOL)enable{
    if (_enableShadowAndHighLightenhancement == enable) {
        return;
    }
    
    _enableShadowAndHighLightenhancement = enable;
    _glView.enableShadowAndHighLightenhancement = enable;
}

-(void) setEnableHardwareDecode:(BOOL)enableHardwareDecode{
    if (_enableHardwareDecode == enableHardwareDecode) {
        return;
    }
    
    _enableHardwareDecode = enableHardwareDecode;
    [_hw_decoder resetLater];
}

-(void) registStreamProcessor:(id<VideoStreamProcessor>)processor{
    if (processor) {
        
        pthread_mutex_lock(&_processor_mutex);
        [_stream_processor_list addObject:processor];
        pthread_mutex_unlock(&_processor_mutex);
    }
}

-(void) unregistStreamProcessor:(id)processor{
    pthread_mutex_lock(&_processor_mutex);
    [_stream_processor_list removeObject:processor];
    pthread_mutex_unlock(&_processor_mutex);
}

-(void) registFrameProcessor:(id<VideoFrameProcessor>)processor{
    if (processor) {
        
        pthread_mutex_lock(&_processor_mutex);
        [_frame_processor_list addObject:processor];
        pthread_mutex_unlock(&_processor_mutex);
    }
}

-(void) unregistFrameProcessor:(id)processor{
    
    pthread_mutex_lock(&_processor_mutex);
    [_frame_processor_list removeObject:processor];
    pthread_mutex_unlock(&_processor_mutex);
}

-(NSUInteger)frameProcessorCount{
    pthread_mutex_lock(&_processor_mutex);
    NSMutableArray* processors = _frame_processor_list.mutableCopy;
    pthread_mutex_unlock(&_processor_mutex);
    NSUInteger count = 0;
    for (id<VideoFrameProcessor> processor in processors){
        if ([processor conformsToProtocol:@protocol(VideoFrameProcessor)]
            && [processor videoProcessorEnabled]){
            count++;
        }
    }
    return count;
}

#pragma mark - private
- (void)enterBackground{
    //It is not allowed to call OpenGL's interface in the background. Ensure all work is done before entering the background.
    [_renderCond lock];
    while (_isRendering) {
        [_renderCond wait];
    }
    DJILOG(@"videoPreviewer resign active");
    _status.isBackground = YES;
    [_renderCond unlock];
}

- (void)enterForegournd{
    DJILOG(@"videoPreviewer active");
    [_renderCond lock];
    _status.isBackground = NO;
    [_renderCond unlock];
}

// Update the decoder's status according to the timestamp when the previous data is received
- (void)updateDecoderStatus{
    if (_status.isPause) {//not update under the pause state
        return;
    }
    long long current = [self getTickCount];
    
    DJIVideoDecoderStatus status = DJIVideoDecoderStatus_Normal;
    if (current - _lastDataInputTime > 2000*1000) {
        status = DJIVideoDecoderStatus_NoData;
    }
    else if (current - _lastFrameDecodedTime > 2000*1000) {
        status = DJIVideoDecoderStatus_DecoderError;
    }
    self.decoderStatus = status;
    if (_status.isBackground){
        return;
    }
	
	[self.frameControlHandler syncDecoderStatus:status == DJIVideoDecoderStatus_Normal];
}

-(long long) getTickCount
{
    struct timeval t;
    gettimeofday(&t, NULL);
    long long uSec = t.tv_sec*1000*1000 + t.tv_usec;
    
    return uSec;
}

-(BOOL)tryRenderAction:(dispatch_block_t)action {
    BOOL shouldRender = NO;
    [_renderCond lock];
    if ([self glviewCanRender]) {
        _isRendering = YES;
        shouldRender = YES;
    }
    [_renderCond unlock];
    
    if (shouldRender) {
        SAFE_BLOCK(action);
        [_renderCond lock];
        _isRendering = NO;
        [_renderCond signal];
        [_renderCond unlock];
    }
    
    return shouldRender;
}

-(void) decodeRunloop
{
    [self.decodeRunloopBlocker lock];
    
    _status.isRunning = YES;
    _status.isFinish = NO;
    safe_resume_skip_count = 0;
    
    videoDecoderCanReset = NO;
    videoDecoderFailedCount = 0;
    
    BOOL stream_info_changed = YES; //need notify at the first time
    DJIVideoStreamBasicInfo current_stream_info = {0};
    memcpy(&current_stream_info, &_stream_basic_info, sizeof(DJIVideoStreamBasicInfo));
    
    while(![NSThread currentThread].isCancelled)
    {
        @autoreleasepool {
            //handle command
            [self.cmdQueue runloop];
            
            VideoFrameH264Raw* frameRaw = nil;
            int inputDataSize = 0;
            uint8_t *inputData = nil;
            
            int queueNodeSize;
#if __TEST_QUEUE_PULL__
            //Get the test data from the queue
            frameRaw = [self testQueuePull:&queueNodeSize];
#elif __TEST_FRAME_PULL__
            //Get test data frame
            frameRaw = [self testFramePull:&queueNodeSize];
#else
            
#if __TEST_PACK_PULL__
            [self testPackPull];
#endif
            //Normal access to data
            frameRaw = (VideoFrameH264Raw*)[_dataQueue pull:&queueNodeSize];
#endif
            
            if (frameRaw && frameRaw->frame_size + sizeof(VideoFrameH264Raw) == queueNodeSize) {
                inputData = frameRaw->frame_data;
                inputDataSize = frameRaw->frame_size;
            }
            [self updateDecoderStatus];
            
#if __TEST_FRAME_DUMP__
            if (!frameLayerDumper) {
                frameLayerDumper = [[DJIH264FrameRawLayerDumper alloc] init];
            }
            [frameLayerDumper dumpFrame:frameRaw];
#endif
            
            //for smooth decode
            double decodeStart = [DJIVideoPreviewSmoothHelper getTick];
            
            //sync config
            _glView.overExposedMark = _overExposedWarningThreshold;
            _glView.luminanceScale = _luminanceScale;
            _glView.enableFocusWarning = _enableFocusWarning;
            _glView.focusWarningThreshold = _focusWarningThreshold;
            _glView.dLogReverse = _dLogReverse;
            _glView.enableHSB = _enableHSB;
            _glView.hsbConfig = _hsbConfig;
            _glView.enableShadowAndHighLightenhancement = _enableShadowAndHighLightenhancement;
            _glView.shadowsLighten = _shadowsLighten;
            _glView.highlightsDecrease = _highlightsDecrease;
            
            if(inputData == NULL)
            {
                if (safe_resume_skip_count) {
                    //waiting for safe resume
                    _status.hasImage = NO; // no image, but it won't trigger the NoImage notification
                    continue;
                }
                
                videoDecoderCanReset = NO;
                
                [self tryRenderAction:^{
                    // render as grey when it is paused
                    _glView.grayScale = _grayOutPause;
                    [_glView render:nil];
                    _glView.grayScale = NO;
                }];
                
                if(_status.hasImage && !_status.isPause){
                    _status.hasImage = NO;
                    
                    if (self.isDefaultPreviewer) {
                        //only notify if this is default previewer
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:VIDEO_PREVIEWER_EVEN_NOTIFICATIOIN
                                                                                object:@(DJIVideoPreviewerEventNoImage)];
                        });
                    }
                }
                continue;
            }
            
            if(!_status.hasImage){
                _status.hasImage = YES;
                if (self.isDefaultPreviewer) {
                    //only notify if this is default previewer
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:VIDEO_PREVIEWER_EVEN_NOTIFICATIOIN
                                                                            object:@(DJIVideoPreviewerEventHasImage)];
                    });
                }
            }
            
            
            _stream_basic_info.frameRate = _customizedFramerate != 0 ? _customizedFramerate : frameRaw->frame_info.fps;
            _stream_basic_info.frameSize = CGSizeMake(frameRaw->frame_info.width, frameRaw->frame_info.height);
            
            
            if (memcmp(&current_stream_info, &_stream_basic_info, sizeof(current_stream_info)) !=0 ) {
                current_stream_info = _stream_basic_info;
                stream_info_changed = YES;
            }
            
            
            //notifiy rkvo
            if (stream_info_changed) {
                __weak DJIVideoPreviewer* target = self;
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                   target.currentStreamInfo = current_stream_info;
                               });
            }
            
            if (frameRaw->type_tag == TYPE_TAG_VideoFrameH264Raw) {
                
                //frame lost test
#if __TEST_FRAME_LOST__
                int goodCount = 300;
                int lostCount = 200;
                int badCount = 16;
                
                static int counter = 0;
                counter++;
                
                if (counter < goodCount) {
                    
                }
                else if(counter < goodCount+lostCount){
                    if (counter - goodCount < badCount/2
                        || counter > goodCount-lostCount - badCount/2) {
                        //bad frame
                        frameRaw->frame_size = frameRaw->frame_size/2;
                    }
                    else{
                        //lost frame
                        if (frameRaw) {
                            free(frameRaw);
                            frameRaw = NULL;
                        }
                        continue;
                    }
                }
                else{
                    counter = 0;
                }
#endif
                //decoder select
                if(_hw_decoder && !_hw_decoder.hardwareUnavailable && _enableHardwareDecode){
                    //decode use video toolbox
                    _hw_decoder.enabled = YES;
                    _hw_decoder.encoderType = _encoderType;
                    _hw_decoder.enableFastUpload = self.enableFastUpload;
                    _soft_decoder.enabled = NO;
                    
                    if (self.enableFastUpload) {
                        //fast upload，the output format is difference
                        self.frameOutputType = VPFrameTypeYUV420SemiPlaner;
                    }
                    else{
                        self.frameOutputType = VPFrameTypeYUV420Planer;
                    }
                }
                else{
                    _hw_decoder.enabled = NO;
                    _soft_decoder.enabled = YES;
                    self.frameOutputType = VPFrameTypeYUV420Planer;
                }
                
                // Phantom 4 workaround: frames of Phantom 4 may set the IDR
                // flag mistakenly. To be save, unset the IDR flag for all frames.
                if (_encoderType == H264EncoderType_1860_phantom4x) {
                    frameRaw->frame_info.frame_flag.has_idr = 0;
                }
                
                //rotation info set
                //will effect video cache system
                frameRaw->frame_info.rotate = _rotation;
                frameRaw->frame_info.frame_flag.channelType = _videoChannelTag;
                
                pthread_mutex_lock(&_processor_mutex);
                NSArray* streamProcessorCopyList = [NSArray arrayWithArray:_stream_processor_list];
                pthread_mutex_unlock(&_processor_mutex);
                
                //processors
                for (id<VideoStreamProcessor> processor in streamProcessorCopyList) {
                    if (![processor conformsToProtocol:@protocol(VideoStreamProcessor)]) {
                        continue;
                    }
                    
                    
                    if (stream_info_changed && [processor respondsToSelector:@selector(streamProcessorInfoChanged:)]) {
                        [processor streamProcessorInfoChanged:&current_stream_info];
                    }
                    
                    if (![processor streamProcessorEnabled]) {
                        continue;
                    }
                    
                    
                    DJIVideoStreamProcessorType processor_type = [processor streamProcessorType];
                    if (processor_type == DJIVideoStreamProcessorType_Decoder) {
                        //A decoder having a special treatment
                        if(!_status.isBackground){ //Background without decoding
#if __TEST_VIDEO_STUCK__
                            [DJIVideoStuckTester startDecodeFrameWithIndex:frameRaw->frame_uuid];
#endif
                            bool isSuccess = false;
                            if ([processor streamProcessorHandleFrameRaw:frameRaw]) {
                                //success decoding! reset failCount
                                videoDecoderFailedCount = 0;
                                
                                videoDecoderCanReset = YES;
                                isSuccess = true;
                            }else{
#if __TEST_VIDEO_STUCK__
                                [DJIVideoStuckTester finisedDecodeFrameWithIndex:frameRaw->frame_uuid withState:false];
#endif
                                frameRaw->frame_info.frame_flag.incomplete_frame_flag = 1;
                                [self videoProcessFailedFrame:frameRaw];
                            }
                        }
                    }
                    else if(processor_type == DJIVideoStreamProcessorType_Modify
                            || processor_type == DJIVideoStreamProcessorType_Passthrough){
                        //It does not affect the subsequent processor
                        [processor streamProcessorHandleFrameRaw:frameRaw];
                        //[processor streamProcessorHandleFrame:inputData size:inputDataSize];
                    }
                    else if (processor_type == DJIVideoStreamProcessorType_Consume){
                        //consume not in need of a last copy data
                        VideoFrameH264Raw* data_copy = (VideoFrameH264Raw*)malloc(queueNodeSize);
                        memcpy(data_copy, frameRaw, queueNodeSize);
                        if (![processor streamProcessorHandleFrameRaw:data_copy]) {
                            free(data_copy);
                        }
                    }
                }
            }
            
            //cleanups
            stream_info_changed = NO;
            
            if (self.isPerformanceCountEnabled) {
                [self performanceCount:inputDataSize];
            }
            
            //Performance Testing
            if(safe_resume_skip_count){
                safe_resume_skip_count--;
                //DJILog(@"safe resume frame:%d", safe_resume_skip_count);
                if (safe_resume_skip_count == 0) { //Recovering from decoding pause
                    DJILOG(@"safe resume complete");
                    
                    if (self.isDefaultPreviewer) {
                        //only notify if this is default previewer
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:VIDEO_PREVIEWER_EVEN_NOTIFICATIOIN object:@(DJIVideoPreviewerEventResumeReady)];
                        });
                    }
                }
            }
            
            if(self.smoothDecode){
                //Decoding Smoothing
                double current = [DJIVideoPreviewSmoothHelper getTick];
                double sleepTime = [self.smoothDecode sleepTimeForCurrentFrame:[self getTickCount]/1000000.0
                                                          framePushInQueueTime:frameRaw->time_tag/1000000.0
                                                                decodeCostTime:current-decodeStart];
                
                uint32_t sleepTimeUS = MIN(sleepTime*1000000, 180*1000);
                usleep(sleepTimeUS);
            }
            
            if (frameRaw) {
                free(frameRaw);
                frameRaw = NULL;
            }
        }
    }
    
    [self clearPocBuffer];
    _status.isFinish = YES;
    
    [self.decodeRunloopBlocker unlock];
}

// This method has to be executed with render mutex locked.
-(void) decoderRenderFrame:(VideoFrameYUV*)frame{
    //Out frame processing
    BOOL dropFrame = NO;
    NSUInteger basicBufferedFrameCount = ceil([self.smoothDecode frameBuffered]);
    
    if (self.dataQueue.count >= 2*RENDER_DROP_THRESHOLD + basicBufferedFrameCount)
    {
        if (glViewRenderFrameCount% 3!=0) {
            dropFrame = YES;
        }
    }
    else if(self.dataQueue.count > RENDER_DROP_THRESHOLD + basicBufferedFrameCount)
    {
        if (glViewRenderFrameCount%2 != 0) {
            dropFrame = YES;
        }
    }
    
    if (!dropFrame) {
        if (frame->frame_info.assistInfo.has_time_stamp) {
            self.globalTimeStamp = frame -> frame_info.assistInfo.timestamp;
        }
        else {
            self.globalTimeStamp = 0;
        }
        [_glView render:frame];
    }
    glViewRenderFrameCount++;
}

#pragma mark - command queue
-(void) workInRenderQueue:(void(^)(void))operation{
    DJIAsyncCommandObject* cmd = [DJIAsyncCommandObject commandWithTag:nil afterDate:nil block:^(DJIAsyncCommandObjectWorkHint hint) {
        SAFE_BLOCK(operation);
    }];
    [self.cmdQueue pushCommand:cmd withOption:DJIAsyncCommandOption_FIFO];
    
    //wakeup render
    [self.dataQueue wakeupReader];
}

#pragma mark - glview frame change

-(void) movieGlView:(DJIMovieGLView *)view didChangedFrame:(CGRect)frame{
    self.frame = frame;
}

#pragma mark - lb2 workaround delegate

-(void) lb2AUDRemoveParser:(id)parser didParsedData:(void *)data size:(int)size{
    
#if __LB2_PARSER_DUMP__
    if(!lb2Dumper){
        lb2Dumper = [[DJIDataDumper alloc] init];
        lb2Dumper.namePerfix = @"lb2_workaround";
    }
    
    [lb2Dumper dumpData:data length:size];
#endif
    
    [_videoExtractor parseVideo:data length:size withFrame:^(VideoFrameH264Raw *frame) {
        if (!frame) {
            return;
        }
        
        if (self.dataQueue.count > FRAME_DROP_THRESHOLD) {
            DJILOG(@"decode dataqueue drop %d", FRAME_DROP_THRESHOLD);
            [self.smoothDecode resetSmooth];
            [self.dataQueue clear];
        }
        
        frame->time_tag = [self getTickCount];
        [self.dataQueue push:(uint8_t*)frame length:sizeof(VideoFrameH264Raw) + frame->frame_size];
    }];
}

#pragma mark - frame processor interface

-(BOOL) videoProcessorEnabled
{
    return YES;
}

-(void) videoProcessFrame:(VideoFrameYUV *)frame{
    _lastFrameDecodedTime = [self getTickCount];
    
    if (safe_resume_skip_count || _status.isPause) {
        //Decoding need to skip a certain number of frames
        return;
    }
	
    if (frame != NULL &&
		frame->frame_info.assistInfo.timestamp != 0){
		if (self.frameControlHandler && [self.frameControlHandler respondsToSelector:@selector(decodingDidSucceedWithTimestamp:)]) {
			[self.frameControlHandler decodingDidSucceedWithTimestamp:frame->frame_info.assistInfo.timestamp];
		}
		
    }
    if (frame != NULL
        && frame->frame_info.assistInfo.should_ignore != 0
        && frame->frame_info.assistInfo.force_30_fps != 0){
        //skip this frame for keep 30fps
        return;
    }
    
    /*
     -----------------------------------------------------------
	 Here we monitor the real-time frame rate as a parameter to the encoder for encoder-related services (video buffer, no SD card recording, live broadcast, quickmovie)
     This value is currently used by the encoder. You cannot write this value directly to streamInfo.fps because the measurement fluctuation will cause stream_info_changed to trigger, thus resetting the decoder.
     -----------------------------------------------------------
     */
    if (self.detectRealtimeFrameRate) {
        [self.frameRateMonitor newFrameArrived];
        self.realTimeFrameRate = [self.frameRateMonitor realTimeFrameRate];
    }
    // 保险起见，这里也把realTimeFrameRate写成streamInfo中的值吧
    else {
        self.realTimeFrameRate = self.currentStreamInfo.frameRate;
    }
    
    //poc process
    int pocSize  = self.pocBufferSize;
    if (__TEST_REORDER__) {
        pocSize = __TEST_REORDER__;
    }
    
    BOOL needReleaseFrame = NO;
    if (pocSize != 0 && frame->cv_pixelbuffer_fastupload) {
        
        if (!self.pocQueue) {
            //Do not need thread safety, operate in one thread
            self.pocQueue = [[DJIH264PocQueue alloc] initWithSize:pocSize
                                                       threadSafe:NO];
        }
        if (!self.pocMemCache){
            //Do not need thread safety, operate in one thread
            self.pocMemCache = [[DJIH264PocQueue alloc] initWithSize:INT_MAX
                                                          threadSafe:NO];
        }
        
        //create poc buffer
        while (self.pocQueue.count >= pocSize) {
            //pop
            VideoFrameYUV* pop = [self.pocQueue pull];
            if (pop == NULL){
                continue;
            }
            if (pop->cv_pixelbuffer_fastupload) {
                CVPixelBufferRelease(pop->cv_pixelbuffer_fastupload);
            }
            memset(pop,0,sizeof(VideoFrameYUV));
            BOOL isOk = [self.pocMemCache push:pop];//Memory recycling
            if (!isOk){
                free(pop);
                pop = NULL;
            }
        }
        VideoFrameYUV* push = NULL;
        do{
            if (self.pocMemCache.count <= 0){
                break;
            }
            push = [self.pocMemCache pull];
        }while (push == NULL);
        
        //push into buffer, only support fastupload
        if (push == NULL){
            push = (VideoFrameYUV*) malloc(sizeof(VideoFrameYUV));
        }
        memcpy(push, frame, sizeof(VideoFrameYUV));
        CVPixelBufferRetain(push->cv_pixelbuffer_fastupload);
        BOOL isOk = [self.pocQueue push:push];
        if (!isOk){
            if (push != NULL
                && push->cv_pixelbuffer_fastupload) {
                CVPixelBufferRelease(push->cv_pixelbuffer_fastupload);
            }
            free(push);
            push = NULL;
        }
        
        if (self.pocQueue.count >= pocSize) {
            //pop
            frame = [self.pocQueue pull];
            needReleaseFrame = YES;
        }else{
            return;
        }
    } //if (pocSize != 0 && frame->cv_pixelbuffer_fastupload)
    
    //image distoration calibration control
    if ([self shouldCreateCalibrateHelper]){
        DJIImageCalibrateHelper* helper = [self getCalibrateHelper];
        if (frame != NULL
            && frame->frame_info.assistInfo.has_lut_idx != 0){
            if (helper != nil){
                if (helper.handler != self){
                    helper.handler = self;
                }
                DJIImageCalibrateFilterDataSource* dataSource = [self calibrateDataSource];
                if ([helper independancyWithReander]){
                    //Independent correction logic, after the correction continues to move moviegview render and other processors
                    //for test only!!!
                    _glView.calibrateEnabled = NO;
                    _glView.lutIndex = 0;
                    _glView.colorConverter.enabledConverter = NO;
                    if ([helper isKindOfClass:[DJIDecodeImageCalibrateHelper class]]){
                        DJIDecodeImageCalibrateHelper* standAloneHelper = (DJIDecodeImageCalibrateHelper*)helper;
                        standAloneHelper.enabledColorSpaceConverter = YES;
                        DJILiveViewCalibrateFilter* filter = [standAloneHelper calibrateFilter];
                        if (filter != nil){
                            filter.idx = frame->frame_info.assistInfo.lut_idx;
                            filter.fovState = frame->frame_info.assistInfo.fov_state;
                            filter.dataSource = dataSource;
                        }
                    }
                }
                else {
                    //Mix the render correction logic, complete the correction in the movieglview, and correct the transfer to other processors.
                    _glView.calibrateEnabled = YES;
                    if (_glView.calibrateFilter != nil && _glView.calibrateFilter.dataSource != dataSource){
                        _glView.calibrateFilter.dataSource = dataSource;
                    }
#if !__USE_PIXELBUFFER_PROVIDER__
                    DJIImageCalibrateColorConverter* colorConverter = _glView.colorConverter;
                    if (colorConverter != nil && colorConverter.delegate != helper){
                        colorConverter.delegate = helper;
                    }
                    //Optimized to set to YES only when optimization is needed
                    _glView.colorConverter.enabledConverter = ([self frameProcessorCount] > 0);
#else
                    DJICalibratePixelBufferProvider* pixelBufferProvider = _glView.calibratePixelBufferProvider;
                    // The rendering step takes place in the following notifyRenderWithFrame:, where the frame is first passed to the provider to get the frameInfo.
                    // After the rendering starts, the frameBuffer will be passed into the pixelBufferProvider. When the VideoFrameYUV is assembled, the information will be taken out.
                    // Because this order is certain, it can be guaranteed that the pixelbuffer and frameInfo obtained are the correct number.
                    pixelBufferProvider.providerEnabled = ([self frameProcessorCount] > 0);
                    if (pixelBufferProvider.providerEnabled) {
                        [pixelBufferProvider updateFrameInfoWithFrameYUV:frame];
                    }
                    if (pixelBufferProvider != nil && pixelBufferProvider.delegate != self) {
                        pixelBufferProvider.delegate = self;
                    }
#endif
                    _glView.lutIndex = frame->frame_info.assistInfo.lut_idx;
                    _glView.fovState = frame->frame_info.assistInfo.fov_state;
                }
                
                if ([helper independancyWithReander]){
                    [helper pushFrame:frame];
                }
                else{
                    [helper updateFrame:frame];
                    [self notifyRenderWithFrame:frame];
                }
                if (needReleaseFrame){
                    [self releaseFrame:frame];
                }
                [helper handlePullFrame];
            }
            else {
                _glView.lutIndex = 0;
                _glView.fovState = DJISEIInfoLiveViewFOVState_GDC_No_Needed;
                _glView.calibrateEnabled = NO;
            }
        }
        else {
            //no need to calibrate
            _glView.calibrateEnabled = NO;
            _glView.lutIndex = 0;
            _glView.fovState = DJISEIInfoLiveViewFOVState_GDC_No_Needed;
            _glView.colorConverter.enabledConverter = NO;
            _glView.calibratePixelBufferProvider.providerEnabled = NO;
            [self internalProcessFrame:frame needReleased:needReleaseFrame];
            if (helper != nil){
                helper.handler = nil;
                [helper handlePullFrame];//If there are still cached frames before, you need to clear.
            }
        }
    }
    else {
        //without calibrate
        [self removeCalibrateHelper];
        _glView.calibrateEnabled = NO;
        _glView.lutIndex = 0;
        _glView.fovState = DJISEIInfoLiveViewFOVState_GDC_No_Needed;
        _glView.colorConverter.enabledConverter = NO;
        _glView.calibratePixelBufferProvider.providerEnabled = NO;
        [self internalProcessFrame:frame needReleased:needReleaseFrame];
    }
}

#pragma mark - calibratePixelBufferProviderDelegate

- (void)calibratePixelBufferProviderDidOutputFrame:(VideoFrameYUV *)frame {
    pthread_mutex_lock(&_processor_mutex);
    NSArray* frameProcessorCopyList = [NSArray arrayWithArray:_frame_processor_list];
    pthread_mutex_unlock(&_processor_mutex);
    for (id<VideoFrameProcessor> processor in frameProcessorCopyList) {
        if ([processor conformsToProtocol:@protocol(VideoFrameProcessor)]) {
            if (![processor videoProcessorEnabled]) {
                continue;
            }
            [processor videoProcessFrame:frame];
        }
    }
}

#pragma mark - calibration helper delegate

-(BOOL)shouldCreateCalibrateHelper{
    id<DJIImageCalibrateDelegate> calibrateDelegate = self.calibrateDelegate;
    if (calibrateDelegate != nil && [calibrateDelegate respondsToSelector:@selector(helperCreated)]){
        return [calibrateDelegate shouldCreateHelper];
    }
    return NO;
}

-(DJIImageCalibrateHelper*)getCalibrateHelper{
    id<DJIImageCalibrateDelegate> calibrateDelegate = self.calibrateDelegate;
    if (calibrateDelegate != nil
        && [calibrateDelegate respondsToSelector:@selector(helperCreated)]){
        return [calibrateDelegate helperCreated];
    }
    return nil;
}

-(void)removeCalibrateHelper{
    id<DJIImageCalibrateDelegate> calibrateDelegate = self.calibrateDelegate;
    if (calibrateDelegate != nil && [calibrateDelegate respondsToSelector:@selector(destroyHelper)]){
        [calibrateDelegate destroyHelper];
    }
}

-(DJIImageCalibrateFilterDataSource*)calibrateDataSource{
    id<DJIImageCalibrateDelegate> calibrateDelegate = self.calibrateDelegate;
    if (calibrateDelegate != nil
        && [calibrateDelegate respondsToSelector:@selector(calibrateDataSource)]){
        return [calibrateDelegate calibrateDataSource];
    }
    return nil;
}

#pragma mark - calibrate handler
-(void)newFrame:(VideoFrameYUV*)frame arrivalFromHelper:(DJIImageCalibrateHelper*)helper{
    if (frame == NULL || helper == nil){
        return;
    }
    if ([helper independancyWithReander]){
        [self internalProcessFrame:frame needReleased:NO];
    }
    else {
        [self notifyProcessorsWithFrame:frame];
    }
}

#pragma mark - frame render and processing

-(void)releaseFrame:(VideoFrameYUV*)frame{
    if (frame == NULL){
        return;
    }
    if (frame->cv_pixelbuffer_fastupload) {
        CVPixelBufferRelease(frame->cv_pixelbuffer_fastupload);
    }
    memset(frame,0,sizeof(VideoFrameYUV));
    BOOL isOk = [self.pocMemCache push:frame];
    if (!isOk){
        free(frame);
        frame = NULL;
    }
}

-(void)internalProcessFrame:(VideoFrameYUV*)frame
               needReleased:(BOOL)needReleaseFrame{
    [self notifyRenderWithFrame:frame];
    [self notifyProcessorsWithFrame:frame];
    if (needReleaseFrame) {
        [self releaseFrame:frame];
    }
}

-(void)notifyRenderWithFrame:(VideoFrameYUV*)frame{
    if (frame == NULL){
        return;
    }
    DJIImageCalibrateHelper* helper = nil;
    BOOL shouldHaveHelper = [self shouldCreateCalibrateHelper];
    if (shouldHaveHelper){
        helper = [self getCalibrateHelper];
    }
    if (helper != nil
        && shouldHaveHelper){
        [helper renderLockStatus:YES];
    }
    [self tryRenderAction:^{
        [self decoderRenderFrame:frame];
    }];
    if (helper != nil
        && shouldHaveHelper){
        [helper renderLockStatus:NO];
    }
}

-(void)notifyProcessorsWithFrame:(VideoFrameYUV*)frame{
    if (frame == NULL){
        return;
    }
    DJIImageCalibrateHelper* helper = nil;
    BOOL shouldHaveHelper = [self shouldCreateCalibrateHelper];
    if (shouldHaveHelper){
        helper = [self getCalibrateHelper];
    }
    // If you do not take the calibratePixelBufferProvider path, then notify VideoFrameProcessor here
    // If you follow the calibratePixelBufferProvider path, notify in the calibratePixelBufferProviderDidOutputFrame: method
    DJICalibratePixelBufferProvider* provider = _glView.calibratePixelBufferProvider;
    if (provider == nil || provider.delegate != self || provider.providerEnabled == NO) {
        if (helper != nil
            && shouldHaveHelper){
            [helper renderLockStatus:YES];
        }
        pthread_mutex_lock(&_processor_mutex);
        NSArray* frameProcessorCopyList = [NSArray arrayWithArray:_frame_processor_list];
        pthread_mutex_unlock(&_processor_mutex);
        for (id<VideoFrameProcessor> processor in frameProcessorCopyList) {
            if ([processor conformsToProtocol:@protocol(VideoFrameProcessor)]) {
                if (![processor videoProcessorEnabled]) {
                    continue;
                }
                [processor videoProcessFrame:frame];
            }
        }
        if (helper != nil
            && shouldHaveHelper){
            [helper renderLockStatus:NO];
        }
    }
}

//decode single frame failed.
- (void)videoProcessFailedFrame:(VideoFrameH264Raw*)frame{
    videoDecoderFailedCount++;
    if (videoDecoderFailedCount >= 6) {
        if (videoDecoderCanReset || _enableHardwareDecode){
            [self reset];
            videoDecoderCanReset = NO;
        }
        
        videoDecoderFailedCount = 0;
    }
    
    pthread_mutex_lock(&_processor_mutex);
    NSArray* frameProcessorCopyList = [NSArray arrayWithArray:_frame_processor_list];
    pthread_mutex_unlock(&_processor_mutex);
    
    for (id<VideoFrameProcessor> processor in frameProcessorCopyList) {
        if ([processor respondsToSelector:@selector(videoProcessFailedFrame:)]) {
            
            if (![processor videoProcessorEnabled]) {
                continue;
            }
            
            [processor videoProcessFailedFrame:frame];
        }
    }
}

#pragma mark - videotoolbox decode callback
//handle 264 frame output from videotoolbox
-(void) decompressedFrame:(CVImageBufferRef)image frameInfo:(VideoFrameH264Raw *)frame
{
    if (image == nil) {
#if __TEST_VIDEO_STUCK__
        if (frame != NULL)
        {
            [DJIVideoStuckTester finisedDecodeFrameWithIndex:frame->frame_uuid withState:false];
        }
#endif
        [self videoProcessFailedFrame:frame];
        return;
    }
#if __TEST_VIDEO_STUCK__
    if (frame != NULL)
    {
        [DJIVideoStuckTester finisedDecodeFrameWithIndex:frame->frame_uuid withState:true];
    }
#endif
    //check status
    if(_status.isPause || _status.isBackground){
        return;
    }
    
    [self processDecompressedFrame:image
                         frameInfo:frame];
}

-(void)processDecompressedFrame:(CVImageBufferRef)image
                      frameInfo:(VideoFrameH264Raw *)frame{
    CFTypeID imageType = CFGetTypeID(image);
    if (imageType == CVPixelBufferGetTypeID()
        && (kCVPixelFormatType_420YpCbCr8Planar == CVPixelBufferGetPixelFormatType(image)
            || kCVPixelFormatType_420YpCbCr8PlanarFullRange == CVPixelBufferGetPixelFormatType(image))) {
            //make sure this is a yuv420 image
            CGSize size = CVImageBufferGetDisplaySize(image);
            if(kCVReturnSuccess != CVPixelBufferLockBaseAddress(image, 0)){
                return;
            }
            
            VideoFrameYUV yuvImage = {0};
            yuvImage.luma = CVPixelBufferGetBaseAddressOfPlane(image, 0);
            yuvImage.chromaB = CVPixelBufferGetBaseAddressOfPlane(image, 1);
            yuvImage.chromaR = CVPixelBufferGetBaseAddressOfPlane(image, 2);
            yuvImage.lumaSlice = (int)CVPixelBufferGetBytesPerRowOfPlane(image, 0);
            yuvImage.chromaBSlice = (int)CVPixelBufferGetBytesPerRowOfPlane(image, 1);
            yuvImage.chromaRSlice = (int)CVPixelBufferGetBytesPerRowOfPlane(image, 2);
            yuvImage.width = size.width;
            yuvImage.height = size.height;
            yuvImage.frame_uuid = -1;
            yuvImage.frame_info.frame_index = H264_FRAME_INVALIED_UUID;
            if (frame != NULL
                && frame->frame_info.assistInfo.has_lut_idx != 0){
                //copy lut index info for image calibration
                yuvImage.frame_info.assistInfo.lut_idx = frame->frame_info.assistInfo.lut_idx;
                yuvImage.frame_info.assistInfo.has_lut_idx = frame->frame_info.assistInfo.has_lut_idx;
                yuvImage.frame_info.assistInfo.fov_state = frame->frame_info.assistInfo.fov_state;
            }
            else{
                yuvImage.frame_info.assistInfo.lut_idx = 0;
                yuvImage.frame_info.assistInfo.has_lut_idx = 0;
                yuvImage.frame_info.assistInfo.fov_state = DJISEIInfoLiveViewFOVState_Undefined;
            }
            
            if (frame != NULL
                && frame->frame_uuid != H264_FRAME_INVALIED_UUID) {
                yuvImage.frame_info = frame->frame_info;
                yuvImage.frame_uuid = frame->frame_uuid;
            }
            
            [self videoProcessFrame:&yuvImage];
            
            CVPixelBufferUnlockBaseAddress(image, 0);
        }
    else if (imageType == CVPixelBufferGetTypeID()
             && (kCVPixelFormatType_420YpCbCr8BiPlanarFullRange == CVPixelBufferGetPixelFormatType(image)
                 || kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange == CVPixelBufferGetPixelFormatType(image))) {
                 
                 CGSize size = CVImageBufferGetDisplaySize(image);
                 if(kCVReturnSuccess != CVPixelBufferLockBaseAddress(image, 0)){
                     return;
                 }
                 
                 VideoFrameYUV yuvImage = {0};
                 yuvImage.luma = CVPixelBufferGetBaseAddressOfPlane(image, 0);
                 yuvImage.chromaB = CVPixelBufferGetBaseAddressOfPlane(image, 1);
                 yuvImage.lumaSlice = (int)CVPixelBufferGetBytesPerRowOfPlane(image, 0);
                 yuvImage.chromaBSlice = (int)CVPixelBufferGetBytesPerRowOfPlane(image, 1);
                 yuvImage.width = size.width;
                 yuvImage.height = size.height;
                 yuvImage.frame_uuid = -1;
                 yuvImage.frameType = VPFrameTypeYUV420SemiPlaner;
                 yuvImage.frame_info.frame_index = H264_FRAME_INVALIED_UUID;
                 if (frame != NULL
                     && frame->frame_info.assistInfo.has_lut_idx != 0){
                     //copy lut index info for image calibration
                     yuvImage.frame_info.assistInfo.lut_idx = frame->frame_info.assistInfo.lut_idx;
                     yuvImage.frame_info.assistInfo.has_lut_idx = frame->frame_info.assistInfo.has_lut_idx;
                     yuvImage.frame_info.assistInfo.fov_state = frame->frame_info.assistInfo.fov_state;
                 }
                 else{
                     yuvImage.frame_info.assistInfo.lut_idx = 0;
                     yuvImage.frame_info.assistInfo.has_lut_idx = 0;
                     yuvImage.frame_info.assistInfo.fov_state = DJISEIInfoLiveViewFOVState_Undefined;
                 }
                 
                 if (frame != NULL
                     && frame->frame_uuid != H264_FRAME_INVALIED_UUID) {
                     yuvImage.frame_info = frame->frame_info;
                     yuvImage.frame_uuid = frame->frame_uuid;
                 }
                 yuvImage.cv_pixelbuffer_fastupload = image;
                 [self videoProcessFrame:&yuvImage];
                 
                 CVPixelBufferUnlockBaseAddress(image, 0);
             }
}

-(void) hardwareDecoderUnavailable{
    //use soft decoder
    self.enableHardwareDecode = NO;
}

-(void) clearPocBuffer{
    //only support fastupload
    
    if (nil != self.pocMemCache){
        VideoFrameYUV* frame = (VideoFrameYUV*)[self.pocMemCache pull];
        while (frame) {
            free(frame);
            frame = [self.pocMemCache pull];
        }
    }
    
    if (nil != self.pocQueue) {
        VideoFrameYUV* frame = (VideoFrameYUV*)[self.pocQueue pull];
        while (frame) {
            if (frame) {
                if (frame->cv_pixelbuffer_fastupload) {
                    CVPixelBufferRelease(frame->cv_pixelbuffer_fastupload);
                }
            }
            free(frame);
            frame = [self.pocQueue pull];
        }
    }
}

#pragma mark - Frame Extractor Delegate

- (BOOL)parseDecodingAssistInfoWithBuffer:(uint8_t *)buffer length:(int)length assistInfo:(DJIDecodingAssistInfo *)assistInfo {
	if (self.frameControlHandler && [self.frameControlHandler respondsToSelector:@selector(parseDecodingAssistInfoWithBuffer:length:assistInfo:)]) {
		return [self.frameControlHandler parseDecodingAssistInfoWithBuffer:buffer length:length assistInfo:assistInfo];
	}
	return YES;
}

- (BOOL)isNeedFitFrameWidth {
	if (self.frameControlHandler && [self.frameControlHandler respondsToSelector:@selector(isNeedFitFrameWidth)]) {
		return [self.frameControlHandler isNeedFitFrameWidth];
	}
	return NO;
}


- (void)frameExtractorDidFailToParseFrames:(DJICustomVideoFrameExtractor *)extractor {
	if (self.frameControlHandler && [self.frameControlHandler respondsToSelector:@selector(decodingDidFail)]) {
		[self.frameControlHandler decodingDidFail];
	}
}

#pragma mark - tests

static FILE* g_fp = nil;
static uint8_t* g_pBuffer = nil;
static DJIVideoPreviewerH264Parser* g_testParser = nil;

#if __WAIT_STEP_FRAME__
dispatch_semaphore_t g_restart_wait = 0;
#endif

-(uint8_t*) testQueuePull:(int*)size{
    int frameSize = 2048;
    
    if (!g_fp) {
        NSArray* doucuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* filePath = [doucuments objectAtIndex:0];
        
        filePath = [filePath stringByAppendingPathComponent:@"out1.bin"];
        g_fp = fopen([filePath UTF8String], "rb");
        g_pBuffer = (uint8_t*)malloc(frameSize);
    }
    
    if (!g_testParser) {
        g_testParser = [[DJIVideoPreviewerH264Parser alloc] init];
    }
    
#if __WAIT_STEP_FRAME__
    if (g_restart_wait == 0) {
        g_restart_wait = dispatch_semaphore_create(0);
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleTestNotification:)
                                                     name:@"preview"
                                                   object:nil];
    }
    
#endif
    
    while (g_fp)
    {
        static int read_size = 0;
        static int parse_size = 0;
        static int frame_counter = 0;
        
        while (!feof(g_fp)) {
            
            VideoFrameH264Raw* outframe = nil;
            int outframeSize = 0;
            
            size_t nRead = fread(g_pBuffer, 1, frameSize, g_fp);
            //                        [[[DJIVideoPreviewer instance] dataQueue] push:pBuffer length:nRead];
            
            
            int parseLength = 0;
            outframe = [g_testParser parseVideo:g_pBuffer length:(int)nRead usedLength:&parseLength];
            
            if (parseLength != 0 && parseLength < nRead) {
                nRead = parseLength;
                fseek(g_fp, read_size+parseLength, SEEK_SET);
            }
            
            read_size += nRead;
            
            if (outframe) {
                self.encoderType = H264EncoderType_unknown;
                self.enableHardwareDecode = YES;
                outframeSize = sizeof(VideoFrameH264Raw) + outframe->frame_size;
                *size = outframeSize;
                
#if __WAIT_STEP_FRAME__
                dispatch_semaphore_wait(g_restart_wait, DISPATCH_TIME_FOREVER);
                NSLog(@"frame %d offset:%p", frame_counter, parse_size);
#endif
                parse_size += outframeSize;
                frame_counter ++;
                return (uint8_t*)outframe;
            }
        }
        
        read_size = 0;
        parse_size = 0;
        frame_counter = 0;
        fseek(g_fp, 0, SEEK_SET);
        [_hw_decoder resetInDecodeThread];
        [g_testParser reset];
    }
    return nil;
}

#if __WAIT_STEP_FRAME__
-(void) handleTestNotification:(NSNotification*)notify{
    
    if ([notify.object isEqualToString:@"start"]) {
        
        if (g_restart_wait) {
            dispatch_semaphore_signal(g_restart_wait);
        }
    }
}
#endif

#if __TEST_FRAME_PULL__
static DJIH264FrameRawLayerDumper* g_frameReader = nil;

-(VideoFrameH264Raw*) testFramePull:(int*)size{
    static DJIDataDumper* dumper = nil;
    
    if (!g_frameReader) {
        g_frameReader = [[DJIH264FrameRawLayerDumper alloc] init];
        [g_frameReader openFile:@"h264frame_2016-05-06[10][29][48][372]_clip.bin"];
        //dumper = [[DJIDataDumper alloc] init];
        //dumper.namePerfix = @"frame_out";
    }
    
#if __WAIT_STEP_FRAME__
    if (g_restart_wait == 0) {
        g_restart_wait = dispatch_semaphore_create(0);
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleTestNotification:)
                                                     name:@"preview"
                                                   object:nil];
    }
    dispatch_semaphore_wait(g_restart_wait, DISPATCH_TIME_FOREVER);
#endif
    
    VideoFrameH264Raw* frame = [g_frameReader readNextFrame];
    if (!frame) {
        [g_frameReader seekToHead];
        return nil;
    }
    
    [dumper dumpData:frame->frame_data length:frame->frame_size];
    
    self.encoderType = H264EncoderType_H1_Inspire2;
    *size = (int)frame->frame_size + (int)sizeof(VideoFrameH264Raw);
    return frame;
}

static NSThread* g_pack_pull_test_thread;

-(void) testPackPull{
    if (g_pack_pull_test_thread) {
        return;
    }
    
    g_pack_pull_test_thread = [[NSThread alloc] initWithTarget:self
                                                      selector:@selector(packPullThreadWork)
                                                        object:nil];
    [g_pack_pull_test_thread start];
}

-(void) packPullThreadWork{
    DJIDataDumper* dumper = [[DJIDataDumper alloc] init];
    if (![dumper openFile:@"videoPack_2016-09-24[21][12][15][720].bin" withPackAlignMode:YES]) {
        return;
    }
    
    size_t data_counter = 0;
    size_t pack_counter = 0;
    
    while (1) {
        @autoreleasepool {
            if (self.dataQueue.count > 3) {
                usleep(5000);
                continue;
            }
            
            size_t size = 0;
            uint8_t* data = [dumper readNextPack:&size];
            pack_counter++;
            data_counter += size;
            
            if (data && size) {
                self.encoderType = H264EncoderType_LightBridge2;
                [self push:data length:(int)size];
            }
            else{
                [dumper seekToHead];
                pack_counter = 0;
                data_counter = 0;
#if __WAIT_STEP_FRAME__
                if (g_restart_wait == 0) {
                    g_restart_wait = dispatch_semaphore_create(0);
                    [[NSNotificationCenter defaultCenter] addObserver:self
                                                             selector:@selector(handleTestNotification:)
                                                                 name:@"preview"
                                                               object:nil];
                }
                dispatch_semaphore_wait(g_restart_wait, DISPATCH_TIME_FOREVER);
#endif
            }
            
            if (data) {
                free(data);
            }
        }
        usleep(2000);
    }
}

#endif

-(void) performanceCount:(int)inputDataSize {
    static NSDate* startTime = nil;
    static int video_last_count_time = 0;
    CGFloat _outputFps;
    int _outputKbitPerSec;
    
    if (startTime == nil) {
        startTime = [NSDate date];
    }
    
    //status check
    int tEndTime = (1000*(-[startTime timeIntervalSinceNow]));
    {
        static int frame_count = 0;
        static int bits_count = 0;
        
        frame_count++;
        bits_count += inputDataSize*8;
        
        int diff = (int)((tEndTime - video_last_count_time));
        if (diff >= 1000) {
            _outputFps = 1000*frame_count/(double)diff;
            _outputKbitPerSec = (1000/(double)1024)*(bits_count/(double)diff);
            
            DJILOG(@"fps:%.2f rate:%dkbps buffer:%d", _outputFps, _outputKbitPerSec, (int)_dataQueue.count);
            
            frame_count = 0;
            bits_count = 0;
            video_last_count_time = tEndTime;
        }
    }
}

@end
