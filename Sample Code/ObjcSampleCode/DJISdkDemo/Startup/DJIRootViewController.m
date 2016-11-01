//
//  DJIRootViewController.m
//  DJISdkDemo
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import "DJIRootViewController.h"
#import "ComponentSelectionViewController.h"
#import "BluetoothConnectorViewController.h"
#import "DemoAlertView.h"
#import "DemoUtilityMacro.h"

#define ENTER_DEBUG_MODE 0
#define ENABLE_REMOTE_LOGGER 0

@interface DJIRootViewController ()

@property(nonatomic, weak) DJIBaseProduct* product;
@property (weak, nonatomic) IBOutlet UILabel *productConnectionStatus;
@property (weak, nonatomic) IBOutlet UILabel *productModel;
@property (weak, nonatomic) IBOutlet UILabel *productFirmwarePackageVersion;
@property (weak, nonatomic) IBOutlet UILabel *debugModeLabel;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UILabel *sdkVersionLabel;
@end

@implementation DJIRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Register App with App Key
    NSString* appKey = @""; //TODO: Please enter your App Key here
    
    if ([appKey length] == 0) {
        ShowResult(@"Please enter your app key.");
    }
    else
    {
        [DJISDKManager registerApp:appKey withDelegate:self];
    }
    
    [self initUI];
}

- (void)initUI
{
    self.title = @"DJI iOS SDK Sample";
    self.sdkVersionLabel.text = [@"DJI SDK Version: " stringByAppendingString:[DJISDKManager getSDKVersion]];
    self.productFirmwarePackageVersion.hidden = YES;
    self.productModel.hidden = YES;
    //Disable the connect button by default
    [self.connectButton setEnabled:NO];
    [self.debugModeLabel setHidden:!ENTER_DEBUG_MODE];
}

- (void)viewDidAppear:(BOOL)animated{
    if(self.product){
        [self updateStatusBasedOn:self.product];
    }
}

-(IBAction) onConnectButtonClicked:(id)sender
{
    if (self.product) {
        ComponentSelectionViewController* inspireVC = [[ComponentSelectionViewController alloc] init];
        [self.navigationController pushViewController:inspireVC animated:YES];
    }
}

- (IBAction)onBluetoothButtonClicked:(id)sender {
    BluetoothConnectorViewController* vc = [[BluetoothConnectorViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -
-(void) sdkManagerDidRegisterAppWithError:(NSError *)error {
    if (error) {
        ShowResult(@"Registration Error:%@", error);
        [self.connectButton setEnabled:NO];
    }
    else {
        
#if ENTER_DEBUG_MODE
        [DJISDKManager enterDebugModeWithDebugId:@"10.128.129.78"];
#else
        [DJISDKManager startConnectionToProduct];
#endif
        
#if ENABLE_REMOTE_LOGGER
        [DJISDKManager enableRemoteLoggingWithDeviceID:@"Device ID" logServerURLString:@"Enter Remote Logger URL here"];
#endif
    }
    
}

-(void) sdkManagerProductDidChangeFrom:(DJIBaseProduct* _Nullable) oldProduct to:(DJIBaseProduct* _Nullable) newProduct{
    if (newProduct) {
        self.product = newProduct;
        [self.connectButton setEnabled:YES];
        
    } else {
        NSString* message = [NSString stringWithFormat:@"Connection lost. Back to root. "];

        WeakRef(target);
        [DemoAlertView showAlertViewWithMessage:message titles:@[@"Cancel", @"Back"] action:^(NSUInteger buttonIndex) {
            WeakReturn(target);
            if (buttonIndex == 1) {
                if (![target.navigationController.topViewController isKindOfClass:[DJIRootViewController class]]) {
                    [target.navigationController popToRootViewControllerAnimated:NO];
                }
            }
        }];
        [self.connectButton setEnabled:NO];
        
        self.product = nil;
    }
    
    [self updateStatusBasedOn:newProduct];
}

#pragma mark -

-(void) updateFirmwareVersion:(NSString*) version {
    if (nil != version) {
        _productFirmwarePackageVersion.text = [NSString stringWithFormat:NSLocalizedString(@"Firmware Package Version: \%@", @""),version];
        self.productFirmwarePackageVersion.hidden = NO;
    } else {
        _productFirmwarePackageVersion.text = NSLocalizedString(@"Firmware Package Version: Unknown", @"");
        self.productFirmwarePackageVersion.hidden = YES;
    }
}

-(void) updateStatusBasedOn:(DJIBaseProduct* )newConnectedProduct {
    if (newConnectedProduct){
        _productConnectionStatus.text = NSLocalizedString(@"Status: Product Connected", @"");
        _productModel.text = [NSString stringWithFormat:NSLocalizedString(@"Model: \%@", @""),newConnectedProduct.model];
        _productModel.hidden = NO;
        WeakRef(target);
        [newConnectedProduct getFirmwarePackageVersionWithCompletion:^(NSString * _Nonnull version, NSError * _Nullable error) {
            WeakReturn(target);
            if (error == nil) {
                [target updateFirmwareVersion:version];
            }else {
                [target updateFirmwareVersion:nil];
            }
        }];
    }else {
        _productConnectionStatus.text = NSLocalizedString(@"Status: Product Not Connected", @"");
        _productModel.text = NSLocalizedString(@"Model: Unknown", @"");
        [self updateFirmwareVersion:nil];
    }
}

@end
