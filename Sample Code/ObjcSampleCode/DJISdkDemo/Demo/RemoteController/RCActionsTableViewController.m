//
//  RCActionsTableViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import "RCActionsTableViewController.h"
#import "RCHardwareStateViewController.h"
#import "RCParingViewController.h"
#import "RCGimbalControlViewController.h"
#import "DemoSettingItem.h"
#import "DemoComponentHelper.h"
#import <DJISDK/DJISDK.h>

@interface RCActionsTableViewController ()

@end

@implementation RCActionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sectionNames = [NSMutableArray arrayWithArray:@[@"General"]];
    
    DemoSettingItem* item1 = [DemoSettingItem itemWithName:@"RCHardwareState" andClass:[RCHardwareStateViewController class]];
    DemoSettingItem* item2 = [DemoSettingItem itemWithName:@"RCParing" andClass:[RCParingViewController class]];
    DemoSettingItem* item3 = [DemoSettingItem itemWithName:@"RCGimbalControl" andClass:[RCGimbalControlViewController class]];
    [self.items addObject:@[item1, item2, item3]];

}

-(DJIBaseComponent *)getComponent {
    return [DemoComponentHelper fetchRemoteController]; 
}


@end
