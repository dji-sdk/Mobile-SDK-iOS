//
//  GroundStationTestViewController.m
//  DJISdkDemo
//
//  Created by Ares on 14-7-16.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "NavigationWaypointViewController.h"
#import "DJIAircraftAnnotation.h"
#import "DJIAircraftAnnotationView.h"
#import "DJIWaypointAnnotation.h"
#import "DJIWaypointAnnotationView.h"
#import "NavigationWaypointConfigView.h"
#import "NavigationWaypointMissionConfigView.h"

#define DEGREE_OF_THIRTY_METER (0.0000899322 * 3)
#define DEGREE(x) ((x)*180.0/M_PI)

@interface NavigationWaypointViewController ()

@property(nonatomic, assign) BOOL isEditEnable;
@property(nonatomic, strong) NSMutableArray* waypointList;
@property(nonatomic, strong) NSMutableArray* waypointAnnotations;

@property(nonatomic, strong) DJIWaypointAnnotation* homeAnnotation;
@property(nonatomic, strong) DJIAircraftAnnotation* aircraftAnnotation;

@property(nonatomic, strong) NavigationWaypointConfigView* waypointConfigView;
@property(nonatomic, strong) NavigationWaypointMissionConfigView* waypointMissionConfigView;

@property(nonatomic, strong) UITapGestureRecognizer* tapGesture;

@property(nonatomic, assign) DJIDroneType droneType;

@end

@implementation NavigationWaypointViewController

