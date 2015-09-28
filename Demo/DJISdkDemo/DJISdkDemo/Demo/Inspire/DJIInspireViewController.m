//
//  DJIInspirePhantomViewController.m
//  DJISdkDemo
//
//  Created by Ares on 14-6-27.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "DJIInspireViewController.h"
#import "InspireCameraTestViewController.h"
#import "InspireGimbalTestViewController.h"
#import "InspireBatteryTestViewController.h"
#import "InspireMainControllerTestViewController.h"
#import "InspireRemoteControllerTestViewController.h"
#import "InspireImageTransmitterTestViewController.h"
#import "NavigationViewController.h"
#import "Phantom3MediaTestTableViewController.h"
#import "DJIVersionManager.h"
#import <DJISDK/DJISDK.h>

@interface DJIInspireViewController ()

@property(nonatomic, strong) NSMutableDictionary* versionDict;

@property(nonatomic, strong) DJIVersionManager* versionManager;

@end

@implementation DJIInspireViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.versionDict = [[NSMutableDictionary alloc] init];
    if (self.connectedDrone) {
        self.title = [DJIDemoHelper droneName:self.connectedDrone.droneType];
        self.versionManager = [[DJIVersionManager alloc] initWithDrone:self.connectedDrone];
        [self.versionManager getVersionWithResult:^(NSString *version, DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                NSString* ver = [NSString stringWithFormat:@"Version:%@", version];
                self.versionLabel.text = ver;
            }
            else
            {
                ShowResult(@"Get Version Error:%@", error.errorDescription);
            }
        }];
    }
    else
    {
        self.title = [DJIDemoHelper droneName:DJIDrone_Inspire];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.toolbarHidden = YES;
}

-(IBAction) onCameraButtonClicked:(id)sender
{
    InspireCameraTestViewController* cameraTestViewController = [[InspireCameraTestViewController alloc] initWithDrone:self.connectedDrone];
    [self.navigationController presentViewController:cameraTestViewController animated:YES completion:nil];
}

-(IBAction) onManinControllerButtonClicked:(id)sender
{
    InspireMainControllerTestViewController* mcViewController = [[InspireMainControllerTestViewController alloc] initWithDrone:self.connectedDrone];
    [self.navigationController pushViewController:mcViewController animated:YES];
}

-(IBAction) onNavigationButtonClicked:(id)sender
{
    NavigationViewController* navViewController = nil;
    if (self.connectedDrone) {
        navViewController = [[NavigationViewController alloc] initWithDrone:self.connectedDrone];
    }
    else
    {
        navViewController = [[NavigationViewController alloc] initWithDroneType:DJIDrone_Inspire];
    }
    
    [self.navigationController pushViewController:navViewController animated:YES];
}

-(IBAction) onGimbalButtonClicked:(id)sender
{
    InspireGimbalTestViewController* gimbalViewController = [[InspireGimbalTestViewController alloc] initWithDrone:self.connectedDrone];
    [self.navigationController pushViewController:gimbalViewController animated:YES];
}

-(IBAction) onBatteryButtonClicked:(id)sender
{
    InspireBatteryTestViewController* batteryViewController = [[InspireBatteryTestViewController alloc] initWithDrone:self.connectedDrone];
    [self.navigationController pushViewController:batteryViewController animated:YES];
}

-(IBAction) onRemoteControllerButtonClicked:(id)sender
{
    InspireRemoteControllerTestViewController* rcViewController = [[InspireRemoteControllerTestViewController alloc] initWithDrone:self.connectedDrone];
    [self.navigationController pushViewController:rcViewController animated:YES];
}

-(IBAction) onImageTransmitterButtonClicked:(id)sender
{
    InspireImageTransmitterTestViewController* transmitterViewController = [[InspireImageTransmitterTestViewController alloc] initWithDrone:self.connectedDrone];
    [self.navigationController pushViewController:transmitterViewController animated:YES];
}

-(IBAction) onMediaButtonClicked:(id)sender
{
    Phantom3MediaTestTableViewController* mediaTestVC = nil;
    if (self.connectedDrone) {
        mediaTestVC = [[Phantom3MediaTestTableViewController alloc] initWithDrone:self.connectedDrone];
    }
    else
    {
        mediaTestVC = [[Phantom3MediaTestTableViewController alloc] initWithDroneType:DJIDrone_Inspire];
    }
    
    [self.navigationController pushViewController:mediaTestVC animated:YES];
}

@end
