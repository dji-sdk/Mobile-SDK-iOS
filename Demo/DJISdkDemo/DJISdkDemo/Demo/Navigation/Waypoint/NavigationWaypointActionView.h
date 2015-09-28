//
//  NavigationWaypointActionView.h
//  DJISdkDemo
//
//  Created by Ares on 15/8/4.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationWaypointActionView : UIView<UITextFieldDelegate>

@property(nonatomic, strong) IBOutlet UISegmentedControl* actionType;
@property(nonatomic, strong) IBOutlet UITextField* actionParam;
@property(nonatomic, strong) IBOutlet UIButton* okButton;

-(instancetype) initWithNib;

@end
