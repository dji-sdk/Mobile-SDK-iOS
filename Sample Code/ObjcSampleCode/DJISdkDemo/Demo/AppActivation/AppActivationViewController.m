//
//  AppActivationViewController.m
//  DJISdkDemo
//
//  Copyright © 2017 DJI. All rights reserved.
//

#import "AppActivationViewController.h"
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"

@interface AppActivationViewController () <DJIAppActivationManagerDelegate, UINavigationControllerDelegate>

@property (nonatomic) DJIAppActivationState activationState;
@property (nonatomic) DJIAppActivationAircraftBindingState aircraftBindingState;
@property (nonatomic) BOOL isShown;
@property (nonatomic) BOOL isLoggingIn;

@property (weak, nonatomic) IBOutlet UILabel *bindingStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *appActivationLabel;

@end

@implementation AppActivationViewController

-(instancetype)init {
    if (self = [super init]) {
        _activationState = DJIAppActivationStateUnknown;
        _aircraftBindingState = DJIAppActivationAircraftBindingStateUnknown;
        _isShown = NO;
        _isLoggingIn = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated {
    [self updateUI];
}

-(void)setup {
    [DJISDKManager appActivationManager].delegate = self;
    self.navController.delegate = self;

    self.activationState = [DJISDKManager appActivationManager].appActivationState;
    self.aircraftBindingState = [DJISDKManager appActivationManager].aircraftBindingState;

    [self displayItselfIfNeeded];
}

-(void)updateUI {
    switch (self.aircraftBindingState) {
        case DJIAppActivationAircraftBindingStateUnboundButCannotSync:
            self.bindingStateLabel.text = @"Unbound. Please connect Internet to update state. ";
            break;
        case DJIAppActivationAircraftBindingStateUnbound:
            self.bindingStateLabel.text = @"Unbound. Use DJI GO to bind the aircraft. ";
            break;
        case DJIAppActivationAircraftBindingStateUnknown:
            self.bindingStateLabel.text = @"Unknown";
            break;
        case DJIAppActivationAircraftBindingStateBound:
            self.bindingStateLabel.text = @"Bound";
            break;
        case DJIAppActivationAircraftBindingStateInitial:
            self.bindingStateLabel.text = @"Initial";
            break;
        case DJIAppActivationAircraftBindingStateNotRequired:
            self.bindingStateLabel.text = @"Binding is not required. ";
            break;
        case DJIAppActivationAircraftBindingStateNotSupported:
            self.bindingStateLabel.text = @"App Activation is not supported. ";
            break;
    }

    switch (self.activationState) {
        case DJIAppActivationStateLoginRequired:
            self.appActivationLabel.text = @"Login is required to activate.";
            break;
        case DJIAppActivationStateUnknown:
            self.appActivationLabel.text = @"Unknown";
            break;
        case DJIAppActivationStateActivated:
            self.appActivationLabel.text = @"Activated";
            break;
        case DJIAppActivationStateNotSupported:
            self.appActivationLabel.text = @"App Activation is not supported.";
            break;
    }
}

-(void)displayItselfIfNeeded {
    if (self.activationState == DJIAppActivationStateLoginRequired ||
        self.aircraftBindingState == DJIAppActivationAircraftBindingStateUnbound ||
        self.aircraftBindingState == DJIAppActivationAircraftBindingStateUnboundButCannotSync) {
        if (!self.isShown && !self.isLoggingIn) {
            [self.navController pushViewController:self animated:YES];
        }
    }
    else {
        if (self.isShown) {
            [self.navController popViewControllerAnimated:YES];
        }
    }
}

- (IBAction)onLoginClick:(id)sender {
    self.isLoggingIn = YES;
    WeakRef(target);
    [[DJISDKManager userAccountManager] logIntoDJIUserAccountWithAuthorizationRequired:NO withCompletion:^(DJIUserAccountState state, NSError * _Nullable error) {
        if (error) {
            ShowResult(@"Login error: %@", error.description);
        }
        target.isLoggingIn = NO;
    }];
}

- (IBAction)onLogoutClick:(id)sender {
    [[DJISDKManager userAccountManager] logOutOfDJIUserAccountWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"Logout error: %@", error.description);
        }
    }];
}

#pragma mark App Activation
-(void)manager:(DJIAppActivationManager *)manager didUpdateAppActivationState:(DJIAppActivationState)appActivationState {
    self.activationState = appActivationState;
    [self updateUI];
    [self displayItselfIfNeeded];
}

-(void)manager:(DJIAppActivationManager *)manager didUpdateAircraftBindingState:(DJIAppActivationAircraftBindingState)aircraftBindingState {
    self.aircraftBindingState = aircraftBindingState;
    [self updateUI];
    [self displayItselfIfNeeded];
}

#pragma mark Navigation View Controller
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.isShown = (viewController == self);
    [self displayItselfIfNeeded];
}

@end