-(id) initWithDroneType:(DJIDroneType)type
{
    self = [super init];
    if (self) {
        self.droneType = type;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.connectedDrone) {
        _drone = self.connectedDrone;
    }
    else
    {
        _drone = [[DJIDrone alloc] initWithType:self.droneType];
    }
    
    _drone.delegate = self;
    
    self.navigationManager = _drone.mainController.navigationManager;
    self.navigationManager.delegate = self;
    _drone.mainController.mcDelegate = self;
    self.waypointMission = self.navigationManager.waypointMission;
    
    self.navigationController.navigationBarHidden = YES;
    
    _isPOIMissionStarted = NO;
    _isPOIMissionPaused = NO;
    self.waypointList = [[NSMutableArray alloc] init];
    self.waypointAnnotations = [[NSMutableArray alloc] init];
    self.isEditEnable = NO;
    
    _connectionStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    _connectionStatusLabel.backgroundColor = [UIColor clearColor];
    _connectionStatusLabel.textAlignment = NSTextAlignmentCenter;
    _connectionStatusLabel.text = @"Disconnected";
    
    [self.navigationController.navigationBar addSubview:_connectionStatusLabel];
    
    self.waypointConfigView = [[NavigationWaypointConfigView alloc] initWithNib];
    self.waypointConfigView.alpha = 0;
    self.waypointConfigView.delegate = self;
    [self.waypointConfigView.okButton addTarget:self action:@selector(onWaypointConfigOKButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.waypointConfigView];
    
    self.waypointMissionConfigView = [[NavigationWaypointMissionConfigView alloc] initWithNib];
    self.waypointMissionConfigView.alpha = 0;
    [self.waypointMissionConfigView.okButton addTarget:self action:@selector(onMissionConfigOKButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.waypointMissionConfigView];
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
    
    [self.navigationController setNavigationBarHidden:NO];
    
    [_drone.mainController stopUpdateMCSystemState];
    [_connectionStatusLabel removeFromSuperview];
    [_drone disconnectToDrone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - User Action

-(IBAction) onEnterNavigationButtonClicked:(id)sender
{
    [self.navigationManager enterNavigationModeWithResult:^(DJIError *error) {
        ShowResult(@"Enter Navigation Mode:%@", error.errorDescription);
    }];
}

-(IBAction) onExitNavigationButtonClicked:(id)sender
{
    [self.navigationManager exitNavigationModeWithResult:^(DJIError *error) {
        ShowResult(@"Exit Navigation Mode:%@", error.errorDescription);
    }];
}

-(float) getCornerRadius:(DJIWaypoint*)pointA middleWaypoint:(DJIWaypoint*)pointB nextWaypoint:(DJIWaypoint*)pointC
{
    if (pointA == nil || pointB == nil || pointC == nil) {
        return 2.0;
    }
    CLLocation* loc1 = [[CLLocation alloc] initWithLatitude:pointA.coordinate.latitude longitude:pointA.coordinate.longitude];
    CLLocation* loc2 = [[CLLocation alloc] initWithLatitude:pointB.coordinate.latitude longitude:pointB.coordinate.longitude];
    CLLocation* loc3 = [[CLLocation alloc] initWithLatitude:pointC.coordinate.latitude longitude:pointC.coordinate.longitude];
    CLLocationDistance d1 = [loc2 distanceFromLocation:loc1];
    CLLocationDistance d2 = [loc2 distanceFromLocation:loc3];
    CLLocationDistance dmin = MIN(d1, d2);

    if (dmin < 1.0) {
        dmin = 1.0;
    }
    else
    {
        dmin = 1.0 + (dmin - 1.0) * 0.2;
        dmin = MIN(dmin, 10.0);
    }
    return dmin;
}

-(void) calcCornerRadius
{
    for (int i = 0; i < self.waypointMission.waypointCount; i++) {
        DJIWaypoint* wp = (DJIWaypoint*)[self.waypointMission waypointAtIndex:i];
        DJIWaypoint* prevWaypoint = nil;
        DJIWaypoint* nextWaypoint = nil;
        int prev = i - 1;
        int next = i + 1;
        if (prev >= 0) {
            prevWaypoint = [self.waypointMission waypointAtIndex:prev];
        }
        if (next < self.waypointMission.waypointCount) {
            nextWaypoint = [self.waypointMission waypointAtIndex:next];
        }
        wp.cornerRadius = [self getCornerRadius:prevWaypoint middleWaypoint:wp nextWaypoint:nextWaypoint];
    }
}

- (void)createWaypointMission
{
    const float height = 30;
    [self.waypointMission removeAllWaypoints];
    self.waypointMission.maxFlightSpeed = 6.0;
    self.waypointMission.autoFlightSpeed = 4.0;
    self.waypointMission.finishedAction = DJIWaypointMissionFinishedGoHome;
    self.waypointMission.headingMode = DJIWaypointMissionHeadingAuto;
    self.waypointMission.flightPathMode = DJIWaypointMissionFlightPathNormal;//DJIWaypointMissionAirLineCurve
    
    CLLocationCoordinate2D point1;
    CLLocationCoordinate2D point2;
    CLLocationCoordinate2D point3;
    CLLocationCoordinate2D point4;
    point1 = CLLocationCoordinate2DMake(mCurrentDroneCoordinate.latitude + DEGREE_OF_THIRTY_METER, mCurrentDroneCoordinate.longitude);
    point2 = CLLocationCoordinate2DMake(mCurrentDroneCoordinate.latitude, mCurrentDroneCoordinate.longitude + DEGREE_OF_THIRTY_METER);
    point3 = CLLocationCoordinate2DMake(mCurrentDroneCoordinate.latitude - DEGREE_OF_THIRTY_METER, mCurrentDroneCoordinate.longitude);
    point4 = CLLocationCoordinate2DMake(mCurrentDroneCoordinate.latitude, mCurrentDroneCoordinate.longitude - DEGREE_OF_THIRTY_METER);
    
    DJIWaypoint* wp1 = [[DJIWaypoint alloc] initWithCoordinate:point1];
    wp1.altitude = height;
    DJIWaypointAction* action1 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionStartTakePhoto param:0];
    DJIWaypointAction* action2 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionRotateAircraft param:-180];
    DJIWaypointAction* action3 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionStartTakePhoto param:0];
    DJIWaypointAction* action4 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionRotateAircraft param:-90];
    DJIWaypointAction* action5 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionStartTakePhoto param:0];
    DJIWaypointAction* action6 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionRotateAircraft param:0];
    DJIWaypointAction* action7 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionStartTakePhoto param:0];
    DJIWaypointAction* action8 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionRotateAircraft param:90];
    DJIWaypointAction* action9 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionStartTakePhoto param:0];
    DJIWaypointAction* action10 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionRotateAircraft param:180];
    DJIWaypointAction* action11 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionRotateGimbalPitch param:-45];
    [wp1 addAction:action1];
    [wp1 addAction:action2];
    [wp1 addAction:action3];
    [wp1 addAction:action4];
    [wp1 addAction:action5];
    [wp1 addAction:action6];
    [wp1 addAction:action7];
    [wp1 addAction:action8];
    [wp1 addAction:action9];
    [wp1 addAction:action10];
    [wp1 addAction:action11];
    
    DJIWaypoint* wp2 = [[DJIWaypoint alloc] initWithCoordinate:point2];
    wp2.altitude = height;
    DJIWaypointAction* action12 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionRotateGimbalPitch param:29];
    [wp2 addAction:action12];
    
    DJIWaypoint* wp3 = [[DJIWaypoint alloc] initWithCoordinate:point3];
    wp3.altitude = height;
    DJIWaypointAction* action14 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionStartRecord param:0];
    [wp3 addAction:action14];
    
    DJIWaypoint* wp4 = [[DJIWaypoint alloc] initWithCoordinate:point4];
    wp4.altitude = height;
    DJIWaypointAction* action15 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionStopRecord param:0];
    [wp4 addAction:action15];
    
    [self.waypointMission addWaypoint:wp1];
    [self.waypointMission addWaypoint:wp2];
    [self.waypointMission addWaypoint:wp3];
    [self.waypointMission addWaypoint:wp4];
    
    if (self.waypointMission.flightPathMode == DJIWaypointMissionFlightPathCurved) {
        [self calcCornerRadius];
    }
}

