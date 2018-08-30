//
//  DJILiveViewColorMonitorFilter.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//


#import "DJILiveViewColorMonitorFilter.h"
@interface DJILiveViewColorMonitorMapedCGImageHolder : NSObject{
    uint8_t* outputBuffer;
}

@property (nonatomic, readonly) UIView* holderView;
@property (nonatomic, readonly) NSUInteger bufferedImageWidth;
@property (nonatomic, readonly) NSUInteger bufferedImageHeight;

-(id) initWithSize:(CGSize)size;
@end

@implementation DJILiveViewColorMonitorMapedCGImageHolder

-(id) initWithSize:(CGSize)size{
    if (self = [super init]) {
        //create view and bufferd image
        
        
        _bufferedImageWidth = size.width;
        _bufferedImageHeight = size.height;
        
        if (_bufferedImageWidth == 0 || _bufferedImageHeight == 0) {
            return nil;
        }
        
        _holderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        outputBuffer = malloc(_bufferedImageWidth*_bufferedImageHeight*4);
    }
    return self;
}

-(uint8_t*) dataBuffer{
    return outputBuffer;
}

-(void) update{
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(nil,
                                                              outputBuffer,
                                                              _bufferedImageWidth*_bufferedImageHeight*4,
                                                              nil);
    
    CGColorSpaceRef defaultRGBColorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImageFromBytes = CGImageCreate((int)_bufferedImageWidth,
                                                (int)_bufferedImageHeight,
                                                8, 32, 4 * (int)_bufferedImageWidth,
                                                defaultRGBColorSpace,
                                                kCGBitmapByteOrderDefault | kCGImageAlphaNoneSkipLast,
                                                provider, NULL, NO, kCGRenderingIntentDefault);
    
    // Capture image with current device orientation
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(defaultRGBColorSpace);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // output image
        if (NO == CGRectEqualToRect(self.holderView.frame, self.holderView.superview.bounds)) {
            self.holderView.frame = self.holderView.bounds;
        }
        
        self.holderView.layer.contents = (__bridge id _Nullable)(cgImageFromBytes);
        CGImageRelease(cgImageFromBytes);
    });

}

-(void) dealloc{
    
    uint8_t* buffer = outputBuffer;
    UIView* holderView = _holderView;;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [holderView removeFromSuperview];
        
        if(holderView.layer.contents){
            holderView.layer.contents = nil;
        }
        
       //release in main queue
        if (buffer) {
            free(buffer);
        }
    });
}

@end

#define FRAME_BUFFER_COUNT (1)
#define HIST_HEIGH (256)
#define MAX_VALUE_INDEX (HIST_HEIGH)

#define P_HIST(x, value, channel) ((ushort*)(histBuffer + value*bytesPerHistBuffer) + (x<<2) + channel)
#define HIST_SHORT_SET(x, value, channel) {(*P_HIST(x, value, channel))++;}

void bufferReleaseFunc(void * __nullable info,
                       const void *  data, size_t size){
    if (data) {
        free((void*)data);
    }
}

@interface DJILiveViewColorMonitorFilter (){
    
    //////////////////////////////////
    //for hist mode
    BOOL needUpdateView;
    NSUInteger bufferInputWidth;
    NSUInteger bufferInputHeigh;
    
    DJILiveViewColorMonitorDisplayType bufferDisplayType;
    DJILiveViewColorMonitorMapedCGImageHolder* imageHolder;
    
    NSUInteger histBufferSize;
    NSUInteger bytesPerHistBuffer;
    uint8_t* histBuffer; //w * (HIST_HEIGH+1)[ushort] * 4, one more line for maxium hist value
    
    //////////////////////////////////
    
    NSUInteger pointsBufferSize;
    CGPoint* pointsBuffer;
    
    NSTimeInterval start;
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
    
    _intensity = 2.0;
    _lineBlendMode = kCGBlendModePlusLighter;
    bufferInputWidth = 0;
    bufferInputHeigh = 0;
    needUpdateView = YES;
    
