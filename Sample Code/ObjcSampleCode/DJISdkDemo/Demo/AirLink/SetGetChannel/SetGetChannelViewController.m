//
//  SetGetChannelViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  There are several channels to choose for the communication between the remote controllerr and the aircraft. Normally, it is selected
 *  automatically. SDK provides the capability to select the channel manually. This file demonstrates how to do so. 
 *
 *  By default, the channel is selected automatically. Therefore, we need to set the selection mode to manual first. After that, we can
 *  select the channel using the UI. 
 *
 *  Before exiting the view, the selection mode is set to auto, because it is recommended to use the auto mode and normally the auto mode
 *  will have a better performance.
 */
#import "DemoUtility.h"
#import <DJISDK/DJISDK.h>
#import "SetGetChannelViewController.h"

@interface SetGetChannelViewController ()

@end

@implementation SetGetChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Set/Get LB Channel";
    self.rangeLabel.text = @"The input should be an integer. The valid range is [0, 7]. ";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // disable the set/get button first.
    [self.getValueButton setEnabled:NO];
    [self.setValueButton setEnabled:NO];
    
    
    DJIAirLink* airLink = [DemoComponentHelper fetchAirLink];
    if (airLink && [airLink isLBAirLinkSupported]) {
        [self getLBChannelMode];
    }
    else {
        ShowResult(@"The product doesn't support LB Air Link. ");
    }
}


/**
 *  It is recommended to keep the selection mode as Auto. Normally, it will have a more stable performance.
 *  Therefore, we set the mode back to Auto while exiting the view.
 */
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    DJIAirLink* airLink = [DemoComponentHelper fetchAirLink];
    if (airLink && [airLink isLBAirLinkSupported]) {
        [airLink.lbAirLink setChannelSelectionMode:DJILBAirLinkChannelSelectionModeAuto withCompletion:nil];
    }
}

/**
 *  Check if the LB Air Link is in mode DJILBAirLinkChannelSelectionModeManual. 
 *  We need to set it to DJILBAirLinkChannelSelectionModeManual if it is not.
 */
-(void) getLBChannelMode {
    DJIAirLink* airLink = [DemoComponentHelper fetchAirLink];
    if (airLink) {
        WeakRef(target);
        [airLink.lbAirLink getChannelSelectionModeWithCompletion:^(DJILBAirLinkChannelSelectionMode mode, NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"ERROR: getChannelSelectionMode. %@", error.description);
            }
            else if (mode == DJILBAirLinkChannelSelectionModeManual) {
                [target.getValueButton setEnabled:YES];
                [target.setValueButton setEnabled:YES];
            }
            else {
                [target setLBChannelMode];
            }
        }];
    }
}

-(void) setLBChannelMode {
    DJIAirLink* airLink = [DemoComponentHelper fetchAirLink];
    if (airLink) {
        WeakRef(target);
        [airLink.lbAirLink setChannelSelectionMode:DJILBAirLinkChannelSelectionModeManual withCompletion:^(NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"ERROR: setChannelSelectionMode. %@", error.description);
            }
            else {
                [target.getValueButton setEnabled:YES];
                [target.setValueButton setEnabled:YES];
            }
        }];
    }
}

- (IBAction)onGetButtonClicked:(id)sender {
    DJIAirLink* airLink = [DemoComponentHelper fetchAirLink];
    if (airLink) {
        WeakRef(target);
        [airLink.lbAirLink getChannelWithCompletion:^(int channel, NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"ERROR: getChannel. %@",error.description);
            }
            else {
                NSString* getTextString = [NSString stringWithFormat:@"%u", (unsigned int)channel];
                target.getValueTextField.text = getTextString;
            }
        }];
    }
}

- (IBAction)onSetButtonClicked:(id)sender {
    DJIAirLink* airLink = [DemoComponentHelper fetchAirLink];
    if (airLink) {
        int channelIndex = [self.setValueTextField.text intValue];
        [airLink.lbAirLink setChannel:channelIndex withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"ERROR: setChannel. %@", error.description);
            }
            else {
                ShowResult(@"SUCCESS. ");
            }
        }];
    }
}

@end