-(void) updateMission
{
    self.waypointMission.maxFlightSpeed = [self.waypointMissionConfigView.maxFlightSpeed.text floatValue];
    self.waypointMission.autoFlightSpeed = [self.waypointMissionConfigView.autoFlightSpeed.text floatValue];
    self.waypointMission.finishedAction = (DJIWaypointMissionFinishedAction)self.waypointMissionConfigView.finishedAction.selectedSegmentIndex;
    self.waypointMission.headingMode = (DJIWaypointMissionHeadingMode)self.waypointMissionConfigView.headingMode.selectedSegmentIndex;
    self.waypointMission.flightPathMode = (DJIWaypointMissionFlightPathMode)self.waypointMissionConfigView.airlineMode.selectedSegmentIndex;
    
    [self.waypointMission removeAllWaypoints];
    [self.waypointMission addWaypoints:self.waypointList];
    
    if (self.waypointMission.flightPathMode == DJIWaypointMissionFlightPathCurved) {
        [self calcCornerRadius];
    }
}

-(IBAction) onUploadMissionButtonClicked:(id)sender
{
    mCurrentDroneCoordinate = CLLocationCoordinate2DMake(22, 111);
    if (CLLocationCoordinate2DIsValid(mCurrentDroneCoordinate)) {
//        [self createWaypointMission];
        [self updateMission];
        
        if (self.waypointMission.isValid) {
            WeakRef(obj);
            [self.waypointMission setUploadProgressHandler:^(uint8_t progress) {
                WeakReturn(obj);
                NSString* message = [NSString stringWithFormat:@"Mission Uploading:%d%%", progress];
                if (obj.progressAlertView == nil) {
                    obj.progressAlertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
                    [obj.progressAlertView show];
                }
                else
                {
                    [obj.progressAlertView setMessage:message];
                }
                
                if (progress == 100) {
                    [obj.progressAlertView dismissWithClickedButtonIndex:0 animated:YES];
                    obj.progressAlertView = nil;
                }
            }];
            [self.waypointMission uploadMissionWithResult:^(DJIError *error) {
                WeakReturn(obj);
                if (obj.progressAlertView) {
                    [obj.progressAlertView dismissWithClickedButtonIndex:0 animated:YES];
                    obj.progressAlertView = nil;
                }
                [obj.waypointMission setUploadProgressHandler:nil];
                ShowResult(@"Upload Mission Result:%@", error.errorDescription);
            }];
        }
        else
        {
            ShowResult(@"Waypoint mission invalid:%@", self.waypointMission.failureReason);
        }
    }
    else
    {
        ShowResult(@"Current Drone Location Invalid");
    }
}