    imageHolder = nil;
    histBuffer = nil;
    pointsBuffer = nil;

    self.colorMonitorScaleFactor = 1.0;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.renderedColorWaveFormView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
    });
    
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
    
    UIView* monitor = self.renderedColorWaveFormView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [monitor removeFromSuperview];
    });
    
    if (histBuffer) {
        free(histBuffer);
    }
    
    if (pointsBuffer) {
        free(pointsBuffer);
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
    
    if (FBOSize.width * FBOSize.height == 0) {
        //nothing to do
        [self pushFrameBuffer:frameBuffer];
        return;
    }
    
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
    
    [self generateColorWaveWithInputBuffer:frameBuffer];
}

-(CGSize) sizeOfFBO{
    //input size should decieded by view size
    CGSize inputSize = [super sizeOfFBO];
    CGSize monitorSize = self.renderedColorWaveFormView.bounds.size;
    
    if (self.renderMode == DJILiveViewColorMonitorRenderModeHistgram) {
        CGSize newSize = CGSizeMake(monitorSize.width, inputSize.height);
        if (_displayType == DJILiveViewColorMonitorDisplayTypeSeparate) {
            newSize.width /= 3;
        }
        
        return newSize;
    }else{
        // Reduce some resolutions and improve performance
        CGSize newSize = CGSizeMake(MIN(monitorSize.width, inputSize.width),
                                    MIN(monitorSize.height * 0.5, inputSize.height));
        
        if(_displayType == DJILiveViewColorMonitorDisplayTypeSeparate){
            newSize.width /= 3;
        }
        
        
        return [self sizeScale:newSize scale:self.colorMonitorScaleFactor];

        
    }
}

-(CGSize)sizeScale:(CGSize)size scale:(float)scale{
    return CGSizeMake(size.width*scale, size.height*scale);
}

-(void) setDisplayType:(DJILiveViewColorMonitorDisplayType)displayType{
    _displayType = displayType;
    needUpdateView = YES;
}

-(void) setRenderMode:(DJILiveViewColorMonitorRenderMode)renderMode{
    _renderMode = renderMode;
    needUpdateView = YES;
}

#pragma mark - input control

-(DJILiveViewFrameBuffer*) frameBufferForOutput{
    DJILiveViewFrameBuffer* buffer = nil;
    [_frameBufferLock lock];
    if (_frameBuffers.count) {
        buffer = _frameBuffers.lastObject;
        [_frameBuffers removeLastObject];
        
        start = CFAbsoluteTimeGetCurrent();
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
//    NSTimeInterval duration = CFAbsoluteTimeGetCurrent() - start;
    //NSLog(@"duration:\t%f", duration);
    [_frameBufferLock unlock];
}

#pragma mark - color monitor

- (void)generateColorWaveWithInputBuffer:(DJILiveViewFrameBuffer*)input {
    if (_renderMode == DJILiveViewColorMonitorRenderModeHistgram) {
        dispatch_async(_workingQueue, ^{
            [self performFirstColorWaveRenderingPassWithInputBuffer:input];
        });
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), _workingQueue, ^{
            if(_displayType == DJILiveViewColorMonitorDisplayTypeYChannel){
                
                [self performColorWaveRenderingPassUsingCoreGraphicsYChannelWithInputBuffer:input];
            }else{
                
                [self performColorWaveRenderingPassUsingCoreGraphicsWithInputBuffer:input];
            }
        });
    }
}

