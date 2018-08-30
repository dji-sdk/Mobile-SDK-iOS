//
//  DJIImageCalibrateColorGPUConverter.m
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "DJIImageCalibrateColorGPUConverter.h"
#import "DJIImageCalibrateColorConverter_Private.h"
#import "DJILiveViewColorSpaceFilter.h"
//frame
#import "DJIDecodeImageCalibrateDataBuffer.h"
//holder
#import "DJIImageCalibrateHelperHolder.h"

//If output yuv format, defalut is 0；If need support rgba，set as 1.
#define DJI_Enabled_RGBA_FastUpload_Output_From_Source              (0)

@interface DJIImageCalibrateColorGPUConverterWeakObject : NSObject
//weak buffer
@property (nonatomic,weak) DJIDecodeImageCalibrateDataBuffer* buffer;
//
-(instancetype)initWithBuffer:(DJIDecodeImageCalibrateDataBuffer*)buffer;

+(instancetype)defaultObject;

@end

@implementation DJIImageCalibrateColorGPUConverterWeakObject

-(instancetype)initWithBuffer:(DJIDecodeImageCalibrateDataBuffer*)buffer{
    if (self = [super init]){
        self.buffer = buffer;
    }
    return self;
}

+(instancetype)defaultObject{
    return [[DJIImageCalibrateColorGPUConverterWeakObject alloc] initWithBuffer:nil];
}

@end

@interface DJIImageCalibrateColorGPUConverter()<DJILiveViewRenderInput>{
    NSUInteger _processedMask;
    NSUInteger _doneMask;
    BOOL _firstInit;
    CGSize _inputFrameSize;//Current output frame size, If not same as _lastInputFrameSize, reset _firstInit.
    CGSize _lastInputFrameSize;
    NSMutableDictionary<NSNumber*,DJILiveViewRenderFilter*>* _filterInfo;
    NSMutableDictionary<NSNumber*,DJIImageCalibrateColorGPUConverterWeakObject*>* _bufferInfo;
    DJIImageCalibrateHelperHolder* _safeHolder;
}

@end

@implementation DJIImageCalibrateColorGPUConverter

-(void)prepareToClean{
    [self deleteFilters];
    [self removeBuffers];
}

-(void)deleteFilters{
    if (!_filterInfo){
        return;
    }
    NSArray<DJILiveViewRenderFilter*>* filters = _filterInfo.allValues;
    for (DJILiveViewRenderFilter* filter in filters){
        [filter removeAllTargets];
        [filter releaseResources];
    }
    [_filterInfo removeAllObjects];
}

-(void)removeBuffers{
    if (!_bufferInfo){
        return;
    }
    [_bufferInfo removeAllObjects];
}

-(void)resetBuffers{
    _processedMask = 0;
    if (!_bufferInfo){
        return;
    }
    NSArray<DJIImageCalibrateColorGPUConverterWeakObject*>* objects = _bufferInfo.allValues;
    for (DJIImageCalibrateColorGPUConverterWeakObject* object in objects){
        object.buffer = nil;
    }
}

-(void)resetState{
    _firstInit = NO;
    _inputFrameSize = CGSizeZero;
    _lastInputFrameSize = CGSizeZero;
}

-(void)setEnabledConverter:(BOOL)enabledConverter{
    if (self.enabledConverter == enabledConverter){
        return;
    }
    [super setEnabledConverter:enabledConverter];
    [self resetState];
}

-(instancetype)initWithFrameType:(VPFrameType)type{
    if (self = [super initWithFrameType:type]){
        [self initData];
    }
    return self;
}

-(void)initData{
    _filterInfo = [NSMutableDictionary dictionary];
    _bufferInfo = [NSMutableDictionary dictionary];
    _doneMask = 0;
    _safeHolder = nil;
    [self resetState];
    [self resetBuffers];
    _combinedChannel = YES;//default YES, for more effective
    [self updateFiltersAndBuffers];
}