-(IBAction) onDownloadMissionButtonClicked:(id)sender
{
    WeakRef(obj);
    [self.waypointMission setDownloadProgressHandler:^(uint8_t progress) {
        WeakReturn(obj);
        NSString* message = [NSString stringWithFormat:@"Mission Downloading:%d%%", progress];
        if (obj.progressAlertView == nil) {
            obj.progressAlertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
            [obj.progressAlertView show];
        }
        else
        {
            [obj.progressAlertView setMessage:message];
        }
        
        if (progress == 100) {
            [obj.progressAlertView dismissWithClickedButtonIndex:0 animated:YES];
            obj.progressAlertView = nil;
        }
    }];
    [self.waypointMission downloadMissionWithResult:^(DJIError *error) {
        WeakReturn(obj);
        if (obj.progressAlertView) {
            [obj.progressAlertView dismissWithClickedButtonIndex:0 animated:YES];
            obj.progressAlertView = nil;
        }
        [obj.waypointMission setDownloadProgressHandler:nil];
        ShowResult(@"Download Mission Result:%@", error.errorDescription);
    }];
}

-(IBAction) onStartMissionButtonClicked:(id)sender
{
    [self.waypointMission startMissionWithResult:^(DJIError *error) {
        ShowResult(@"Start Mission:%@", error.errorDescription);
    }];
}

-(IBAction) onStopMissionButtonClicked:(id)sender
{
    [self.waypointMission stopMissionWithResult:^(DJIError *error) {
        ShowResult(@"Stop Mission:%@", error.errorDescription);
    }];
}

-(IBAction) onPauseMissionButtonClicked:(id)sender
{
    [self.waypointMission pauseMissionWithResult:^(DJIError *error) {
        ShowResult(@"Pause Mission:%@", error.errorDescription);
    }];
}

-(IBAction) onResumeMissionButtonClicked:(id)sender
{
    [self.waypointMission resumeMissionWithResult:^(DJIError *error) {
        ShowResult(@"Resume Mission:%@", error.errorDescription);
    }];
}

-(IBAction) onBackButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction) onMissionConfigButtonClicked:(id)sender
{
    self.waypointMissionConfigView.center = self.view.center;
    [UIView animateWithDuration:0.25 animations:^{
        self.waypointMissionConfigView.alpha = 1;
    }];
}

-(IBAction) onWaypointConfigButtonClicked:(id)sender
{
    self.waypointConfigView.center = self.view.center;
    [self.waypointConfigView setWaypointList:self.waypointList];
    [UIView animateWithDuration:0.25 animations:^{
        self.waypointConfigView.alpha = 1;
    }];
}

-(IBAction) onEditButtonClicked:(UIButton*)sender
{
    self.isEditEnable = !self.isEditEnable;
    if (self.isEditEnable) {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMapViewTap:)];
        [self.view addGestureRecognizer:self.tapGesture];
        [sender setTitle:@"Finished" forState:UIControlStateNormal];
    }
    else
    {
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
        [self.view removeGestureRecognizer:self.tapGesture];
        self.tapGesture = nil;
    }
}

-(void) onWaypointConfigOKButtonClicked:(id)sender
{
    [UIView animateWithDuration:0.25 animations:^{
        self.waypointConfigView.alpha = 0;
    }];
}

-(void) onMissionConfigOKButtonClicked:(id)sender
{
    [UIView animateWithDuration:0.25 animations:^{
        self.waypointMissionConfigView.alpha = 0;
    }];
}

