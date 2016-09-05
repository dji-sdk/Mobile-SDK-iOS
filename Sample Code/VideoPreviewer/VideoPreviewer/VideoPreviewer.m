//
//  VideoPreviewer.m
//
//  Copyright (c) 2013 DJI. All rights reserved.
//

#import "VideoPreviewer.h"
#import <sys/time.h>
#include <OpenGLES/ES2/gl.h>
#import "SoftwareDecodeProcessor.h"
#import "LB2AUDHackParser.h"
#import "H264VTDecode.h"
#import "DJISDK/DJISDK.h"

#define BEGIN_DISPATCH_QUEUE dispatch_async(_dispatchQueue, ^{
#define END_DISPATCH_QUEUE   });
#define __TEST_VIDEO_DELAY__ 0

#if __TEST_VIDEO_DELAY__
#import "DJITestDelayLogic.h"
#endif

@interface VideoPreviewer () <H264DecoderOutput, LB2AUDHackParserDelegate>{
    NSThread *_decodeThread;
    MovieGLView *_glView;
    
    BOOL videoDecoderCanReset;
    int videoDecoderFailedCount;
    int safe_resume_skip_count;
    
    DJIVideoStreamBasicInfo _stream_basic_info;
    pthread_mutex_t _processor_mutex;
    pthread_mutex_t _render_mutex;
    
    long long _lastDataInputTime;
    long long _lastFrameDecodedTime;
}

@property (assign, nonatomic) BOOL enableHardwareDecode;

@property (assign,nonatomic) H264EncoderType encoderType;

//hardware decode use videotool box on ios8
@property (strong, nonatomic) H264VTDecode *hw_decoder;
//software decoder use ffmpeg
@property (strong, nonatomic) SoftwareDecodeProcessor* soft_decoder;

@property (assign, nonatomic) VideoDecoderStatus decoderStatus;

@property (assign, nonatomic) VPFrameType frameOutputType;
//stream processor list
@property (strong, nonatomic) NSMutableArray* stream_processor_list;
@property (strong, nonatomic) NSMutableArray* frame_processor_list;
@property (assign, nonatomic) BOOL grayOutPause;


//remove the redundant aud in LB2's stream
@property (strong, nonatomic) LB2AUDHackParser* lb2Hack;
@end

@implementation VideoPreviewer
{
    dispatch_queue_t _dispatchQueue;
}

-(id)init
{
    self= [super init];
    
    memset(&_stream_basic_info, 0, sizeof(_stream_basic_info));
    _stream_basic_info.frameRate = 30;
    _stream_basic_info.encoderType = H264EncoderType_DM368_inspire;
    
    _dispatchQueue = dispatch_queue_create("video_previewer_async_queue", DISPATCH_QUEUE_SERIAL);
    
    _decodeThread = nil;
    _glView = nil;
    _dataQueue = [[VideoPreviewerQueue alloc] initWithSize:100];
    _videoExtractor = [[VideoFrameExtractor alloc] initExtractor];
    _stream_processor_list = [[NSMutableArray alloc] init];
    _frame_processor_list = [[NSMutableArray alloc] init];
    pthread_mutex_init(&_processor_mutex, nil);
    pthread_mutex_init(&_render_mutex, nil);
    
    safe_resume_skip_count = 0;

    _type = VideoPreviewerTypeAutoAdapt;
    memset(&_status, 0, sizeof(VideoPreviewerStatus));
    _status.isInit = YES;
    _status.isRunning = NO;
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeGround:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    _decoderStatus = VideoDecoderStatus_Normal;
    
    _soft_decoder = [[SoftwareDecodeProcessor alloc] initWithExtractor:_videoExtractor];
    _soft_decoder.frameProcessor = self;
    
#if !TARGET_IPHONE_SIMULATOR
    
    if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
        //use hardware decode on ios8
        _hw_decoder = [[H264VTDecode alloc] init];
        _hw_decoder.delegate = self;
    }
