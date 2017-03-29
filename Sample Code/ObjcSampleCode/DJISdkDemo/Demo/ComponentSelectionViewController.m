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

#import "WaypointMissionViewController.h"
#import "HotpointMissionViewController.h"
#import "FollowMeMissionViewController.h"
#import "TimelineMissionViewController.h"
#import "PanoramaMissionViewController.h"

#import "KeyedInterfaceViewController.h"

@interface ComponentSelectionViewController () <DJIBaseProductDelegate>

@property(nonatomic) NSMutableArray *data;
@property(nonatomic, strong) NSArray* missions;

@end

@implementation ComponentSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Components & Missions";
    
    self.sectionNames = [NSMutableArray arrayWithArray:@[@"SDK 4.0 New Interfaces", @"Components"]];
    
    [self initializeSDK40Section];
    [self initializeComponentSection];
}

- (void)initializeSDK40Section {
    DJIBaseProduct* product = [DemoComponentHelper fetchProduct];
    NSMutableArray *sdk40Interfaces = [NSMutableArray new];
    
    if ([product isKindOfClass:[DJIAircraft class]]) {
        [sdk40Interfaces addObject:[DemoSettingItem itemWithName:@"Waypoint Mission Operator" andClass:[WaypointMissionViewController class]]];
        [sdk40Interfaces addObject:[DemoSettingItem itemWithName:@"Hotpoint Mission Operator" andClass:[HotpointMissionViewController class]]];
        [sdk40Interfaces addObject:[DemoSettingItem itemWithName:@"FollowMe Mission Operator" andClass:[FollowMeMissionViewController class]]];
        [sdk40Interfaces addObject:[DemoSettingItem itemWithName:@"Timeline Mission Operator" andClass:[TimelineMissionViewController class]]];
    } else if ([product isKindOfClass:[DJIHandheld class]]) {
    	[sdk40Interfaces addObject:[DemoSettingItem itemWithName:@"Panorama Mission Operator" andClass:[PanoramaMissionViewController class]]];
    }
    
    [sdk40Interfaces addObject:[DemoSettingItem itemWithName:@"Keyed Interface" andClass:[KeyedInterfaceViewController class]]];
    
    [self.items addObject:sdk40Interfaces];
}

// Use DJIBaseProduct's components property to initialize the table view.
-(void) initializeComponentSection {
    NSMutableArray* components = [[NSMutableArray alloc] init];
    
    if ([DemoComponentHelper fetchBattery]) {
        [components addObject:[DemoSettingItem itemWithName:[DJIBatteryComponent capitalizedString] andClass:[[self componentVCDict] objectForKey:DJIBatteryComponent]]];
    }
    if ([DemoComponentHelper fetchGimbal]) {
        [components addObject:[DemoSettingItem itemWithName:[DJIGimbalComponent capitalizedString] andClass:[[self componentVCDict] objectForKey:DJIGimbalComponent]]];
    }
    if ([DemoComponentHelper fetchCamera]) {
        [components addObject:[DemoSettingItem itemWithName:[DJICameraComponent capitalizedString] andClass:[[self componentVCDict] objectForKey:DJICameraComponent]]];
    }
    if ([DemoComponentHelper fetchAirLink]) {
        [components addObject:[DemoSettingItem itemWithName:[DJIAirLinkComponent capitalizedString] andClass:[[self componentVCDict] objectForKey:DJIAirLinkComponent]]];
    }
    if ([DemoComponentHelper fetchFlightController]) {
        [components addObject:[DemoSettingItem itemWithName:[DJIFlightControllerComponent capitalizedString] andClass:[[self componentVCDict] objectForKey:DJIFlightControllerComponent]]];
    }
    if ([DemoComponentHelper fetchRemoteController]) {
        [components addObject:[DemoSettingItem itemWithName:[DJIRemoteControllerComponent capitalizedString] andClass:[[self componentVCDict] objectForKey:DJIRemoteControllerComponent]]];
    }
    if ([DemoComponentHelper fetchHandheldController]) {
        [components addObject:[DemoSettingItem itemWithName:[DJIHandheldControllerComponent capitalizedString] andClass:[[self componentVCDict] objectForKey:DJIHandheldControllerComponent]]];
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
                           };
        
    });
    return componentsDict;
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
        for (DemoSettingItem* item in self.items[1]) {
            if ([item.itemName isEqualToString:[key capitalizedString]]) {
                return;
            }
        }
        [self.items[1] addObject:[DemoSettingItem itemWithName:[key capitalizedString] andClass:[[self componentVCDict] objectForKey:key]]];
        [self.tableView reloadData];
        return;
    }

    for (DemoSettingItem* item in self.items[1]) {
        if ([item.itemName isEqualToString:[key capitalizedString]]) {
            if (oldComponent != nil && newComponent == nil) { // a component is disconnected
                [self.items[1] removeObject:item];
                [self.tableView reloadData];
                return;
            }
        }
    }
}

@end
