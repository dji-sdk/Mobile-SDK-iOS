//
//  MainControllerTestViewController.m
//  DJISdkDemo
//
//  Created by Ares on 14-7-16.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "InspireMainControllerTestViewController.h"

@interface InspireMainControllerTestViewController ()


-(IBAction) onSetHomePointButtonClicked:(id)sender;

-(IBAction) onTakeoffButtonClicked:(id)sender;

-(IBAction) onLandingButtonClicked:(id)sender;
- (IBAction)onSetAircraftNameClicked:(id)sender;
- (IBAction)onGetNameClicked:(id)sender;
- (IBAction)onSendExternalDeviceDataButtonClicked:(id)sender;
-(IBAction) onGoHomeButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *dataInputBox;
@property (weak, nonatomic) IBOutlet UITextField *altitudeInputBox;
- (IBAction)onGoHomeAltitudeButtonClicked:(id)sender;
@end

@implementation InspireMainControllerTestViewController

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
        _drone = [[DJIDrone alloc] initWithType:DJIDrone_Inspire];
    }
    
    _drone.delegate = self;
    mInspireMainController = (DJIInspireMainController*)_drone.mainController;
    mInspireMainController.mcDelegate = self;
    
    mLastDeviceCoordinate = kCLLocationCoordinate2DInvalid;
    mLastDroneCoordinate = kCLLocationCoordinate2DInvalid;
    if ([CLLocationManager locationServicesEnabled]) {
        mLocationManager = [[CLLocationManager alloc] init];
        mLocationManager.delegate = self;
        mLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [mLocationManager startUpdatingLocation];
    }
    
    self.statusTextView = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.scrollView.frame.size.width - 20, 2*self.scrollView.frame.size.height)];
    self.statusTextView.numberOfLines = 0;
    self.statusTextView.font = [UIFont systemFontOfSize:12];
    self.statusTextView.textAlignment = NSTextAlignmentLeft;
    [self.scrollView setContentSize:self.statusTextView.bounds.size];
    [self.scrollView addSubview:self.statusTextView];
    self.scrollView.layer.borderColor = [UIColor blackColor].CGColor;
    self.scrollView.layer.borderWidth = 1.3;
    self.scrollView.layer.cornerRadius = 3.0;
    self.scrollView.layer.masksToBounds = YES;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
    [mInspireMainController setHomePointUsingAircraftCurrentLocationWithResult:^(DJIError *error) {
        ShowResult(@"Set Home Point:%@", error.errorDescription);
    }];
}

-(IBAction) onTakeoffButtonClicked:(id)sender
{
    [mInspireMainController startTakeoffWithResult:^(DJIError *error) {
        ShowResult(@"Takeoff:%@", error.errorDescription);
    }];
}

