//
//  DJIMapOverlay.h
//  Phantom3
//
//  Created by DJISoft on 2017/1/19.
//  Copyright © 2017年 DJIDevelopers.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DJIMapOverlay : NSObject

@property (nonatomic, strong) NSMutableArray<id<MKOverlay>> *subOverlays;

@end
