//
//  LDMViewController.m
//  DJISdkDemo
//
//  Copyright © 2021 DJI. All rights reserved.
//

#import "LDMViewController.h"
#import <DJISDK/DJISDK.h>
#import "DemoUtilityMacro.h"
#import "DemoUtility.h"

@interface LDMViewController ()

@property (weak, nonatomic) IBOutlet UITextView *panelView;

@end

@implementation LDMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.panelView.editable = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self onRefreshPannelContent];
}

- (IBAction)onGetLDMLicense:(id)sender {
    WeakRef(target);
    [[DJISDKManager ldmManager] getIsLDMSupportedWithCompletion:^(BOOL isLDMSupported, NSError * _Nullable error) {
        WeakReturn(target);
        
        if (error) {
            ShowResult(@"get LDM support failure: %@", error.description);
        }
        
        [target onRefreshPannelContent];
    }];
}

- (IBAction)onEnableLDM:(id)sender {
    WeakRef(target);
    [[DJISDKManager ldmManager] enableLDMWithCompletion:^(NSError * _Nullable error) {
        WeakReturn(target);
        
        if (error) {
            ShowResult(@"enable LDM failure: %@", error.description);
        }
        
        [target onRefreshPannelContent];
    }];
}

- (IBAction)onDisableLDM:(id)sender {
    [[DJISDKManager ldmManager] disableLDM];
    [self onRefreshPannelContent];
}

- (IBAction)onEnableRTKNetwork:(id)sender {
    DJILDMModule *settings = [[DJILDMModule alloc] initWithModule:DJILDMModuleTypeRTK andEnable:YES];
    NSError *error = [[DJISDKManager ldmManager] setModuleNetworkServiceEnabled:@[settings]];
    if (error) {
        ShowResult(@"enable rtk network: %@", error.description);
    }
    [self onRefreshPannelContent];
}

- (IBAction)onDisableRTKNetwork:(id)sender {
    DJILDMModule *settings = [[DJILDMModule alloc] initWithModule:DJILDMModuleTypeRTK andEnable:NO];
    NSError *error = [[DJISDKManager ldmManager] setModuleNetworkServiceEnabled:@[settings]];
    if (error) {
        ShowResult(@"disable rtk network: %@", error.description);
    }
    [self onRefreshPannelContent];
}

- (IBAction)onEnableUserAccount:(id)sender {
    DJILDMModule *settings = [[DJILDMModule alloc] initWithModule:DJILDMModuleTypeUserAccount andEnable:YES];
    NSError *error = [[DJISDKManager ldmManager] setModuleNetworkServiceEnabled:@[settings]];
    if (error) {
        ShowResult(@"enable user account: %@", error.description);
    }
    [self onRefreshPannelContent];
}

- (IBAction)onDisableUserAccount:(id)sender {
    DJILDMModule *settings = [[DJILDMModule alloc] initWithModule:DJILDMModuleTypeUserAccount andEnable:NO];
    NSError *error = [[DJISDKManager ldmManager] setModuleNetworkServiceEnabled:@[settings]];
    if (error) {
        ShowResult(@"disable user account: %@", error.description);
    }
    [self onRefreshPannelContent];
}

//MARK: - Refresh UI

/// 刷新LDM所有属性的状态
/// Refresh the status of all LDM attributes
- (void)onRefreshPannelContent {
    NSMutableString *content = [[NSMutableString alloc] init];
    [content appendFormat:@"LDM enabled: %@\n", [DJISDKManager ldmManager].isLDMEnabled ? @"true" : @"false"];
    [content appendFormat:@"LDM supported: %@\n", [DJISDKManager ldmManager].isLDMSupported ? @"true" : @"false"];
    [content appendFormat:@"isRTKEnabled: %@\n", [[DJISDKManager ldmManager] isLDMModuleNetworkServiceEnabled:DJILDMModuleTypeRTK] ? @"true" : @"false"];
    [content appendFormat:@"isUserAccountEnabled: %@", [[DJISDKManager ldmManager] isLDMModuleNetworkServiceEnabled:DJILDMModuleTypeUserAccount] ? @"true" : @"false"];
    
    self.panelView.text = content;
}

@end
