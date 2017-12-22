//
//  DJILiveViewColorMonitorFilter.h
//

#import "DJILiveViewRenderFilter.h"

/*
 * from zisheng.cao
 * 色彩示波器, 由于需要直方图运算, 使用双缓冲渲染到CPU中进行处理
 */
@interface DJILiveViewColorMonitorFilter : DJILiveViewRenderFilter

//image output, can be changed, for RKVO
@property (nonatomic, strong) UIView* monitor;
@end
