//
//  GSFlyLimitCircleView.m
//  DJEye
//
//  Created by Ares on 14-4-29.
//  Copyright (c) 2014年 Sachsen & DJI. All rights reserved.
//

#import "DJIFlyLimitCircleView.h"
#import <DJISDK/DJISDK.h>
#import "DJIFlyZoneColorProvider.h"

@implementation DJIFlyLimitCircleView

- (id)initWithCircle:(DJIFlyLimitCircle *)circle
{
    self = [super initWithCircle:circle];
    if (self) {
        
        if (circle.isClosed) {
            self.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
            self.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
        } else {
            self.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
            self.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.9];
        }
		
		self.fillColor = [DJIFlyZoneColorProvider getFlyZoneOverlayColorWithCategory:circle.category isHeightLimit:NO isFill:YES];
		self.strokeColor = [DJIFlyZoneColorProvider getFlyZoneOverlayColorWithCategory:circle.category isHeightLimit:NO isFill:NO];
		
        if (circle.outerRadius > circle.innerRadius) {
            self.lineWidth = 1.0;
        } else {
            self.lineWidth = 3.0f;
        }
        
    }
    
    return self;
}

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)context
{
    [super drawMapRect:mapRect zoomScale:zoomScale inContext:context];
    DJIFlyLimitCircle * limitCircle =(DJIFlyLimitCircle *)self.circle;
    MKMapPoint mapCenterPoint = MKMapPointForCoordinate(self.circle.coordinate);
    double mapPointPerMeter = MKMapPointsPerMeterAtLatitude(self.circle.coordinate.latitude);
    CGPoint viewCenterPoint = [self pointForMapPoint:mapCenterPoint];

    if (!limitCircle.isClosed) {
        return;
    }

    CGContextSaveGState(context);
    
    CGFloat rectWidth = 2 * limitCircle.innerRadius * mapPointPerMeter;
    CGRect ellipseRect = CGRectMake(viewCenterPoint.x - 0.5 * rectWidth, viewCenterPoint.y - 0.5 * rectWidth, rectWidth, rectWidth);
    CGFloat lineWidth = 5.0f * self.contentScaleFactor;
    CGContextSetLineWidth(context, lineWidth/zoomScale);
	
	UIColor *fillColor = [DJIFlyZoneColorProvider getFlyZoneOverlayColorWithCategory:limitCircle.category isHeightLimit:NO isFill:YES];
	CGContextSetStrokeColorWithColor(context,fillColor.CGColor);
	CGContextStrokeEllipseInRect(context, ellipseRect);
	UIColor *strokeColor = [DJIFlyZoneColorProvider getFlyZoneOverlayColorWithCategory:limitCircle.category isHeightLimit:NO isFill:NO];
	CGContextSetFillColorWithColor(context, strokeColor.CGColor);
	CGContextFillEllipseInRect(context, ellipseRect);
		

    CGContextRestoreGState(context);
}
@end