#endif
    
    [self registStreamProcessor:_soft_decoder];
    [self registStreamProcessor:_hw_decoder];
    
    //rtmp server
    self.encoderType = H264EncoderType_DM368_inspire;
    
    //lb2 hack
    self.lb2Hack = [[LB2AUDHackParser alloc] init];
    self.lb2Hack.delegate = self;

    return self;
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

+(VideoPreviewer*) instance
{
    static VideoPreviewer* previewer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        previewer = [[VideoPreviewer alloc] init];
    });
    return previewer;
}

-(void) lb2AUDHackParser:(id)parser didParsedData:(void *)data size:(int)size{
    [_videoExtractor parseVideo:data length:size withFrame:^(VideoFrameH264Raw *frame) {
        if (!frame) {
            return;
        }
        
        if (self.dataQueue.count > 30) {
            NSLog(@"decode dataqueue drop");
            [self.dataQueue clear];
        }
        [self.dataQueue push:(uint8_t*)frame length:sizeof(VideoFrameH264Raw) + frame->frame_size];
    }];
}

- (CGRect) frame {
    if (!_glView) {
        return CGRectZero;
    }
    
    return [_glView frame];
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
    
    _lastDataInputTime = [self getTickCount]; // status purpose only
    if (_status.isRunning) {
        if (_encoderType == H264EncoderType_LightBridge2) {
            [_lb2Hack parse:videoData inSize:len];
        }else{
            [_videoExtractor parseVideo:videoData length:len withFrame:^(VideoFrameH264Raw *frame) {
                if (!frame) {
                    return;
                }
                
                if (self.dataQueue.count > 30) {
                    NSLog(@"decode dataqueue drop");
                    [self.dataQueue clear];
                }
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
}

-(BOOL)setView:(UIView *)view
{
    BEGIN_DISPATCH_QUEUE
    if(_glView == nil){
        _glView = [[MovieGLView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, view.frame.size.width, view.frame.size.height)];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_glView.superview != view){
            [view addSubview:_glView];
        }
        [view sendSubviewToBack:_glView];
        [_glView adjustSize];
        _status.isGLViewInit = YES;
    });
    END_DISPATCH_QUEUE
    return NO;
}

-(void)unSetView
{
    BEGIN_DISPATCH_QUEUE
    if(_glView != nil && _glView.superview !=nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_glView removeFromSuperview];
            //_glView = nil; // Robert:刻意不释放glView避免每次进入view时，画面闪烁的问题。
            _status.isGLViewInit = NO;
        });
    }
    END_DISPATCH_QUEUE
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
    BEGIN_DISPATCH_QUEUE
    if(_decodeThread == nil && !_status.isRunning)
    {
        _decodeThread = [[NSThread alloc] initWithTarget:self selector:@selector(decodeRunloop) object:nil];
        _decodeThread.qualityOfService = NSQualityOfServiceUserInteractive;
        [_decodeThread start];
    }
    END_DISPATCH_QUEUE
    return YES;
}

-(void) reset
{
    BEGIN_DISPATCH_QUEUE
    if(_decodeThread && _status.isRunning)
    {
        safe_resume_skip_count = 0;
        _status.isRunning = NO;
        while (!_status.isFinish) {
            usleep(10000);
        }
        [_decodeThread cancel];
        while (!_decodeThread.isFinished) {
            usleep(10000);
        }
        _decodeThread = nil;
        [_videoExtractor clearBuffer];
        [_dataQueue clear];
        _decodeThread = [[NSThread alloc] initWithTarget:self selector:@selector(decodeRunloop) object:nil];
        [_decodeThread start];
        
        if (_hw_decoder) {
            [_hw_decoder resetLater];
        }
        

        for (id<VideoStreamProcessor> processor in _stream_processor_list) {
            if ([processor respondsToSelector:@selector(streamProcessorReset)]) {
                [processor streamProcessorReset];
            }
        }
    }
    END_DISPATCH_QUEUE
}

- (void)resume{
    BEGIN_DISPATCH_QUEUE
    _status.isPause = NO;
    NSLog(@"Resume the decoding");
    END_DISPATCH_QUEUE
}

- (void)safeResume{
    NSLog(@"Try safe resuming");
    safe_resume_skip_count = 25;
    [self resume];
}