- (void)performFirstColorWaveRenderingPassWithInputBuffer:(DJILiveViewFrameBuffer*)input{
    //working in background thread
    
    if (input == nil){
        return;
    }
    
    if(input.size.width == 0
        || input.size.height == 0)
    {
        [self pushFrameBuffer:input];
        return;
    }
    
    NSUInteger outputBufferWidth = input.size.width;
    DJILiveViewColorMonitorDisplayType displayType = _displayType;
    if (displayType == DJILiveViewColorMonitorDisplayTypeSeparate) {
        //more width if seperate
        outputBufferWidth *= 3;
    }
    
    //input size check & buffer prepear
    if ((NSUInteger)input.size.width != bufferInputWidth
        || bufferDisplayType != displayType
        || imageHolder == nil) {
        
        imageHolder = [[DJILiveViewColorMonitorMapedCGImageHolder alloc] initWithSize:CGSizeMake(outputBufferWidth, HIST_HEIGH)];
        
        if (input.size.width > bufferInputWidth) {
            //only recreate if larger
            if (histBuffer != nil) {
                free(histBuffer);
            }
            
            bytesPerHistBuffer = input.size.width*4*sizeof(short);
            histBufferSize = bytesPerHistBuffer * (HIST_HEIGH+1);
            histBuffer = malloc(histBufferSize);
        }
        
        bufferInputWidth = input.size.width;
        bufferInputHeigh = input.size.height;
        bufferDisplayType = displayType;
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
    uint8_t r, g, b;//, l;
    uint8_t* rowPixel = nil;
    
    memset(histBuffer, 0, histBufferSize);
    for (int row = 0; row < bufferInputHeigh; row++) {
        
        rowPixel = inputBuffer + bytesPerRow*row;
        
        for (int col = 0; col < bufferInputWidth; col++) {
            uint8_t* pixel = rowPixel + (col<<2);
            
            r = *pixel;
            g = *(pixel+1);
            b = *(pixel+2);
            //l = *(pixel+3); //workaround for luminance
            
            HIST_SHORT_SET(col, r, 0);
            HIST_SHORT_SET(col, g, 1);
            HIST_SHORT_SET(col, b, 2);
            //HIST_SHORT_SET(col, l, 3);
            
        }
    }
    
    //next stage
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.005 * NSEC_PER_SEC)), _workingQueue, ^{
        [self performSecondColorWaveRenderingPassWithInputBuffer:input];
    });
}

