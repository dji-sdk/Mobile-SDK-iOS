//
//  DJIFlyLimitPolygonView.m
//  Copyright © 2016 DJIDevelopers.com. All rights reserved.
//

#import "DJIFlyLimitPolygonView.h"
#import <DJISDK/DJISDK.h>
#import "DJIFlyZoneColorProvider.h"

@implementation DJIFlyLimitPolygonView

#pragma mark - life cycle
- (id)initWithPolygon:(DJIPolygon *)polygon {
    if (self = [super initWithPolygon:polygon]) {
		self.fillColor = [DJIFlyZoneColorProvider getFlyZoneOverlayColorWithCategory:polygon.level isHeightLimit:NO isFill:YES];
		self.strokeColor = [DJIFlyZoneColorProvider getFlyZoneOverlayColorWithCategory:polygon.level isHeightLimit:NO isFill:NO];
        self.lineJoin = kCGLineJoinBevel;
        self.lineCap = kCGLineCapButt;
    }
    return self;
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    [super drawMapRect:mapRect zoomScale:zoomScale inContext:context];
    /*
    MKMapPoint *points = self.polygon.points;
    NSUInteger pointsCount = self.polygon.pointCount;
    //step 1：创建路径
    CGMutablePathRef path = CGPathCreateMutable();
    //step 2：设置路径起始点
    CGPoint startPoint = [self pointForMapPoint:points[0]];
    CGPathMoveToPoint(path, nil, startPoint.x, startPoint.y);
    //step 3：绘制路径
    for (int i = 0; i < pointsCount; i++) {
        CGPoint polygonPoint = [self pointForMapPoint:points[i]];
        CGPathAddLineToPoint(path, nil, polygonPoint.x, polygonPoint.y);
    }
    //step 4：将路径添加到上下文
    CGContextAddPath(context, path);
    //step 5：设置绘制参数
    CGContextSetStrokeColorWithColor(context, UIColorFromRGBA(0xACDF31, 1).CGColor);//设置笔触颜色
    CGContextSetFillColorWithColor(context, UIColorFromRGBA(0xFEC300, 0.1).CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);//最后一个参数是填充类型
    //step 6：释放路径
    CGPathRelease(path);
     */
}

@end
