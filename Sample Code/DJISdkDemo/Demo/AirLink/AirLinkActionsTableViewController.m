//
//  AirLinkActionsTableViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"
#import "AirLinkActionsTableViewController.h"
#import "WiFiLinkSSIDViewController.h"
#import "RebootWiFiViewController.h"
#import "SetGetChannelViewController.h"

@implementation AirLinkActionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sectionNames = [NSMutableArray arrayWithArray:@[@"WiFiLink", @"Lightbridge"]];
    [self.items addObject:@[[DemoSettingItem itemWithName:@"Set/Get WiFi SSID" andClass:[WiFiLinkSSIDViewController class]],
                            [DemoSettingItem itemWithName:@"Reboot WiFi" andClass:[RebootWiFiViewController class]]]];
    
    [self.items addObject:@[[DemoSettingItem itemWithName:@"Set/Get Channel" andClass:[SetGetChannelViewController class]]]];
    
    // The AirLink doesn't support firmware version checking and serial number checking.
}

@end
