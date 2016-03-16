//
//  FCFlightLimitationViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates how to configure the flight limitaion setting through DJIFlightController.
 */
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"
#import "FCFlightLimitationViewController.h"

@interface FCFlightLimitationViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *heightLimitTextField;
@property (weak, nonatomic) IBOutlet UITextField *radiusLimitTextField;
@property (weak, nonatomic) IBOutlet UISwitch *radiusLimitSwitch;
- (IBAction)onLimitSwitchValueChanged:(id)sender;

@end

@implementation FCFlightLimitationViewController

/**
 *  Display current limitation when view loaded.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        // initialize the UI
        [self displayMaxFlightHeight];
        [self displayFlightRadiusLimitation];
    }
}

-(void) displayMaxFlightHeight {
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {        
        WeakRef(target);
        [fc.flightLimitation getMaxFlightHeightWithCompletion:^(float height, NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"Get Max Flight Height:%@", error.localizedDescription);
            }
            else
            {
                target.heightLimitTextField.text = [NSString stringWithFormat:@"%0.1f", height];
            }
        }];
    }
}

/**
 *  The setting for flight radius limitation is a bit complicated than flight height limitation. SDK provides the capability to toggle
 *  the radius limitation. Therefore, before fetching the exact radius limitation, we check if it is already enabled or not.
 */
-(void) displayFlightRadiusLimitation {
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        WeakRef(target);
        [fc.flightLimitation getMaxFlightRadiusLimitationEnabledWithCompletion:^(BOOL enabled, NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"Get RadiusLimitationEnable:%@", error.localizedDescription);
            }
            else
            {
                [target.radiusLimitSwitch setOn:enabled];
                
                // We check the flight radius limitation only if it is enabled.
                if (enabled) {
                    target.radiusLimitTextField.enabled = YES;
                    [fc.flightLimitation getMaxFlightRadiusWithCompletion:^(float radius, NSError * _Nullable error) {
                        WeakReturn(target);
                        if (error) {
                            ShowResult(@"Get MaxFlightRadius:%@", error.localizedDescription);
                        }
                        else
                        {
                            target.radiusLimitTextField.text = [NSString stringWithFormat:@"%0.1f", radius];
                        }
                    }];
                }
                else
                {
                    target.radiusLimitTextField.enabled = NO;
                    target.radiusLimitTextField.text = @"0";
                }
            }
        }];
    }
}

/**
 *  User can enable or disable the flight radius limitation using the UI component. 
 *  Whenever the functionality is enabled, we fetch the limitation and display it.
 */
- (IBAction)onLimitSwitchValueChanged:(UISwitch*)sender {
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        WeakRef(target);
        [fc.flightLimitation setMaxFlightRadiusLimitationEnabled:sender.on withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"setMaxFlightRadiusLimitationEnabled:%@", error.localizedDescription);
                [sender setOn:!sender.on animated:YES];
            }
            else
            {
                WeakReturn(target);
                if (sender.on) {
                    target.radiusLimitTextField.enabled = YES;
                    [fc.flightLimitation getMaxFlightRadiusWithCompletion:^(float radius, NSError * _Nullable error) {
                        WeakReturn(target);
                        if (error) {
                            ShowResult(@"%@", error.localizedDescription);
                        }
                        else
                        {
                            target.radiusLimitTextField.text = [NSString stringWithFormat:@"%0.1f", radius];
                        }
                    }];
                }
                else
                {
                    target.radiusLimitTextField.enabled = NO;
                    target.radiusLimitTextField.text = @"0";
                }
            }
        }];
    }
}

-(void) setMaxFlightHeight:(float)height
{
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        [fc.flightLimitation setMaxFlightHeight:height withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"setMaxFlightHeight:%@", error.localizedDescription);
            }
        }];
    }
}

-(void) setMaxFlightRadius:(float)radius
{
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        [fc.flightLimitation setMaxFlightRadius:radius withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"setMaxFlightRadius:%@", error.localizedDescription);
            }
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.heightLimitTextField]) {
        float value = [textField.text floatValue];
        [self setMaxFlightHeight:value];
    }
    else
    {
        float value = [textField.text floatValue];
        [self setMaxFlightRadius:value];
    }
    
    if (textField.isFirstResponder) {
        [textField resignFirstResponder];
    }
    return YES;
}
@end