- (void)pause{
    [self pauseWithGrayout:YES];
}

- (void)pauseWithGrayout:(BOOL)isGrayout{
    BEGIN_DISPATCH_QUEUE
    _status.isPause = YES;
    _grayOutPause = isGrayout;
    NSLog(@"Pause decoding");
    [self.dataQueue wakeupReader];
    
    for (id<VideoStreamProcessor> processor in _stream_processor_list) {
        if ([processor respondsToSelector:@selector(streamProcessorPause)]) {
            [processor streamProcessorPause];
        }
    }
    END_DISPATCH_QUEUE
}

- (void)close{
    BEGIN_DISPATCH_QUEUE
    [_dataQueue clear];
    if(_decodeThread!=nil){
        [_decodeThread cancel];
    }
    _status.isRunning = NO;
    END_DISPATCH_QUEUE
}

- (void)setType:(VideoPreviewerType)type{
    if(_type == type)return;
    if(_glView == nil)return;
    BEGIN_DISPATCH_QUEUE
    pthread_mutex_lock(&_render_mutex);
    _type = type;
    if(_type == VideoPreviewerTypeFullWindow){
        [_glView setType:MovieGLViewTypeFullWindow];
        
        if ([self glviewCanRender]) {
            [_glView render:nil];
        }
    }
    else if(_type == VideoPreviewerTypeAutoAdapt){
        [_glView setType:MovieGLViewTypeAutoAdjust];
        
        if ([self glviewCanRender]) {
            [_glView render:nil];
        }
    }
    pthread_mutex_unlock(&_render_mutex);
    END_DISPATCH_QUEUE
}

- (BOOL) setDecoderWithProduct:(DJIBaseProduct*)product andDecoderType:(VideoPreviewerDecoderType)decoder {
    if (product == nil) {
        return NO;
    }
    
    NSString* stringName = product.model;
    
    if ([stringName isEqualToString:DJIAircraftModelNameUnknownAircraft]) {
        // determine if it is Lightbridge 2
        if ([product isKindOfClass:[DJIAircraft class]]) {
            DJIAircraft* aircraft = (DJIAircraft*)product;
            if (aircraft.airLink &&
                aircraft.airLink.lbAirLink &&
                ([aircraft.model isEqual:DJIAircraftModelNameA3] ||
                 [aircraft.model isEqual:DJIAircraftModelNameMatrice600] ||
                 [aircraft.model isEqual:DJIAircraftModelNameUnknownAircraft])) {
                self.enableHardwareDecode = NO;
                self.encoderType = H264EncoderType_LightBridge2;
                return YES;
            }
        }
        
        return NO;
    }
    
    // Otherwise, the decoder depends on the camera
    DJICamera* camera = nil;
    BOOL isHandheld = NO;
    if ([product isKindOfClass:[DJIAircraft class]]) {
        DJIAircraft* aircraft = (DJIAircraft*)product;
        camera = aircraft.camera;
        isHandheld = NO;
    }
    else if ([product isKindOfClass:[DJIHandheld class]]) {
        DJIHandheld* handheld = (DJIHandheld*)product;
        camera = handheld.camera;
        isHandheld = YES;
    }
    
    if (camera == nil) {
        return NO;
    }
    
    // if the decoder type is software decoder, we don't care about the camera type
    if (decoder == VideoPreviewerDecoderTypeSoftwareDecoder) {
        self.enableHardwareDecode = NO;
        self.encoderType = H264EncoderType_DM368_inspire;
        
        return YES;
    }
    
    H264EncoderType dataSource = [VideoPreviewer getDataSourceWithCamera:camera andIsHandheld:isHandheld];
    if (dataSource == H264EncoderType_unknown) { // The product does not support hardware decoding
        return NO;
    }
    
    self.enableHardwareDecode = YES;
    self.encoderType = dataSource; 
    [self.hw_decoder setEncoderType:(H264EncoderType)dataSource];
    
    return YES;
}

