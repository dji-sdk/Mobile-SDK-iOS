//
//  DJIRootViewController.m
//  DJISdkDemo
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import "DJIRootViewController.h"
#import "ComponentSelectionViewController.h"
#import "DemoAlertView.h"
#import "DemoUtilityMacro.h"

#define ENTER_DEBUG_MODE 0
#define ENABLE_REMOTE_LOGGER 0

@interface DJIRootViewController ()

@property(nonatomic, weak) DJIBaseProduct* product;
@property (weak, nonatomic) IBOutlet UILabel *productConnectionStatus;
@property (weak, nonatomic) IBOutlet UILabel *productModel;
@property (weak, nonatomic) IBOutlet UILabel *productFirmwarePackageVersion;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UILabel *sdkVersionLabel;
@end

@implementation DJIRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // disable the connect button by default
    [self.connectButton setEnabled:NO];
    
    //Register App with key
    NSString* appKey = @"Please enter your App Key here";
    
    if ([appKey isEqualToString:@"Please enter your App Key here"]) {
        ShowResult(@"Please enter App Key.");
    }
    else
    {
        [DJISDKManager registerApp:appKey withDelegate:self];
    }

    self.sdkVersionLabel.text = [@"DJI SDK Version: " stringByAppendingString:[DJISDKManager getSDKVersion]];
    
    self.productFirmwarePackageVersion.hidden = YES;
    self.productModel.hidden = YES;
    
    self.title = @"DJI iOS SDK Sample";
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

#pragma mark -
-(void) sdkManagerDidRegisterAppWithError:(NSError *)error {
    if (error) {
        ShowResult(@"Registration Error:%@", error);
        [self.connectButton setEnabled:NO];
    }
    else {
        
#if ENTER_DEBUG_MODE
        [DJISDKManager enterDebugModeWithDebugId:@"Enter Debug ID Here"];
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
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Back", nil];
        [self.connectButton setEnabled:NO];
        
        [alertView show];
        self.product = nil;
    }
    
    [self updateStatusBasedOn:newProduct];
}

#pragma mark -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (![self.navigationController.topViewController isKindOfClass:[DJIRootViewController class]]) {
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
    }
}

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
