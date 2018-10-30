//
//  SpotlightViewController.m
//  DJISdkDemo
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import "SpotlightViewController.h"
#import "DemoComponentHelper.h"
#import "DemoUtilityMacro.h"

@interface SpotlightViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *enableSwitch;
@property (weak, nonatomic) IBOutlet UITextView *panel;

@end

@implementation SpotlightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    DJISpotlight *spotlight = [DemoComponentHelper fetchAccessoryAggregation].spotlight;
    if (spotlight) {
        WeakRef(target);
        [spotlight getEnabledWithCompletion:^(BOOL enabled, NSError * _Nullable error) {
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
    
     DJIKey *enabledKey = [DJIAccessoryKey keyWithIndex:0 subComponent:DJIAccessoryParamSpotlightSubComponent subComponentIndex:0 andParam:DJIAccessoryParamEnabled];
    WeakRef(target);
    [[DJISDKManager keyManager] startListeningForChangesOnKey:enabledKey withListener:self andUpdateBlock:^(DJIKeyedValue * _Nullable oldValue, DJIKeyedValue * _Nullable newValue) {
        WeakReturn(target);
        if (newValue) {
            [target.enableSwitch setOn:newValue.boolValue];
        }
    }];
    
    DJISpotlight *spotlight = [DemoComponentHelper fetchAccessoryAggregation].spotlight;
    [spotlight addSpotlightStateListener:self withQueue:dispatch_get_main_queue() andBlock:^(DJISpotlightState * _Nonnull state) {
        
    }];
    
    [self updatePanelContent:spotlight.state];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[DJISDKManager keyManager] stopAllListeningOfListeners:self];
    DJISpotlight *spotlight = [DemoComponentHelper fetchAccessoryAggregation].spotlight;
    [spotlight removeSpotlightStateListener:self];
}

- (IBAction)enableSwitch:(UISwitch *)sender {
    DJISpotlight *spotlight = [DemoComponentHelper fetchAccessoryAggregation].spotlight;
    [spotlight setEnabled:sender.on withCompletion:^(NSError * _Nullable error) {
    }];
}

- (void)updatePanelContent:(DJISpotlightState *)state {
    NSMutableString *content = [NSMutableString string];
    [content appendFormat:@"temperature: %@", @(state.temperature)];
    [content appendFormat:@"brightness: %@", @(state.brightness)];
    self.panel.text = content;
}

@end
