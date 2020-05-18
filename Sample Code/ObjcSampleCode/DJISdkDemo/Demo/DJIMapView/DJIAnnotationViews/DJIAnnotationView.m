//
//  DJIAnnotationView.m
//  Phantom3
//
//  Created by Jayce Yang on 14-4-10.
//  Copyright (c) 2014年 Jerome.zhang. All rights reserved.
//

#import "DJIAnnotationView.h"

#import "DJIAnnotation.h"
#import "DJIMapView.h"

/**
 *  动画参数
 */
static CGFloat const DropCompressAmount = 0.05f;

@interface DJIAnnotationView () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIView *containerView;

/**
 *  大头针图片
 */
@property (strong, nonatomic) UIImageView *imageView;

/**
 *  阴影图片
 */
@property (strong, nonatomic) UIImageView *shadowImageView;

/**
 *  序号标签
 */
@property (strong, nonatomic) UILabel *indexLabel;

/**
 *  距离背景
 */
@property (strong, nonatomic) UIImageView *distanceBackgroundImageView;

/**
 *  距离标签
 */
@property (strong, nonatomic) UILabel *distanceLabel;

/**
 *  顶部距离背景
 */
@property (strong, nonatomic) UIImageView *topDistanceBackgroundImageView;

/**
 *  顶部距离标签
 */
@property (strong, nonatomic) UILabel *topDistanceLabel;

/**
 *  平移手势
 */
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

/**
 *  偏好的尺寸
 */
@property (nonatomic) CGSize preferedSize;

@property (nonatomic) CGPoint preferedCenterOffset;

/**
 *  标记处于拖动模式
 */
@property (nonatomic) BOOL inPanningState;

@end

@implementation DJIAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size centerOffset:(CGPoint)offset
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.preferedSize = size;
        self.preferedCenterOffset = offset;
//        self.centerOffset = offset;
        [self setupDefaults];
    }
    return self;
}

- (void)dealloc
{
//    NSLog();
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

//- (void)didMoveToSuperview
//{
//    [super didMoveToSuperview];
//    
//    [self animateDrop];
//}

#pragma mark - Public

- (void)setAnnotation:(id<MKAnnotation>)annotation
{
    [super setAnnotation:annotation];
    
    DJIAnnotation *theAnnotation = annotation;
    if(self.indexLabel){
        self.indexLabel.text = theAnnotation.index;
    }
}

- (void)setDistanceIndicatorHidden:(BOOL)hidden
{
    self.distanceBackgroundImageView.hidden = hidden;
    self.distanceLabel.hidden = hidden;
}

- (void)setTopDistanceIndicatorHidden:(BOOL)hidden
{
    self.topDistanceBackgroundImageView.hidden = hidden;
    self.topDistanceLabel.hidden = hidden;
}

- (void)updateDistanceWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    CLLocation *startingLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    CLLocation *endingLocation = [[CLLocation alloc] initWithLatitude:self.annotation.coordinate.latitude longitude:self.annotation.coordinate.longitude];
    self.distanceLabel.text = [NSString stringWithFormat:@"%.1lfM", [startingLocation distanceFromLocation:endingLocation]];
    self.topDistanceLabel.text = self.distanceLabel.text;
}

- (void)animateDrop
{
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
//    animation.duration = 0.4;
//    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, CGRectGetHeight([UIScreen mainScreen].bounds) / - 4.f, 0)];
//    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation2.duration = 0.10;
//    animation2.beginTime = animation.duration;
    animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation2.toValue = [NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DMakeTranslation(0, self.layer.frame.size.height * DropCompressAmount, 0), 1.0, 1.0 - DropCompressAmount, 1.0)];
    animation2.fillMode = kCAFillModeForwards;
    
    CABasicAnimation *animation3 = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation3.duration = 0.15;
    animation3.beginTime = animation2.duration;
    animation3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation3.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation3.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = [NSArray arrayWithObjects:animation2, animation3, nil];
    group.duration = animation2.duration + animation3.duration;
    group.fillMode = kCAFillModeForwards;
    
    [self.imageView.layer addAnimation:group forKey:nil];
}

#pragma mark - Private

/**
 *  构建视图层级，并设置默认值
 */