+ (H264EncoderType) getDataSourceWithCamera:(DJICamera*)camera andIsHandheld:(BOOL)isHandheld {
    NSString* name = camera.displayName;
    if ([name isEqualToString:DJICameraDisplayNameX3] ||
        [name isEqualToString:DJICameraDisplayNameZ3]) {
        // use `isDigitalZoomScaleSupported` to determine if Osmo with X3 is new firmware version
        // `isDigitalZoomScaleSupported` has bug in SDK 3.2. Old firmware version doesn't support
        // digital zoom, but `isDigitalZoomScaleSupported` still returns `YES`.
        if (isHandheld && [camera isDigitalZoomScaleSupported]) {
            return H264EncoderType_A9_OSMO_NO_368;
        }
        else {
            return H264EncoderType_DM368_inspire;
        }
    }
    else if ([name isEqualToString:DJICameraDisplayNameX5] ||
             [name isEqualToString:DJICameraDisplayNameX5R]) {
        return H264EncoderType_DM368_inspire;
    }
    else if ([name isEqualToString:DJICameraDisplayNamePhantom3ProfessionalCamera]) {
        return H264EncoderType_DM365_phamtom3x;
    }
    else if ([name isEqualToString:DJICameraDisplayNamePhantom3AdvancedCamera]) {
        return H264EncoderType_A9_phantom3s;
    }
    else if ([name isEqualToString:DJICameraDisplayNamePhantom3StandardCamera]) {
        return H264EncoderType_A9_phantom3c;
    }
    else if ([name isEqualToString:DJICameraDisplayNamePhantom4Camera]) {
        return H264EncoderType_1860_phantom4x;
    }
    
    return H264EncoderType_unknown;
}

-(BOOL) glviewCanRender{
    return !_status.isBackground && _status.isGLViewInit;
}

