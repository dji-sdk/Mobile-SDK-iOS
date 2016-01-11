//
//  BatteryActionsTableViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"
#import "BatteryActionsTableViewController.h"
#import "BatterySelfDischargeViewController.h"

@implementation BatteryActionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sectionNames = [NSMutableArray arrayWithArray:@[@"General"]];
    [self.items addObject:@[[DemoSettingItem itemWithName:@"Set/Get Self-discharge Day" andClass:[BatterySelfDischargeViewController class]]]];
}

-(DJIBaseComponent *)getComponent {
    return [DemoComponentHelper fetchBattery]; 
}

@end
