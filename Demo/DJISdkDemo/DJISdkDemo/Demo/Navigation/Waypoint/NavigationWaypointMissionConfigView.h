//
//  NavigationWaypointMissionConfigView.h
//  DJISdkDemo
//
//  Created by Ares on 15/8/4.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationWaypointMissionConfigView : UIView<UITextFieldDelegate>

@property(nonatomic, strong) IBOutlet UITextField* autoFlightSpeed;
@property(nonatomic, strong) IBOutlet UITextField* maxFlightSpeed;
@property(nonatomic, strong) IBOutlet UISegmentedControl* finishedAction;
@property(nonatomic, strong) IBOutlet UISegmentedControl* headingMode;
@property(nonatomic, strong) IBOutlet UISegmentedControl* airlineMode;
@property(nonatomic, strong) IBOutlet UIButton* okButton;

-(instancetype) initWithNib;

@end
