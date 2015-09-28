//
//  GimbalTestViewController.m
//  DJISdkDemo
//
//  Created by Ares on 14-7-16.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "InspireGimbalTestViewController.h"

@interface InspireGimbalTestViewController ()
- (IBAction)onWorkModeSelectionChanged:(id)sender;
- (IBAction)onRollFineTuneChanged:(id)sender;
- (IBAction)onGimbalResetButtonClicked:(id)sender;
- (IBAction)onGimbalCalibrationButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *yawReachMax;
@property (weak, nonatomic) IBOutlet UILabel *pitchReachMax;
@property (weak, nonatomic) IBOutlet UILabel *rollFineTune;
@property (weak, nonatomic) IBOutlet UISegmentedControl *workModeSegmented;

@property (strong, nonatomic) DJIGimbalState* lastGimbalState;

@end

@implementation InspireGimbalTestViewController

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
    if (self.connectedDrone) {
        mDrone = self.connectedDrone;
    }
    else
    {
        mDrone = [[DJIDrone alloc] initWithType:DJIDrone_Inspire];
    }
    
    mDrone.delegate = self;
    mGimbal = (DJIInspireGimbal*)mDrone.gimbal;
    mGimbal.delegate = self;
    
    self.lastGimbalState = nil;

    [self initViews];
}

-(void) initViews
{
    self.attitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    self.attitudeLabel.backgroundColor = [UIColor clearColor];
    self.attitudeLabel.textAlignment = NSTextAlignmentCenter;
    self.attitudeLabel.font = [UIFont systemFontOfSize:14];
    self.attitudeLabel.text = @"Pitch:0\tRoll:0\tYaw:0";
    [self.navigationController.navigationBar addSubview:self.attitudeLabel];
    
    self.pitchReachMax.layer.cornerRadius = self.pitchReachMax.frame.size.width * 0.5;
    self.pitchReachMax.layer.borderColor = [UIColor blackColor].CGColor;
    self.pitchReachMax.layer.borderWidth = 1.2;
    self.pitchReachMax.layer.masksToBounds = YES;
    
    self.yawReachMax.layer.cornerRadius = self.yawReachMax.frame.size.width * 0.5;
    self.yawReachMax.layer.borderColor = [UIColor blackColor].CGColor;
    self.yawReachMax.layer.borderWidth = 1.2;
    self.yawReachMax.layer.masksToBounds = YES;
    
    self.rollFineTune.layer.cornerRadius = 4.0;
    self.rollFineTune.layer.borderColor = [UIColor blackColor].CGColor;
    self.rollFineTune.layer.borderWidth = 1.2;
    self.rollFineTune.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    
    [mDrone connectToDrone];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.attitudeLabel removeFromSuperview];

    [mDrone disconnectToDrone];
}

-(void) onGimbalAttitudeYawRotationForward
{
    DJIGimbalRotation pitch = {YES, 0, RelativeAngle, RotationForward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationForward};
    DJIGimbalRotation yaw = {YES, 20, RelativeAngle, RotationForward};
    
    while (_gimbalAttitudeUpdateFlag) {
        [mGimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:nil];
        usleep(40000);
    }
    // stop rotation.
    pitch.angle = 0;
    roll.angle = 0;
    yaw.angle = 0;
    [mGimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:nil];
}

-(void) onGimbalAttitudeYawRotationBackward
{
    DJIGimbalRotation pitch = {YES, 0, RelativeAngle, RotationBackward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationBackward};
    DJIGimbalRotation yaw = {YES, 20, RelativeAngle, RotationBackward};
    
    while (_gimbalAttitudeUpdateFlag) {
        [mGimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:nil];
        usleep(40000);
    }
    
    // stop rotation.
    pitch.angle = 0;
    roll.angle = 0;
    yaw.angle = 0;
    [mGimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:nil];
}