-(void)performSecondColorWaveRenderingPassWithInputBuffer:(DJILiveViewFrameBuffer*)input{
    //generate final image
    uint8_t* outputBuffer = [imageHolder dataBuffer];
    
    if(bufferDisplayType == DJILiveViewColorMonitorDisplayTypeSeparate){
    // Three-channel separation display mode
        
        NSUInteger outputBytesPerRow = bufferInputWidth*4*3;
        NSUInteger colOffset = 0;
        NSUInteger hist_row = 0;
        
        for (int col = 0; col < bufferInputWidth; col++) {
            
            //r
            colOffset = (col+0)*4;
            for (int row = 0; row < HIST_HEIGH; row++) {
                
                hist_row = HIST_HEIGH - row - 1;
                
                ushort r = *P_HIST(col, hist_row, 2);
                uint8_t out_r = MIN(r*_intensity, 255);
                
                uint8_t* pixel = outputBuffer + row*outputBytesPerRow + colOffset;
                *pixel = out_r;
                *(pixel+1) = 0;
                *(pixel+2) = 0;
                //*(pixel+3) = out_r; //alpha
            }
            
            //g
            colOffset = (col+bufferInputWidth)*4;
            for (int row = 0; row < HIST_HEIGH; row++) {
                
                hist_row = HIST_HEIGH - row - 1;
                
                ushort g = *P_HIST(col, hist_row, 1);
                uint8_t out_g = MIN(g*_intensity, 255);
                
                uint8_t* pixel = outputBuffer + row*outputBytesPerRow + colOffset;
                *pixel = 0;
                *(pixel+1) = out_g;
                *(pixel+2) = 0;
                //*(pixel+3) = out_g;
            }
            
            //b
            colOffset = (col+bufferInputWidth*2)*4;
            for (int row = 0; row < HIST_HEIGH; row++) {
                
                hist_row = HIST_HEIGH - row - 1;
                

                ushort b = *P_HIST(col, hist_row, 0);
                uint8_t out_b = MIN(b*_intensity, 255);
                
                uint8_t* pixel = outputBuffer + row*outputBytesPerRow + colOffset;
                *pixel = 0;
                *(pixel+1) = 0;
                *(pixel+2) = out_b;
                //*(pixel+3) = out_b;
            }
        }
        
    }else{
        // Three-channel mixed display mode
        
        NSUInteger outputBytesPerRow = bufferInputWidth*4;
        for (int col = 0; col < bufferInputWidth; col++) {
            
            for (int row = 0; row < HIST_HEIGH; row++) {
                
                NSUInteger hist_row = HIST_HEIGH - row - 1;
                
                CGFloat r = (CGFloat)*P_HIST(col, hist_row, 2);
                CGFloat g = (CGFloat)*P_HIST(col, hist_row, 1);
                CGFloat b = (CGFloat)*P_HIST(col, hist_row, 0);
                //CGFloat l = (CGFloat)*P_HIST(col, hist_row, 3);
                
                //uint8_t out_l_half = (l/l_max);
                
                uint8_t out_r = MIN(r*_intensity, 255);
                uint8_t out_g = MIN(g*_intensity, 255);
                uint8_t out_b = MIN(b*_intensity, 255);
                
                uint8_t* pixel = outputBuffer + row*outputBytesPerRow + col*4;
                *pixel = out_r;
                *(pixel+1) = out_g;
                *(pixel+2) = out_b;
                //*(pixel+3) = MIN(255, (int)out_r + out_b + out_g); //alpha
            }
        }
    }
    
    [input unlockAfterReading];
    [self pushFrameBuffer:input];
    
    //image create
    [imageHolder update];
    dispatch_async(dispatch_get_main_queue(), ^{
        // output image
        UIImageView* monitor = (UIImageView*)self.renderedColorWaveFormView;
        
        if (monitor.image) {
            monitor.image = nil;
        }
        
        if (monitor.subviews.firstObject != imageHolder.holderView) {
            [monitor.subviews.firstObject removeFromSuperview];
            
            [monitor addSubview:imageHolder.holderView];
            imageHolder.holderView.frame = monitor.bounds;
        }
        
        if(needUpdateView){
            needUpdateView = NO;
            [imageHolder.holderView setNeedsDisplay];
        }
    });
}

#pragma mark - core graphics test

