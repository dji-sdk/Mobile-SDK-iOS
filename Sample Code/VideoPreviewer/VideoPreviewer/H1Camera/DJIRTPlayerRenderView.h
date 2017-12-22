//
//  DJIRTPlayerRenderView.h
//  Copyright © 2016年 DJIDevelopers.com. All rights reserved.
//

#import "DJICameraRemotePlayerView.h"
#import "DJIStreamCommon.h"
#import "DJIVideoHelper.h"


typedef NS_ENUM(NSInteger,LiveStreamDecodeType) {
    LiveStreamDecodeType_Software = 0, //默认使用软件解码
    LiveStreamDecodeType_VTHardware = 1,
};

@protocol FPSControlDelegate<NSObject>
@optional
//<0 for just decode ,=0 no need to sleep, >0 sleep time
-(double)frameSleepTime;
@end

//解码+渲染，大礼包
//基本上就是一个同步版本的VideoPreviewer
@interface DJIRTPlayerRenderView : DJICameraRemotePlayerView

//rotation
@property (assign, nonatomic) VideoStreamRotationType rotation;
@property (assign, nonatomic) H264EncoderType encoderType;

-(id) initWithDecoderType:(LiveStreamDecodeType)decodeType
              encoderType:(H264EncoderType)encoderType;

//输入完整帧数据
-(void) decodeH264CompleteFrameData:(uint8_t*)data
                             length:(NSUInteger)size
                         decodeOnly:(BOOL)decodeOnly;

//输入需要组帧的数据
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
