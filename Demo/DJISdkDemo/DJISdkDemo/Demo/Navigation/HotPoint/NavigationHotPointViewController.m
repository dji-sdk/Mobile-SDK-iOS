//
//  InspireHotPointTestViewController.m
//  DJISdkDemo
//
//  Created by Ares on 15/4/27.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "NavigationHotPointViewController.h"
#import "VideoPreviewer.h"

#define RADIAN(x) ((x)*M_PI/180.0)

@interface NavigationHotPointViewController ()
- (IBAction)onSetHotPointButtonClikced:(id)sender;
- (IBAction)onStartStopButtonClicked:(id)sender;
- (IBAction)onPauseResumeButtonClicked:(id)sender;
- (IBAction)onRecordButtonClicked:(id)sender;

@property(nonatomic, assign) DJIDroneType droneType;

@end

@implementation NavigationHotPointViewController

-(id) initWithDroneType:(DJIDroneType)type
{
    self = [super init];
    if (self) {
        self.droneType = type;

    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.connectedDrone) {
        mDrone = self.connectedDrone;
    }
    else
    {
        mDrone = [[DJIDrone alloc] initWithType:self.droneType];
    }
    
    mDrone.delegate = self;
    mDrone.mainController.mcDelegate = self;
    mDrone.camera.delegate = self;
    mNavigationManager = mDrone.mainController.navigationManager;
    mNavigationManager.delegate = self;

    self.mapView.delegate = self;
    
    self.titleLabel = [[UILabel alloc] initWithFrame:self.navigationController.navigationBar.bounds];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont systemFontOfSize:11];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = @"H:{-180.000000, -180.000000}, D:{-180.000000, -180.000000}, GPS:0, H.S:0.0 m/s V.S:0.0 m/s";
    [self.navigationController.navigationBar addSubview:self.titleLabel];
    
    mIsMissionStarted = NO;
    mIsMissionPaused = NO;
    mCurrentHotpointCoordinate = kCLLocationCoordinate2DInvalid;
    
    _isNeedMissionSync = YES;
    
    UIView* button1 = [self.view viewWithTag:100];
    [self decorateView:button1];
    UIView* button2 = [self.view viewWithTag:200];
    [self decorateView:button2];
    UIView* button3 = [self.view viewWithTag:300];
    [self decorateView:button3];
    
    [self decorateView:self.recordButton];
    
    self.configView = [[HotPointConfigView alloc] initWithNib];
    self.configView.alpha = 0;
    self.configView.delegate = self;
    self.configView.layer.cornerRadius = 4.0;
    self.configView.layer.masksToBounds = YES;
    [self.view addSubview:self.configView];
    
    [[VideoPreviewer instance] start];
}