-(void) onGimbalAttitudeScrollUp
{
    DJIGimbalRotation pitch = {YES, 15, RelativeAngle, RotationForward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationForward};
    DJIGimbalRotation yaw = {YES, 0, RelativeAngle, RotationForward};
    
    while (_gimbalAttitudeUpdateFlag) {
        [mGimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:nil];
        usleep(40000);
    }
    
    // stop rotation.
    pitch.angle = 0;
    roll.angle = 0;
    yaw.angle = 0;
    [mGimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:nil];
}

-(void) onGimbalAttitudeScrollDown
{
    DJIGimbalRotation pitch = {YES, 15, RelativeAngle, RotationBackward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationBackward};
    DJIGimbalRotation yaw = {YES, 0, RelativeAngle, RotationBackward};
    while (_gimbalAttitudeUpdateFlag) {
        [mGimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:nil];
        usleep(40000);
    }
    
    // stop rotation.
    pitch.angle = 0;
    roll.angle = 0;
    yaw.angle = 0;
    [mGimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:nil];
}

-(IBAction) onGimbalScrollUpTouchDown:(id)sender
{
    _gimbalAttitudeUpdateFlag = YES;
    [NSThread detachNewThreadSelector:@selector(onGimbalAttitudeScrollUp) toTarget:self withObject:nil];
}

-(IBAction) onGimbalScrollUpTouchUp:(id)sender
{
    _gimbalAttitudeUpdateFlag = NO;
    [mGimbal stopGimbalAttitudeUpdates];
}

-(IBAction) onGimbalScroollDownTouchDown:(id)sender
{
    _gimbalAttitudeUpdateFlag = YES;
    [NSThread detachNewThreadSelector:@selector(onGimbalAttitudeScrollDown) toTarget:self withObject:nil];
}

-(IBAction) onGimbalScroollDownTouchUp:(id)sender
{
    _gimbalAttitudeUpdateFlag = NO;
    [mGimbal stopGimbalAttitudeUpdates];
}

-(IBAction) onGimbalYawRotationForwardTouchDown:(id)sender
{
    _gimbalAttitudeUpdateFlag = YES;
    [NSThread detachNewThreadSelector:@selector(onGimbalAttitudeYawRotationForward) toTarget:self withObject:nil];
}

-(IBAction) onGimbalYawRotationForwardTouchUp:(id)sender
{
    _gimbalAttitudeUpdateFlag = NO;
    [mGimbal stopGimbalAttitudeUpdates];
}

-(IBAction) onGimbalYawRotationBackwardTouchDown:(id)sender
{
    _gimbalAttitudeUpdateFlag = YES;
    [NSThread detachNewThreadSelector:@selector(onGimbalAttitudeYawRotationBackward) toTarget:self withObject:nil];
}

-(IBAction) onGimbalYawRotationBackwardTouchUp:(id)sender
{
    _gimbalAttitudeUpdateFlag = NO;
    [mGimbal stopGimbalAttitudeUpdates];
}

- (IBAction)onWorkModeSelectionChanged:(UISegmentedControl*)sender
{
    DJIGimbalWorkMode workMode = (DJIGimbalWorkMode)sender.selectedSegmentIndex;
    [mGimbal setGimbalWorkMode:workMode withResult:^(DJIError *error) {
        ShowResult(@"Set Gimbal Work Mode:%@", error.errorDescription);
    }];
}

- (IBAction)onRollFineTuneChanged:(UIStepper*)sender
{
    int currentStep = sender.value;
    if (currentStep > mLastStepValue) {
        [mGimbal setGimbalRollFineTune:1 withResult:nil];
    }
    else
    {
        [mGimbal setGimbalRollFineTune:-1 withResult:nil];
    }
    mLastStepValue = currentStep;
}
- (IBAction)onGimbalResetButtonClicked:(UIButton*)sender
{
    [mGimbal resetGimbalWithResult:nil];
}

- (IBAction)onGimbalCalibrationButtonClicked:(UIButton*)sender
{
    [mGimbal startGimbalAutoCalibrationWithResult:^(DJIError *error) {
        ShowResult(@"Start Gimbal Calibration:%@", error.errorDescription);
    }];
}

