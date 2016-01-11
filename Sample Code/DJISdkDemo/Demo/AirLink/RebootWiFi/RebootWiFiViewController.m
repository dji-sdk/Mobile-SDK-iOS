//
//  RebootWiFiViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  In order to make the change in DJIWiFiLink take effect, the WiFi module in the product should be rebooted. SDK provides the method to 
 *  do so and it is demonstrated in this file.
 */
#import "DemoUtility.h"
#import <DJISDK/DJISDK.h>
#import "RebootWiFiViewController.h"

@interface RebootWiFiViewController ()

@property (weak, nonatomic) IBOutlet UIButton *rebootWiFiButton;

@end

@implementation RebootWiFiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Reboot WiFi";
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    DJIAirLink* airLink = [DemoComponentHelper fetchAirLink];
    if (airLink && [airLink isWifiLinkSupported]) {
        [self.rebootWiFiButton setEnabled:YES];
    }
    else {
        [self.rebootWiFiButton setEnabled:NO];
        ShowResult(@"The product doesn't support WiFi. ");
    }
}

- (IBAction)onRebootWiFiClicked:(id)sender {
    DJIAirLink* airLink = [DemoComponentHelper fetchAirLink];
    if (airLink) {
        [airLink.wifiLink rebootWiFiWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"ERROR: rebootWiFi. %@", error.description);
            }
            else {
                ShowResult(@"SUCCESS: rebootWiFi. "); 
            }
        }];
    }
    
}

@end