-(void) decorateView:(UIView*)theView
{
    theView.layer.cornerRadius = theView.frame.size.width * 0.5;
    theView.layer.borderWidth = 1.2;
    theView.layer.borderColor = [UIColor blueColor].CGColor;
    theView.layer.masksToBounds = YES;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [mDrone connectToDrone];
    [mDrone.mainController  startUpdateMCSystemState];
    [mDrone.camera startCameraSystemStateUpdates];
    
    [[VideoPreviewer instance] setView:self.previewView];
    [[VideoPreviewer instance] setDecoderDataSource:[self dataSourceFromDroneType:mDrone.droneType]];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.titleLabel removeFromSuperview];
    [mDrone.mainController stopUpdateMCSystemState];
    [mDrone.camera stopCameraSystemStateUpdates];
    [mDrone disconnectToDrone];
    
    [[VideoPreviewer instance] unSetView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showConfigView
{
    if (self.systemState) {
        [self.configView setAltitude:self.systemState.altitude];
    }
    self.configView.center = self.view.center;
    [UIView animateWithDuration:0.25 animations:^{
        self.configView.alpha = 1.0;
    }];
}

#pragma mark - Func

-(void) downloadHotPointMission
{
    [mNavigationManager.hotpointMission getMissionWithResult:^(DJIError *error) {
        if (error.errorCode == ERR_Succeeded) {
            [self resumeMissionScene];
        }
        else
        {
            ShowResult(@"Download Mission Falied:%@", error.errorDescription);
        }
    }];
}

-(void) resumeMissionScene
{
    if (mNavigationManager.hotpointMission.isValid) {
        mCurrentHotpointCoordinate = mNavigationManager.hotpointMission.hotPoint;
        if (CLLocationCoordinate2DIsValid(mCurrentHotpointCoordinate)) {
            if (self.hotPointAnnotation == nil) {
                self.hotPointAnnotation = [[MKPointAnnotation alloc] init];
                [self.mapView addAnnotation:self.hotPointAnnotation];
            }
            [self.hotPointAnnotation setCoordinate:mCurrentHotpointCoordinate];
            self.hotPointAnnotation.title = [NSString stringWithFormat:@"{%0.6f, %0.6f}", mCurrentHotpointCoordinate.latitude, mCurrentHotpointCoordinate.longitude];
            
            MKCoordinateRegion region = {0};
            region.center = mCurrentHotpointCoordinate;
            region.span.latitudeDelta = 0.001;
            region.span.longitudeDelta = 0.001;
            
            [self.mapView setRegion:region animated:YES];
            
            mIsMissionStarted = YES;
            [self.startStopButton setTitle:@"Stop" forState:UIControlStateNormal];
        }
    }
}

#pragma mark - DJINavigation

-(void) onNavigationMissionStatusChanged:(DJINavigationMissionStatus*)missionStatus
{
    if (missionStatus.missionType == DJINavigationMissionHotpoint) {
        DJIHotpointMissionStatus* hotPointMissionStatus = (DJIHotpointMissionStatus*)missionStatus;
        NSLog(@"Radius:%f", hotPointMissionStatus.currentRadius);
        
        if (_isNeedMissionSync) {
            _isNeedMissionSync = NO;
            [self downloadHotPointMission];
        }
        
        if (hotPointMissionStatus.error.errorCode != ERR_Succeeded) {
            ShowResult(@"Mission Error:%@", hotPointMissionStatus.error.errorDescription);
        }
    }
}

#pragma mark - DJIMainControllerDelegate

-(void) mainController:(DJIMainController*)mc didUpdateSystemState:(DJIMCSystemState*)state
{
    float speed = sqrtf(state.velocityX*state.velocityX + state.velocityY*state.velocityY);
    NSString* titleMessage = [NSString stringWithFormat:@"H:{%0.6f, %0.6f}, D:{%0.6f, %0.6f}, GPS:%d, H.S:%0.1f m/s V.S:%0.1f m/s", state.homeLocation.latitude, state.homeLocation.longitude, state.droneLocation.latitude, state.droneLocation.longitude, state.satelliteCount, speed, state.velocityZ];
    self.titleLabel.text = titleMessage;
    
    self.systemState = state;
    
    if (CLLocationCoordinate2DIsValid(state.droneLocation)) {
        if (self.aircraftAnnotation == nil) {
            self.aircraftAnnotation = [[DJIAircraftAnnotation alloc] initWithCoordiante:state.droneLocation];
            [self.mapView addAnnotation:self.aircraftAnnotation];
        }

        [self.aircraftAnnotation setCoordinate:state.droneLocation];
        double heading = RADIAN(state.attitude.yaw);
        DJIAircraftAnnotationView* annoView = (DJIAircraftAnnotationView*)[self.mapView viewForAnnotation:self.aircraftAnnotation];
        [annoView updateHeading:heading];
    }
}

#pragma mark - DJICameraDelegate

-(void) camera:(DJICamera*)camera didReceivedVideoData:(uint8_t*)videoBuffer length:(int)length
{
    uint8_t* pBuffer = (uint8_t*)malloc(length);
    memcpy(pBuffer, videoBuffer, length);
    [[[VideoPreviewer instance] dataQueue] push:pBuffer length:length];
}

-(void) camera:(DJICamera*)camera didUpdateSystemState:(DJICameraSystemState*)systemState
{
    if (_isRecording != systemState.isRecording) {
        [self.recordButton setTitleColor:(systemState.isRecording ? [UIColor redColor] : [UIColor blueColor]) forState:UIControlStateNormal];
    }
    _isRecording = systemState.isRecording;
    
    if (systemState.workMode != CameraWorkModeRecord) {
        if ([mDrone.camera isKindOfClass:[DJIInspireCamera class]]) {
            [(DJIInspireCamera*)mDrone.camera setCameraWorkMode:CameraWorkModeRecord withResult:nil];
        }
        else if ([mDrone.camera isKindOfClass:[DJIPhantom3ProCamera class]])
        {
            [(DJIPhantom3ProCamera*)mDrone.camera setCameraWorkMode:CameraWorkModeRecord withResult:nil];
        }
        else if ([mDrone.camera isKindOfClass:[DJIPhantom3AdvancedCamera class]])
        {
            [(DJIPhantom3AdvancedCamera*)mDrone.camera setCameraWorkMode:CameraWorkModeRecord withResult:nil];
        }
    }
}

#pragma mark -

-(void) droneOnConnectionStatusChanged:(DJIConnectionStatus)status
{
    
    if (status == ConnectionSucceeded) {
        [self enterNavigation];
    }
}

-(void) enterNavigation
{
    [mNavigationManager enterNavigationModeWithResult:^(DJIError *error) {
        if (error.errorCode == ERR_Succeeded) {
            ShowResult(@"Enter Navigation Mode:%@", error.errorDescription);
        }
        else
        {
            NSString* message = [NSString stringWithFormat:@"Enter Navigation Mode:%@", error.errorDescription];
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil];
            alertView.tag = 1000;
            [alertView show];
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000) {
        if (buttonIndex != 0) {
            [self enterNavigation];
        }
    }
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        if (annotation == self.hotPointAnnotation) {
            MKPinAnnotationView* pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"HotPointAnnotation"];
            pinView.pinColor = MKPinAnnotationColorRed;
            pinView.animatesDrop = YES;
            return pinView;
        }
    }
    else if ([annotation isKindOfClass:[DJIAircraftAnnotation class]]) {
        MKAnnotationView* annoView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"DJIAircraftAnnotationView"];
        if (annoView == nil) {
            annoView = [[DJIAircraftAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"DJIAircraftAnnotationView"];
        }
        return annoView;
    }
    
    return nil;
}

