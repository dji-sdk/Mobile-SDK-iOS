//
//  VideoPreviewer.h
//  DJI
//
//  Copyright (c) 2013年. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoFrameExtractor.h"
#import "MovieGLView.h"
#import "DJILinkQueues.h"

#define VIDEO_PREVIEWER_DISPATCH "video_preview_create_thread_dispatcher"

#define RENDER_FRAME_NUMBER (4)

#define kDJIDecoderDataSoureNone                    (0)
#define kDJIDecoderDataSoureInspire                 (1)
#define kDJIDecoderDataSourePhantom3Advanced        (4)
#define kDJIDecoderDataSourePhantom3Professional    (5)

typedef struct{
    BOOL isInit:1;  //是否已初始化
    BOOL isRunning:1;   //解码线程是否正在运行
    BOOL isPause:1;     //解码是否暂停
    BOOL hasImage:1;    //是否有图像数据
    BOOL isGLViewInit:1; //OpenGLView是否已经创建
    BOOL isBackground:1;    //是否进入到背景中
    uint8_t other:2;    //暂留
}VideoPreviewerStatus;

typedef NS_ENUM(NSUInteger, VideoPreviewerEvent){
    VideoPreviewerEventNoImage,     //解析不出图像
    VideoPreviewerEventHasImage,    //解析出现图像
};

@protocol VideoPreviewerDelegate <NSObject>

@optional

/**
 *  回调返回当前图像的状态
 *
 *  @param state 图像状态
 */
- (void)previewDidUpdateStatus;

/**
 *  VideoPreviewer事件通知
 *
 *  @param event 事件
 */
- (void)previewDidReceiveEvent:(VideoPreviewerEvent)event;

@end

/**
 *  视频预览组件，需引用第三方库FFMPEG。由解码器，数据缓冲队列，OpenGL渲染层组成。
 *  使用该组件，需先设置显示用的view，然后调用start开启解码线程。
 *  将视频数据push到dataQueue中，视频数据即开始进行解析并显示。
 */
@interface VideoPreviewer : NSObject
{
    NSThread *_decodeThread;    //解码线程
    MovieGLView *_glView;   //OpenGL渲染层
    VideoFrameYUV *_renderYUVFrame[RENDER_FRAME_NUMBER];
    int _decodeFrameIndex;   //解码帧
    int _renderFrameIndex;    //渲染帧
    
    dispatch_queue_t _dispatchQueue;
}

@property(nonatomic, assign) BOOL isHardwareDecoding;

/**
 *  解码器
 */
@property (retain) VideoFrameExtractor *videoExtractor;
/**
 *  数据通道
 */
@property(retain) DJILinkQueues *dataQueue;
/**
 *  解码组件状态
 */
@property (assign,readonly) VideoPreviewerStatus status;

@property (weak,nonatomic) id<VideoPreviewerDelegate> delegate;

+(VideoPreviewer*) instance;

/**
 *  设置显示的view
 *
 *  @param view 指定的View
 *
 *  @return 是否成功
 */
- (BOOL)setView:(UIView *)view;

/**
 *  去掉显示图像的view
 */
- (void)unSetView;

/**
 *  开始解码线程
 *
 *  @return 是否成功
 */
- (BOOL)start;

/**
 *  恢复解码图像
 */
- (void)resume;

/**
 *  暂停解码图像
 */
- (void)pause;

/**
 *  关闭解码线程
 *
 *  @return 是否成功
 */
- (void)close __attribute__ ((__deprecated__));

- (void)stop;

/**
 *  进入背景
 */
- (void)enterBackground;

/**
 *  进入前景
 */
- (void)enterForeground;

/**
 *  Set decoder's data source
 *
 *  @param type See reference kDJIDecoderDataSoureXXX
 */
- (void) setDecoderDataSource:(int)type;

@end
