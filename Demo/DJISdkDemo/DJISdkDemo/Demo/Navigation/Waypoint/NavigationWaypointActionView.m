//
//  NavigationWaypointActionView.m
//  DJISdkDemo
//
//  Created by Ares on 15/8/4.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "NavigationWaypointActionView.h"

@implementation NavigationWaypointActionView

-(instancetype) initWithNib
{
    NSArray* objs = [[NSBundle mainBundle] loadNibNamed:@"NavigationWaypointActionView" owner:self options:nil];
    UIView* mainView = [objs objectAtIndex:0];
    self = [super initWithFrame:mainView.bounds];
    if (self) {
        self.okButton.layer.cornerRadius = 4.0;
        self.okButton.layer.borderColor = [UIColor blueColor].CGColor;
        self.okButton.layer.borderWidth = 1.2;
        
        mainView.layer.cornerRadius = 5.0;
        mainView.layer.masksToBounds = YES;
        self.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.7];
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
