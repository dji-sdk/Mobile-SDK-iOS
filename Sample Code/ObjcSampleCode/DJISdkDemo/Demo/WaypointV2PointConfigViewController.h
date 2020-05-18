//
//  WaypointV2PointConfigViewController.h
//  DJISdkDemo
//
//  Created by ethan.jiang on 2020/5/12.
//  Copyright © 2020 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJIWaypointV2.h>

NS_ASSUME_NONNULL_BEGIN

@interface WaypointV2PointConfigViewController : UIViewController

@property (nonatomic, strong) NSArray <DJIWaypointV2 *> *waypoints;

@end

NS_ASSUME_NONNULL_END
