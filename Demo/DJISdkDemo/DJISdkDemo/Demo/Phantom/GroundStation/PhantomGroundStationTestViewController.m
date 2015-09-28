//
//  GroundStationTestViewController.m
//  DJISdkDemo
//
//  Created by Ares on 14-7-16.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "PhantomGroundStationTestViewController.h"

@interface PhantomGroundStationTestViewController ()

@end

@implementation PhantomGroundStationTestViewController

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
    
    _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom];
    _groundStation = (id<DJIGroundStation>)_drone.mainController;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    _drone.delegate = self;
    _groundStation.groundStationDelegate = self;
    
    [_drone connectToDrone];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_connectionStatusLabel removeFromSuperview];
    [_drone disconnectToDrone];
    _drone.delegate = Nil;
    _groundStation.groundStationDelegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Action

-(IBAction) onOpenButtonClicked:(id)sender
{
    [_groundStation openGroundStation];
}

-(IBAction) onCloseButtonClicked:(id)sender
{
    [_groundStation closeGroundStation];
}

-(IBAction) onUploadTaskClicked:(id)sender
{
    const float height = 30;
    DJIGroundStationTask* newTask = [DJIGroundStationTask newTask];
    CLLocationCoordinate2D  point1 = { 22.5351709662 , 113.9419635173 };
    CLLocationCoordinate2D  point2 = { 22.5352549662 , 113.9433645173 };
    CLLocationCoordinate2D  point3 = { 22.5346709662 , 113.9434005173 };
    CLLocationCoordinate2D  point4 = { 22.5346039662 , 113.9418915173 };
    
    if (CLLocationCoordinate2DIsValid(_homeLocation)) {
#define TEN_METER 0.0000899322
        point1 = CLLocationCoordinate2DMake(_homeLocation.latitude + TEN_METER, _homeLocation.longitude);
        point2 = CLLocationCoordinate2DMake(_homeLocation.latitude, _homeLocation.longitude + TEN_METER);
        point3 = CLLocationCoordinate2DMake(_homeLocation.latitude - TEN_METER, _homeLocation.longitude);
        point4 = CLLocationCoordinate2DMake(_homeLocation.latitude, _homeLocation.longitude - TEN_METER);
    }
    DJIGroundStationWaypoint* wp1 = [[DJIGroundStationWaypoint alloc] initWithCoordinate:point1];
    wp1.altitude = height;
    wp1.horizontalVelocity = 8;
    wp1.stayTime = 3.0;
    
    DJIGroundStationWaypoint* wp2 = [[DJIGroundStationWaypoint alloc] initWithCoordinate:point2];
    wp2.altitude = height;
    wp2.horizontalVelocity = 8;
    wp2.stayTime = 3.0;
    
    DJIGroundStationWaypoint* wp3 = [[DJIGroundStationWaypoint alloc] initWithCoordinate:point3];
    wp3.altitude = height;
    wp3.horizontalVelocity = 8;
    wp3.stayTime = 3.0;
    
    DJIGroundStationWaypoint* wp4 = [[DJIGroundStationWaypoint alloc] initWithCoordinate:point4];
    wp4.altitude = height;
    wp4.horizontalVelocity = 8;
    wp4.stayTime = 3.0;
    
    [newTask addWaypoint:wp1];
    [newTask addWaypoint:wp2];
    [newTask addWaypoint:wp3];
    [newTask addWaypoint:wp4];

    
    [_groundStation uploadGroundStationTask:newTask];
}

-(IBAction) onDownloadTaskClicked:(id)sender
{
    [_groundStation downloadGroundStationTask];
}

-(IBAction) onStartTaskButtonClicked:(id)sender
{
    [_groundStation startGroundStationTask];
}

-(IBAction) onPauseTaskButtonClicked:(id)sender
{
    [_groundStation pauseGroundStationTask];
}

-(IBAction) onContinueTaskButtonClicked:(id)sender
{
    [_groundStation continueGroundStationTask];
}

-(IBAction) onGoHomeButtonClicked:(id)sender
{
    [_groundStation gohome];
}

#pragma mark - GroundStation Result

-(void) onGroundStationOpenWithResult:(GroundStationExecuteResult*)result
{
    if (result.executeStatus == GSExecStatusBegan) {
        NSLog(@"Ground Station Open Began");
    }
    else if (result.executeStatus == GSExecStatusSucceeded)
    {
        NSLog(@"Ground Station Open Successed");
    }
    else
    {
        NSLog(@"Ground Station Open Failed:%d", (int)result.error);
    }
}

-(void) onGroundStationCloseWithResult:(GroundStationExecuteResult*)result
{
    if (result.executeStatus == GSExecStatusBegan) {
        
    }
    else if (result.executeStatus == GSExecStatusSucceeded)
    {
        
    }
    else
    {
        
    }
}

-(void) onGroundStationUploadTaskWithResult:(GroundStationExecuteResult*)result
{
    if (result.executeStatus == GSExecStatusBegan) {
        NSLog(@"Upload Task Began");
    }
    else if (result.executeStatus == GSExecStatusSucceeded)
    {
        NSLog(@"Upload Task Success");
    }
    else
    {
        NSLog(@"Upload Task Failed: %d", (int)result.error);
    }
}

-(void) onGroundStationDownloadTaskWithResult:(GroundStationExecuteResult*)result
{
    if (result.executeStatus == GSExecStatusBegan) {
        NSLog(@"Download Task Began");
    }
    else if (result.executeStatus == GSExecStatusSucceeded)
    {
        NSLog(@"Download Task Success: waypoint:%d", _groundStation.groundStationTask.waypointCount);
    }
    else
    {
        NSLog(@"Download Task Failed: %d", (int)result.error);
    }
}

