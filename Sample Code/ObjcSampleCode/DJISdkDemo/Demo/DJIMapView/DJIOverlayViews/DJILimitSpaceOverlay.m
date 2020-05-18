//
//  DJILimitSpaceOverlay.m
//  Phantom3
//
//  Created by DJISoft on 2017/1/19.
//  Copyright © 2017年 DJIDevelopers.com. All rights reserved.
//

#import "DJILimitSpaceOverlay.h"
#import "DJIFlyLimitCircleView.h"
#import "DJIPolygon.h"
#import "DJICircle.h"
#import "DJIMapPolygon.h"
#import "DJIFlyZoneColorProvider.h"
#define kDJILimitFlightSpaceBufferHeight (5)

@interface DJILimitSpaceOverlay()

@property (nonatomic, strong) DJIFlyZoneInformation *limitSpaceInfo;

@end

@implementation DJILimitSpaceOverlay

- (id)initWithLimitSpace:(DJIFlyZoneInformation *)limitSpaceInfo
{
    self = [super init];
    if (self) {
        _limitSpaceInfo = limitSpaceInfo;
        [self createOverlays];
    }
    
    return self;
}

- (NSArray<id<MKOverlay>> *)overlysForSubFlyZoneSpace:(DJISubFlyZoneInformation *)aSpace
{
	BOOL isHeightLimit = aSpace.maximumFlightHeight > 0 && aSpace.maximumFlightHeight < UINT16_MAX;
    if (aSpace.shape == DJISubFlyZoneShapeCylinder) {
        CLLocationCoordinate2D coordinateInMap = aSpace.center;
        DJICircle *circle = [DJICircle circleWithCenterCoordinate:coordinateInMap
                                                           radius:aSpace.radius];
        circle.lineWidth = [self strokLineWidthWithHeight:aSpace.maximumFlightHeight];
		circle.fillColor = [DJIFlyZoneColorProvider getFlyZoneOverlayColorWithCategory:_limitSpaceInfo.category isHeightLimit:isHeightLimit isFill:YES];
		circle.strokeColor = [DJIFlyZoneColorProvider getFlyZoneOverlayColorWithCategory:_limitSpaceInfo.category isHeightLimit:isHeightLimit isFill:NO];
        return @[circle];

    } else if(aSpace.shape == DJISubFlyZoneShapePolygon) {
        if (aSpace.vertices.count <= 0) {
            return @[];
        }
        
        CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D *)malloc(sizeof(CLLocationCoordinate2D) * aSpace.vertices.count);
        
        int i = 0;
        for (i = 0; i < aSpace.vertices.count; i++) {
            NSValue *aPointValue = aSpace.vertices[i];
            CLLocationCoordinate2D coordinate = [aPointValue MKCoordinateValue];
            CLLocationCoordinate2D coordinateInMap = coordinate;
            coordinates[i] = coordinateInMap;
            NSLog(@"coordiantes: %lf, %lf", coordinate.latitude, coordinate.longitude);
        }
        DJIMapPolygon *polygon = [DJIMapPolygon polygonWithCoordinates:coordinates count:aSpace.vertices.count];
        polygon.lineWidth = [self strokLineWidthWithHeight:aSpace.maximumFlightHeight];
		polygon.fillColor = [DJIFlyZoneColorProvider getFlyZoneOverlayColorWithCategory:_limitSpaceInfo.category isHeightLimit:isHeightLimit isFill:YES];
		polygon.strokeColor = [DJIFlyZoneColorProvider getFlyZoneOverlayColorWithCategory:_limitSpaceInfo.category isHeightLimit:isHeightLimit isFill:NO];
        free(coordinates);
        return @[polygon];
    }
    return nil;
}

- (NSArray<id<MKOverlay>> *)overlysForFlyZoneSpace:(DJIFlyZoneInformation *)aSpace
{
    if (!aSpace) {
        return @[];
    }
    if (aSpace.subFlyZones.count <= 0) {
        CLLocationCoordinate2D coordinateInMap = aSpace.center;
        CGFloat radius = aSpace.radius;
        DJIFlyLimitCircle *circle = [DJIFlyLimitCircle circleWithCenterCoordinate:coordinateInMap radius:radius];
        circle.innerRadius = radius;
        circle.outerRadius = 0.0f;
        circle.realCoordinate = coordinateInMap;
        circle.category = aSpace.category;
        circle.flyZoneID = aSpace.flyZoneID;
        circle.name = aSpace.name;
        return @[circle];
    } else {
        NSMutableArray *results = [NSMutableArray array];
        for (DJISubFlyZoneInformation *aSubSpace in aSpace.subFlyZones) {
            NSArray *subOverlays = [self overlysForSubFlyZoneSpace:aSubSpace];
            [results addObjectsFromArray:subOverlays];
        }
        
        return results;
    }
    return @[];
}

- (void)createOverlays
{
    self.subOverlays = [NSMutableArray array];
    NSArray *overlays = [self overlysForFlyZoneSpace:self.limitSpaceInfo];
    [self.subOverlays addObjectsFromArray:overlays];
}

-(CGFloat)strokLineWidthWithHeight:(NSInteger)height
{
    if (height <= 30 + kDJILimitFlightSpaceBufferHeight) {
        return 0;
    }
    return 1.0;
}

@end
