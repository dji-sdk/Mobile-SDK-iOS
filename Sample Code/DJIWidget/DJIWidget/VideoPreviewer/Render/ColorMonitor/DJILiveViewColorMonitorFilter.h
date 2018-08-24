//
//  DJILiveViewColorMonitorFilter.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//


#import "DJILiveViewRenderFilter.h"


typedef enum : NSUInteger {
    DJILiveViewColorMonitorRenderModeHistgram, //Based on histogram generation
    DJILiveViewColorMonitorRenderModeLines, //Generate based on color lines
} DJILiveViewColorMonitorRenderMode;

typedef enum : NSUInteger {
    DJILiveViewColorMonitorDisplayTypeCombine =0, //Merge display
    DJILiveViewColorMonitorDisplayTypeSeparate =1, //Split display
    DJILiveViewColorMonitorDisplayTypeYChannel = 2, //brightness
} DJILiveViewColorMonitorDisplayType;

/*
 * Color oscilloscope, due to the need for histogram operation, using buffered rendering to the CPU for processing
 */
@interface DJILiveViewColorMonitorFilter : DJILiveViewRenderFilter

//image output, can be changed, for RKVO
@property (nonatomic, strong) UIView* renderedColorWaveFormView;

//render mode
@property (nonatomic, assign) DJILiveViewColorMonitorRenderMode renderMode;
@property (nonatomic, assign) DJILiveViewColorMonitorDisplayType displayType;

// default 2
@property(readwrite, nonatomic) CGFloat intensity;

//blend mode for line drawing rander method
@property (readwrite, nonatomic) CGBlendMode lineBlendMode;

@property (nonatomic, assign) float colorMonitorScaleFactor;
@end
