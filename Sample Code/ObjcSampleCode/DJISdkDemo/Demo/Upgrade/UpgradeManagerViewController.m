//
//  UpgradeManagerViewController.m
//  DJISdkDemo
//
//  Copyright © 2019 DJI. All rights reserved.
//

#import "UpgradeManagerViewController.h"
#import <DJISDK/DJISDK.h>
#import "UpgradeComponentViewController.h"

NSString * const UpgradeManagerKey = @"Upgrade Manager";

@interface UpgradeManagerViewController ()

@property (weak, nonatomic) IBOutlet UIButton *remoteControllerButton;

@property (weak, nonatomic) IBOutlet UIButton *aircraftButton;

@end

@implementation UpgradeManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    DJIUpgradeManager *upgradeManager = [DJISDKManager upgradeManager];
    DJIUpgradeComponent *aircraftComponent = upgradeManager.aircraft;
    DJIUpgradeComponent *rcComponent = upgradeManager.remoteController;
    
    [self.aircraftButton setEnabled:(upgradeManager && aircraftComponent ? YES : NO)];
    [self.remoteControllerButton setEnabled:(upgradeManager && rcComponent ? YES : NO)];
    
    [self.aircraftButton setBackgroundColor:self.aircraftButton.enabled ? [UIColor blueColor] : [UIColor grayColor]];
    [self.remoteControllerButton setBackgroundColor:self.remoteControllerButton.enabled ? [UIColor blueColor] : [UIColor grayColor]];
}

- (IBAction)enterRemoteControllUpgrade:(id)sender {
    UpgradeComponentViewController *vc = [[UpgradeComponentViewController alloc] initWithComponent:[DJISDKManager upgradeManager].remoteController];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)enterAircraftUpgrade:(id)sender {
    UpgradeComponentViewController *vc = [[UpgradeComponentViewController alloc] initWithComponent:[DJISDKManager upgradeManager].aircraft];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
