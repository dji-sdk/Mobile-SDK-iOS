//
//  WaypointV2ConfigrationViewController.h
//  DJISdkDemo
//
//  Created by ethan.jiang on 2020/5/8.
//  Copyright © 2020 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJIWaypointV2MissionTypes.h>

NS_ASSUME_NONNULL_BEGIN

@interface WaypointV2ConfigItem : NSObject

@property (nonatomic, assign) float maxFlightSpeed;
@property (nonatomic, assign) float autoFlightSpeed;
@property (nonatomic, assign) DJIWaypointV2MissionFinishedAction finishedAction;
@property (nonatomic, assign) DJIWaypointV2MissionGotoFirstWaypointMode gotoFirstWaypointAction;
@property (nonatomic, assign) DJIWaypointV2MissionRCLostAction exitOnRCSignalLostAction;
@property (nonatomic, assign) NSUInteger repeatTimes;

@end

@interface WaypointV2ConfigrationViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@end

NS_ASSUME_NONNULL_END
