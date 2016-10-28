//
//  ComponentSelectionViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file creates a view for user to choose a component in the connected product. 
 *  The components property of DJIBaseProduct is an NSDictionary. Each key/value represents a connected component in the product. 
 *  In this sample, we use the components property to initialize the table view. A connected component may be disconnected after the 
 *  initialization. Therefore, user need to set the view controller as the delegate of DJIBaseProduct to receive the connectivity changes 
 *  of the components.
 */

#import "ComponentSelectionViewController.h"
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"
#import "BatteryActionsTableViewController.h"
#import "GimbalActionsTableViewController.h"
#import "CameraActionsTableViewController.h"
#import "AirLinkActionsTableViewController.h"
#import "FCActionsTableViewController.h"
#import "RCActionsTableViewController.h"
#import "HandheldControllerActionsTableViewController.h"
#import "MobileRemoteControllerViewController.h"

#import "WaypointMissionViewController.h"
#import "HotpointMissionViewController.h"
#import "FollowMeMissionViewController.h"
#import "CustomMissionViewController.h"
#import "PanoramaMissionViewController.h"

@interface ComponentSelectionViewController () <DJIBaseProductDelegate>

@property(nonatomic) NSMutableArray *data;
@property(nonatomic, strong) NSArray* missions;

@end

@implementation ComponentSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Components & Missions";
    
    self.sectionNames = [NSMutableArray arrayWithArray:@[@"Components", @"Missions"]];
    
    [self initializeComponentSection];
    [self initializeMissionSection];
}


// Use DJIBaseProduct's components property to initialize the table view.
-(void) initializeComponentSection {
    NSMutableArray* components = [[NSMutableArray alloc] init];
    for (NSString* name in [[DemoComponentHelper fetchProduct].components allKeys]) {
        [components addObject:[DemoSettingItem itemWithName:[name capitalizedString] andClass:[[self componentVCDict] objectForKey:name]]];
    }
    
    [self.items addObject:components];
}

// Each type of component has the corresponding key name. We create an dictionary to mapping the key name and the corresponding view.
-(NSDictionary*) componentVCDict {
    static NSDictionary *componentsDict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        componentsDict = @{DJIBatteryComponent : [BatteryActionsTableViewController class],
                           DJIGimbalComponent : [GimbalActionsTableViewController class],
                           DJICameraComponent : [CameraActionsTableViewController class],
                           DJIAirLinkComponent : [AirLinkActionsTableViewController class],
                           DJIFlightControllerComponent : [FCActionsTableViewController class],
                           DJIRemoteControllerComponent : [RCActionsTableViewController class],
                           DJIHandheldControllerComponent : [HandheldControllerActionsTableViewController class],
                           DJIMobileRemoteControllerComponent : [MobileRemoteControllerViewController class],
                           };
        
    });
    return componentsDict;
}

// An aircraft can execute four types of missions while a handheld device can execute only the panorama mission.
-(void) initializeMissionSection {
    DJIBaseProduct* product = [DemoComponentHelper fetchProduct];
    if ([product isKindOfClass:[DJIAircraft class]]) {
        [self.items addObject:@[[DemoSettingItem itemWithName:@"Waypoint Mission" andClass:[WaypointMissionViewController class]],
                                [DemoSettingItem itemWithName:@"Hotpoint Mission" andClass:[HotpointMissionViewController class]],
                                [DemoSettingItem itemWithName:@"Follow-me Mission" andClass:[FollowMeMissionViewController class]],
                                [DemoSettingItem itemWithName:@"Custom Mission" andClass:[CustomMissionViewController class]]]];
    }
    else if ([product isKindOfClass:[DJIHandheld class]]) {
        [self.items addObject:@[[DemoSettingItem itemWithName:@"Panorama Mission" andClass:[PanoramaMissionViewController class]]]];
    }
    else {
        [self.items addObject:@[]];
    }
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([DemoComponentHelper fetchProduct]) {
        [[DemoComponentHelper fetchProduct] setDelegate:self];
    }
}

#pragma mark - DJIBaseProductDelegate

// Callback for the connectivity change for a component.
// 1. When a connected component is disconnected (newComponent is nil), we remove the corresponding item in the table.
// 2. When a new component is connected (newComponent is not nil), we add an item to the table.
-(void) componentWithKey:(NSString *)key changedFrom:(DJIBaseComponent *)oldComponent to:(DJIBaseComponent *)newComponent {
    if (oldComponent == nil && newComponent != nil) { // a new component is connected
        for (DemoSettingItem* item in self.items[0]) {
            if ([item.itemName isEqualToString:[key capitalizedString]]) {
                return;
            }
        }
        [self.items[0] addObject:[DemoSettingItem itemWithName:[key capitalizedString] andClass:[[self componentVCDict] objectForKey:key]]];
        [self.tableView reloadData];
        return;
    }

    for (DemoSettingItem* item in self.items[0]) {
        if ([item.itemName isEqualToString:[key capitalizedString]]) {
            if (oldComponent != nil && newComponent == nil) { // a component is disconnected
                [self.items[0] removeObject:item];
                [self.tableView reloadData];
                return;
            }
        }
    }
}

@end
