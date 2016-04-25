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
#import "FCIntelligentAssistantViewController.h"
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
    DemoSettingItem* item3 = [DemoSettingItem itemWithName:@"Landing Gear" andClass:[FCLandingGearViewController class]];
    DemoSettingItem* item4 = [DemoSettingItem itemWithName:@"Intelligent Flight Assistant" andClass:[FCIntelligentAssistantViewController class]];
    NSMutableArray* array = [[NSMutableArray alloc] initWithArray:@[item0, item1, item2]];
    if (fc && fc.isLandingGearMovable) {
        [array addObject:item3];
    }
    if (fc && fc.intelligentFlightAssistant) {
        [array addObject:item4];
    }
    
    [self.items addObject:array];
    
    // Orientation Mode
    [self.items addObject:@[[DemoSettingItem itemWithName:@"Orientation Mode" andClass:[FCOrientationViewController class]]]];
    
    // Virtual Stick
    [self.items addObject:@[[DemoSettingItem itemWithName:@"Virtual Stick" andClass:[FCVirtualStickViewController class]]]];
}

-(DJIBaseComponent *)getComponent {
    return [DemoComponentHelper fetchFlightController]; 
}

@end
