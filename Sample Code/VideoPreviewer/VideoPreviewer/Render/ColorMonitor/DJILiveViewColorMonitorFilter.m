//
//  DJILiveViewColorMonitorFilter.m
//

#import "DJILiveViewColorMonitorFilter.h"
#import <UIKit/UIKit.h>

#define FRAME_BUFFER_COUNT (1)
#define HIST_HEIGH (256)
#define MAX_VALUE_INDEX (HIST_HEIGH)

#define P_HIST(x, value, channel) ((ushort*)(histBuffer + value*bytesPerHistBuffer) + x*4 + channel)
#define HIST_SHORT_SET(x, value, channel) {ushort* pHist = P_HIST(x, value, channel); *pHist = *pHist+1;}

void bufferReleaseFunc(void * __nullable info,
                       const void *  data, size_t size){
    if (data) {
        free((void*)data);
    }
}

@interface DJILiveViewColorMonitorFilter (){
    NSUInteger inputWidth;
    NSUInteger inputHeigh;
    
    uint8_t* outputBuffer; //w * h *4
    
    NSUInteger histBufferSize;
    NSUInteger bytesPerHistBuffer;
    uint8_t* histBuffer; //w * (HIST_HEIGH+1)[ushort] * 4, one more line for maxium hist value
    
    CGImageRef lastImage; //not need release
}

@property (nonatomic, strong) NSLock* frameBufferLock;
@property (nonatomic, strong) NSMutableArray* frameBuffers;
@property (nonatomic, strong) dispatch_queue_t workingQueue;
@end

@implementation DJILiveViewColorMonitorFilter

-(id) initWithContext:(DJILiveViewRenderContext *)acontext{
    self = [super initWithContext:acontext];
    
    _frameBufferLock = [[NSLock alloc] init];
    _frameBuffers = [NSMutableArray array];
    inputWidth = 0;
    inputHeigh = 0;
    
    for (int i =0; i < FRAME_BUFFER_COUNT; i++) {
        [_frameBuffers addObject:[NSNull null]];
    }
    _workingQueue = dispatch_queue_create("colorMonitor",
                                          dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL,
                                                                                  QOS_CLASS_BACKGROUND,
                                                                                  0));
    return self;
}