-(void) setEncoderType:(H264EncoderType)encoderType{
    if (_encoderType == encoderType) {
        return;
    }
    
    _encoderType = encoderType;
    _stream_basic_info.encoderType = encoderType;
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

-(void) registFrameProcessor:(id<VideoFrameProcessor>)processor{
    if (processor) {
        
        pthread_mutex_lock(&_processor_mutex);
        [_frame_processor_list addObject:processor];
        pthread_mutex_unlock(&_processor_mutex);
    }
}

-(void) unregistProcessor:(id)processor{
    
    pthread_mutex_lock(&_processor_mutex);
    [_stream_processor_list removeObject:processor];
    [_frame_processor_list removeObject:processor];
    pthread_mutex_unlock(&_processor_mutex);
}

#pragma mark - private
- (void)enterBackground{
    //It is not allowed to call OpenGL's interface in the background. Ensure all work is done before entering the background.
    pthread_mutex_lock(&_render_mutex);
    NSLog(@"videoPreviewer background");
    _status.isBackground = YES;
    pthread_mutex_unlock(&_render_mutex);
}

- (void)enterForegournd{
    NSLog(@"videoPreviewer active");
    _status.isBackground = NO;
}

// Update the decoder's status according to the time stamp when the previous data is received
- (void)updateDecoderStatus{
    if (_status.isPause) {
        return;
    }
    
    long long current = [self getTickCount];
    
//    NSLog(@"%lld, %lld, %lld", current, current - _lastDataInputTime, current - _lastFrameDecodedTime);
    
    if (current - _lastDataInputTime > 2000*1000) {
        self.decoderStatus = VideoDecoderStatus_NoData;
        return;
    }
    
    if (current - _lastFrameDecodedTime > 2000*1000) {
        self.decoderStatus = VideoDecoderStatus_DecoderError;
        return;
    }
    
    self.decoderStatus = VideoDecoderStatus_Normal;
    return;
}

-(long long) getTickCount
{
    struct timeval t;
    gettimeofday(&t, NULL);
    long long microSec = t.tv_sec*1000*1000 + t.tv_usec;
    
    return microSec;
}

-(void) decodeRunloop
{
    _status.isRunning = YES;
    _status.isFinish = NO;
    safe_resume_skip_count = 0;
    
    videoDecoderCanReset = NO;
    videoDecoderFailedCount = 0;
    DJIVideoStreamBasicInfo current_stream_info = {0};
    
    __block long decodeTime = 0;
    
    while(_status.isRunning)
    {
        @autoreleasepool
        {
            VideoFrameH264Raw* frameRaw = nil;
            int inputDataSize = 0;
            uint8_t *inputData = nil;
            
            int queueNodeSize;
            frameRaw = (VideoFrameH264Raw*)[_dataQueue pull:&queueNodeSize]; //now we have got h264 raw format data in frameRaw
            if (frameRaw && frameRaw->frame_size + sizeof(VideoFrameH264Raw) == queueNodeSize) {
                inputData = frameRaw->frame_data;
                inputDataSize = frameRaw->frame_size;
            }
            [self updateDecoderStatus];
            
            if(inputData == NULL)
            {
                if (safe_resume_skip_count) {
                    //waiting for safe resume
                    _status.hasImage = NO; // no image, but it won't trigger the NoImage notification
                    continue;
                }
                
                videoDecoderCanReset = NO;
                pthread_mutex_lock(&_render_mutex);
                if([self glviewCanRender]){
                    // render as grey when it is paused
                    _glView.grayScale = _grayOutPause;
                    [_glView render:nil];
                    _glView.grayScale = NO;
                }
                pthread_mutex_unlock(&_render_mutex);
                
                if(_status.hasImage && !_status.isPause){
                    _status.hasImage = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:VIDEO_PREVIEWER_EVEN_NOTIFICATIOIN object:@(VideoPreviewerEventNoImage)];
                }
                continue;
            }
            
            if(!_status.hasImage){
                _status.hasImage = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:VIDEO_PREVIEWER_EVEN_NOTIFICATIOIN object:@(VideoPreviewerEventHasImage)];
            }
            
            BOOL stream_info_changed = NO;
            _stream_basic_info.frameRate = _videoExtractor.frameRate;
            _stream_basic_info.frameSize = CGSizeMake(_videoExtractor.outputWidth, _videoExtractor.outputHeight);
            if (memcmp(&current_stream_info, &_stream_basic_info, sizeof(current_stream_info)) !=0 ) {
                current_stream_info = _stream_basic_info;
                stream_info_changed = YES;
            }
            
            if (frameRaw->type_tag == TYPE_TAG_VideoFrameH264Raw) {
                
                //decoder select
                if(_hw_decoder && !_hw_decoder.hardware_unavailable && _enableHardwareDecode){
                    //decode use video toolbox
                    _hw_decoder.enabled = YES;
                    _soft_decoder.enabled = NO;
                    
                    self.frameOutputType = VPFrameTypeYUV420Planer;
                }
                else{
                    _hw_decoder.enabled = NO;
                    _soft_decoder.enabled = YES;
                    self.frameOutputType = VPFrameTypeYUV420Planer;
                }
                
                //phantom 4 hack
                if (_encoderType == H264EncoderType_1860_phantom4x) {
                    frameRaw->frame_info.frame_flag.has_idr = 0;
                }
                
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
                    
                    if (processor_type == DJIVideoStreamProcessorType_Decoder)
                    {
                        if(!_status.isBackground){ // do nothing when it is in background
                            long long beforeDecode = [self getTickCount];
                            if ([processor streamProcessorHandleFrameRaw:frameRaw]) {  //start decode here 
                                videoDecoderCanReset = YES;
                            }else{
                                [self videoProcessFailedFrame];
                            }
                            decodeTime = (long)([self getTickCount] - beforeDecode);
                        }
                    }
                    else if(processor_type == DJIVideoStreamProcessorType_Modify
                             || processor_type == DJIVideoStreamProcessorType_Passthrough){
                        [processor streamProcessorHandleFrameRaw:frameRaw];
                    }
                    else if (processor_type == DJIVideoStreamProcessorType_Consume){
                        if(processor != _stream_processor_list.lastObject) {
                            VideoFrameH264Raw* data_copy = (VideoFrameH264Raw*)malloc(queueNodeSize);
                            memcpy(data_copy, frameRaw, queueNodeSize);
                            if (![processor streamProcessorHandleFrameRaw:data_copy]) {
                                free(data_copy);
                            }
                        }
                        else if([processor streamProcessorHandleFrameRaw:frameRaw]){
                            frameRaw = NULL; // the frame is not released
                        }
                    }
                } //for
            }//if
            
            if(safe_resume_skip_count){
                safe_resume_skip_count--;
                NSLog(@"safe resume frame:%d", safe_resume_skip_count);
                if (safe_resume_skip_count == 0) {
                    NSLog(@"safe resume complete");
                    [[NSNotificationCenter defaultCenter] postNotificationName:VIDEO_PREVIEWER_EVEN_NOTIFICATIOIN object:@(VideoPreviewerEventResumeReady)];
                }
            }
            
            if (frameRaw) {
                free(frameRaw);
                frameRaw = NULL;
            }
        }
    }
    
    _status.isFinish = YES;
}

