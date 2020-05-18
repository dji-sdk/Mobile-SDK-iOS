//
//  DJIAnnotationView.h
//  Phantom3
//
//  Created by Jayce Yang on 14-4-10.
//  Copyright (c) 2014年 Jerome.zhang. All rights reserved.
//

#import <MapKit/MapKit.h>

#ifndef DJIAnnotationViewLongPressToDelete
//#define DJIAnnotationViewLongPressToDelete
#endif

@class DJIMapView;

@interface DJIAnnotationView : MKAnnotationView

/**
 *  大头针图片视图
 */
@property (readonly, strong, nonatomic) UIImageView *imageView;

/**
 *  距离标签
 */
//@property (readonly, strong, nonatomic) UILabel *distanceLabel;

/**
 *  引用DJIMapView
 */
@property (weak, nonatomic) DJIMapView *DJIMapView;

/**
 *  平移回调
 */
@property (copy, nonatomic) void (^panHandler)(UIGestureRecognizerState state, CGPoint point);

@property (copy, nonatomic) void (^longPressHandler)(UIGestureRecognizerState state);

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size centerOffset:(CGPoint)offset;

/**
 *  隐藏或者显示距离指示器，默认显示
 *
 *  @param hidden 若为真，隐藏；否则，显示
 */
- (void)setDistanceIndicatorHidden:(BOOL)hidden;

- (void)setTopDistanceIndicatorHidden:(BOOL)hidden;

- (void)updateDistanceWithCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 *  对标注进行动画
 */
- (void)animateDrop;

@end
