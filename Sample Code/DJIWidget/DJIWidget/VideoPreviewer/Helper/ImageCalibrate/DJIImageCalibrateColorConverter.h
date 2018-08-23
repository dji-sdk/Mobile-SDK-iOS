//
//  DJIImageCalibrateColorConverter.h
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//
#ifndef DJIImageCalibrateColorConverter_h
#define DJIImageCalibrateColorConverter_h

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <DJIWidget/DJIStreamCommon.h>
#import <DJIWidget/DJILiveViewRenderPass.h>
#import <DJIWidget/DJILiveViewFrameBuffer.h>

@class DJIImageCalibrateColorConverter;

@protocol DJIImageCalibrateColorConverterHandlerProtocol <NSObject>
@required
/*
 * rgba->yuvData array count = 1(rgba);
 * yuv420Planer->yuvData array count = 3(y+u+v);
 * yuv420BiPlaner->yuvData array count = 2(y+uv)
 * yuvSlice array count same as the yuvData
 * fastupload, the pixelbuffer pointer, usually NULL in yuv
 */
-(void)colorConverter:(DJIImageCalibrateColorConverter*)converter
          passYUVData:(uint8_t**)yuvData
             yuvSlice:(int*)yuvSlice
         withFastload:(CVPixelBufferRef)fastload;
@end

@interface DJIImageCalibrateColorConverterHolder : NSObject<DJILiveViewRenderInput>
//target converter
@property (nonatomic,weak) DJIImageCalibrateColorConverter* converter;

@end

@interface DJIImageCalibrateColorConverter : NSObject

@property (nonatomic,weak) id<DJIImageCalibrateColorConverterHandlerProtocol> delegate;

-(instancetype)initWithFrameType:(VPFrameType)type;

//output type
@property (nonatomic,readonly) VPFrameType type;

//default NO
@property (nonatomic,assign) BOOL enabledConverter;

-(DJIImageCalibrateColorConverterHolder*)holder;

@end

#endif /* DJIImageCalibrateColorConverter_h */
