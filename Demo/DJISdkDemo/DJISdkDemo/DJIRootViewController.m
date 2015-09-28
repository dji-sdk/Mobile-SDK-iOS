//
//  DJIRootViewController.m
//  DJISdkDemo
//
//  Created by Ares on 15/2/9.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "DJIRootViewController.h"
#import "DJIPhantomViewController.h"
#import "DJIInspireViewController.h"
#import "DJIPhantom3AdvancedViewController.h"
#import "DJIDemoHelper.h"

@interface DJIRootViewController ()

@property(nonatomic, strong) DJIDrone* drone;

@end

@implementation DJIRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Register App with key
    NSString* appKey = @"";
    [DJIAppManager registerApp:appKey withDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) onPhantomButtonClicked:(id)sender
{
    DJIPhantomViewController* phantomVC = [[DJIPhantomViewController alloc] init];
    [self.navigationController pushViewController:phantomVC animated:YES];
}

-(IBAction) onInspireButtonClicked:(id)sender
{
    DJIInspireViewController* inspireVC = [[DJIInspireViewController alloc] initWithDrone:self.drone];
    [self.navigationController pushViewController:inspireVC animated:YES];
}

-(IBAction) onPhantom3AdvancedButtonClicked:(id)sender
{
    DJIPhantom3AdvancedViewController* phantom3VC = nil;
    if (self.drone && self.drone.droneType == DJIDrone_Phantom3Advanced) {
        phantom3VC = [[DJIPhantom3AdvancedViewController alloc] initWithDrone:self.drone];
    }
    else
    {
        phantom3VC = [[DJIPhantom3AdvancedViewController alloc] init];
    }
    [self.navigationController pushViewController:phantom3VC animated:YES];
}

#pragma mark -

-(void) appManagerDidRegisterWithError:(int)errorCode
{
    if (errorCode != RegisterSuccess) {
        ShowResult(@"Regist Error:%d", errorCode);
    }
}

-(void) appManagerDidConnectedDroneChanged:(DJIDrone*)newDrone
{
    if (newDrone) {
        self.drone = newDrone;
        NSString* message = [NSString stringWithFormat:@"Connected To Drone:%@",[DJIDemoHelper droneName:newDrone.droneType]];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"GO", nil];
        [alertView show];
    }
}

-(void) appManagerDidConnectionStatusChanged:(DJIConnectionStatus)status
{

}

#pragma mark -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (![self.navigationController.topViewController isKindOfClass:[DJIRootViewController class]]) {
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
        if (self.drone) {
            if (self.drone.droneType == DJIDrone_Inspire ||
                self.drone.droneType == DJIDrone_Phantom3Professional) {
                [self onInspireButtonClicked:nil];
            }
            else if (self.drone.droneType == DJIDrone_Phantom3Advanced)
            {
                [self onPhantom3AdvancedButtonClicked:nil];
            }
        }
    }
}

@end
