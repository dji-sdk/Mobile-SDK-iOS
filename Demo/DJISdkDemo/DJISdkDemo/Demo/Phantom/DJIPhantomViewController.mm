//
//  DJIRootViewController.m
//  DJISdkDemo
//
//  Created by Ares on 14-6-27.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "DJIPhantomViewController.h"
#import "PhantomCameraTestViewController.h"
#import "PhantomGimbalTestViewController.h"
#import "PhantomBatteryTestViewController.h"
#import "PhantomMainControllerTestViewController.h"
#import "PhantomGroundStationTestViewController.h"
#import "PhantomRangeExtenderTestViewController.h"
#import "PhantomMediaTestViewController.h"

@interface DJIPhantomViewController ()

@end

@implementation DJIPhantomViewController

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
    PhantomCameraTestViewController* cameraTestViewController = [[PhantomCameraTestViewController alloc] init];
    [self.navigationController presentViewController:cameraTestViewController animated:YES completion:nil];
}

-(IBAction) onManinControllerButtonClicked:(id)sender
{
    PhantomMainControllerTestViewController* mcViewController = [[PhantomMainControllerTestViewController alloc] init];
    [self.navigationController pushViewController:mcViewController animated:YES];
}

-(IBAction) onGroundStationButtonClicked:(id)sender
{
    PhantomGroundStationTestViewController* gsViewController = [[PhantomGroundStationTestViewController alloc] init];
    [self.navigationController pushViewController:gsViewController animated:YES];
}

-(IBAction) onGimbalButtonClicked:(id)sender
{
    PhantomGimbalTestViewController* gimbalViewController = [[PhantomGimbalTestViewController alloc] init];
    [self.navigationController pushViewController:gimbalViewController animated:YES];
}

-(IBAction) onRangeExtenderButtonClicked:(id)sender
{
    PhantomRangeExtenderTestViewController* reViewController = [[PhantomRangeExtenderTestViewController alloc] init];
    [self.navigationController pushViewController:reViewController animated:YES];
}

-(IBAction) onBatteryButtonClicked:(id)sender
{
    PhantomBatteryTestViewController* batteryViewController = [[PhantomBatteryTestViewController alloc] init];
    [self.navigationController pushViewController:batteryViewController animated:YES];
}

-(IBAction) onMediaButtonClicked:(id)sender
{
    PhantomMediaTestViewController* mediaViewController = [[PhantomMediaTestViewController alloc] init];
    [self.navigationController pushViewController:mediaViewController animated:YES];
}

@end
