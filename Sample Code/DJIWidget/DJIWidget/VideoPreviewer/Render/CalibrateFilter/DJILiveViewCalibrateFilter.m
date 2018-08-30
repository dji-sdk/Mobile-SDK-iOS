//
//  DJILiveViewCalibrateFilter.m
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJILiveViewCalibrateFilter.h"
#import "DJIDecodeImageCalibrateDataBuffer.h"
#import "DJIImageCalibrateHelperHolder.h"

@interface DJILiveViewCalibrateFilter(){
    //input size
    CGSize _inputSize;
    BOOL _needUpdateDataSource;
}
//buffer vertex
@property (nonatomic,assign) GLuint vertexBuffer;
@property (nonatomic,strong) NSArray* vertexBufferArray;
//buffer index
@property (nonatomic,assign) GLuint indexBuffer;

@end

@implementation DJILiveViewCalibrateFilter

-(void)dealloc{
    [self releaseCacheData];
}

-(void)releaseCacheData{
    if (_indexBuffer != 0){
        glDeleteBuffers(1, &_indexBuffer);
        _indexBuffer = 0;
    }
    for (NSNumber* vertex in _vertexBufferArray){
        GLuint vertexBuffer = vertex.unsignedIntValue;
        glDeleteBuffers(1, &vertexBuffer);
        vertexBuffer = 0;
    }
    _vertexBuffer = 0;
    _vertexBufferArray = nil;
}

-(void)updateVertextBuffer{
    GLuint lutWidth = _inputSize.width / 8;
    GLuint lutHeight = _inputSize.height / 8;
    GLuint w = lutWidth + 1;
    GLuint h = lutHeight + 1;
    NSUInteger sizeNeeded = 4 * w * h * sizeof(GLfloat);
    NSUInteger idx = _idx;
    DJISEIInfoLiveViewFOVState fovState = _fovState;
    NSUInteger dataIndex = NSNotFound;
    DJIImageCalibrateFilterDataSource* dataSource = _dataSource;
    if (dataSource != nil){
        dataIndex = [dataSource dataIndexForResolution:_inputSize
                                              lutIndex:idx
                                           andFovState:fovState];
    }
    if (_vertexBufferArray.count > 0){
        NSUInteger index = MIN(dataIndex,_vertexBufferArray.count - 1);
        _vertexBuffer = [[_vertexBufferArray objectAtIndex:index] unsignedIntValue];
        return;
    }
    __weak typeof(self) target = self;
    [self getVertexDataWithHandler:^(GLfloat *vertex,NSUInteger stride,NSUInteger totalIndex) {
        DJILiveViewCalibrateFilter* strongTarget = target;
        if (strongTarget == nil
            || vertex == NULL
            || stride < sizeNeeded
            || totalIndex <= 0){
            return;
        }
        NSMutableArray* newArray = nil;
        for (NSUInteger index = 0; index < totalIndex; index++){
            GLuint vertexBuffer = [strongTarget genBufferWithTarget:GL_ARRAY_BUFFER
                                                              usage:GL_STATIC_DRAW
                                                               size:(GLuint)stride
                                                            andData:((uint8_t*)vertex + index * stride)];
            if (!newArray){
                newArray = [NSMutableArray array];
            }
            [newArray addObject:@(vertexBuffer)];
        }
        strongTarget.vertexBufferArray = newArray;
        if (newArray.count > 0){
            NSUInteger index = MIN(dataIndex,newArray.count - 1);
            strongTarget.vertexBuffer = [[strongTarget.vertexBufferArray objectAtIndex:index] unsignedIntValue];
        }
    }];
}

-(void)updateIndexBuffer{
    GLuint lutWidth = _inputSize.width / 8;
    GLuint lutHeight = _inputSize.height / 8;
    NSUInteger sizeNeeded = 6 * lutWidth * lutHeight * sizeof(GLuint);
    __weak typeof(self) target = self;
    [self getVertexIndexWithHandler:^(GLuint *indexes,NSUInteger size) {
        DJILiveViewCalibrateFilter* strongTarget = target;
        if (strongTarget == nil
            || indexes == NULL
            || size < sizeNeeded){
            return;
        }
        strongTarget.indexBuffer = [strongTarget genBufferWithTarget:GL_ELEMENT_ARRAY_BUFFER
                                                               usage:GL_STATIC_DRAW
                                                                size:(GLuint)size
                                                             andData:indexes];
    }];
}

-(id) initWithContext:(DJILiveViewRenderContext *)acontext{
    if (self = [super initWithContext:acontext]) {
        [self initData];
    }
    return self;
}

-(void)initData{
    _vertexBuffer = 0;
    _indexBuffer = 0;
    _inputSize = CGSizeZero;
    _needUpdateDataSource = NO;
    _dataSource = nil;
    _vertexBufferArray = nil;
}

-(GLuint)genBufferWithTarget:(GLenum)target
                       usage:(GLenum)usage
                        size:(GLsizei)size
                     andData:(void*)data{
    GLuint buffer = 0;
    glGenBuffers(1, &buffer);
    glBindBuffer(target, buffer);
    glBufferData(target, size, data, usage);
    glBindBuffer(target, 0);
    return buffer;
}

