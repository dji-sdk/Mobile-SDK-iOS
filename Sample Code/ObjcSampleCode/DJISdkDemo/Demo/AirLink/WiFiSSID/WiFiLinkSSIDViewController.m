//
//  WiFiLinkSSIDViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates how to change the SSID of DJIWiFiLink. 
 */
#import "DemoUtility.h"
#import <DJISDK/DJISDK.h>
#import "WiFiLinkSSIDViewController.h"

@interface WiFiLinkSSIDViewController ()

@end

@implementation WiFiLinkSSIDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"WiFi SSID";
    self.rangeLabel.text = @"The input should just include alphabet, number, space, '-'\nandshould not be more than 30 characters. ";
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    DJIAirLink* airLink = [DemoComponentHelper fetchAirLink];
    if (airLink && [airLink isWifiLinkSupported]) {
        [self.getValueButton setEnabled:YES];
        [self.setValueButton setEnabled:YES];
    }
    else {
        [self.getValueButton setEnabled:NO];
        [self.setValueButton setEnabled:NO];
        ShowResult(@"The product doesn't support WiFi. ");
    }
}

- (IBAction)onGetButtonClicked:(id)sender {
    __weak DJIWiFiLink* wifiLink = [DemoComponentHelper fetchAirLink].wifiLink;
    if (wifiLink) {
        WeakRef(target);
        [wifiLink getWiFiSSIDWithCompletion:^(NSString * _Nonnull ssid, NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"ERROR: getWiFiSSID. %@", error.description);
            }
            else {
                target.getValueTextField.text = ssid;
            }
        }];
    }
}

- (IBAction)onSetButtonClicked:(id)sender {
    __weak DJIWiFiLink* wifiLink = [DemoComponentHelper fetchAirLink].wifiLink;
    if (wifiLink) {
        [wifiLink setWiFiSSID:self.setValueTextField.text withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"ERROR: setWiFiSSID. %@. ", error.description);
            }
            else {
                ShowResult(@"Succeed. ");
            }
        }];
    }
}


@end