-(void)setCombinedChannel:(BOOL)combinedChannel{
    if (_combinedChannel == combinedChannel){
        return;
    }
    _combinedChannel = combinedChannel;
    [self updateFiltersAndBuffers];
}

-(void)setContext:(DJILiveViewRenderContext *)context{
    if (_context == context){
        return;
    }
    _context = context;
    [self updateFiltersAndBuffers];
}

-(void)updateFiltersAndBuffers{
    [self deleteFilters];
    [self resetBuffers];
    
    DJILiveViewRenderContext* context = self.context;
    if (!context){
        return;
    }
    
    NSArray* filterTypes = nil;
    switch (self.type){
        case VPFrameTypeRGBA:{
            filterTypes = @[
                            @(DJILiveViewColorSpaceFilterType_RGBA),
                            ];
        }
            break;
        case VPFrameTypeYUV420Planer:{
            if (!self.combinedChannel){
                filterTypes = @[
                                @(DJILiveViewColorSpaceFilterType_Y),
                                @(DJILiveViewColorSpaceFilterType_U),
                                @(DJILiveViewColorSpaceFilterType_V),
                                ];
            }
            else{
                filterTypes = @[
                                @(DJIColorSpace420PCombinedType),
                                ];
            }
        }
            break;
        case VPFrameTypeYUV420SemiPlaner:{
            if (!self.combinedChannel){
                filterTypes = @[
                                @(DJILiveViewColorSpaceFilterType_Y),
                                @(DJILiveViewColorSpaceFilterType_UV),
                                ];
            }
            else{
                filterTypes = @[
                                @(DJIColorSpace420PBiCombinedType),
                                ];
            }
        }
            break;
        default:
            break;
    }
    _doneMask = 0;
    for (NSNumber* filterType in filterTypes){
        [_bufferInfo setObject:[DJIImageCalibrateColorGPUConverterWeakObject defaultObject]
                        forKey:filterType];
        DJILiveViewColorSpaceFilter* filter = [[DJILiveViewColorSpaceFilter alloc] initWithContext:context
                                                                                 andColorSpaceType:filterType.unsignedIntegerValue];
        [filter addTarget:[self safeHolder]
        atTextureLocation:0];
        [_filterInfo setObject:filter
                        forKey:filterType];
        _doneMask |= filterType.unsignedIntegerValue;
    }
}

-(DJIImageCalibrateHelperHolder*)safeHolder{
    if (_safeHolder == nil){
        _safeHolder = [[DJIImageCalibrateHelperHolder alloc] init];
        _safeHolder.target = self;
    }
    return _safeHolder;
}

#pragma mark - override
- (void)setColorConverterInputSize:(CGSize)newSize
                           atIndex:(NSInteger)textureIndex{
#if DJI_Enabled_RGBA_FastUpload_Output_From_Source
    if (self.type == VPFrameTypeRGBA){//rgba don't need.
        return;
    }
#endif
    _inputFrameSize = newSize;
    NSArray<DJILiveViewRenderFilter*>* filters = _filterInfo.allValues;
    for (DJILiveViewRenderFilter* filter in filters){
        [filter setInputSize:newSize
                     atIndex:textureIndex];
    }
}

- (void)setColorConverterInputFramebuffer:(DJILiveViewFrameBuffer *)newInputFramebuffer
                                  atIndex:(NSInteger)textureIndex{
#if DJI_Enabled_RGBA_FastUpload_Output_From_Source
    if (self.type == VPFrameTypeRGBA){//rgba don't need.
        if ([newInputFramebuffer isKindOfClass:[DJIDecodeImageCalibrateDataBuffer class]]){
            DJIDecodeImageCalibrateDataBuffer* dataBuffer = (DJIDecodeImageCalibrateDataBuffer*)newInputFramebuffer;
            dataBuffer.bufferFlag = DJILiveViewColorSpaceFilterType_RGBA;
            [self setInputFramebuffer:dataBuffer
                              atIndex:0];
        }
        return;
    }
#endif
    NSArray<DJILiveViewRenderFilter*>* filters = _filterInfo.allValues;
    for (DJILiveViewRenderFilter* filter in filters){
        [filter setInputFramebuffer:newInputFramebuffer
                            atIndex:textureIndex];
    }
}