-(BOOL) videoProcessorEnabled
{
    return YES;
}

-(void) videoProcessFrame:(VideoFrameYUV *)frame{
    _lastFrameDecodedTime = [self getTickCount];
    
    if (safe_resume_skip_count || _status.isPause) {
        return;
    }
    
    pthread_mutex_lock(&_render_mutex);
    if ([self glviewCanRender]) {
        [_glView render:frame];
    }
    pthread_mutex_unlock(&_render_mutex);
    
    pthread_mutex_lock(&_processor_mutex);
    NSArray* frameProcessorCopyList = [NSArray arrayWithArray:_frame_processor_list];
    pthread_mutex_unlock(&_processor_mutex);
    
    for (id<VideoFrameProcessor> processor in frameProcessorCopyList) {
        if (processor == self) {
            continue;
        }
        
        if ([processor conformsToProtocol:@protocol(VideoFrameProcessor)]) {
            
            if (![processor videoProcessorEnabled]) {
                continue;
            }
            
            [processor videoProcessFrame:frame];
        }
    }
}

//单帧解析失败
-(void) videoProcessFailedFrame{
    
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
        if ([processor conformsToProtocol:@protocol(VideoFrameProcessor)]) {
            
            if (![processor videoProcessorEnabled]) {
                continue;
            }
            
            [processor videoProcessFailedFrame];
        }
    }
}

- (NSUInteger)runLoopCount{
    return 0;
}

- (NSUInteger)frameCount{
    return 0;
}

-(void) dealloc
{
    if (_videoExtractor) {
        _videoExtractor.delegate = nil;
    }
    
    [_videoExtractor freeExtractor];
    [self close];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

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
            
            NSLog(@"fps:%.2f rate:%dkbps buffer:%d", _outputFps, _outputKbitPerSec, (int)_dataQueue.count);
            
            frame_count = 0;
            bits_count = 0;
            video_last_count_time = tEndTime;
        }
    }
}

#pragma mark - videotoolbox decode callback

//handle 264 frame output from videotoolbox
-(void) decompressedFrame:(CVImageBufferRef)image frameInfo:(VideoFrameH264Raw *)frame
{
    if (image == nil) {
        [self videoProcessFailedFrame];
        return;
    }
    
    //check status
    if(_status.isPause || _status.isBackground){
        return;
    }
    
    CFTypeID imageType = CFGetTypeID(image);
    if (imageType == CVPixelBufferGetTypeID()
        && (kCVPixelFormatType_420YpCbCr8Planar == CVPixelBufferGetPixelFormatType(image)
            || kCVPixelFormatType_420YpCbCr8PlanarFullRange == CVPixelBufferGetPixelFormatType(image))) {
            //make sure this is a yuv420 image
            CGSize size = CVImageBufferGetDisplaySize(image);
            if(kCVReturnSuccess != CVPixelBufferLockBaseAddress(image, 0))
                return;
            
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
            
            if (frame && frame->frame_uuid != H264_FRAME_INVALIED_UUID) {
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
                 if(kCVReturnSuccess != CVPixelBufferLockBaseAddress(image, 0))
                     return;
                 
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
                 
                 if (frame && frame->frame_uuid != H264_FRAME_INVALIED_UUID) {
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

@end
