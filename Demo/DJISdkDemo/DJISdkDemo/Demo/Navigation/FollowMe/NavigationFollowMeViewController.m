//
//  InspireFollowMeViewController.m
//  DJISdkDemo
//
//  Created by Ares on 15/3/5.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "NavigationFollowMeViewController.h"
#import "VideoPreviewer.h"

#define SIMULATOR_DEBUG 0

@interface NavigationFollowMeViewController ()

@property(nonatomic, assign) DJIDroneType droneType;

@end

@implementation NavigationFollowMeViewController

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
    
    self.drone.mainController.mcDelegate = self;
    self.drone.camera.delegate = self;
    self.navigationManager = self.drone.mainController.navigationManager;
    self.navigationManager.delegate = self;

    self.locationLabel.backgroundColor = [UIColor lightGrayColor];
    self.locationLabel.layer.cornerRadius = 5.0;
    self.locationLabel.layer.masksToBounds = YES;
    self.locationLabel.text = @"N/A";
    self.locationLabel.textAlignment = NSTextAlignmentCenter;
    
    self.accuracyLabel.backgroundColor = [UIColor lightGrayColor];
    self.accuracyLabel.layer.cornerRadius = 5.0;
    self.accuracyLabel.layer.masksToBounds = YES;
    self.accuracyLabel.text = @"N/A";
    self.accuracyLabel.textAlignment = NSTextAlignmentCenter;
    
    self.followMeStarted = NO;
    
    self.droneLocation = kCLLocationCoordinate2DInvalid;
    self.userLocation = kCLLocationCoordinate2DInvalid;

    [self.headingControl setSelectedSegmentIndex:0];
    
    [[VideoPreviewer instance] start];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.drone connectToDrone];
    [self.drone.mainController startUpdateMCSystemState];
    [self startUpdateLocation];
    
    [[VideoPreviewer instance] setView:self.previewView];
    [[VideoPreviewer instance] setDecoderDataSource:[self dataSourceFromDroneType:_drone.droneType]];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.drone.mainController stopUpdateMCSystemState];
    [self.drone disconnectToDrone];
    self.drone.delegate = nil;
    
    [[VideoPreviewer instance] unSetView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) startUpdateLocation
{
#if SIMULATOR_DEBUG
    return YES;
#endif
    if ([CLLocationManager locationServicesEnabled]) {
        if (mLocationManager == nil) {
            mLocationManager = [[CLLocationManager alloc] init];
            mLocationManager.delegate = self;
            mLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            mLocationManager.distanceFilter = 0.1;
            if ([mLocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [mLocationManager requestAlwaysAuthorization];
            }
            [mLocationManager startUpdatingLocation];
        }
        
        return YES;
    }
    else
    {
        ShowResult(@"Your device not support FollowMe feature");
        return NO;
    }
}

-(void) stopUpdateLocation
{
    if (mLocationManager) {
        [mLocationManager stopUpdatingLocation];
        mLocationManager = nil;
    }
}

-(void) startUpdateTimer
{
#if SIMULATOR_DEBUG
    [NSThread detachNewThreadSelector:@selector(followMeTest) toTarget:self withObject:nil];
#else
    if (mUpdateTimer == nil) {
        mUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onUpdateTimerTicked:) userInfo:nil repeats:YES];
        [mUpdateTimer fire];
    }
#endif
}

-(void) stopUpdateTimer
{
    if (mUpdateTimer) {
        [mUpdateTimer invalidate];
        mUpdateTimer = nil;
    }
}

-(void) onUpdateTimerTicked:(id)sender
{
    if (CLLocationCoordinate2DIsValid(self.userLocation)) {
        CLLocation* currentLocation = [[CLLocation alloc] initWithLatitude:self.userLocation.latitude longitude:self.userLocation.longitude];
        double distance = 0;
        if (CLLocationCoordinate2DIsValid(self.droneLocation)) {
            CLLocation* droneLocation = [[CLLocation alloc] initWithLatitude:self.droneLocation.latitude longitude:self.droneLocation.longitude];
            distance = [currentLocation distanceFromLocation:droneLocation];
        }
        self.locationLabel.text = [NSString stringWithFormat:@"Loc:{%0.7f, %0.7f}  Drone:{%0.7f, %0.7f} D:%0.2fM", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, self.droneLocation.latitude, self.droneLocation.longitude, distance];
        
        
        if (self.followMeStarted) {
            [self.navigationManager.followMeMission updateUserCoordinate:currentLocation.coordinate withResult:nil];
        }
    }
}

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

