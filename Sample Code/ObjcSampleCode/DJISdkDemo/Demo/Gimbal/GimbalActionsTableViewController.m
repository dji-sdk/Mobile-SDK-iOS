//
//  GimbalActionsTableTableViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"
#import "GimbalActionsTableViewController.h"
#import "GimbalPushInfoViewController.h"
#import "GimbalRotationInSpeedViewController.h"

@interface GimbalActionsTableViewController ()

@end

@implementation GimbalActionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sectionNames = [NSMutableArray arrayWithArray:@[@"General"]];
    [self.items addObject:@[[DemoSettingItem itemWithName:@"Push Data" andClass:[GimbalPushInfoViewController class]],[DemoSettingItem itemWithName:@"Rotation with speed" andClass:[GimbalRotationInSpeedViewController class]]]];
    
}

-(DJIBaseComponent *)getComponent {
    return [DemoComponentHelper fetchGimbal];
}

@end
