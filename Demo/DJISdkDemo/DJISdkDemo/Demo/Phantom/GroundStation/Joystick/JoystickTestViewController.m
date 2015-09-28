//
//  JoystickTestViewController.m
//  DJISdkDemo
//
//  Created by Ares on 14-10-27.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "JoystickTestViewController.h"
#import "JoystickTestViewController.h"
#import "JoyStickView.h"
#import "VideoPreviewer.h"
#import "DJIDemoHelper.h"

@implementation JoystickTestViewController
{
    int mThrottle;
    int mPitch;
    int mRoll;
    int mYaw;
    
    GroundStationControlMode mControlMode;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //    playerOrigin = player.frame.origin;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver: self
                           selector: @selector (onStickChanged:)
                               name: @"StickChanged"
                             object: nil];
    
    _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom];
    _drone.delegate = self;
    _drone.camera.delegate = self;
    
    _groundStation = (id<DJIGroundStation>)_drone.mainController;
    _groundStation.groundStationDelegate = self;
    mControlMode = GSModeUnknown;
    
    self.videoPreviewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:self.videoPreviewView];
    [self.view sendSubviewToBack:self.videoPreviewView];
    self.videoPreviewView.backgroundColor = [UIColor grayColor];
    [[VideoPreviewer instance] start];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.logLabel.text = @"";
    self.logLabel.numberOfLines = 0;
    _logText = [[NSMutableArray alloc] init];
    [self.navigationController setToolbarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES];
    [[VideoPreviewer instance] setView:self.videoPreviewView];
    
    
    [_drone connectToDrone];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VideoPreviewer instance] setView:nil];
    [_drone disconnectToDrone];
}

-(IBAction) onBackButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction) onEnterNavigationButtonClicked:(id)sender
{
    [_groundStation openGroundStation];
}

- (void)onStickChanged:(NSNotification*)notification
{
    NSDictionary *dict = [notification userInfo];
    NSValue *vdir = [dict valueForKey:@"dir"];
    CGPoint dir = [vdir CGPointValue];
    
    JoyStickView* joystick = (JoyStickView*)notification.object;
    if (joystick) {
        if (joystick == self.joystickLeft) {
            [self setThrottle:dir.y andYaw:dir.x];
        }
        else
        {
            [self setPitch:dir.y andRoll:dir.x];
        }
    }
}

-(void) setThrottle:(float)y andYaw:(float)x
{
    if (y > 0.8) {
        mThrottle = 2;
    }
    else if (y < -0.8) {
        mThrottle = -2;
    }
    else
    {
        mThrottle = 0;
    }
    
    mYaw = (int)( x * 20);
    [self updateJoystick];
}


-(void) setPitch:(float)y andRoll:(float)x
{
    mPitch = (int)(y * 15);
    mRoll  = (int)(x * 15);
    [self updateJoystick];
}

-(void) updateJoystick
{
    [_groundStation setAircraftJoystickWithPitch:mPitch Roll:mRoll Yaw:mYaw Throttle:mThrottle];
}

-(void) logString:(NSString*)text
{
    [_logText addObject:text];
    if (_logText.count > 4) {
        [_logText removeObjectAtIndex:0];
    }
    self.logLabel.text = [_logText componentsJoinedByString:@"\n"];
}

#pragma mark - Delegate

-(void) droneOnConnectionStatusChanged:(DJIConnectionStatus)status
{
    if (status == ConnectionSucceeded) {
        [self logString:@"Connection Successed!"];
    }
    else
    {
        [self logString:@"Connection Broken!"];
    }
}

-(void) camera:(DJICamera*)camera didReceivedVideoData:(uint8_t*)videoBuffer length:(int)length
{
    uint8_t* pBuffer = (uint8_t*)malloc(length);
    memcpy(pBuffer, videoBuffer, length);
    [[[VideoPreviewer instance] dataQueue] push:pBuffer length:length];
}

-(void) camera:(DJICamera*)camera didUpdateSystemState:(DJICameraSystemState*)systemState
{
    
}

-(void) groundStation:(id<DJIGroundStation>)gs didExecuteWithResult:(GroundStationExecuteResult*)result
{
    GSExecuteStatus execStatus = result.executeStatus;
    if (execStatus == GSExecStatusBegan) {
        return;
    }
    
    NSString* message = (execStatus == GSExecStatusSucceeded) ? @"Successed" : @"Failed";
    
    if (result.currentAction == GSActionOpen) {
        [self logString:[NSString stringWithFormat:@"GSOpen: %@", message]];
        if (execStatus == GSExecStatusSucceeded) {
            DJIGroundStationTask* newTask = [DJIGroundStationTask newTask];
            DJIGroundStationWaypoint* waypoint = [[DJIGroundStationWaypoint alloc] initWithCoordinate:_droneLocation];
            waypoint.altitude = 50;
            [newTask addWaypoint:waypoint];
            [_groundStation uploadGroundStationTask:newTask];
        }
    }
    else if (result.currentAction == GSActionUploadTask)
    {
        [self logString:[NSString stringWithFormat:@"GSUploadTask: %@", message]];
        
        if (execStatus == GSExecStatusSucceeded) {
            [_groundStation startGroundStationTask];
        }
    }
    else if (result.currentAction == GSActionStart)
    {
        [self logString:[NSString stringWithFormat:@"GSStart: %@", message]];
    }
    else if (result.currentAction == GSActionPause)
    {
        [self logString:[NSString stringWithFormat:@"GSPause: %@", message]];
    }
    else if (result.currentAction == GSActionGoHome)
    {
        [self logString:[NSString stringWithFormat:@"GSGoHome: %@", message]];
    }
}

-(void) onControlModeChanged:(GroundStationControlMode)ctrlMode
{
    if (mControlMode != ctrlMode && ctrlMode == GSModeWaypoint) {
        [_groundStation pauseGroundStationTask];
    }
    mControlMode = ctrlMode;
}


-(void) groundStation:(id<DJIGroundStation>)gs didUpdateFlyingInformation:(DJIGroundStationFlyingInfo*)flyingInfo
{
    self.gpsLabel.text = [NSString stringWithFormat:@"GPS: %d", flyingInfo.satelliteCount];
    
    _droneLocation = flyingInfo.droneLocation;
    _homeLocation = flyingInfo.homeLocation;
    self.locationLabel.text = [NSString stringWithFormat:@"Location: {%0.6f, %0.6f}", _droneLocation.latitude, _droneLocation.longitude];
    [self onControlModeChanged:flyingInfo.controlMode];
}

@end
