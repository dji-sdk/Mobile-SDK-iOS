//
//  DJILogerViewController.m
//  DJISdkDemo
//
//  Created by Ares on 15/2/15.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "DJILogerViewController.h"

@interface DJILogerViewController ()

@end

@implementation DJILogerViewController
{
    UITapGestureRecognizer* mTapGesture;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    mTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackgroundViewTaped:)];
    mTapGesture.numberOfTapsRequired = 2;
    mTapGesture.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:mTapGesture];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view removeGestureRecognizer:mTapGesture];
}

-(void) onBackgroundViewTaped:(id)sender
{
    DJILogerView* logerView = [DJILogerView sharedView];
    if (logerView.superview && logerView.superview != self.view) {
        [logerView removeFromSuperview];
    }
    if (logerView.superview == nil) {
        logerView.center = self.view.center;
        [self.view addSubview:logerView];
        [self.view bringSubviewToFront:logerView];
    }
}

@end
