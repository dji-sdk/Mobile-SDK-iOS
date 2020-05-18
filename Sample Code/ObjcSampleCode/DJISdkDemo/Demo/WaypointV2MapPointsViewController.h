//
//  WaypointV2MapPointsViewController.h
//  DJISdkDemo
//
//  Created by ethan.jiang on 2020/5/8.
//  Copyright © 2020 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJIFlightController.h>
@class WaypointV2ConfigItem;

NS_ASSUME_NONNULL_BEGIN

@interface WaypointV2MapPointsViewController : UIViewController <DJIFlightControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) WaypointV2ConfigItem *missionConfig;

@end

NS_ASSUME_NONNULL_END
