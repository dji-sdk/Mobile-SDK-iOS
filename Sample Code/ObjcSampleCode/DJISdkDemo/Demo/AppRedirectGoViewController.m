//
//  AppRedirectGoViewController.h
//  DJISdkDemo
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import "AppRedirectGoViewController.h"
#import "DemoUtility.h"

#define GO4_REDIRECT_URL @"djiVideoNew://"
#define GO3_REDIRECT_URL @"djiVideo://"

@interface AppRedirectGoViewController ()

@property (weak, nonatomic) IBOutlet UIButton *redirectGo4Button;
@property (weak, nonatomic) IBOutlet UIButton *redirectGo3Button;

@end

@implementation AppRedirectGoViewController

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (IBAction)onRedirectGo4ButtonClicked:(id)sender {
	NSURL *url = [NSURL URLWithString:GO4_REDIRECT_URL];
	if ([[UIApplication sharedApplication] canOpenURL:url]) {
		[[UIApplication sharedApplication] openURL:url];
	} else {
		ShowResult(@"Cannot redirect to DJI Go 4, Please check if DJI Go 4 has installed");
	}
}

- (IBAction)onRedirectGo3ButtonClicked:(id)sender {
	NSURL *url = [NSURL URLWithString:GO3_REDIRECT_URL];
	if ([[UIApplication sharedApplication] canOpenURL:url]) {
		[[UIApplication sharedApplication] openURL:url];
	} else {
		ShowResult(@"Cannot redirect to DJI Go, Please check if DJI Go has installed");
	}
}

@end
