//
//  DJIImageCalibrateFilterDataSource.m
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIImageCalibrateFilterDataSource.h"
#import <pthread.h>

#pragma pack(1)
typedef struct{
    uint16_t y_decimal:5;//1/32
    uint16_t y_integer:11;
    uint16_t x_decimal:5;//1/32
    uint16_t x_integer:11;
}DJICalibratuonLutCoordinateStruct;
#pragma pack()

@interface DJIImageCalibrateFilterDataSource(){
    pthread_mutex_t _dataMutex;
    BOOL _loading;
    CGSize _latestSize;
    void* _dataLoaded;
    NSUInteger _loadedDataLen;
    void* _indexLoaded;
    NSUInteger _indexLen;
}
@property (nonatomic,assign) NSUInteger workMode;

@end

@implementation DJIImageCalibrateFilterDataSource

+(instancetype)instanceWithWorkMode:(NSUInteger)workMode{
    DJIImageCalibrateFilterDataSource* inst = [[self alloc] init];
    inst.workMode = workMode;
    return inst;
}

-(void)dealloc{
    [self releaseCache];
}

-(instancetype)init{
    if (self = [super init]){
        [self initDataSourceData];
    }
    return self;
}

-(void)initDataSourceData{
    pthread_mutex_init(&_dataMutex, NULL);
    _loading = NO;
    _latestSize = CGSizeZero;
    _dataLoaded = NULL;
    _indexLoaded = NULL;
    _loadedDataLen = 0;
    _indexLen = 0;
}

-(void)internalLoad{
    _loading = YES;
    [self internalLoadData];
    [self internalLoadIndex];
    _loading = NO;
}

-(void)internalLoadData{
    GLuint lutWidth = _latestSize.width / 8;
    GLuint lutHeight = _latestSize.height / 8;
    CGSize resolution = CGSizeMake(_latestSize.width, _latestSize.height);
    GLuint w = lutWidth + 1;
    GLuint h = lutHeight + 1;
    NSUInteger idxCount = [self validIndexCountForResolution:resolution];
    if (idxCount == 0){
        if (_dataLoaded != NULL){
            free(_dataLoaded);
            _dataLoaded = NULL;
        }
        _loadedDataLen = 0;
        return;
    }
    NSUInteger totalIdx = idxCount;
    NSUInteger sizeNeeded = 4 * w * h * sizeof(GLfloat);
    NSUInteger sizeNeededAll = sizeNeeded * totalIdx;
    if (_loadedDataLen < sizeNeededAll){
        if (_dataLoaded != NULL){
            free(_dataLoaded);
            _dataLoaded = NULL;
        }
        _loadedDataLen = 0;
    }
    if (!_dataLoaded){
        _loadedDataLen = sizeNeededAll;
        _dataLoaded = malloc(sizeNeededAll);
    }
    //first zone calculation
    GLfloat factorY = 1.0 / lutHeight;
    GLfloat factorX = 1.0 / lutWidth;
    for (GLuint y = 0; y < h; y++){
        NSUInteger offsetY = y * w * 4;
        GLfloat vertexY = factorY * y;
        for (GLuint x = 0; x < w; x++){
            NSUInteger offsetX = offsetY + x * 4;
            GLfloat* ptr = (GLfloat*)_dataLoaded + offsetX;
            ptr[2] = x * factorX;
            ptr[3] = vertexY;
            ptr[0] = ptr[2] * 2 - 1;
            ptr[1] = ptr[3] * 2 - 1;
        }
    }
    //copy from the index 0
    for (NSUInteger index = 1; index < totalIdx; index++){
        memcpy((GLubyte*)_dataLoaded + index * sizeNeeded,
               _dataLoaded,
               sizeNeeded);
    }
    if ([self loadFromFiles]){
        for (NSUInteger index = 0; index < totalIdx; index++){
            NSData* lutData = [self textureCoordinateDataForResolution:resolution
                                                             dataIndex:index];
            DJICalibratuonLutCoordinateStruct* lutBytes = NULL;
            if (nil != lutData
                && lutData.length >= (sizeof(DJICalibratuonLutCoordinateStruct) * h * w)){
                lutBytes = (DJICalibratuonLutCoordinateStruct*)lutData.bytes;
            }
            if (!lutBytes){
                continue;
            }
            GLfloat* dataLoaded = (GLfloat*)((uint8_t*)_dataLoaded + index * sizeNeeded);
            for (GLuint y = 0; y < h; y++){
                NSUInteger offsetY = y * w * 4;
                for (GLuint x = 0; x < w; x++){
                    NSUInteger offsetX = offsetY + x * 4;
                    GLfloat* ptr = dataLoaded + offsetX;
                    ptr[2] = (lutBytes->x_integer + lutBytes->x_decimal / 32.0)/MAX(1.0e-3,resolution.width);
                    ptr[3] = (lutBytes->y_integer + lutBytes->y_decimal / 32.0)/MAX(1.0e-3,resolution.height);
                    lutBytes++;
                }
            }
        }
    }
}

