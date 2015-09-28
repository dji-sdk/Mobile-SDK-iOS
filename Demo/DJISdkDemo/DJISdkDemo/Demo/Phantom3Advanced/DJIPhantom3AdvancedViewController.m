//
//  DJIInspirePhantomViewController.m
//  DJISdkDemo
//
//  Created by Ares on 14-6-27.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "DJIPhantom3AdvancedViewController.h"
#import "Phantom3AdvancedCameraTestViewController.h"
#import "Phantom3AdvancedGimbalTestViewController.h"
#import "Phantom3AdvancedBatteryTestViewController.h"
#import "Phantom3AdvancedMainControllerTestViewController.h"
#import "NavigationViewController.h"
#import "Phantom3MediaTestTableViewController.h"
#import "Phantom3AdvancedRemoteControllerTestViewController.h"
#import "InspireImageTransmitterTestViewController.h"
#import "DJIVersionManager.h"

@interface DJIPhantom3AdvancedViewController ()

@property(nonatomic, strong) DJIVersionManager* versionManager;

@end

@implementation DJIPhantom3AdvancedViewController

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
    
    if (self.connectedDrone) {
        self.title = [DJIDemoHelper droneName:self.connectedDrone.droneType];
        self.versionManager = [[DJIVersionManager alloc] initWithDrone:self.connectedDrone];
        [self.versionManager getVersionWithResult:^(NSString *version, DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                NSString* ver = [NSString stringWithFormat:@"Version: %@", version];
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
        self.title = [DJIDemoHelper droneName:DJIDrone_Phantom3Advanced];
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
    Phantom3AdvancedCameraTestViewController* cameraTestViewController = [[Phantom3AdvancedCameraTestViewController alloc] initWithDrone:self.connectedDrone];
    [self.navigationController presentViewController:cameraTestViewController animated:YES completion:nil];
}

-(IBAction) onManinControllerButtonClicked:(id)sender
{
    Phantom3AdvancedMainControllerTestViewController* mcViewController = [[Phantom3AdvancedMainControllerTestViewController alloc] initWithDrone:self.connectedDrone];
    [self.navigationController pushViewController:mcViewController animated:YES];
}

-(IBAction) onNavigationButtonClicked:(id)sender
{
    NavigationViewController* naviViewController = nil;
    if (self.connectedDrone) {
        naviViewController = [[NavigationViewController alloc] initWithDrone:self.connectedDrone];
    }
    else
    {
        naviViewController = [[NavigationViewController alloc] initWithDroneType:DJIDrone_Phantom3Advanced];
    }
    [self.navigationController pushViewController:naviViewController animated:YES];
}

-(IBAction) onGimbalButtonClicked:(id)sender
{
    Phantom3AdvancedGimbalTestViewController* gimbalViewController = [[Phantom3AdvancedGimbalTestViewController alloc] initWithDrone:self.connectedDrone];
    [self.navigationController pushViewController:gimbalViewController animated:YES];
}

-(IBAction) onBatteryButtonClicked:(id)sender
{
    Phantom3AdvancedBatteryTestViewController* batteryViewController = [[Phantom3AdvancedBatteryTestViewController alloc] initWithDrone:self.connectedDrone];
    [self.navigationController pushViewController:batteryViewController animated:YES];
}

-(IBAction) onMediaButtonClicked:(id)sender
{
    Phantom3MediaTestTableViewController* mediaTestVC = nil;
    if (self.connectedDrone) {
        mediaTestVC = [[Phantom3MediaTestTableViewController alloc] initWithDrone:self.connectedDrone];
    }
    else
    {
        mediaTestVC = [[Phantom3MediaTestTableViewController alloc] initWithDroneType:DJIDrone_Phantom3Advanced];
    }
    
    [self.navigationController pushViewController:mediaTestVC animated:YES];
}

-(IBAction) onRemoteControllerButtonClicked:(id)sender
{
    Phantom3AdvancedRemoteControllerTestViewController* rcViewController = [[Phantom3AdvancedRemoteControllerTestViewController alloc] initWithDrone:self.connectedDrone];
    [self.navigationController pushViewController:rcViewController animated:YES];
}

-(IBAction) onImageTransmitterButtonClicked:(id)sender
{
    InspireImageTransmitterTestViewController* transmitterViewController = [[InspireImageTransmitterTestViewController alloc] initWithDrone:self.connectedDrone];
    [self.navigationController pushViewController:transmitterViewController animated:YES];
}

@end