- (void)newColorConverterFrameReadyAtTime:(CMTime)frameTime
                                  atIndex:(NSInteger)textureIndex{
#if DJI_Enabled_RGBA_FastUpload_Output_From_Source
    if (self.type == VPFrameTypeRGBA){//rgba don't need.
        return;
    }
#endif
    if (CGSizeEqualToSize(_inputFrameSize, _lastInputFrameSize)){
        _firstInit = YES;
    }
    else{
        _firstInit = NO;
        _lastInputFrameSize = _inputFrameSize;
    }
    NSArray<DJILiveViewRenderFilter*>* filters = _filterInfo.allValues;
    for (DJILiveViewRenderFilter* filter in filters){
        [filter newFrameReadyAtTime:frameTime
                            atIndex:textureIndex];
    }
}

- (void)endProcessingColorConverter{
#if DJI_Enabled_RGBA_FastUpload_Output_From_Source
    if (self.type == VPFrameTypeRGBA){//rgba don't need.
        return;
    }
#endif
    NSArray<DJILiveViewRenderFilter*>* filters = _filterInfo.allValues;
    for (DJILiveViewRenderFilter* filter in filters){
        [filter endProcessing];
    }
}

#pragma mark - filter delegate
- (BOOL)enabled{
    BOOL enabledConverter = self.enabledConverter;
    if (!enabledConverter){
        [self resetState];
        [self resetBuffers];
    }
    return enabledConverter;
}

- (void)setInputSize:(CGSize)newSize
             atIndex:(NSInteger)textureIndex{
    //do nothing
}

- (void)setInputFramebuffer:(DJILiveViewFrameBuffer *)newInputFramebuffer
                    atIndex:(NSInteger)textureIndex{
    if ([newInputFramebuffer isKindOfClass:[DJIDecodeImageCalibrateDataBuffer class]]){
        DJIDecodeImageCalibrateDataBuffer* dataBuffer = (DJIDecodeImageCalibrateDataBuffer*)newInputFramebuffer;
        _processedMask |= dataBuffer.bufferFlag;
        DJIImageCalibrateColorGPUConverterWeakObject* object = [_bufferInfo objectForKey:@(dataBuffer.bufferFlag)];
        if (object == nil
            || ![object isKindOfClass:[DJIImageCalibrateColorGPUConverterWeakObject class]]){
            object = [DJIImageCalibrateColorGPUConverterWeakObject defaultObject];
            object.buffer = dataBuffer;
            [_bufferInfo setObject:object
                            forKey:@(dataBuffer.bufferFlag)];
        }
        else{
            object.buffer = dataBuffer;
        }
    }
}

- (void)newFrameReadyAtTime:(CMTime)frameTime
                    atIndex:(NSInteger)textureIndex{
    if (_firstInit){
        [self checkNewFrameDone];
    }
    else{
        [self resetBuffers];
    }
}

- (void)endProcessing{
    //do nothing
}