- (void)setupDefaults
{
//    self.backgroundColor = [UIColor colorWithWhite:.5 alpha:.1];
    self.backgroundColor = [UIColor clearColor];
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.containerView.backgroundColor = [UIColor clearColor];
    self.containerView.clipsToBounds = NO;
//    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.containerView];


    self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.imageView];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTop multiplier:1 constant:self.preferedCenterOffset.y]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeBottom multiplier:1 constant:- self.preferedCenterOffset.y]];

    UIImage *shadowImage = [UIImage imageNamed:@"gs_annotation_shadow.png"];
    self.shadowImageView = [[UIImageView alloc] initWithImage:shadowImage];
    self.shadowImageView.backgroundColor = [UIColor clearColor];
    self.shadowImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView insertSubview:self.shadowImageView belowSubview:self.imageView];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.shadowImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeCenterX multiplier:1 constant:11]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.shadowImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeCenterY multiplier:1 constant:5]];
    [self.shadowImageView addConstraint:[NSLayoutConstraint constraintWithItem:self.shadowImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:shadowImage.size.width]];
    [self.shadowImageView addConstraint:[NSLayoutConstraint constraintWithItem:self.shadowImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:shadowImage.size.height]];
    
    self.indexLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.indexLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.indexLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0f];
    self.indexLabel.textColor = [UIColor whiteColor];
    self.indexLabel.backgroundColor = [UIColor clearColor];
    self.indexLabel.textAlignment = NSTextAlignmentCenter;
    [self.containerView addSubview:self.indexLabel];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.indexLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.indexLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeTop multiplier:1 constant:self.preferedSize.height * 0.15f]];
    
    self.distanceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.distanceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.distanceLabel.font = [UIFont fontWithName:@"BebasNeue" size:12.0f];
    self.distanceLabel.textColor = [UIColor whiteColor];
    self.distanceLabel.backgroundColor = [UIColor clearColor];
    [self.containerView addSubview:self.distanceLabel];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.distanceLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeLeft multiplier:1 constant:self.preferedSize.width / 2 + 5]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.distanceLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTop multiplier:1 constant:self.preferedSize.height / 2]];
    
    self.distanceBackgroundImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"gs_annocation_distance_background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 20, 20, 12)]];
    self.distanceBackgroundImageView.backgroundColor = [UIColor clearColor];
    self.distanceBackgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView insertSubview:self.distanceBackgroundImageView belowSubview:self.distanceLabel];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.distanceBackgroundImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.distanceLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:- 10]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.distanceBackgroundImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.distanceLabel attribute:NSLayoutAttributeRight multiplier:1 constant:8]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.distanceBackgroundImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.distanceLabel attribute:NSLayoutAttributeTop multiplier:1 constant:- 6]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.distanceBackgroundImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.distanceLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:4]];
    
    self.topDistanceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.topDistanceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.topDistanceLabel.font = [UIFont fontWithName:@"BebasNeue" size:20.0f];
    self.topDistanceLabel.textColor = [UIColor whiteColor];
    self.topDistanceLabel.backgroundColor = [UIColor clearColor];
    self.topDistanceLabel.textAlignment = NSTextAlignmentCenter;
    [self.containerView addSubview:self.topDistanceLabel];
    self.topDistanceLabel.hidden = YES;
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.topDistanceLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.topDistanceLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeTop multiplier:1 constant:self.preferedCenterOffset.y - self.preferedSize.height / 2]];
    
    //[[UIImage imageNamed:@"gs_annocation_top_distance_background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 5.5, 7, 5.5)]
    self.topDistanceBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gs_annocation_top_distance_background.png"]];
    self.topDistanceBackgroundImageView.backgroundColor = [UIColor clearColor];
    self.topDistanceBackgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView insertSubview:self.topDistanceBackgroundImageView belowSubview:self.topDistanceLabel];
    self.topDistanceBackgroundImageView.hidden = YES;
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.topDistanceBackgroundImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.topDistanceLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:- 4]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.topDistanceBackgroundImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.topDistanceLabel attribute:NSLayoutAttributeRight multiplier:1 constant:4]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.topDistanceBackgroundImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topDistanceLabel attribute:NSLayoutAttributeTop multiplier:1 constant:- 4]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.topDistanceBackgroundImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.topDistanceLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:8]];
    
    
#ifdef DJIAnnotationViewLongPressToDelete
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
//    longPressGesture.numberOfTapsRequired = 1;
    longPressGesture.numberOfTouchesRequired = 1;
    longPressGesture.delegate = self;
    [self.containerView addGestureRecognizer:longPressGesture];
#endif
    self.inPanningState = NO;
}



#ifdef DJIAnnotationViewLongPressToDelete
- (void)longPressAction:(UILongPressGestureRecognizer *)sender
{
//    NSLog();
    if (self.longPressHandler) {
        self.longPressHandler(sender.state);
    }
}
#endif

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
