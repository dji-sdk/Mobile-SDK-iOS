//
//  HandheldControllerActionsTableViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"
#import "HandheldControllerActionsTableViewController.h"
#import "SleepModeViewController.h"

@interface HandheldControllerActionsTableViewController ()

@end

@implementation HandheldControllerActionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sectionNames = [NSMutableArray arrayWithArray:@[@"General"]];
    [self.items addObject:@[[DemoSettingItem itemWithName:@"Sleep Mode" andClass:[SleepModeViewController class]]]];
}

-(DJIBaseComponent *)getComponent {
    return [DemoComponentHelper fetchHandheldController]; 
}

@end
