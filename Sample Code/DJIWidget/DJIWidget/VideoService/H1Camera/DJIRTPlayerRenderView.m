//
//  DJIRTPlayerRenderView.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import "DJIH264VTDecode.h"
#import "DJISoftwareDecodeProcessor.h"
#import "DJIRTPlayerRenderView.h"
#import "DJIMovieGLView.h"
#import <UIKit/UIKit.h>
#import "DJIStreamCommon.h"
#import "DJIVTH264DecoderIFrameData.h"

#define weakSelf(__TARGET__) __weak typeof(self) __TARGET__=self

#define MAX_FRAME_BUFFER_SIZE (1024*1024) //1MB

@interface DJIRTPlayerRenderView () <VideoFrameProcessor, H264DecoderOutput>{
    //uint8_t* frameDataBuffer;
}

@property (nonatomic) LiveStreamDecodeType decoderType;


@property (nonatomic) NSLock* renderLock;
@property (nonatomic) DJIMovieGLView* glView;

@property (nonatomic) BOOL isBackGround;
@property (nonatomic) BOOL framePushed;

@property (nonatomic) DJICustomVideoFrameExtractor* frameExtractor;
@property (nonatomic) DJIH264VTDecode* hwDecoder;
@property (nonatomic) DJISoftwareDecodeProcessor* softDecoder;
@end

@implementation DJIRTPlayerRenderView