-(void) configViewWillDisappear
{
    NSObject<DJIHotPointMission>* mission = mNavigationManager.hotpointMission;
    mission.hotPoint = mCurrentHotpointCoordinate;
    mission.altitude = self.configView.altitude;
    mission.surroundRadius = self.configView.radius;
    mission.angularVelocity = self.configView.speed;
    mission.entryPoint = self.configView.entryPoint;
    mission.headingMode = self.configView.headingMode;
    mission.clockwise = self.configView.clockwise;
    
    //Hot point mission's altitude should between low limit and hight limit. default low limit is 5M, hight limit is 120M
    if (mission.altitude < 5 ||
        mission.altitude > 120) {
        ShowResult(@"Mission altitude should be in [5M, 120M]");
        return;
    }
    
    if (mission.surroundRadius > DJIMaxSurroundingRadius) {
        ShowResult(@"Mission surround radius too large");
        return;
    }
    
    float maxSpeed = [mission maxAngularVelocityForRadius:mission.surroundRadius];
    if (mission.angularVelocity > maxSpeed) {
        ShowResult(@"Speed should not larger then:%0.1f", maxSpeed);
        return;
    }

    [mNavigationManager.hotpointMission startMissionWithResult:^(DJIError *error) {
        ShowResult(@"Start Hotpoint Mission:%@(%d)", error.errorDescription, error.errorCode);
        if (error.errorCode == ERR_Succeeded) {
            mIsMissionStarted = YES;
            [self.startStopButton setTitle:@"Stop" forState:UIControlStateNormal];
        }
    }];
}

#pragma mark - Button Action

- (IBAction)onSetHotPointButtonClikced:(id)sender
{
    if (mIsMissionStarted) {
        ShowResult(@"There is a mission in executing...");
        return;
    }
    if (self.systemState == nil) {
        return;
    }
    
    _isNeedMissionSync = NO;
    
    mCurrentHotpointCoordinate = self.systemState.droneLocation;
    if (CLLocationCoordinate2DIsValid(mCurrentHotpointCoordinate)) {
        if (self.hotPointAnnotation == nil) {
            self.hotPointAnnotation = [[MKPointAnnotation alloc] init];
            [self.mapView addAnnotation:self.hotPointAnnotation];
        }
        [self.hotPointAnnotation setCoordinate:mCurrentHotpointCoordinate];
        self.hotPointAnnotation.title = [NSString stringWithFormat:@"{%0.6f, %0.6f}", mCurrentHotpointCoordinate.latitude, mCurrentHotpointCoordinate.longitude];
        
        MKCoordinateRegion region = {0};
        region.center = mCurrentHotpointCoordinate;
        region.span.latitudeDelta = 0.001;
        region.span.longitudeDelta = 0.001;
        
        [self.mapView setRegion:region animated:YES];
    }
}

- (IBAction)onStartStopButtonClicked:(UIButton*)sender
{
    if (mIsMissionStarted) {
        [mNavigationManager.hotpointMission stopMissionWithResult:^(DJIError *error) {
            ShowResult(@"Stop Hotpoint Mission:%@(%d)", error.errorDescription, error.errorCode);
            if (error.errorCode == ERR_Succeeded) {
                mIsMissionStarted = NO;
                [self.startStopButton setTitle:@"Start" forState:UIControlStateNormal];
            }
        }];
    }
    else
    {
        if (CLLocationCoordinate2DIsValid(mCurrentHotpointCoordinate)) {
            [self showConfigView];
        }
        else
        {
            ShowResult(@"Current location is invalid.");
        }
    }

}

- (IBAction)onPauseResumeButtonClicked:(UIButton*)sender
{
    if (mIsMissionStarted) {
        if (mIsMissionPaused) {
            [mNavigationManager.hotpointMission resumeMissionWithResult:^(DJIError *error) {
                ShowResult(@"Resume Hotpoint Mission:%@", error.errorDescription);
                if (error.errorCode == ERR_Succeeded) {
                    mIsMissionPaused = NO;
                    [sender setTitle:@"Pause" forState:UIControlStateNormal];
                }
            }];
        }
        else
        {
            [mNavigationManager.hotpointMission pauseMissionWithResult:^(DJIError *error) {
                ShowResult(@"Pause Hotpoint Mission:%@", error.errorDescription);
                if (error.errorCode == ERR_Succeeded) {
                    mIsMissionPaused = YES;
                    [sender setTitle:@"Resume" forState:UIControlStateNormal];
                }
            }];
        }
    }
}

- (IBAction)onRecordButtonClicked:(id)sender
{
    if (_isRecording) {
        [mDrone.camera stopRecord:^(DJIError *error) {
            ShowResult(@"Stop Rec:%@", error.errorDescription);
        }];
    }
    else
    {
        [mDrone.camera startRecord:^(DJIError *error) {
            ShowResult(@"Stard Rec:%@", error.errorDescription);
        }];
    }
}
@end