-(IBAction) onFollowMeStart:(id)sender
{
    if (!CLLocationCoordinate2DIsValid(self.userLocation)) {
        ShowResult(@"Could not locating my location");
        return;
    }
    if (!CLLocationCoordinate2DIsValid(self.droneLocation)) {
        ShowResult(@"Could not get drone location");
        return;
    }

    self.navigationManager.followMeMission.userCoordinate = self.userLocation;
    self.navigationManager.followMeMission.headingMode = (DJIFollowMeHeadingMode)self.headingControl.selectedSegmentIndex;
    if (self.navigationManager.followMeMission.isValid) {
        WeakRef(obj);
        [self.navigationManager.followMeMission startMissionWithResult:^(DJIError *error) {
            ShowResult(@"Start FollowMe Mission:%@", error.errorDescription);
            if (error.errorCode == ERR_Succeeded) {
                WeakReturn(obj);
                obj.followMeStarted = YES;
                [obj startUpdateTimer];
            }
        }];
    }
    else
    {
        ShowResult(@"Follow me mission invalid");
    }
}

-(IBAction) onFollowMeStop:(id)sender
{
    WeakRef(obj);
    [self.navigationManager.followMeMission stopMissionWithResult:^(DJIError *error) {
        ShowResult(@"Stop FollowMe Mission:%@", error.errorDescription);
        if (ERR_Succeeded == error.errorCode) {
            WeakReturn(obj);
            obj.followMeStarted = NO;
            [obj stopUpdateTimer];
        }
    }];
}

-(IBAction) onFollowMePause:(id)sender
{
    [self.navigationManager.followMeMission pauseMissionWithResult:^(DJIError *error) {
        ShowResult(@"Start FollowMe Mission:%@", error.errorDescription);
    }];
}

-(IBAction) onFollowMeResume:(id)sender
{
    [self.navigationManager.followMeMission resumeMissionWithResult:^(DJIError *error) {
        ShowResult(@"Start FollowMe Mission:%@", error.errorDescription);
    }];
}

#pragma mark - DJIMainControllerDelegate

-(void) mainController:(DJIMainController *)mc didUpdateSystemState:(DJIMCSystemState *)state
{
#if SIMULATOR_DEBUG
    if (!CLLocationCoordinate2DIsValid(self.userLocation)) {
        self.userLocation = CLLocationCoordinate2DMake(state.droneLocation.latitude + 0.000004, state.droneLocation.longitude + 0.000002);//state.droneLocation;
    }
#endif
    self.droneLocation = state.droneLocation;
}

#pragma mark - DJINavigtaionDelegate

-(void) onNavigationMissionStatusChanged:(DJINavigationMissionStatus*)missionStatus
{
    if (missionStatus.missionType == DJINavigationMissionFollowMe) {
        DJIFollowMeMissionStatus* fmStatus = (DJIFollowMeMissionStatus*)missionStatus;
#if SIMULATOR_DEBUG
        self.locationLabel.text = [NSString stringWithFormat:@"ExecState:%d Distance:%0.01f m Err:%d", (int)fmStatus.execState, fmStatus.distance, (int)fmStatus.error.errorCode];
#endif
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
    
}

#pragma mark - MKLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* currentLocation = [locations lastObject];
    if (currentLocation && currentLocation.horizontalAccuracy > 0)
    {
        self.accuracyLabel.text = [NSString stringWithFormat:@"%0.2f M", currentLocation.horizontalAccuracy];
        self.userLocation = currentLocation.coordinate;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        {
            if ([mLocationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                [mLocationManager requestWhenInUseAuthorization];
            }
            break;
        }
        default:
            break;
    }
}

-(void) followMeTest
{
#if SIMULATOR_DEBUG
    double tar_pos_lat;
    double tar_pos_lon;
    double tgt_pos_x;
    double tgt_pos_y;
    
    double init_lati;
    double init_lont;
    
    while (self.followMeStarted)
    {
        if (CLLocationCoordinate2DIsValid(self.droneLocation)) {
            break;
        }
        [NSThread sleepForTimeInterval:0.5];
    }
    
    init_lati = RADIAN(self.droneLocation.latitude);
    init_lont = RADIAN(self.droneLocation.longitude);
    
    float clock = 0;
    float radius = 6378137.0;
    while (self.followMeStarted) {
        tgt_pos_x = 5.0* sin(clock/10.0*0.5);
        tgt_pos_y = 5.0* cos(clock/10.0*0.5);
        tar_pos_lat = init_lati + tgt_pos_x/radius;
        tar_pos_lon = init_lont + tgt_pos_y/radius/cos(init_lati);
        [self.navigationManager.followMeMission updateUserCoordinate:CLLocationCoordinate2DMake(DEGREE(tar_pos_lat), DEGREE(tar_pos_lon)) withResult:nil];
        
        clock++;
        [NSThread sleepForTimeInterval:0.1];
    }
    
#endif
}

@end