-(id) initWithDecoderType:(LiveStreamDecodeType)decodeType
                encoderType:(H264EncoderType)encoderType{
    
    if(self = [super init]){
        _decoderType = decodeType;
        _encoderType = encoderType;
        
        //render
        CGRect frame = self.bounds;
        if (0 == frame.size.width * frame.size.height) {
            frame.size.width = 64;
            frame.size.height = 64;
        }
        
        //cannot init with zero frame
        _glView = [[DJIMovieGLView alloc] initWithFrame:frame multiThreadSupported:YES];
        [self addSubview:_glView];
        self.backgroundColor = [UIColor blackColor];
        
        //frame buffer
        //frameDataBuffer = (uint8_t*)malloc(MAX_FRAME_BUFFER_SIZE);
        
        //decode
        _frameExtractor = [[DJICustomVideoFrameExtractor alloc] initExtractor];
        
#if TARGET_IPHONE_SIMULATOR
        // use software decoder
        decodeType = LiveStreamDecodeType_Software;
#endif
        
        if(decodeType == LiveStreamDecodeType_Software){
            //software decoder only
            _softDecoder = [[DJISoftwareDecodeProcessor alloc] initWithExtractor:_frameExtractor];
            _softDecoder.frameProcessor = self;
        }
        else{
            //hardware decoder only
            _hwDecoder = [[DJIH264VTDecode alloc] init];
            _hwDecoder.enabled = YES;
            _hwDecoder.delegate = self;
            _hwDecoder.enableFastUpload = YES;

            if (g_loadPrebuildIframeOverrideFunc == NULL) {
                g_loadPrebuildIframeOverrideFunc = loadPrebuildIframePrivate;
            }

            DJIVideoStreamBasicInfo info = {0};
            info.encoderType = _encoderType;
            [_hwDecoder streamProcessorInfoChanged:&info];
        }
        
        //background
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillEnterForeGround:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    
    return self;
}

-(void) layoutSubviews{
    [super layoutSubviews];
    [self reDraw];
}

-(void) dealloc{
//    if(frameDataBuffer){
//        free(frameDataBuffer);
//    }
    
    [_glView releaseResourece];
    [_frameExtractor freeExtractor];
}

-(void) setRotation:(VideoStreamRotationType)rotation{
    if(rotation == _rotation){
        return;
    }
    
    _rotation = rotation;
    _glView.rotation = _rotation;
    [self reDraw];
}

-(void) appDidEnterBackground:(NSNotification*)notify{
    [_renderLock lock];
    self.isBackGround = YES;
    [_renderLock unlock];
}

-(void) appWillEnterForeGround:(NSNotification*)notify{
    [_renderLock lock];
    self.isBackGround = NO;
    [_renderLock unlock];
    
    //draw
    [self reDraw];
}

-(void) setEncoderType:(H264EncoderType)encoderType{
    if (encoderType == _encoderType) {
        return;
    }
    
    DJIVideoStreamBasicInfo info = {0};
    info.encoderType = _encoderType;
    [_hwDecoder streamProcessorInfoChanged:&info];
}

#pragma mark - decode

-(void) decodeH264CompleteFrameData:(uint8_t *)data
                             length:(NSUInteger)size
                         decodeOnly:(BOOL)decodeOnly
{
    if (data == nil
        || size == 0) {
        return;
    }

    //parser
    weakSelf(target);
    [_frameExtractor parseVideo:data
                         length:(uint32_t)size
                      withFrame:^(VideoFrameH264Raw *frame)
    {
        frame->frame_info.frame_flag.ignore_render = decodeOnly;
        [target decodeFrame:frame];
    }];
}

-(BOOL) decodeH264RawData:(uint8_t *)data
                   length:(NSUInteger)size
{
    if (data == nil
        || size == 0) {
        return NO;
    }

    //parser
    weakSelf(target);
    __block BOOL hasFrame = NO;
    [_frameExtractor parseVideo:data
                         length:(uint32_t)size
                      withFrame:^(VideoFrameH264Raw *frame)
     {
         if(!target){
             return;
         }
         
         if(frame){
             hasFrame = YES;
             if ( target.delegate && [target.delegate respondsToSelector:@selector(frameSleepTime)] ){
                 double sleepTime = [target.delegate frameSleepTime];
                 if ( sleepTime < 0){
                     frame->frame_info.frame_flag.ignore_render = YES ;
                 }
                 else if ( sleepTime > 0 ){
                     usleep(sleepTime * 1000 * 1000) ;
                     frame->frame_info.frame_flag.ignore_render = NO ;
                 }
                 else{
                     frame->frame_info.frame_flag.ignore_render = NO ;
                 }
             }
         }
         [target decodeFrame:frame];
     }];
    
    return YES;
}

-(void) decodeFrame:(VideoFrameH264Raw*)frame{
    
    id<VideoStreamProcessor> processor = nil;
    if (_softDecoder) {
        processor = _softDecoder;
    }else{
        processor = _hwDecoder;
    }
    if(frame){
        [processor streamProcessorHandleFrameRaw:frame];
        free(frame);
    }
}

-(void) snapshotPreview:(void (^)(UIImage *))block{
    _glView.snapshotCallback = block;
}

#pragma mark - render

/**
 * Enables the frame processor
 */
-(BOOL) videoProcessorEnabled{
    return YES;
}

//handle 264 frame output from videotoolbox
-(void) decompressedFrame:(CVImageBufferRef)image
                frameInfo:(VideoFrameH264Raw *)frame
{
    if (image == nil) {
        [self videoProcessFailedFrame];
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

-(void) videoProcessFrame:(VideoFrameYUV*)frame{
    if (frame == nil) {
        return;
    }
    
    if(frame->frame_info.frame_flag.ignore_render){
        return;
    }
    
    [_renderLock lock];
    if([self canRender]){
        [_glView render:frame];
        _framePushed = YES;
    }
    [_renderLock unlock];
}

-(void) videoProcessFailedFrame{

}


#pragma mark - render

-(void) reDraw{
    [self reDrawWithGrayout:NO];
}

-(void) reDrawWithGrayout:(BOOL)gray{
    
    //workaround for an issue, where if the render is initialized before a redraw it will not work
    //potentially an issue in multithreading feature of OpenGL ES
    if(_framePushed == NO)
        return;
    
    [_renderLock lock];
    if ([self canRender]) {
        _glView.grayScale = gray;
        [_glView render:nil];
    }
    [_renderLock unlock];
}

-(BOOL) canRender{
    if (_glView && _isBackGround == NO) {
        return YES;
    }
    
    return NO;
}

@end