-(IBAction) onLandingButtonClicked:(id)sender
{
    [mInspireMainController startLandingWithResult:^(DJIError *error) {
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
    [mInspireMainController getAircraftNameWithResult:^(NSString *name, DJIError *error) {
        ShowResult(@"Get Name:%@ Result:%@", error.errorDescription ,name);
    }];
}

-(IBAction) onGoHomeButtonClicked:(id)sender
{
    [mInspireMainController startGoHomeWithResult:^(DJIError *error) {
        ShowResult(@"GoHome:%@", error.errorDescription);
    }];
}

/**
 *  Send data to external device. Supported in M100 drone only. Inspire/Phantom3 PRO not support.
 *
 */
- (IBAction)onSendExternalDeviceDataButtonClicked:(id)sender {
    if ([self.dataInputBox isFirstResponder]) {
        [self.dataInputBox resignFirstResponder];
    }
    
    NSString* text = self.dataInputBox.text;
    if (text == nil || text.length == 0) {
        ShowResult(@"Please input data.");
        return;
    }
    
    NSData* data = [text dataUsingEncoding:NSUTF8StringEncoding];
    [mInspireMainController sendDataToExternalDevice:data withResult:^(DJIError *error) {
        ShowResult(@"Send Data:%@ Result:%@", data, error.errorDescription);
    }];
}

- (IBAction)onGoHomeAltitudeButtonClicked:(UIButton*)sender {
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
    [mInspireMainController setGoHomeDefaultAltitude:altitude withResult:^(DJIError *error) {
        ShowResult(@"Set GoHome Altitude:%@", error.errorDescription);
        if (error.errorCode == ERR_Succeeded) {
            WeakReturn(obj);
            [obj getGoHomeAltitude];
        }
    }];
}

-(void) getGoHomeAltitude
{
    [mInspireMainController getGoHomeDefaultAltitude:^(float altitude, DJIError *error) {
        if (ERR_Succeeded == error.errorCode) {
            self.altitudeInputBox.text = [NSString stringWithFormat:@"%d", (int)altitude];
        }
    }];
}

-(void) mainController:(DJIMainController*)mc didMainControlError:(MCError)error
{
    switch (error) {
        case MC_NO_ERROR:
        {
            self.errorLabel.text = @"NO Error";
            break;
        }
        case MC_CONFIG_ERROR:
        {
            self.errorLabel.text = @"Config Error";
            break;
        }
        case MC_SERIALNUM_ERROR:
        {
            self.errorLabel.text = @"SERIALNUM_ERROR";
            break;
        }
        case MC_IMU_ERROR:
        {
            self.errorLabel.text = @"IMU_ERROR";
            break;
        }
        case MC_X1_ERROR:
        {
            self.errorLabel.text = @"X1_ERROR";
            break;
        }
        case MC_X2_ERROR:
        {
            self.errorLabel.text = @"X2_ERROR";
            break;
        }
        case MC_PMU_ERROR:
        {
            self.errorLabel.text = @"PMU_ERROR";
            break;
        }
        case MC_TRANSMITTER_ERROR:
        {
            self.errorLabel.text = @"TRANSMITTER_ERROR";
            break;
        }
        case MC_SENSOR_ERROR:
        {
            self.errorLabel.text = @"SENSOR_ERROR";
            break;
        }
        case MC_COMPASS_ERROR:
        {
            self.errorLabel.text = @"COMPASS_ERROR";
            break;
        }
        case MC_IMU_CALIBRATION_ERROR:
        {
            self.errorLabel.text = @"IMU_CALIBRATION_ERROR";
            break;
        }
        case MC_COMPASS_CALIBRATION_ERROR:
        {
            self.errorLabel.text = @"COMPASS_CALIBRATION_ERROR";
            break;
        }
        case MC_TRANSMITTER_CALIBRATION_ERROR:
        {
            self.errorLabel.text = @"TRANSMITTER_CALIBRATION_ERROR";
            break;
        }
        case MC_INVALID_BATTERY_ERROR:
        {
            self.errorLabel.text = @"INVALID_BATTERY_ERROR";
            break;
        }
        case MC_INVALID_BATTERY_COMMUNICATION_ERROR:
        {
            self.errorLabel.text = @"INVALID_BATTERY_COMMUNICATION_ERROR";
            break;
        }
            
        default:
            break;
    }
}

-(void) mainController:(DJIMainController*)mc didUpdateSystemState:(DJIMCSystemState*)state
{
    DJIMCSystemState* inspireSystemState = (DJIMCSystemState*)state;
    {
        NSMutableString* MCSystemStateString = [[NSMutableString alloc] init];
        
        [MCSystemStateString appendFormat:@"satelliteCount = %d\n", inspireSystemState.satelliteCount];
        [MCSystemStateString appendFormat:@"homeLocation = {%f, %f}\n", inspireSystemState.homeLocation.latitude, inspireSystemState.homeLocation.longitude];
        [MCSystemStateString appendFormat:@"droneLocation = {%f, %f}\n", inspireSystemState.droneLocation.latitude, inspireSystemState.droneLocation.longitude];
        [MCSystemStateString appendFormat:@"velocityX = %f m/s\n", inspireSystemState.velocityX];
        [MCSystemStateString appendFormat:@"velocityY = %f m/s\n", inspireSystemState.velocityY];
        [MCSystemStateString appendFormat:@"velocityZ = %f m/s\n", inspireSystemState.velocityZ];
        [MCSystemStateString appendFormat:@"altitude = %f m\n", inspireSystemState.altitude];
        [MCSystemStateString appendFormat:@"DJIaltitude  = {%f, %f , %f}\n", inspireSystemState.attitude.pitch ,inspireSystemState.attitude.roll , inspireSystemState.attitude.yaw];
        [MCSystemStateString appendFormat:@"powerLevel = %d\n", inspireSystemState.powerLevel];
        [MCSystemStateString appendFormat:@"isFlying = %d\n", inspireSystemState.isFlying];
        [MCSystemStateString appendFormat:@"noFlyStatus = %d\n", (int)inspireSystemState.noFlyStatus];
        [MCSystemStateString appendFormat:@"noFlyZoneCenter = {%f,%f}\n", inspireSystemState.noFlyZoneCenter.latitude,inspireSystemState.noFlyZoneCenter.longitude];
        [MCSystemStateString appendFormat:@"noFlyZoneRadius = %d\n", inspireSystemState.noFlyZoneRadius];
        [MCSystemStateString appendFormat:@"RemainTimeForFlight = %d min\n", (int)inspireSystemState.smartGoHomeData.remainTimeForFlight / 60];
        [MCSystemStateString appendFormat:@"timeForGoHome = %d s\n", (int)inspireSystemState.smartGoHomeData.timeForGoHome];
        [MCSystemStateString appendFormat:@"timeForLanding = %d s\n", (int)inspireSystemState.smartGoHomeData.timeForLanding];
        [MCSystemStateString appendFormat:@"powerPercentForGoHome = %d%%\n", (int)inspireSystemState.smartGoHomeData.powerPercentForGoHome];
        [MCSystemStateString appendFormat:@"powerPercentForLanding = %d%%\n", (int)inspireSystemState.smartGoHomeData.powerPercentForLanding];
        [MCSystemStateString appendFormat:@"radiusForGoHome = %d m\n", (int)inspireSystemState.smartGoHomeData.radiusForGoHome];
        [MCSystemStateString appendFormat:@"droneRequestGoHome = %d\n", inspireSystemState.smartGoHomeData.droneRequestGoHome];
        
        [MCSystemStateString appendFormat:@"isFailsafe = %d\n", inspireSystemState.isFailsafe];
        [MCSystemStateString appendFormat:@"isIMUPreheating = %d\n", inspireSystemState.isIMUPreheating];
        [MCSystemStateString appendFormat:@"isUltrasonicWorking = %d\n", inspireSystemState.isUltrasonicWorking];
        [MCSystemStateString appendFormat:@"isVisionWorking = %d\n", inspireSystemState.isVisionWorking];
        [MCSystemStateString appendFormat:@"isMotorWorking = %d\n", inspireSystemState.isMotorWorking];
        [MCSystemStateString appendFormat:@"flightModeString = %@\n", inspireSystemState.flightModeString];
        
        [MCSystemStateString appendFormat:@"isReachMaxHeight:%d\n", _drone.mainController.flightLimitation.isReachedMaxFlightHeight];
        [MCSystemStateString appendFormat:@"isReachMaxRadius:%d", _drone.mainController.flightLimitation.isReachedMaxFlightRadius];
        
        _statusTextView.text = MCSystemStateString;
        
        mLastSystemState = state;
        mLastDroneCoordinate = state.droneLocation;
    }
}

-(void) mainController:(DJIMainController *)mc didReceivedDataFromExternalDevice:(NSData *)data
{
    NSString* recvString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (recvString == nil) {
        NSLog(@"External Device Data:%@", data);
    }
    else
    {
        NSLog(@"External Device Data:%@", recvString);
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
                    [mInspireMainController setAircraftName:newName withResult:^(DJIError *error) {
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
