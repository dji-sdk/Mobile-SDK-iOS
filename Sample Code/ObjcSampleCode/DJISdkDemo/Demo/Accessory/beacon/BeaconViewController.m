//
//  BeaconViewController.m
//  DJISdkDemo
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import "BeaconViewController.h"
#import "DemoComponentHelper.h"
#import "DemoUtilityMacro.h"

@interface BeaconViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *enableSwitch;

@end

@implementation BeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    DJIBeacon *beacon = [DemoComponentHelper fetchAccessoryAggregation].beacon;
    if (beacon) {
        WeakRef(target);
        [beacon getEnabledWithCompletion:^(BOOL enabled, NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                return;
            }
            
            [target.enableSwitch setOn:enabled];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    DJIKey *beaconEnabled = [DJIAccessoryKey keyWithIndex:0 subComponent:DJIAccessoryParamBeaconSubComponent subComponentIndex:0 andParam:DJIAccessoryParamEnabled];
    WeakRef(target);
    [[DJISDKManager keyManager] startListeningForChangesOnKey:beaconEnabled withListener:self andUpdateBlock:^(DJIKeyedValue * _Nullable oldValue, DJIKeyedValue * _Nullable newValue) {
        WeakReturn(target);
        if (newValue) {
            [target.enableSwitch setOn:newValue.boolValue];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[DJISDKManager keyManager] stopAllListeningOfListeners:self];
}

- (IBAction)enabledSwitch:(UISwitch *)sender {
    DJIBeacon *beacon = [DemoComponentHelper fetchAccessoryAggregation].beacon;
    [beacon setEnabled:sender.on withCompletion:^(NSError * _Nullable error) {
    }];
}

@end