-(void)internalLoadIndex{
    GLuint lutWidth = _latestSize.width / 8;
    GLuint lutHeight = _latestSize.height / 8;
    NSUInteger sizeNeeded = 6 * lutWidth * lutHeight * sizeof(GLuint);
    if (_indexLen < sizeNeeded){
        if (_indexLoaded != NULL){
            free(_indexLoaded);
            _indexLoaded = NULL;
        }
        _indexLen = 0;
    }
    if (!_indexLoaded){
        _indexLen = sizeNeeded;
        _indexLoaded = malloc(sizeNeeded);
    }
    GLuint w = lutWidth + 1;
    for (GLuint y = 0; y < lutHeight; y++){
        NSUInteger offsetY = y * lutWidth * 6;
        GLuint posY = y * w;
        for (GLuint x = 0; x < lutWidth; x++){
            NSUInteger offsetX = offsetY + x * 6;
            GLuint* ptr = (GLuint*)_indexLoaded + offsetX;
            ptr[0] = posY + x;
            ptr[1] = ptr[0] + w;
            ptr[2] = ptr[1] + 1;
            ptr[3] = ptr[0];
            ptr[4] = ptr[1] + 1;
            ptr[5] = ptr[0] + 1;
        }
    }
}

-(void)releaseCache{
    pthread_mutex_lock(&_dataMutex);
    if (_dataLoaded != NULL){
        free(_dataLoaded);
        _dataLoaded = NULL;
    }
    if (_indexLoaded != NULL){
        free(_indexLoaded);
        _indexLoaded = NULL;
    }
    _loadedDataLen = 0;
    _indexLen = 0;
    pthread_mutex_unlock(&_dataMutex);
}

-(BOOL)checkLoadDoneForSize:(CGSize)size{
    if (CGSizeEqualToSize(size, _latestSize)
        && size.width > 1.0e-6
        && size.height > 1.0e-6
        && !_loading){
        return YES;
    }
    return NO;
}

#pragma mark - override by subclass
-(BOOL)loadFromFiles{
    return NO;
}

-(NSData*)textureCoordinateDataForResolution:(CGSize)resolution
                                   dataIndex:(NSUInteger)index{
    return nil;
}

-(NSUInteger)validIndexCountForResolution:(CGSize)resolution{
    return 1;
}

-(NSUInteger)dataIndexForResolution:(CGSize)resolution
                           lutIndex:(NSUInteger)index
                        andFovState:(DJISEIInfoLiveViewFOVState)fovState{
    return NSNotFound;
}

#pragma mark - data source
-(void)loadDataForFrameSize:(CGSize)frameSize{
    pthread_mutex_lock(&_dataMutex);
    if (!CGSizeEqualToSize(frameSize, _latestSize)
        && !_loading
        && frameSize.width > 1.0e-6
        && frameSize.height > 1.0e-6){
        _latestSize = frameSize;
        [self internalLoad];
    }
    pthread_mutex_unlock(&_dataMutex);
}

-(BOOL)checkDataReadyForFrameSize:(CGSize)frameSize{
    BOOL checkOK = NO;
    pthread_mutex_lock(&_dataMutex);
    checkOK = [self checkLoadDoneForSize:frameSize];
    pthread_mutex_unlock(&_dataMutex);
    return checkOK;
}

-(void)getVertexIndexDataForFrameSize:(CGSize)frameSize
                           andHandler:(void(^)(GLuint* data,NSUInteger size))handler{
    GLuint* retData = NULL;
    NSUInteger dataSize = 0;//bytes
    pthread_mutex_lock(&_dataMutex);
    BOOL checkOK = [self checkLoadDoneForSize:frameSize];
    if (checkOK
        && handler != nil){
        GLuint lutWidth = _latestSize.width / 8;
        GLuint lutHeight = _latestSize.height / 8;
        NSUInteger sizeNeeded = 6 * lutWidth * lutHeight * sizeof(GLuint);
        if (sizeNeeded <= _indexLen
            && _indexLoaded != NULL){
            retData = (GLuint*)_indexLoaded;
            dataSize = sizeNeeded;
        }
    }
    pthread_mutex_unlock(&_dataMutex);
    if (handler != nil){
        handler(retData,dataSize);
    }
}

-(void)getVertexDataForFrameSize:(CGSize)frameSize
                      andHandler:(void(^)(GLfloat* data,NSUInteger strideForIndex,NSUInteger indexCount))handler{
    GLfloat* retData = NULL;
    NSUInteger strideForIndex = 0;//bytes
    NSUInteger indexCount = 0;
    pthread_mutex_lock(&_dataMutex);
    BOOL checkOK = [self checkLoadDoneForSize:frameSize];
    if (checkOK
        && handler != nil){
        GLuint lutWidth = _latestSize.width / 8;
        GLuint lutHeight = _latestSize.height / 8;
        GLuint w = lutWidth + 1;
        GLuint h = lutHeight + 1;
        NSUInteger sizeNeeded = 4 * w * h * sizeof(GLfloat);
        NSUInteger idxCount = [self validIndexCountForResolution:frameSize];
        if (_loadedDataLen >= (sizeNeeded * idxCount)
            && _dataLoaded != NULL){
            retData = (GLfloat*)_dataLoaded;
            strideForIndex = sizeNeeded;
            indexCount = idxCount;
        }
    }
    pthread_mutex_unlock(&_dataMutex);
    if (handler != nil){
        handler(retData,strideForIndex,indexCount);
    }
}

@end

