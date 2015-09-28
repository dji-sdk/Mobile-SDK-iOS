//
//  NavigationViewController.m
//  DJISdkDemo
//
//  Created by Ares on 15/7/2.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "NavigationViewController.h"
#import "NavigationJoystickViewController.h"
#import "NavigationWaypointViewController.h"
#import "NavigationHotPointViewController.h"
#import "NavigationFollowMeViewController.h"
#import "NavigationIOCViewController.h"

@interface NavigationViewController ()
- (IBAction)onJoystickButtonClicked:(id)sender;
- (IBAction)onWaypointButtonClicked:(id)sender;
- (IBAction)onHotPointButtonClicked:(id)sender;
- (IBAction)onFollowMeButtonClicked:(id)sender;
- (IBAction)onIOCButtonClicked:(id)sender;

@end

@implementation NavigationViewController

-(id) initWithDroneType:(DJIDroneType)type
{
    self = [super init];
    if (self) {
        _droneType = type;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onJoystickButtonClicked:(id)sender {
    NavigationJoystickViewController* joystickVC = nil;
    if (self.connectedDrone) {
        joystickVC = [[NavigationJoystickViewController alloc] initWithDrone:self.connectedDrone];
    }
    else
    {
        joystickVC = [[NavigationJoystickViewController alloc] initWithDroneType:self.droneType];
    }
    [self.navigationController pushViewController:joystickVC animated:YES];
}

- (IBAction)onWaypointButtonClicked:(id)sender {
    NavigationWaypointViewController* wpVC = nil;
    if (self.connectedDrone) {
        wpVC = [[NavigationWaypointViewController alloc] initWithDrone:self.connectedDrone];
    }
    else
    {
        wpVC = [[NavigationWaypointViewController alloc] initWithDroneType:self.droneType];
    }

    [self.navigationController pushViewController:wpVC animated:YES];
}

- (IBAction)onHotPointButtonClicked:(id)sender {
    NavigationHotPointViewController* hpVC = nil;
    if (self.connectedDrone) {
        hpVC = [[NavigationHotPointViewController alloc] initWithDrone:self.connectedDrone];
    }
    else
    {
        hpVC = [[NavigationHotPointViewController alloc] initWithDroneType:self.droneType];
    }

    [self.navigationController pushViewController:hpVC animated:YES];
}

- (IBAction)onFollowMeButtonClicked:(id)sender {
    NavigationFollowMeViewController* fmVC = nil;
    if (self.connectedDrone) {
        fmVC = [[NavigationFollowMeViewController alloc] initWithDrone:self.connectedDrone];
    }
    else
    {
        fmVC = [[NavigationFollowMeViewController alloc] initWithDroneType:self.droneType];
    }
    
    [self.navigationController pushViewController:fmVC animated:YES];
}

- (IBAction)onIOCButtonClicked:(id)sender {
    NavigationIOCViewController* iocVC = nil;
    if (self.connectedDrone) {
        iocVC = [[NavigationIOCViewController alloc] initWithDrone:self.connectedDrone];
    }
    else
    {
        iocVC = [[NavigationIOCViewController alloc] initWithDroneType:self.droneType];
    }

    [self.navigationController pushViewController:iocVC animated:YES];
}
@end
