//
//  DJILiveViewColorMonitorFilter.h
//

#import "DJILiveViewRenderFilter.h"


typedef enum : NSUInteger {
    DJILiveViewColorMonitorRenderModeHistgram, //基于直方图生成
    DJILiveViewColorMonitorRenderModeLines, //基于色彩线条生成
} DJILiveViewColorMonitorRenderMode;

typedef enum : NSUInteger {
    DJILiveViewColorMonitorDisplayTypeCombine =0, //合并显示
    DJILiveViewColorMonitorDisplayTypeSeparate =1, //拆分显示
    DJILiveViewColorMonitorDisplayTypeYChannel = 2, //亮度
} DJILiveViewColorMonitorDisplayType;

/*
 *
 * 色彩示波器, 由于需要直方图运算, 使用缓冲渲染到CPU中进行处理
 */
@interface DJILiveViewColorMonitorFilter : DJILiveViewRenderFilter

//image output, can be changed, for RKVO
@property (nonatomic, strong) UIView* monitor;

//render mode
@property (nonatomic, assign) DJILiveViewColorMonitorRenderMode renderMode;
@property (nonatomic, assign) DJILiveViewColorMonitorDisplayType displayType;

// default 2
@property(readwrite, nonatomic) CGFloat intensity;

//blend mode for line drawing rander method
@property (readwrite, nonatomic) CGBlendMode lineBlendMode;

@property (nonatomic, assign) float colorMonitorScaleFactor;
@end
