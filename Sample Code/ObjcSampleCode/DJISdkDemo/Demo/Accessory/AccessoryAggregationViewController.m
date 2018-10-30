//
//  AccessoryAggregationViewController.m
//  DJISdkDemo
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import "AccessoryAggregationViewController.h"
#import <DJISDK/DJISDK.h>
#import "DemoUtilityMacro.h"
#import "DemoComponentHelper.h"
#import "SpotlightViewController.h"
#import "BeaconViewController.h"
#import "SpeakerViewController.h"

@interface AccessoryAggregationViewController ()

@property (weak, nonatomic) IBOutlet UIButton *spotlightBtn;
@property (weak, nonatomic) IBOutlet UIButton *beaconBton;
@property (weak, nonatomic) IBOutlet UIButton *speakerBtn;

@end

@implementation AccessoryAggregationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    DJIAccessoryAggregation *accessoryAggregation = [DemoComponentHelper fetchAccessoryAggregation];
    self.spotlightBtn.enabled = accessoryAggregation.spotlight ? YES : NO;
    self.beaconBton.enabled = accessoryAggregation.beacon ? YES : NO;
    self.speakerBtn.enabled = accessoryAggregation.speaker ? YES : NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    WeakRef(target);
    DJIKey *spotlightConnectKey = [DJIAccessoryKey keyWithIndex:0 subComponent:DJIAccessoryParamSpotlightSubComponent subComponentIndex:0 andParam:DJIAccessoryParamIsConnected];
    [[DJISDKManager keyManager] startListeningForChangesOnKey:spotlightConnectKey withListener:self andUpdateBlock:^(DJIKeyedValue * _Nullable oldValue, DJIKeyedValue * _Nullable newValue) {
        WeakReturn(target);
        if (newValue) {
            target.spotlightBtn.enabled = newValue.boolValue;
        } else {
            target.spotlightBtn.enabled = NO;
        }
    }];
    
    DJIKey *beaconConnectKey = [DJIAccessoryKey keyWithIndex:0 subComponent:DJIAccessoryParamBeaconSubComponent subComponentIndex:0 andParam:DJIAccessoryParamIsConnected];
    [[DJISDKManager keyManager] startListeningForChangesOnKey:beaconConnectKey withListener:self andUpdateBlock:^(DJIKeyedValue * _Nullable oldValue, DJIKeyedValue * _Nullable newValue) {
        WeakReturn(target);
        if (newValue) {
            target.beaconBton.enabled = newValue.boolValue;
        } else {
            target.beaconBton.enabled = NO;
        }
    }];
    
    DJIKey *speakerConnectKey = [DJIAccessoryKey keyWithIndex:0 subComponent:DJIAccessoryParamSpeakerSubComponent subComponentIndex:0 andParam:DJIAccessoryParamIsConnected];
    [[DJISDKManager keyManager] startListeningForChangesOnKey:speakerConnectKey withListener:self andUpdateBlock:^(DJIKeyedValue * _Nullable oldValue, DJIKeyedValue * _Nullable newValue) {
        WeakReturn(target);
        if (newValue) {
            target.speakerBtn.enabled = newValue.boolValue;
        } else {
            target.speakerBtn.enabled = NO;
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[DJISDKManager keyManager] stopAllListeningOfListeners:self];
}

- (IBAction)openSpotlight:(id)sender {
    SpotlightViewController *vc = [[SpotlightViewController alloc] init];
    vc.title = @"Spotlight";
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)openBeacon:(id)sender {
    BeaconViewController *vc = [[BeaconViewController alloc] init];
    vc.title = @"Beacon";
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)openSpeaker:(id)sender {
    SpeakerViewController *vc = [[SpeakerViewController alloc] init];
    vc.title = @"Speaker";
    [self.navigationController pushViewController:vc animated:YES];
}

@end
