//
//  DJIRTPlayerRenderView.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import "DJICameraRemotePlayerView.h"
#import "DJIStreamCommon.h"
#import "DJIVideoHelper.h"


typedef NS_ENUM(NSInteger,LiveStreamDecodeType) {
    LiveStreamDecodeType_Software = 0, //Default
    LiveStreamDecodeType_VTHardware = 1,
};

@protocol FPSControlDelegate<NSObject>
@optional
///< for just decode ,=0 no need to sleep, >0 sleep time
-(double)frameSleepTime;
@end

@interface DJIRTPlayerRenderView : DJICameraRemotePlayerView

//rotation
@property (assign, nonatomic) VideoStreamRotationType rotation;
@property (assign, nonatomic) H264EncoderType encoderType;

-(id) initWithDecoderType:(LiveStreamDecodeType)decodeType
              encoderType:(H264EncoderType)encoderType;

-(void) decodeH264CompleteFrameData:(uint8_t*)data
                             length:(NSUInteger)size
                         decodeOnly:(BOOL)decodeOnly;

//return YES if contains a frame
-(BOOL) decodeH264RawData:(uint8_t*)data
                   length:(NSUInteger)size;

-(void) reDraw;
-(void) reDrawWithGrayout:(BOOL)gray;

/**
 *  Screen capture of the current view
 */
-(void) snapshotPreview:(void(^)(UIImage* snapshot))block;

@property (nonatomic,weak) id<FPSControlDelegate> delegate ;
@end