-(IBAction) onSetGimbalAngleButtonClicked:(id)sender
{
    float pitch = [self.pitchInputBox.text floatValue];
    float yaw = [self.yawInputBox.text floatValue];
    DJIGimbalRotationDirection pitchDir = pitch > 0 ? RotationForward : RotationBackward;
    DJIGimbalRotationDirection yawDir = yaw > 0 ? RotationForward : RotationBackward;
    DJIGimbalRotation pitchRotation, yawRotation, rollRotation = {0};
    pitchRotation.angle = pitch;
    pitchRotation.angleType = AbsoluteAngle;
    pitchRotation.direction = pitchDir;
    pitchRotation.enable = YES;
    
    yawRotation.angle = yaw;
    yawRotation.angleType = AbsoluteAngle;
    yawRotation.direction = yawDir;
    yawRotation.enable = YES;
    
    rollRotation.enable = NO;
    
    mGimbal.completionTimeForControlAngleAction = 1.5;
    
    [mGimbal setGimbalPitch:pitchRotation Roll:rollRotation Yaw:yawRotation withResult:^(DJIError *error) {
        ShowResult(@"Set Gimbal Angle:%@", error.errorDescription);
    }];
}

#pragma mark - DJIDroneDelegate

-(void) droneOnConnectionStatusChanged:(DJIConnectionStatus)status
{
    if (status == ConnectionSucceeded) {
        
    }
}

#pragma mark - DJIGimbalDelegate

-(void) gimbalController:(DJIGimbal*)controller didGimbalError:(DJIGimbalError)error
{
    if (error == GimbalClamped) {
        NSLog(@"Gimbal Clamped");
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Gimbal Clamped" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    if (error == GimbalErrorNone) {
        NSLog(@"Gimbal Error None");
        
    }
    if (error == GimbalMotorAbnormal) {
        NSLog(@"Gimbal Motor Abnormal");
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Gimbal Motor Abnormal" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

-(void) gimbalController:(DJIGimbal *)controller didUpdateGimbalState:(DJIGimbalState*)gimbalState
{
    if (self.lastGimbalState.isCalibrating != gimbalState.isCalibrating) {
        NSMutableString* message = [[NSMutableString alloc] init];
        [message appendFormat:@"Is Calibrating:%d", gimbalState.isCalibrating];
        if (self.lastGimbalState.isCalibrating == YES && gimbalState.isCalibrating == NO) {
            [message appendFormat:@" Calibration %@", gimbalState.isCalibrationSueeeeded ? @"Succeeded" : @"Failed"];
        }
        
        ShowResult(message);
    }

    NSString* atti = [NSString stringWithFormat:@"Pitch:%0.1f\tRoll:%0.1f\tYaw:%0.1f", gimbalState.attitude.pitch, gimbalState.attitude.roll, gimbalState.attitude.yaw];
    self.attitudeLabel.text = atti;
    
    if (gimbalState.isPitchReachMax) {
        [self.pitchReachMax setBackgroundColor:[UIColor redColor]];
    }
    else
    {
        [self.pitchReachMax setBackgroundColor:[UIColor whiteColor]];
    }
    if (gimbalState.isYawReachMax) {
        [self.yawReachMax setBackgroundColor:[UIColor redColor]];
    }
    else
    {
        [self.yawReachMax setBackgroundColor:[UIColor whiteColor]];
    }
    self.rollFineTune.text = [NSString stringWithFormat:@"%ld", (long)gimbalState.rollFineTune];
    [self.workModeSegmented setSelectedSegmentIndex:gimbalState.workMode];
    
    self.lastGimbalState = gimbalState;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if ([self.pitchInputBox isFirstResponder]) {
        [self.pitchInputBox resignFirstResponder];
    }
    if ([self.yawInputBox isFirstResponder]) {
        [self.yawInputBox resignFirstResponder];
    }
    return YES;
}

@end