-(void) newFrameReadyAtTime:(CMTime)frameTime
                    atIndex:(NSInteger)textureIndex{
    
    DJILiveViewFrameBuffer* inputBuffer = firstInputFramebuffer;
    if (!CGSizeEqualToSize(_inputSize, inputBuffer.size)
        || _needUpdateDataSource){
        [self releaseCacheData];
        _inputSize = inputBuffer.size;
        _needUpdateDataSource = NO;
    }
    
    if (![self checkDataReady]){
        [self loadData];
        return;
    }
    
    if (_vertexBuffer != 0){
        NSUInteger index = _idx;
        DJISEIInfoLiveViewFOVState fovState = _fovState;
        DJIImageCalibrateFilterDataSource* dataSource = _dataSource;
        NSUInteger dataIndex = NSNotFound;
        if (dataSource != nil){
            dataIndex = [dataSource dataIndexForResolution:_inputSize
                                                  lutIndex:index
                                               andFovState:fovState];
        }
        if (dataIndex != NSNotFound
            && dataIndex < _vertexBufferArray.count){
            NSNumber* vertexBufferValue = [_vertexBufferArray objectAtIndex:dataIndex];
            if (vertexBufferValue.unsignedIntValue != _vertexBuffer){
                _vertexBuffer = 0;
            }
        }
        else{
            _vertexBuffer = 0;
        }
    }
    
    if (_vertexBuffer == 0
        && _inputSize.width > 1.0e-6
        && _inputSize.height > 1.0e-6){
        [self updateVertextBuffer];
    }
    if (_indexBuffer == 0
        && _inputSize.width > 1.0e-6
        && _inputSize.height > 1.0e-6){
        [self updateIndexBuffer];
    }
    
    if (_vertexBuffer == 0
        || _indexBuffer == 0
        || _inputSize.width < 1.0e-6
        || _inputSize.height < 1.0e-6){
        return;
    }
    
    [self renderToTextureWithVertices:NULL
                   textureCoordinates:NULL];
    
    [self informTargetsAboutNewFrameAtTime:frameTime];
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices
                 textureCoordinates:(const GLfloat *)textureCoordinates{
    if (self.preventRendering){
        return;
    }
    
    [context setContextShaderProgram:filterProgram];
    CGSize FBOSize = [self sizeOfFBO];
    
    if (outputFramebuffer == nil
        || NO == CGSizeEqualToSize(FBOSize, self.framebufferForOutput.size)) {
        outputFramebuffer = [[DJIDecodeImageCalibrateDataBuffer alloc]
                             initWithContext:context
                             size:FBOSize
                             textureOptions:self.outputTextureOptions
                             onlyTexture:NO];
    }
    
    [outputFramebuffer activateFramebuffer];
    
    [self setUniformsForProgramAtIndex:0];
    glClearColor(backgroundColorRed,
                 backgroundColorGreen,
                 backgroundColorBlue,
                 backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform, 2);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    
    NSUInteger offset = 0;
    glVertexAttribPointer(filterPositionAttribute,
                          2,
                          GL_FLOAT,
                          false,
                          4 * sizeof(GLfloat),
                          (void*)offset);
    glEnableVertexAttribArray(filterPositionAttribute);
    offset += 2 * sizeof(GLfloat);
    glVertexAttribPointer(filterTextureCoordinateAttribute,
                          2,
                          GL_FLOAT,
                          false,
                          4 * sizeof(GLfloat),
                          (void*)offset);
    glEnableVertexAttribArray(filterTextureCoordinateAttribute);
    
    GLuint lutWidth = _inputSize.width / 8;
    GLuint lutHeight = _inputSize.height / 8;
    glDrawElements(GL_TRIANGLES,
                   lutWidth * lutHeight * 6,
                   GL_UNSIGNED_INT,
                   0);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

#pragma mark - data source
-(void)loadData{
    DJIImageCalibrateFilterDataSource* dataSource = _dataSource;
    [dataSource loadDataForFrameSize:_inputSize];
}

-(BOOL)checkDataReady{
    DJIImageCalibrateFilterDataSource* dataSource = _dataSource;
    return [dataSource checkDataReadyForFrameSize:_inputSize];
}

-(void)getVertexIndexWithHandler:(void(^)(GLuint* indexes,NSUInteger size))handler{
    DJIImageCalibrateFilterDataSource* dataSource = _dataSource;
    [dataSource getVertexIndexDataForFrameSize:_inputSize
                                    andHandler:handler];
}

-(void)getVertexDataWithHandler:(void(^)(GLfloat* vertex,NSUInteger stride,NSUInteger totalIndex))handler{
    DJIImageCalibrateFilterDataSource* dataSource = _dataSource;
    [dataSource getVertexDataForFrameSize:_inputSize
                               andHandler:handler];
}

//override
- (void)addTarget:(id<DJILiveViewRenderInput>)newTarget
atTextureLocation:(NSInteger)textureLocation{
    NSMutableArray* targetsToRemoved = nil;
    for (id<DJILiveViewRenderInput> target in targets){
        if ([target isKindOfClass:[DJIImageCalibrateHelperHolder class]]
            && ![(DJIImageCalibrateHelperHolder*)target target]){
            if (targetsToRemoved == nil){
                targetsToRemoved = [NSMutableArray array];
            }
            [targetsToRemoved addObject:target];
        }
    }
    if (targetsToRemoved != nil
        && targetsToRemoved.count > 0){
        for (id<DJILiveViewRenderInput> target in targetsToRemoved){
            [self removeTarget:target];
        }
    }
    if (!newTarget){
        return;
    }
    [super addTarget:newTarget
   atTextureLocation:textureLocation];
}

-(void)setDataSource:(DJIImageCalibrateFilterDataSource*)dataSource{
    if (_dataSource == dataSource){
        return;
    }
    _dataSource = dataSource;
    _needUpdateDataSource = YES;
}

@end
