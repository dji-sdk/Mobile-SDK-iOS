//
//  NavigationWaypointMissionConfigView.m
//  DJISdkDemo
//
//  Created by Ares on 15/8/4.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "NavigationWaypointMissionConfigView.h"

@implementation NavigationWaypointMissionConfigView

-(instancetype) initWithNib
{
    NSArray* objs = [[NSBundle mainBundle] loadNibNamed:@"NavigationWaypointMissionConfigView" owner:self options:nil];
    UIView* mainView = [objs objectAtIndex:0];
    self = [super initWithFrame:mainView.bounds];
    if (self) {
        mainView.layer.cornerRadius = 5.0;
        mainView.layer.masksToBounds = YES;
        [self addSubview:mainView];
    }
    
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