#define DST_X_FROM_SRC(x) (x * dst_one_srcW)
#define DST_Y_FROM_HIST(v) (dstH - (v * dat_one_hist))
- (void)performColorWaveRenderingPassUsingCoreGraphicsWithInputBuffer:(DJILiveViewFrameBuffer*)input {
        //working in background thread
    
    if (input == nil){
        return;
    }
    
    if(input.size.width == 0
        || input.size.height == 0) {
        [self pushFrameBuffer:input];
        return;
    }
    
    //input size check & buffer prepear
    NSUInteger inputWidth = input.size.width;
    NSUInteger inputHeigh = input.size.height;
    DJILiveViewColorMonitorDisplayType displayType = _displayType;
    
    //bytes read
    [input lockForReading];
    uint8_t* inputBuffer = [input byteBuffer];
    NSUInteger bytesPerRow = [input bytesPerRow];
    if (inputBuffer == nil) {
        [input unlockAfterReading];
        [self pushFrameBuffer:input];
        return;
    }
    
    NSUInteger pointCountRequired = inputWidth;
    if (displayType == DJILiveViewColorMonitorDisplayTypeSeparate) {
        pointCountRequired*=3;
    }
    if (pointsBufferSize < pointCountRequired) {
        if(pointsBuffer){
            free(pointsBuffer);
        }
        
        pointsBuffer = (CGPoint*)malloc(sizeof(CGPoint)*pointCountRequired);
        pointsBufferSize = pointCountRequired;
    }
    
    CGPoint* points = pointsBuffer;
    uint8_t* rowPixel, *pixel;
    CGFloat srcW = inputWidth;
    CGFloat srcH = inputHeigh;
    CGFloat dstW = self.renderedColorWaveFormView.bounds.size.width;
    CGFloat dstH = self.renderedColorWaveFormView.bounds.size.height;
    
    CGFloat one_srcW = 1.0/srcW;
    CGFloat one_srcH = 1.0/srcH;
    
    CGFloat dst_one_srcW = dstW * one_srcW;
    CGFloat one_hist = 1.0/255.0;
    CGFloat dat_one_hist = dstH * one_hist;
    
    if (_displayType == DJILiveViewColorMonitorDisplayTypeSeparate) {
        dst_one_srcW /= 3;
    }
    
    CGFloat renderScale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(dstW, dstH), NO, renderScale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(ctx, _lineBlendMode);
    
    //Calculate the concentration
    CGFloat lineWidth = MAX(0.01, MIN(1.0, _intensity * one_srcH));
    CGContextSetLineWidth(ctx, lineWidth); // the width of the line, use this to determine the color concentration
    
    //R channel
    NSUInteger pixelOffset = 2;
    CGContextSetRGBStrokeColor(ctx, 1.0, 0.5, 0.5, 1.0);
    
    if (displayType == DJILiveViewColorMonitorDisplayTypeSeparate) {
        for (NSUInteger col =0; col < inputWidth*3; col++) {
            points[col].x = DST_X_FROM_SRC(col);
        }
    }else{
        for (NSUInteger col =0; col < inputWidth; col++) {
            points[col].x = DST_X_FROM_SRC(col);
        }
    }
    
    for (NSUInteger row = 0; row < inputHeigh; row++) {
        
        rowPixel = inputBuffer + bytesPerRow*row;
        
        for (NSUInteger col = 0; col < inputWidth; col++) {
            
            pixel = rowPixel + (col<<2) + pixelOffset;
            points[col].y = DST_Y_FROM_HIST(*pixel);
        }
        
        CGContextAddLines(ctx, points, inputWidth);
    }
    CGContextStrokePath(ctx);

    
    //B channel
    NSUInteger colOffset = 0;
    pixelOffset = 0;
    if (displayType == DJILiveViewColorMonitorDisplayTypeSeparate) {
        colOffset = 2*inputWidth;
    }
    
    CGContextSetRGBStrokeColor(ctx, 0.5, 0.5, 1.0, 1.0);
    
    for (NSUInteger row = 0; row < inputHeigh; row++) {
        
        rowPixel = inputBuffer + bytesPerRow*row;
        
        for (NSUInteger col = 0; col < inputWidth; col++) {
            
            pixel = rowPixel + (col<<2) + pixelOffset;
            points[col + colOffset].y = DST_Y_FROM_HIST(*pixel);
        }
        
        CGContextAddLines(ctx, points + colOffset, inputWidth);
    }
    CGContextStrokePath(ctx);
    
    
    //G channel
    if (displayType == DJILiveViewColorMonitorDisplayTypeSeparate) {
        colOffset = inputWidth;
    }
    
    pixelOffset = 1;
    CGContextSetRGBStrokeColor(ctx, 0.5, 1.0, 0.5, 1.0);
    
    for (NSUInteger row = 0; row < inputHeigh; row++) {
        
        rowPixel = inputBuffer + bytesPerRow*row;
        
        for (NSUInteger col = 0; col < inputWidth; col++) {
            
            pixel = rowPixel + (col<<2) + pixelOffset;
            points[col + colOffset].y = DST_Y_FROM_HIST(*pixel);
        }
        
        CGContextAddLines(ctx, points + colOffset, inputWidth);
    }
    CGContextStrokePath(ctx);
    
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext(); //0.3s
    UIGraphicsEndImageContext();
    
    [input unlockAfterReading];
    [self pushFrameBuffer:input];
    if(imageHolder){
        imageHolder = nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self.renderedColorWaveFormView.subviews.count){
            [self.renderedColorWaveFormView.subviews.firstObject removeFromSuperview];
        }
        
        ((UIImageView*)self.renderedColorWaveFormView).image = result;
    });
}

