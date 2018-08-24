//
//  DJIDecodeImageCalibrateDataBuffer.h
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#ifndef DJIDecodeImageCalibrateDataBuffer_h
#define DJIDecodeImageCalibrateDataBuffer_h

#import "DJILiveViewFrameBuffer.h"

@class DJIDecodeImageCalibrateDataBuffer;

@protocol DJIDecodeImageCalibrateDataBufferHandlerDelegate<NSObject>
@required
-(void)dataBuffer:(DJIDecodeImageCalibrateDataBuffer*)dataBuffer
  arrivalRGBAData:(uint8_t*)rgbaData
         withSize:(CGSize)size;

@end

@interface DJIDecodeImageCalibrateDataBuffer : DJILiveViewFrameBuffer

//call back via delegate
-(void)requestRGBAPixelBuffer;

//direct return buffer
-(uint8_t*)rgbaPixelBuffer;

//render buffer, for fast upload
-(CVPixelBufferRef)renderTarget;

@property (nonatomic,weak) id<DJIDecodeImageCalibrateDataBufferHandlerDelegate> dataBufferHandler;

@property (nonatomic,assign) NSUInteger bufferFlag;

@end

#endif /* DJIDecodeImageCalibrateDataBuffer_h */
