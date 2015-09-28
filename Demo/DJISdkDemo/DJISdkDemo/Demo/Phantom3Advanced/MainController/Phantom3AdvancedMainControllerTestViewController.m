//
//  MainControllerTestViewController.m
//  DJISdkDemo
//
//  Created by Ares on 14-7-16.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "Phantom3AdvancedMainControllerTestViewController.h"


@interface Phantom3AdvancedMainControllerTestViewController ()

-(IBAction) onSetHomePointButtonClicked:(id)sender;
-(IBAction) onTakeoffButtonClicked:(id)sender;
-(IBAction) onLandingButtonClicked:(id)sender;
- (IBAction)onSetAircraftNameClicked:(id)sender;
- (IBAction)onGetNameClicked:(id)sender;
-(IBAction) onGoHomeButtonClicked:(id)sender;
- (IBAction)onGoHomeAltitudeButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *altitudeInputBox;

@end

@implementation Phantom3AdvancedMainControllerTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _connectionStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    _connectionStatusLabel.backgroundColor = [UIColor clearColor];
    _connectionStatusLabel.textAlignment = NSTextAlignmentCenter;
    _connectionStatusLabel.text = @"Disconnected";
    
    [self.navigationController.navigationBar addSubview:_connectionStatusLabel];

    if (self.connectedDrone) {
        _drone = self.connectedDrone;
    }
    else
    {
        _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom3Advanced];
    }
    mPhantom3AdvancedMainController = (DJIPhantom3AdvancedMainController*)_drone.mainController;

    
    mLastDeviceCoordinate = kCLLocationCoordinate2DInvalid;
    mLastDroneCoordinate = kCLLocationCoordinate2DInvalid;
    if ([CLLocationManager locationServicesEnabled]) {
        mLocationManager = [[CLLocationManager alloc] init];
        mLocationManager.delegate = self;
        mLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [mLocationManager startUpdatingLocation];
    }
    
    self.statusTextView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, 2*self.scrollView.frame.size.height)];
    self.statusTextView.numberOfLines = 0;
    self.statusTextView.font = [UIFont systemFontOfSize:12];
    self.statusTextView.textAlignment = NSTextAlignmentLeft;
    [self.scrollView setContentSize:self.statusTextView.bounds.size];
    [self.scrollView addSubview:self.statusTextView];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _drone.delegate = self;
    _drone.mainController.mcDelegate = self;
    [_drone connectToDrone];
    [_drone.mainController startUpdateMCSystemState];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_connectionStatusLabel removeFromSuperview];
    [_drone.mainController stopUpdateMCSystemState];
    [_drone disconnectToDrone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if (newLocation) {
        mLastDeviceCoordinate = newLocation.coordinate;
    }
}

-(void) showErrorMessage:(NSString*)message
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Failed" message:message delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alertView show];
}

-(void) showSuccessed:(NSString*)message
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Successed" message:message delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alertView show];
}

-(IBAction) onSetHomePointButtonClicked:(id)sender
{
    if (CLLocationCoordinate2DIsValid(mLastDroneCoordinate)) {
        [_drone.mainController setHomePoint:mLastDroneCoordinate withResult:^(DJIError *error) {
            if (error.errorCode != ERR_Succeeded) {
                [self showErrorMessage:[NSString stringWithFormat:@"Set Home Point  Failed:(%@), Drone{%0.6f, %0.6f}",   error.errorDescription, mLastDroneCoordinate.latitude, mLastDroneCoordinate.longitude]];
            }
            else
            {
                [self showSuccessed:[NSString stringWithFormat:@"Set Home Point:{%0.6f, %0.6f}", mLastDroneCoordinate.latitude, mLastDroneCoordinate.longitude]];
            }
        }];
    }
}

-(IBAction) onTakeoffButtonClicked:(id)sender
{
    [mPhantom3AdvancedMainController startTakeoffWithResult:^(DJIError *error) {
        ShowResult(@"Takeoff:%@", error.errorDescription);
    }];
}

-(IBAction) onLandingButtonClicked:(id)sender
{
    [mPhantom3AdvancedMainController startLandingWithResult:^(DJIError *error) {
        ShowResult(@"Landing:%@", error.errorDescription);
    }];
}

- (IBAction)onSetAircraftNameClicked:(id)sender
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Set Aircraft Name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = 1000;
    [alertView show];
}

- (IBAction)onGetNameClicked:(id)sender
{
    [mPhantom3AdvancedMainController getAircraftNameWithResult:^(NSString *name, DJIError *error) {
        ShowResult(@"Get Name:%@ Result:%@", error.errorDescription ,name);
    }];
}

- (IBAction)onGoHomeAltitudeButtonClicked:(id)sender
{
    if (self.altitudeInputBox.text == nil || self.altitudeInputBox.text.length == 0) {
        ShowResult(@"Please input altitude.");
        return;
    }
    
    int altitude = [self.altitudeInputBox.text intValue];
    if (altitude < 20 || altitude > 500) {
        ShowResult(@"GoHome Altitude should be 20M - 5000M");
        return;
    }
    
    WeakRef(obj);
    [mPhantom3AdvancedMainController setGoHomeDefaultAltitude:altitude withResult:^(DJIError *error) {
        ShowResult(@"Set GoHome Altitude:%@", error.errorDescription);
        if (error.errorCode == ERR_Succeeded) {
            WeakReturn(obj);
            [obj getGoHomeAltitude];
        }
    }];
}