#pragma mark - data buffer
-(void)checkNewFrameDone{
    NSUInteger mask = (_processedMask & _doneMask);
    if (mask == _doneMask
        && mask != 0){
        
        uint8_t* yuvData[] = {NULL,NULL,NULL};
        int yuvSlice[] = {0,0,0};
        CVPixelBufferRef fastUpload = NULL;

        switch (self.type){
            case VPFrameTypeRGBA:{
                DJIImageCalibrateColorGPUConverterWeakObject* rgbaObject = [_bufferInfo objectForKey:@(DJILiveViewColorSpaceFilterType_RGBA)];
                if (rgbaObject != nil
                    && [rgbaObject isKindOfClass:[DJIImageCalibrateColorGPUConverterWeakObject class]]){
                    DJIDecodeImageCalibrateDataBuffer* dataBuffer = rgbaObject.buffer;
                    if (dataBuffer != nil){
                        int width = (int)(dataBuffer.size.width + 0.5);
                        yuvSlice[0] = width * 4;
                        yuvData[0] = [dataBuffer rgbaPixelBuffer];
                        fastUpload = [dataBuffer renderTarget];
                    }
                }
            }
                break;
            case VPFrameTypeYUV420Planer:{
                if ([_bufferInfo.allKeys containsObject:@(DJIColorSpace420PCombinedType)]){
                    DJIImageCalibrateColorGPUConverterWeakObject* yuvObject = [_bufferInfo objectForKey:@(DJIColorSpace420PCombinedType)];
                    if (yuvObject != nil
                        && [yuvObject isKindOfClass:[DJIImageCalibrateColorGPUConverterWeakObject class]]){
                        DJIDecodeImageCalibrateDataBuffer* dataBuffer = yuvObject.buffer;
                        if (dataBuffer != nil){
                            uint8_t* dataPtr = [dataBuffer rgbaPixelBuffer];
                            int offset = 0;
                            int yWidth = (int)(dataBuffer.size.width * 4 + 0.5);
                            int yHeight = (int)(dataBuffer.size.height * 0.5 + 0.5);
                            yuvSlice[0] = yWidth;
                            yuvData[0] = (dataPtr != NULL ? dataPtr + offset : NULL);
                            offset += yWidth * yHeight;
                            int uWidth = (int)(dataBuffer.size.width * 2 + 0.5);
                            int uHeight = (int)(dataBuffer.size.height * 0.25 + 0.5);
                            yuvSlice[1] = uWidth;
                            yuvData[1] = (dataPtr != NULL ? dataPtr + offset : NULL);
                            offset += uWidth * uHeight;
                            int vWidth = (int)(dataBuffer.size.width * 2 + 0.5);
                            yuvSlice[2] = vWidth;
                            yuvData[2] = (dataPtr != NULL ? dataPtr + offset : NULL);
                        }
                    }
                }
                else{
                    DJIImageCalibrateColorGPUConverterWeakObject* yObject = [_bufferInfo objectForKey:@(DJILiveViewColorSpaceFilterType_Y)];
                    if (yObject != nil
                        && [yObject isKindOfClass:[DJIImageCalibrateColorGPUConverterWeakObject class]]){
                        DJIDecodeImageCalibrateDataBuffer* dataBuffer = yObject.buffer;
                        if (dataBuffer != nil){
                            int width = (int)(dataBuffer.size.width * 4 + 0.5);
                            yuvSlice[0] = width;
                            yuvData[0] = [dataBuffer rgbaPixelBuffer];
                        }
                    }
                    DJIImageCalibrateColorGPUConverterWeakObject* uObject = [_bufferInfo objectForKey:@(DJILiveViewColorSpaceFilterType_U)];
                    if (uObject != nil
                        && [uObject isKindOfClass:[DJIImageCalibrateColorGPUConverterWeakObject class]]){
                        DJIDecodeImageCalibrateDataBuffer* dataBuffer = uObject.buffer;
                        if (dataBuffer != nil){
                            int width = (int)(dataBuffer.size.width * 4.0 + 0.5);
                            yuvSlice[1] = width;
                            yuvData[1] = [dataBuffer rgbaPixelBuffer];
                        }
                    }
                    DJIImageCalibrateColorGPUConverterWeakObject* vObject = [_bufferInfo objectForKey:@(DJILiveViewColorSpaceFilterType_V)];
                    if (vObject != nil
                        && [vObject isKindOfClass:[DJIImageCalibrateColorGPUConverterWeakObject class]]){
                        DJIDecodeImageCalibrateDataBuffer* dataBuffer = vObject.buffer;
                        if (dataBuffer != nil){
                            int width = (int)(dataBuffer.size.width * 4.0 + 0.5);
                            yuvSlice[2] = width;
                            yuvData[2] = [dataBuffer rgbaPixelBuffer];
                        }
                    }
                }
            }
                break;
            case VPFrameTypeYUV420SemiPlaner:{
                if ([_bufferInfo.allKeys containsObject:@(DJIColorSpace420PBiCombinedType)]){
                    DJIImageCalibrateColorGPUConverterWeakObject* yuvObject = [_bufferInfo objectForKey:@(DJIColorSpace420PBiCombinedType)];
                    if (yuvObject != nil
                        && [yuvObject isKindOfClass:[DJIImageCalibrateColorGPUConverterWeakObject class]]){
                        DJIDecodeImageCalibrateDataBuffer* dataBuffer = yuvObject.buffer;
                        if (dataBuffer != nil){
                            uint8_t* dataPtr = [dataBuffer rgbaPixelBuffer];
                            int offset = 0;
                            int yWidth = (int)(dataBuffer.size.width * 4 + 0.5);
                            int yHeight = (int)(dataBuffer.size.height * 0.5 + 0.5);
                            yuvSlice[0] = yWidth;
                            yuvData[0] = (dataPtr != NULL ? dataPtr + offset : NULL);
                            offset += yWidth * yHeight;
                            int uvWidth = (int)(dataBuffer.size.width * 4 + 0.5);
                            yuvSlice[1] = uvWidth;
                            yuvData[1] = (dataPtr != NULL ? dataPtr + offset : NULL);
                        }
                    }
                }
                else{
                    DJIImageCalibrateColorGPUConverterWeakObject* yObject = [_bufferInfo objectForKey:@(DJILiveViewColorSpaceFilterType_Y)];
                    if (yObject != nil
                        && [yObject isKindOfClass:[DJIImageCalibrateColorGPUConverterWeakObject class]]){
                        DJIDecodeImageCalibrateDataBuffer* dataBuffer = yObject.buffer;
                        if (dataBuffer != nil){
                            int width = (int)(dataBuffer.size.width * 4.0 + 0.5);
                            yuvSlice[0] = width;
                            yuvData[0] = [dataBuffer rgbaPixelBuffer];
                        }
                    }
                    DJIImageCalibrateColorGPUConverterWeakObject* uvObject = [_bufferInfo objectForKey:@(DJILiveViewColorSpaceFilterType_UV)];
                    if (uvObject != nil
                        && [uvObject isKindOfClass:[DJIImageCalibrateColorGPUConverterWeakObject class]]){
                        DJIDecodeImageCalibrateDataBuffer* dataBuffer = uvObject.buffer;
                        if (dataBuffer != nil){
                            int width = (int)(dataBuffer.size.width * 4.0 + 0.5);
                            yuvSlice[1] = width;
                            yuvData[1] = [dataBuffer rgbaPixelBuffer];
                        }
                    }
                }
            }
                break;
            default:{
            }
                break;
        }
        [self handlerYUVData:yuvData
                 andYUVSlice:yuvSlice
              withFastUpload:fastUpload];
        [self resetBuffers];
    }
}

#pragma mark - proposed ouput type
+(VPFrameType)proposedType{
    VPFrameType outputFrameType = VPFrameTypeRGBA;
#if !DJI_Enabled_RGBA_FastUpload_Output_From_Source
    if ([DJILiveViewRenderContext supportsFastTextureUpload]){
        outputFrameType = VPFrameTypeYUV420SemiPlaner;
    }
    else{
        outputFrameType = VPFrameTypeYUV420Planer;
    }
#endif
    return outputFrameType;
}

@end