-(void) dealloc{
    if (histBuffer) {
        free(histBuffer);
    }
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;
{
    if (self.preventRendering)
    {
        return;
    }
    
    DJILiveViewFrameBuffer* frameBuffer = [self frameBufferForOutput];
    if (frameBuffer == nil) {
        //no available framebuffer, return
        return;
    }
    
    [context setContextShaderProgram:filterProgram];
    CGSize FBOSize = [self sizeOfFBO];
    
    if ([frameBuffer isKindOfClass:[DJILiveViewFrameBuffer class]] == NO
        || NO == CGSizeEqualToSize(FBOSize, frameBuffer.size)) {
        frameBuffer = [[DJILiveViewFrameBuffer alloc]
                             initWithContext:context
                             size:FBOSize
                             textureOptions:self.outputTextureOptions
                             onlyTexture:NO];
    }
    
    [frameBuffer activateFramebuffer];
    
    [self setUniformsForProgramAtIndex:0];
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    
    glUniform1i(filterInputTextureUniform, 2);
    glEnableVertexAttribArray(filterPositionAttribute);
    glEnableVertexAttribArray(filterTextureCoordinateAttribute);
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [self colorWave:frameBuffer];
}

#pragma mark - input control

-(DJILiveViewFrameBuffer*) frameBufferForOutput{
    DJILiveViewFrameBuffer* buffer = nil;
    [_frameBufferLock lock];
    if (_frameBuffers.count) {
        buffer = _frameBuffers.lastObject;
        [_frameBuffers removeLastObject];
    }
    [_frameBufferLock unlock];
    return buffer;
};

-(void) pushFrameBuffer:(DJILiveViewFrameBuffer*)frameBuffer{
    if (frameBuffer == nil) {
        return;
    }
    
    [_frameBufferLock lock];
    [_frameBuffers addObject:frameBuffer];
    [_frameBufferLock unlock];
}

#pragma mark - color mointor

-(void) colorWave:(DJILiveViewFrameBuffer*)input{
    //__weak DJILiveViewColorMonitorFilter* target = self;
    dispatch_async(_workingQueue, ^{
        [self doCalcColorMonitorWithInputStage1:input];
    });
}

-(void) doCalcColorMonitorWithInputStage1:(DJILiveViewFrameBuffer*)input{
    //working in background thread
    
    if (input == nil
        || input.size.width == 0
        || input.size.height == 0) {
        return;
    }
    
    //input size check & buffer prepear
    if (input.size.width != inputWidth) {
        
        if (outputBuffer) {
            free(outputBuffer);
        }
        outputBuffer = malloc(input.size.width * HIST_HEIGH * 4);
        
        if (input.size.width > inputWidth) {
            //only recreate if larger
            if (histBuffer != nil) {
                free(histBuffer);
            }
            
            bytesPerHistBuffer = input.size.width*4*sizeof(short);
            histBufferSize = bytesPerHistBuffer * (HIST_HEIGH+1);
            histBuffer = malloc(histBufferSize);
        }
        
        inputWidth = input.size.width;
        inputHeigh = input.size.height;
    }
    
    //bytes read
    [input lockForReading];
    uint8_t* inputBuffer = [input byteBuffer];
    NSUInteger bytesPerRow = [input bytesPerRow];
    if (inputBuffer == nil) {
        [input unlockAfterReading];
        [self pushFrameBuffer:input];
        return;
    }
    
    //generate histgram
    memset(histBuffer, 0, histBufferSize);
    for (int row = 0; row < inputHeigh; row++) {
        
        uint8_t* rowPixel = inputBuffer + bytesPerRow*row;
        
        for (int col = 0; col < inputWidth; col++) {
            uint8_t* pixel = rowPixel + col*4;
            
            uint8_t r = *pixel;
            uint8_t g = *(pixel+1);
            uint8_t b = *(pixel+2);
            uint8_t l = *(pixel+3); //hack for lumiunce
            
            HIST_SHORT_SET(col, r, 0);
            HIST_SHORT_SET(col, g, 1);
            HIST_SHORT_SET(col, b, 2);
            HIST_SHORT_SET(col, l, 3);
            
        }
    }
    
    //next stage
    dispatch_async(_workingQueue, ^{
        [self doCalcColorMonitorWithInputStage2:input];
    });
}

-(void) doCalcColorMonitorWithInputStage2:(DJILiveViewFrameBuffer*)input{
    //get maxium value for hist
    for (int col = 0; col < inputWidth; col++) {
        
        ushort* r_max = P_HIST(col, MAX_VALUE_INDEX, 0);
        ushort* g_max = P_HIST(col, MAX_VALUE_INDEX, 1);
        ushort* b_max = P_HIST(col, MAX_VALUE_INDEX, 2);
        ushort* l_max = P_HIST(col, MAX_VALUE_INDEX, 3);
    
        for (int row = 0; row < HIST_HEIGH; row++) {
            
            ushort r = *P_HIST(col, row, 0);
            ushort g = *P_HIST(col, row, 1);
            ushort b = *P_HIST(col, row, 2);
            ushort l = *P_HIST(col, row, 3);
            
            if (r > *r_max) {
                *r_max = r;
            }
            if (g > *g_max) {
                *g_max = g;
            }
            if (b > *b_max) {
                *b_max = b;
            }
            if (l > *l_max) {
                *l_max = l;
            }
        }
    }
    
    dispatch_async(_workingQueue, ^{
        [self doCalcColorMonitorWithInputStage3:input];
    });
}


-(void) doCalcColorMonitorWithInputStage3:(DJILiveViewFrameBuffer*)input{
    //generate final image
    NSUInteger outputBytesPerRow = inputWidth*4;
    for (int col = 0; col < inputWidth; col++) {
        
        CGFloat r_max = (CGFloat)*P_HIST(col, MAX_VALUE_INDEX, 0);
        if(r_max == 0){
            r_max = CGFLOAT_MAX;
        }
        
        CGFloat g_max = (CGFloat)*P_HIST(col, MAX_VALUE_INDEX, 1);
        if(g_max == 0){
            g_max = CGFLOAT_MAX;
        }
        
        CGFloat b_max = (CGFloat)*P_HIST(col, MAX_VALUE_INDEX, 2);
        if(b_max == 0){
            b_max = CGFLOAT_MAX;
        }
        
        CGFloat l_max = (CGFloat)*P_HIST(col, MAX_VALUE_INDEX, 3);
        if(l_max == 0){
            l_max = CGFLOAT_MAX;
        }
        
        for (int row = 0; row < HIST_HEIGH; row++) {
            
            NSUInteger hist_row = HIST_HEIGH - row - 1;
            
            CGFloat r = (CGFloat)*P_HIST(col, hist_row, 0);
            CGFloat g = (CGFloat)*P_HIST(col, hist_row, 1);
            CGFloat b = (CGFloat)*P_HIST(col, hist_row, 2);
            CGFloat l = (CGFloat)*P_HIST(col, hist_row, 3);
            
            uint8_t out_l_half = (l/l_max);
            
            uint8_t out_r = 127.5*((r/r_max) + out_l_half);
            uint8_t out_g = 127.5*((g/g_max) + out_l_half);
            uint8_t out_b = 127.5*((b/b_max) + out_l_half);
            
            uint8_t* pixel = outputBuffer + row*outputBytesPerRow + col*4;
            *pixel = out_r;
            *(pixel+1) = out_g;
            *(pixel+2) = out_b;
        }
    }
    
    [input unlockAfterReading];
    [self pushFrameBuffer:input];
    
    //image create
    if (true) {
        CGDataProviderRef provider = CGDataProviderCreateWithData(nil,
                                                                  outputBuffer,
                                                                  inputWidth*HIST_HEIGH*4,
                                                                  nil);
        CGColorSpaceRef defaultRGBColorSpace = CGColorSpaceCreateDeviceRGB();
        CGImageRef cgImageFromBytes = CGImageCreate((int)inputWidth,
                                                    (int)HIST_HEIGH,
                                                    8, 32, 4 * (int)inputWidth,
                                                    defaultRGBColorSpace,
                                                    kCGBitmapByteOrderDefault | kCGImageAlphaNoneSkipLast,
                                                    provider, NULL, NO, kCGRenderingIntentDefault);
        
        // Capture image with current device orientation
        CGDataProviderRelease(provider);
        CGColorSpaceRelease(defaultRGBColorSpace);
        lastImage = cgImageFromBytes;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // output image
            if (self.monitor == nil) {
                self.monitor = [[UIView alloc] init];
                self.monitor.contentMode = UIViewContentModeScaleToFill;
            }
            
            self.monitor.layer.contents = (__bridge id _Nullable)(cgImageFromBytes);
            CGImageRelease(cgImageFromBytes);
        });
    }
}

@end