- (void)performColorWaveRenderingPassUsingCoreGraphicsYChannelWithInputBuffer:(DJILiveViewFrameBuffer *)input{
        //working in background thread
    
    if (input == nil){
        return;
    }
    
    if(input.size.width == 0
       || input.size.height == 0) {
        [self pushFrameBuffer:input];
        return;
    }
    
    //input size check & buffer prepear
    NSUInteger inputWidth = input.size.width;
    NSUInteger inputHeigh = input.size.height;
    DJILiveViewColorMonitorDisplayType displayType = _displayType;
    
    //bytes read
    [input lockForReading];
    uint8_t* inputBuffer = [input byteBuffer];
    NSUInteger bytesPerRow = [input bytesPerRow];
    if (inputBuffer == nil) {
        [input unlockAfterReading];
        [self pushFrameBuffer:input];
        return;
    }
    
    NSUInteger pointCountRequired = inputWidth;
    if (displayType == DJILiveViewColorMonitorDisplayTypeSeparate) {
        pointCountRequired*=3;
    }
    if (pointsBufferSize < pointCountRequired) {
        if(pointsBuffer){
            free(pointsBuffer);
        }
        
        pointsBuffer = (CGPoint*)malloc(sizeof(CGPoint)*pointCountRequired);
        pointsBufferSize = pointCountRequired;
    }
    
    CGPoint* points = pointsBuffer;
    uint8_t* rowPixel, *pixel;
    CGFloat srcW = inputWidth;
    CGFloat srcH = inputHeigh;
    CGFloat dstW = self.renderedColorWaveFormView.bounds.size.width;
    CGFloat dstH = self.renderedColorWaveFormView.bounds.size.height;
    
    CGFloat one_srcW = 1.0/srcW;
    CGFloat one_srcH = 1.0/srcH;
    
    CGFloat dst_one_srcW = dstW * one_srcW;
    CGFloat one_hist = 1.0/255.0;
    CGFloat dat_one_hist = dstH * one_hist;
    
    
    
    CGFloat renderScale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(dstW, dstH), NO, renderScale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(ctx, _lineBlendMode);
    
    //Calculate the concentration
    CGFloat lineWidth = MAX(0.01, MIN(1.0, _intensity*2 * one_srcH));
    CGContextSetLineWidth(ctx, lineWidth); // The width of the line, use this to determine the color concentration
    
    //Y channel
    NSUInteger pixelOffset = 3;
    CGContextSetRGBStrokeColor(ctx, 1.0, 1.0, 1.0, 1.0);
    
  
    
    for (NSUInteger col =0; col < inputWidth; col++) {
        points[col].x = DST_X_FROM_SRC(col);
    }
    
    
    for (NSUInteger row = 0; row < inputHeigh; row++) {
        
        rowPixel = inputBuffer + bytesPerRow*row;
        
        for (NSUInteger col = 0; col < inputWidth; col++) {
            
            pixel = rowPixel + (col<<2) + pixelOffset;
            points[col].y = DST_Y_FROM_HIST(*pixel);
        }
        
        CGContextAddLines(ctx, points, inputWidth);
    }
    CGContextStrokePath(ctx);
    
    
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext(); //0.3s
    UIGraphicsEndImageContext();
    
    [input unlockAfterReading];
    [self pushFrameBuffer:input];
    if(imageHolder){
        imageHolder = nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self.renderedColorWaveFormView.subviews.count){
            [self.renderedColorWaveFormView.subviews.firstObject removeFromSuperview];
        }
        
        ((UIImageView*)self.renderedColorWaveFormView).image = result;
    });
}

@end
