//
//  DJIIOCViewController.m
//  DJISdkDemo
//
//  Created by Ares on 15/7/1.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "NavigationIOCViewController.h"
#import "VideoPreviewer.h"
#import "DJIDemoHelper.h"
#import "DJIAircraftAnnotation.h"
#import "DJIAircraftAnnotationView.h"
#import "DJIWaypointAnnotation.h"
#import "DJIWaypointAnnotationView.h"

@interface NavigationIOCViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *iocTypeSegmentCtrl;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *previewView;
- (IBAction)onEnterNavigationButtonClicked:(id)sender;
- (IBAction)onStartIOCButtonClicked:(id)sender;
- (IBAction)onStopIOCButtonClicked:(id)sender;
- (IBAction)onRecordButtonClicked:(id)sender;
- (IBAction)onLockCourseButtonClicked:(id)sender;

@property(nonatomic, strong) DJIAircraftAnnotation* aircraftAnnotation;
@property(nonatomic, strong) DJIWaypointAnnotation* waypointAnnotation;

@property(nonatomic, assign) DJIDroneType droneType;

@end

@implementation NavigationIOCViewController

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
    // Do any additional setup after loading the view from its nib.
    
    if (self.connectedDrone) {
        self.drone = self.connectedDrone;
    }
    else
    {
        self.drone = [[DJIDrone alloc] initWithType:self.droneType];
    }
    
    self.drone.delegate = self;
    self.drone.mainController.mcDelegate = self;
    self.drone.camera.delegate = self;
    self.navigationManager = self.drone.mainController.navigationManager;
    self.navigationManager.delegate = self;
    
    for (int i = 100; i < 105; i++) {
        UIButton* btn = (UIButton*)[self.view viewWithTag:i];
        if (btn) {
            btn.layer.cornerRadius = btn.frame.size.width * 0.5;
            btn.layer.borderWidth = 1.2;
            btn.layer.borderColor = [UIColor redColor].CGColor;
            btn.layer.masksToBounds = YES;
        }
    }
    

    
    [[VideoPreviewer instance] start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[VideoPreviewer instance] setView:self.previewView];
    [[VideoPreviewer instance] setDecoderDataSource:[self dataSourceFromDroneType:_drone.droneType]];
    self.mapView.delegate = self;
    
    [self.drone connectToDrone];
    [self.drone.mainController startUpdateMCSystemState];
    [self.drone.camera startCameraSystemStateUpdates];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.mapView.delegate = nil;
    
    [self.drone.mainController stopUpdateMCSystemState];
    [self.drone.camera stopCameraSystemStateUpdates];
    [self.drone disconnectToDrone];
    self.drone.delegate = nil;
    
    [[VideoPreviewer instance] unSetView];
}

- (IBAction)onEnterNavigationButtonClicked:(id)sender
{
    [self.navigationManager enterNavigationModeWithResult:^(DJIError *error) {
        ShowResult(@"Enter Navigation:%@", error.errorDescription);
    }];
}

- (IBAction)onStartIOCButtonClicked:(id)sender
{
    DJIIOCType type = (DJIIOCType)(self.iocTypeSegmentCtrl.selectedSegmentIndex + 1);
    [self.navigationManager.iocMission setIocType:type];
    [self.navigationManager.iocMission startMissionWithResult:^(DJIError *error) {
        ShowResult(@"Start IOC:%@", error.errorDescription);
    }];
}

- (IBAction)onStopIOCButtonClicked:(id)sender
{
    [self.navigationManager.iocMission stopMissionWithResult:^(DJIError *error) {
        ShowResult(@"Stop IOC:%@", error.errorDescription);
    }];
}

- (IBAction)onRecordButtonClicked:(id)sender {
    if (self.isRecording) {
        [self.drone.camera stopRecord:^(DJIError *error) {
            ShowResult(@"Stop Record:%@", error.errorDescription);
        }];
    }
    else
    {
        [self.drone.camera startRecord:^(DJIError *error) {
            ShowResult(@"Start Record:%@", error.errorDescription);
        }];
    }
    
}

- (IBAction)onLockCourseButtonClicked:(id)sender
{
    [self.navigationManager.iocMission lockCourseUsingCurrentDirectionWithResult:^(DJIError *error) {
        ShowResult(@"Lock Course:%@", error.errorDescription);
    }];
}