-(void) configViewDidDeleteWaypointAtIndex:(int)index
{
    if (index >= 0 && index < self.waypointAnnotations.count) {
        DJIWaypointAnnotation* wpAnno = [self.waypointAnnotations objectAtIndex:index];
        [self.waypointAnnotations removeObject:wpAnno];
        [self.mapView removeAnnotation:wpAnno];
        for (int i = 0; i < self.waypointAnnotations.count; i++) {
            DJIWaypointAnnotation* wpAnno = [self.waypointAnnotations objectAtIndex:i];
            wpAnno.text = [NSString stringWithFormat:@"%d", i+1];
            DJIWaypointAnnotationView* annoView = (DJIWaypointAnnotationView*)[self.mapView viewForAnnotation:wpAnno];
            annoView.titleLabel.text = wpAnno.text;
        }
    }
}

-(void) configViewDidDeleteAllWaypoints
{
    for (int i = 0; i < self.waypointAnnotations.count; i++) {
        DJIWaypointAnnotation* wpAnno = [self.waypointAnnotations objectAtIndex:i];
        [self.mapView removeAnnotation:wpAnno];
    }
    [self.waypointAnnotations removeAllObjects];
    [self.waypointList removeAllObjects];
}

#pragma mark - MapView

-(void) onMapViewTap:(UIGestureRecognizer*)tapGestureRecognizer
{
    if (self.isEditEnable) {
        CGPoint point = [tapGestureRecognizer locationInView:self.mapView];
        CLLocationCoordinate2D touchedCoordinate = [_mapView convertPoint:point toCoordinateFromView:_mapView];
        DJIWaypoint* waypoint = [[DJIWaypoint alloc] initWithCoordinate:touchedCoordinate];
        [self.waypointList addObject:waypoint];
        DJIWaypointAnnotation* wpAnnotation = [[DJIWaypointAnnotation alloc] init];
        [wpAnnotation setCoordinate:touchedCoordinate];
        wpAnnotation.text = [NSString stringWithFormat:@"%d",(int)self.waypointList.count];
        [self.mapView addAnnotation:wpAnnotation];
        [self.waypointAnnotations addObject:wpAnnotation];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[DJIWaypointAnnotation class]]) {
        static NSString* waypointReuseIdentifier = @"DJI_WAYPOINT_ANNOTATION_VIEW";
        static NSString* homepointReuseIdentifier = @"DJI_HOME_POINT_ANNOTATION_VIEW";
        NSString* reuseIdentifier = waypointReuseIdentifier;
        if (annotation == self.homeAnnotation) {
            reuseIdentifier = homepointReuseIdentifier;
        }
        DJIWaypointAnnotation* wpAnnotation = (DJIWaypointAnnotation*)annotation;
        DJIWaypointAnnotationView* annoView = (DJIWaypointAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:waypointReuseIdentifier];
        if (annoView == nil) {
            annoView = [[DJIWaypointAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:waypointReuseIdentifier];
        }
        annoView.titleLabel.text = wpAnnotation.text;
        return annoView;
    }
    else if ([annotation isKindOfClass:[DJIAircraftAnnotation class]])
    {
        static NSString* aircraftReuseIdentifier = @"DJI_AIRCRAFT_ANNOTATION_VIEW";
        DJIAircraftAnnotationView* aircraftAnno = (DJIAircraftAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:aircraftReuseIdentifier];
        if (aircraftAnno == nil) {
            aircraftAnno = [[DJIAircraftAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:aircraftReuseIdentifier];
        }
        return aircraftAnno;
    }
    
    return nil;
}

#pragma mark - DJINavigationDelegate

-(void) onNavigationMissionStatusChanged:(DJINavigationMissionStatus*)missionStatus
{
    if (missionStatus.missionType == DJINavigationMissionWaypoint) {
    }
    else if (missionStatus.missionType == DJINavigationMissionHotpoint)
    {

    }
}

#pragma mark - 

-(void) mainController:(DJIMainController *)mc didUpdateSystemState:(DJIMCSystemState *)state
{
    self.mcSystemState = state;
    mCurrentDroneCoordinate = state.droneLocation;
    
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
        if (self.homeAnnotation == nil) {
            self.homeAnnotation = [[DJIWaypointAnnotation alloc] initWithCoordiante:state.homeLocation];
            self.homeAnnotation.text = @"H";
            [self.mapView addAnnotation:self.homeAnnotation];
        }
        
        [self.homeAnnotation setCoordinate:state.homeLocation];
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
@end

