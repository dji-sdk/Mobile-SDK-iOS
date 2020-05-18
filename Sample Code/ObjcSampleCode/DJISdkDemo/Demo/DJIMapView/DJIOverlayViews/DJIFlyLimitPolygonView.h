//
//  DJIFlyLimitPolygonView.h
//  Phantom3
//
//  Created by tony on 8/8/16.
//  Copyright © 2016 DJIDevelopers.com. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "DJIPolygon.h"

@interface DJIFlyLimitPolygonView : MKPolygonRenderer

- (id)initWithPolygon:(DJIPolygon *)polygon;

@end
