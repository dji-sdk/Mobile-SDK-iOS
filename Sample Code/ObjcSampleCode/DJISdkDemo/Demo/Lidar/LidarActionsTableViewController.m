//
//  LidarActionsTableViewController.m
//  DJISdkDemo
//
//  Created by neo.xu on 2021/8/2.
//  Copyright © 2021 DJI. All rights reserved.
//

#import "LidarActionsTableViewController.h"
#import "PointCloudRecordViewController.h"
#import "DemoUtility.h"

@interface LidarActionsTableViewController ()

@end

@implementation LidarActionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sectionNames = [NSMutableArray arrayWithArray:@[@"General"]];
    [self.items addObject:@[[DemoSettingItem itemWithName:@"point cloud record" andClass:[PointCloudRecordViewController class]]]];
}

-(DJIBaseComponent *)getComponent {
    return [DemoComponentHelper fetchLidar];
}

@end