-(void) onGroundStationStartTaskWithResult:(GroundStationExecuteResult*)result
{
    if (result.executeStatus == GSExecStatusBegan) {
        NSLog(@"Task Start Began");
    }
    else if (result.executeStatus == GSExecStatusSucceeded)
    {
        NSLog(@"Task Start Success");
    }
    else
    {
        NSLog(@"Task Start Failed : %d", (int)result.error);
    }
}

-(void) onGroundStationPauseTaskWithResult:(GroundStationExecuteResult*)result
{
    if (result.executeStatus == GSExecStatusBegan) {
        NSLog(@"Task Start Began");
    }
    else if (result.executeStatus == GSExecStatusSucceeded)
    {
        NSLog(@"Task Start Success");
    }
    else
    {
        NSLog(@"Task Start Failed : %d", (int)result.error);
    }
}

-(void) onGroundStationContinueTaskWithResult:(GroundStationExecuteResult*)result
{
    if (result.executeStatus == GSExecStatusBegan) {
        NSLog(@"Task Start Began");
    }
    else if (result.executeStatus == GSExecStatusSucceeded)
    {
        NSLog(@"Task Start Success");
    }
    else
    {
        NSLog(@"Task Start Failed : %d", (int)result.error);
    }
}

-(void) onGroundStationGoHomeWithResult:(GroundStationExecuteResult*)result
{
    if (result.executeStatus == GSExecStatusBegan) {
        NSLog(@"GoHome Began");
    }
    else if (result.executeStatus == GSExecStatusSucceeded)
    {
        NSLog(@"GoHome Success");
    }
    else
    {
        NSLog(@"GoHome Failed : %d", (int)result.error);
    }
}

-(void) onGroundStationControlModeChanged:(GroundStationControlMode)mode
{
    NSString* ctrlMode = @"N/A";
    switch (mode) {
        case GSModeAtti:
        {
            ctrlMode = @"ATTI";
//            NSLog(@"GSModeAtti");
            break;
        }
        case GSModeGpsAtti:
        {
            ctrlMode = @"GPS";
//            NSLog(@"GSModeGps_Atti");
            break;
        }
        case GSModeGpsCruise:
        {
            ctrlMode = @"GPS";
//            NSLog(@"GSModeGps_Cruise");
            break;
        }
        case GSModeWaypoint:
        {
            ctrlMode = @"WAYPOINT";
//            NSLog(@"GSModeWaypoint");
            break;
        }
        case GSModeGohome:
        {
            ctrlMode = @"GOHOME";
//            NSLog(@"GSModeGohome");
            break;
        }
        case GSModeLanding:
        {
            ctrlMode = @"LANDING";
//            NSLog(@"GSModeLanding");
            break;
        }
        case GSModePause:
        {
            ctrlMode = @"PAUSE";
//            NSLog(@"GSModePause");
            break;
        }
        case GSModeTakeOff:
        {
            ctrlMode = @"TAKEOFF";
//            NSLog(@"GSModeTakeOff");
            break;
        }
            
        case GSModeManual:
        {
            ctrlMode = @"MANUAL";
            NSLog(@"GSModeManual");
            break;
        }
        default:
            break;
    }
    
    self.contrlModeLabel.text = ctrlMode;
}

-(void) onGroundStationGpsStatusChanged:(GroundStationGpsStatus)status
{
    switch (status) {
        case GSGpsGood:
        {
            break;
        }
        case GSGpsWeak:
        {
            break;
        }
        case GSGpsBad:
        {
            break;
        }
        default:
            break;
    }
}

#pragma mark - DJIGroundStationDelegate

-(void) groundStation:(id<DJIGroundStation>)gs didExecuteWithResult:(GroundStationExecuteResult*)result
{
    switch (result.currentAction) {
        case GSActionOpen:
        {
            [self onGroundStationOpenWithResult:result];
            break;
        }
        case GSActionClose:
        {
            [self onGroundStationCloseWithResult:result];
            break;
        }
        case GSActionUploadTask:
        {
            [self onGroundStationUploadTaskWithResult:result];
            break;
        }
        case GSActionDownloadTask:
        {
            [self onGroundStationDownloadTaskWithResult:result];
            break;
        }
        case GSActionStart:
        {
            [self onGroundStationStartTaskWithResult:result];
            break;
        }
        case GSActionPause:
        {
            [self onGroundStationPauseTaskWithResult:result];
            break;
        }
        case GSActionContinue:
        {
            [self onGroundStationContinueTaskWithResult:result];
            break;
        }
        case GSActionGoHome:
        {
            [self onGroundStationGoHomeWithResult:result];
            break;
        }
        default:
            break;
    }
}


-(void) groundStation:(id<DJIGroundStation>)gs didUpdateFlyingInformation:(DJIGroundStationFlyingInfo*)flyingInfo
{
    [self onGroundStationControlModeChanged:flyingInfo.controlMode];
    [self onGroundStationGpsStatusChanged:flyingInfo.gpsStatus];
    
    _homeLocation = flyingInfo.homeLocation;
    self.satelliteLabel.text = [NSString stringWithFormat:@"%d", flyingInfo.satelliteCount];
    self.homeLocationLabel.text = [NSString stringWithFormat:@"%f, %f", flyingInfo.homeLocation.latitude, flyingInfo.homeLocation.longitude];
    self.droneLocationLabel.text = [NSString stringWithFormat:@"%f, %f", flyingInfo.droneLocation.latitude, flyingInfo.droneLocation.longitude];
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
