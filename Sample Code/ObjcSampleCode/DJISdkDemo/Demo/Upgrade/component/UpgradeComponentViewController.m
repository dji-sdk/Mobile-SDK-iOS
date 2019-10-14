//
//  UpgradeComponentViewController.m
//  DJISdkDemo
//
//  Copyright © 2019 DJI. All rights reserved.
//

#import "UpgradeComponentViewController.h"
#import "DemoUtilityMacro.h"
#import "DemoAlertView.h"

@interface UpgradeComponentViewController ()
<
    DJIUpgradeFirmwareDelegate
>

@property (nonatomic) DJIUpgradeComponent *component;

@property (nonatomic) UIAlertController *optionalAlert;

@property (nonatomic) UIAlertController *progressAlert;

@property (weak, nonatomic) IBOutlet UILabel *firmwareState;

@property (weak, nonatomic) IBOutlet UILabel *componentLabel;

@property (weak, nonatomic) IBOutlet UITextView *versionInfoTextView;

@end

@implementation UpgradeComponentViewController

- (instancetype)initWithComponent:(DJIUpgradeComponent *)component {
    self = [super init];
    if (self) {
        self.component = component;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateFirmwareStateUI:self.component.upgradeState];
    [self updateComponentTypeUI:self.component.componentType];
    [self updateFirmwareInformationUI:self.component.latestFirmwareInformation];
    
    [self.component addUpgradeFirmwareListener:self withQueue:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.component removeUpgradeFirmwareListener:self];
}

//MARK: - UI

- (void)updateFirmwareStateUI:(DJIUpgradeFirmwareState)state {
    self.firmwareState.text = [NSString stringWithFormat:@"Firmware State: %@", [UpgradeComponentViewController convertFirmwareStateToStr:state]];
}

- (void)updateComponentTypeUI:(DJIUpgradeComponentType)componentType {
    self.componentLabel.text = [NSString stringWithFormat:@"Component Type: %@", [UpgradeComponentViewController convertComponentTypeToStr:componentType]];
}

- (void)updateFirmwareInformationUI:(DJIFirmwareInformation *)info {
    NSMutableString *message = nil;
    
    if (info) {
        message = [NSMutableString stringWithFormat:@"Firmware Information"];
        [message appendFormat:@"\nVersion: %@", info.version];
        [message appendFormat:@"\nRelease Note: %@", info.releaseNote];
        [message appendFormat:@"\nRelease Date: %@", info.releaseDate];
        [message appendFormat:@"\nFile Size: %@ byte", @(info.fileSize)];
    } else {
        message = [NSMutableString stringWithString:@"Firmware Information\nNot acquired"];
    }
    
    self.versionInfoTextView.text = message;
}

//MARK: - DJIUpgradeFirmwareDelegate

- (void)upgradeComponent:(DJIUpgradeComponent *)component didUpdateUpgradeFirmwareState:(DJIUpgradeFirmwareState)state {
    if (self.component != component) {
        return;
    }
    
    [self updateFirmwareStateUI:state];
}

- (void)upgradeComponent:(DJIUpgradeComponent *)component didUpdateFirmwareUpgradeProgress:(DJIFirmwareUpgradeProgress *)progress {
    if (self.component != component) {
        return;
    }
    
    if (!self.progressAlert) {
        self.progressAlert = [[UIAlertController alloc] init];
        
        WeakRef(target);
        UIAlertAction *packUpAction = [UIAlertAction actionWithTitle:@"Pack up"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * _Nonnull action) {
            WeakReturn(target);
            
            target.progressAlert = nil;
        }];
        
        [self.progressAlert addAction:packUpAction];
        [self.navigationController presentViewController:self.progressAlert animated:YES completion:nil];
    }
    
    self.progressAlert.title = [UpgradeComponentViewController convertProgressStateToStr:progress.state];
    self.progressAlert.message = [NSString stringWithFormat:@"progress: %@", @(progress.progress)];
}

- (void)didReceiveConsistencyUpgradeRequest:(DJIUpgradeComponent *)component {
    if (self.component != component) {
        return;
    }
    
    if (self.optionalAlert) {
        return;
    }
    
    self.optionalAlert = [[UIAlertController alloc] init];
    self.optionalAlert.title = @"Consistency Upgrade";
    self.optionalAlert.message = @"Whether to start the consistency upgrade.";
    
    WeakRef(target);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Stop"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
        WeakReturn(target);
        
        [target.component stopFirmwareConsistencyUpgradeWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(error.description);
            }
        }];
        
        target.optionalAlert = nil;
    }];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Start"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
        WeakReturn(target);
        
        [target.component startFirmwareConsistencyUpgradeWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(error.description);
            }
        }];
        
        target.optionalAlert = nil;
    }];
    
    if ([self.component canCancelConsistencyUpgrade]) {
        [self.optionalAlert addAction:cancelAction];
    }
    
    [self.optionalAlert addAction:confirmAction];
    
    [self.navigationController presentViewController:self.optionalAlert
                                            animated:YES
                                          completion:nil];
}

- (void)upgradeComponent:(DJIUpgradeComponent *)component didUpdateLatestFirmareInformation:(DJIFirmwareInformation *)firmwareInformation {
    if (self.component != component) {
        return;
    }
    
    [self updateFirmwareInformationUI:firmwareInformation];
}

//MARK: - Converter

+ (NSString *)convertComponentTypeToStr:(DJIUpgradeComponentType)componentType {
    switch (componentType) {
        case DJIUpgradeComponentTypeRemoteController:
            return @"Remote Controller";
        case DJIUpgradeComponentTypeAircraft:
            return @"Aircraft";
            
        default:
            return @"Unknown";
    }
}

+ (NSString *)convertFirmwareStateToStr:(DJIUpgradeFirmwareState)firmwareState {
    switch (firmwareState) {
        case DJIUpgradeFirmwareStateInitializating:
            return @"Initializating";
        case DJIUpgradeFirmwareStateChecking:
            return @"Checking";
        case DJIUpgradeFirmwareStateUpToDate:
            return @"Up to date";
        case DJIUpgradeFirmwareStateUpgradeStronglyRecommended:
            return @"Upgrade strongly recommended";
        case DJIUpgradeFirmwareStateOptionalUpgradeAvailable:
            return @"Optional upgrade available";
            
        default:
            break;
    }
    
    return @"Unknown";
}

+ (NSString *)convertProgressStateToStr:(DJIUpgradingProgressState)progressState {
    switch (progressState) {
        case DJIUpgradingProgressStateUpgrading:
            return @"Upgrading";
        case DJIUpgradingProgressStateUpgradeSuccessfully:
            return @"Upgrade successfully";
        case DJIUpgradingProgressStateUpgradeFailed:
            return @"Upgrade failed";
            
        default:
            break;
    }
    
    return @"Unknown";
}

@end
