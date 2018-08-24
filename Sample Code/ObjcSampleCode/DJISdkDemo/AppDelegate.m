//
//  AppDelegate.m
//  DJISdkDemo
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import "AppDelegate.h"
#import "DJIRootViewController.h"
#import <DJISDK/DJISDK.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UINavigationController* rootViewController = [[UINavigationController alloc] initWithRootViewController:[[DJIRootViewController alloc] initWithNibName:@"DJIRootViewController" bundle:nil]];
    [rootViewController.navigationBar setBackgroundColor:[UIColor blackColor]];
    [rootViewController setToolbarHidden:YES];
    
    self.window.rootViewController = rootViewController;
    
    // Override point for customization after application launch.
    [self customizeAppearance];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void) customizeAppearance
{
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:(double)(0x2a)/255 green:(double)(0x3b)/255 blue:(double)(0x55)/255 alpha:1.0]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)applicationWillTerminate:(UIApplication *)application{
    [DJISDKManager stopConnectionToProduct];
}

@end