#pragma mark -

-(void) droneOnConnectionStatusChanged:(DJIConnectionStatus)status
{
    
}

#pragma mark - 

-(void) camera:(DJICamera*)camera didReceivedVideoData:(uint8_t*)videoBuffer length:(int)length
{
    uint8_t* pBuffer = (uint8_t*)malloc(length);
    memcpy(pBuffer, videoBuffer, length);
    [[[VideoPreviewer instance] dataQueue] push:pBuffer length:length];
}

-(void) camera:(DJICamera*)camera didUpdateSystemState:(DJICameraSystemState*)systemState
{
    if (systemState.workMode != CameraWorkModeRecord) {
        if (self.drone.droneType == DJIDrone_Inspire) {
            [(DJIInspireCamera*)self.drone.camera setCameraWorkMode:CameraWorkModeRecord withResult:nil];
        }
        else if (self.drone.droneType == DJIDrone_Phantom3Advanced)
        {
            [(DJIPhantom3AdvancedCamera*)self.drone.camera setCameraWorkMode:CameraWorkModeRecord withResult:nil];
        }
        else if (self.drone.droneType == DJIDrone_Phantom3Professional)
        {
            [(DJIPhantom3ProCamera*)self.drone.camera setCameraWorkMode:CameraWorkModeRecord withResult:nil];
        }
        
    }
    if (self.isRecording != systemState.isRecording) {
        UIButton* recBtn = (UIButton*)[self.view viewWithTag:103];
        if (recBtn) {
            [recBtn setTitleColor:(systemState.isRecording ? [UIColor redColor] : [UIColor blackColor]) forState:UIControlStateNormal];
        }
        self.isRecording = systemState.isRecording;
    }
}

#pragma mark -

-(void) mainController:(DJIMainController*)mc didUpdateSystemState:(DJIMCSystemState*)state
{
    if (CLLocationCoordinate2DIsValid(state.droneLocation)) {
        if (self.aircraftAnnotation == nil) {
            self.aircraftAnnotation = [[DJIAircraftAnnotation alloc] initWithCoordiante:state.droneLocation];
            [self.mapView addAnnotation:self.aircraftAnnotation];
            
            MKCoordinateRegion region = {0};
            region.center = state.droneLocation;
            region.span.latitudeDelta = 0.001;
            region.span.longitudeDelta = 0.001;
            
            [self.mapView setRegion:region animated:YES];
        }
        [self.aircraftAnnotation setCoordinate:state.droneLocation];
        double heading = RADIAN(state.attitude.yaw);
        DJIAircraftAnnotationView* annoView = (DJIAircraftAnnotationView*)[self.mapView viewForAnnotation:self.aircraftAnnotation];
        [annoView updateHeading:heading];
    }
    if (CLLocationCoordinate2DIsValid(state.homeLocation)) {
        if (self.waypointAnnotation == nil) {
            self.waypointAnnotation = [[DJIWaypointAnnotation alloc] initWithCoordiante:state.homeLocation];
            [self.mapView addAnnotation:self.waypointAnnotation];
        }
        
        [self.waypointAnnotation setCoordinate:state.homeLocation];
    }
}

#pragma mark - DJINavigationDelegate

-(void) onNavigationMissionStatusChanged:(DJINavigationMissionStatus*)missionStatus
{
    if (missionStatus.missionType == DJINavigationMissionIOC) {
        DJIIOCMissionStatus* iocStatus = (DJIIOCMissionStatus*)missionStatus;
        if (iocStatus.iocType == DJIIOCTypeCourseLock) {

        }
        else
        {
            
        }
    }
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[DJIAircraftAnnotation class]]) {
        MKAnnotationView* annoView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"DJIAircraftAnnotationView"];
        if (annoView == nil) {
            annoView = [[DJIAircraftAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"DJIAircraftAnnotationView"];
        }
        return annoView;
    }
    else if ([annotation isKindOfClass:[DJIWaypointAnnotation class]]) {
        DJIWaypointAnnotationView* annoView = (DJIWaypointAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"DJIWaypointAnnotationView"];
        if (annoView == nil) {
            annoView = [[DJIWaypointAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"DJIWaypointAnnotationView"];
            annoView.titleLabel.text = @"H";
            return annoView;
        }
    }
    
    return nil;
}
@end