-(void) getGoHomeAltitude
{
    [mPhantom3AdvancedMainController getGoHomeDefaultAltitude:^(float altitude, DJIError *error) {
        if (ERR_Succeeded == error.errorCode) {
            self.altitudeInputBox.text = [NSString stringWithFormat:@"%d", (int)altitude];
        }
    }];
}

-(IBAction) onGoHomeButtonClicked:(id)sender
{
    [mPhantom3AdvancedMainController startGoHomeWithResult:^(DJIError *error) {
        ShowResult(@"GoHome:%@", error.errorDescription);
    }];
}

-(void) mainController:(DJIMainController*)mc didMainControlError:(MCError)error
{
    self.errorLabel.text = [NSString stringWithFormat:@"MCError:%d", (int)error];
}

-(void) mainController:(DJIMainController*)mc didUpdateSystemState:(DJIMCSystemState*)state
{
    {
        NSMutableString* MCSystemStateString = [[NSMutableString alloc] init];
        
        [MCSystemStateString appendFormat:@"satelliteCount = %d\n", state.satelliteCount];
        [MCSystemStateString appendFormat:@"homeLocation = {%f, %f}\n", state.homeLocation.latitude, state.homeLocation.longitude];
        [MCSystemStateString appendFormat:@"droneLocation = {%f, %f}\n", state.droneLocation.latitude, state.droneLocation.longitude];
        [MCSystemStateString appendFormat:@"velocityX = %f m/s\n", state.velocityX];
        [MCSystemStateString appendFormat:@"velocityY = %f m/s\n", state.velocityY];
        [MCSystemStateString appendFormat:@"velocityZ = %f m/s\n", state.velocityZ];
        [MCSystemStateString appendFormat:@"altitude = %f m\n", state.altitude];
        [MCSystemStateString appendFormat:@"DJIaltitude  = {%f, %f , %f}\n", state.attitude.pitch ,state.attitude.roll , state.attitude.yaw];
        [MCSystemStateString appendFormat:@"powerLevel = %d\n", state.powerLevel];
        [MCSystemStateString appendFormat:@"isFlying = %d\n", state.isFlying];
        [MCSystemStateString appendFormat:@"noFlyStatus = %d\n", (int)state.noFlyStatus];
        [MCSystemStateString appendFormat:@"noFlyZoneCenter = {%f,%f}\n", state.noFlyZoneCenter.latitude,state.noFlyZoneCenter.longitude];
        [MCSystemStateString appendFormat:@"noFlyZoneRadius = %d\n", state.noFlyZoneRadius];
        [MCSystemStateString appendFormat:@"RemainTimeForFlight = %d min\n", (int)state.smartGoHomeData.remainTimeForFlight / 60];
        [MCSystemStateString appendFormat:@"timeForGoHome = %d s\n", (int)state.smartGoHomeData.timeForGoHome];
        [MCSystemStateString appendFormat:@"timeForLanding = %d s\n", (int)state.smartGoHomeData.timeForLanding];
        [MCSystemStateString appendFormat:@"powerPercentForGoHome = %d%%\n", (int)state.smartGoHomeData.powerPercentForGoHome];
        [MCSystemStateString appendFormat:@"powerPercentForLanding = %d%%\n", (int)state.smartGoHomeData.powerPercentForLanding];
        [MCSystemStateString appendFormat:@"radiusForGoHome = %d m\n", (int)state.smartGoHomeData.radiusForGoHome];
        [MCSystemStateString appendFormat:@"droneRequestGoHome = %d\n", state.smartGoHomeData.droneRequestGoHome];
        
        [MCSystemStateString appendFormat:@"isFailsafe = %d\n", state.isFailsafe];
        [MCSystemStateString appendFormat:@"isIMUPreheating = %d\n", state.isIMUPreheating];
        [MCSystemStateString appendFormat:@"isUltrasonicWorking = %d\n", state.isUltrasonicWorking];
        [MCSystemStateString appendFormat:@"isVisionWorking = %d\n", state.isVisionWorking];
        [MCSystemStateString appendFormat:@"isMotorWorking = %d\n", state.isMotorWorking];
        [MCSystemStateString appendFormat:@"flightModeString = %@\n", state.flightModeString];

        
        _statusTextView.text = MCSystemStateString;
        mLastDroneCoordinate = state.droneLocation;
        mLastSystemState = state;
    }
}

#pragma mark - DJIDroneDelegate

-(void) droneOnConnectionStatusChanged:(DJIConnectionStatus)status
{
    switch (status) {
        case ConnectionStartConnect:
            
            break;
        case ConnectionSucceeded:
        {
            _connectionStatusLabel.text = @"Connected";
            break;
        }
        case ConnectionFailed:
        {
            _connectionStatusLabel.text = @"Connect Failed";
            break;
        }
        case ConnectionBroken:
        {
            _connectionStatusLabel.text = @"Disconnected";
            break;
        }
        default:
            break;
    }
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000) {
        if (buttonIndex == 1) {
            UITextField* textField = [alertView textFieldAtIndex:0];
            NSString* newName = textField.text;
            if (newName) {
                if (newName.length < 32) {
                    [mPhantom3AdvancedMainController setAircraftName:newName withResult:^(DJIError *error) {
                        ShowResult(@"Set Name: %@", error.errorDescription);
                    }];
                }
                else
                {
                    ShowResult(@"Name is Too Long.(should be < 32 )");
                }
            }
        }
    }
}
@end
