//
//  FCActionsTableViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import "FCActionsTableViewController.h"
#import "DemoSettingItem.h"
#import "DemoComponentHelper.h"
#import "FCLandingGearViewController.h"
#import "FCCompassViewController.h"
#import "FCOrientationViewController.h"
#import "FCVirtualStickViewController.h"
#import "FCFlightLimitationViewController.h"
#import "FCGeneralControlViewController.h"
#import <DJISDK/DJISDK.h>

@interface FCActionsTableViewController ()

@end

@implementation FCActionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    self.sectionNames = [NSMutableArray arrayWithArray:@[@"General", @"Orientation Mode", @"Virtural Stick"]];
    
    //General
    DemoSettingItem* item0 = [DemoSettingItem itemWithName:@"General Control" andClass:[FCGeneralControlViewController class]];
    DemoSettingItem* item1 = [DemoSettingItem itemWithName:@"Compass" andClass:[FCCompassViewController class]];
    DemoSettingItem* item2 = [DemoSettingItem itemWithName:@"Flight Limitation" andClass:[FCFlightLimitationViewController class]];
    if (fc && fc.landingGear.isLandingGearMovable) {
        DemoSettingItem* item3 = [DemoSettingItem itemWithName:@"Landing Gear" andClass:[FCCompassViewController class]];
        [self.items addObject:@[item0, item1, item2, item3]];
    }
    else
    {
        [self.items addObject:@[item0, item1, item2]];
    }
    
    // Orientation Mode
    [self.items addObject:@[[DemoSettingItem itemWithName:@"Orientation Mode" andClass:[FCOrientationViewController class]]]];
    
    // Virtual Stick
    [self.items addObject:@[[DemoSettingItem itemWithName:@"Virtual Stick" andClass:[FCVirtualStickViewController class]]]];
}


-(DJIBaseComponent *)getComponent {
    return [DemoComponentHelper fetchFlightController]; 
}

@end
