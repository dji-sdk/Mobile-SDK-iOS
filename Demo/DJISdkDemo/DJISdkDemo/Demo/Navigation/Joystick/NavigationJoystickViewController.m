//
//  JoystickTestViewController.m
//  DJISdkDemo
//
//  Created by Ares on 14-10-27.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "NavigationJoystickViewController.h"
#import "JoyStickView.h"
#import "VideoPreviewer.h"

#define DeviceSystemVersion ([[[UIDevice currentDevice] systemVersion] floatValue])
#define iOS8System (DeviceSystemVersion >= 8.0)

#define SCREEN_WIDTH  (iOS8System ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)
#define SCREEN_HEIGHT (iOS8System ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width)

@interface NavigationJoystickViewController ()

@property(nonatomic, assign) DJIDroneType droneType;

@end

@implementation NavigationJoystickViewController
{
    float mThrottle;
    float mPitch;
    float mRoll;
    float mYaw;
}

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
	// Do any additional setup after loading the view, typically from a nib.
    //    playerOrigin = player.frame.origin;
    
    if (self.connectedDrone) {
        _drone = self.connectedDrone;
    }
    else
    {
        _drone = [[DJIDrone alloc] initWithType:self.droneType];
    }
    
    _drone.delegate = self;
    _drone.camera.delegate = self;
    _drone.mainController.mcDelegate = self;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver: self
                           selector: @selector (onStickChanged:)
                               name: @"StickChanged"
                             object: nil];
    


    self.videoPreviewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:self.videoPreviewView];
    [self.view sendSubviewToBack:self.videoPreviewView];
    self.videoPreviewView.backgroundColor = [UIColor grayColor];
    [[VideoPreviewer instance] start];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setToolbarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES];
    [[VideoPreviewer instance] setView:self.videoPreviewView];
    [[VideoPreviewer instance] setDecoderDataSource:[self dataSourceFromDroneType:_drone.droneType]];
    
    [_drone connectToDrone];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [[VideoPreviewer instance] setView:nil];
    [_drone disconnectToDrone];
}

-(IBAction) onBackButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction) onEnterNavigationButtonClicked:(id)sender
{
    [_drone.mainController.navigationManager enterNavigationModeWithResult:^(DJIError *error) {
        ShowResult(@"Enter Navigation Mode:%@", error.errorDescription);
    }];
}

-(IBAction) onTakeoffButtonClicked:(id)sender
{
    [_drone.mainController startTakeoffWithResult:^(DJIError *error) {
        ShowResult(@"Takeoff:%@", error.errorDescription);
    }];
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
    mThrottle = y * -2;
    mYaw = x * 30;
    
    [self updateJoystick];
}

-(void) setPitch:(float)y andRoll:(float)x
{
    mPitch = y * 15.0;
    mRoll  = x * 15.0;
    [self updateJoystick];
}

-(void) updateJoystick
{
    DJIFlightControlData ctrlData = {0};
    ctrlData.mPitch = mPitch;
    ctrlData.mRoll = mRoll;
    ctrlData.mYaw = mYaw;
    ctrlData.mThrottle =mThrottle;
//    _drone.mainController.navigationManager.flightControl.verticalControlMode = DJIVerticalControlPosition;
//    _drone.mainController.navigationManager.flightControl.verticalControlMode = DJIVerticalControlVelocity;
//    if (_drone.mainController.navigationManager.flightControl.verticalControlMode == DJIVerticalControlPosition) {
//        ctrlData.mThrottle = 20.0;
//    }
    [_drone.mainController.navigationManager.flightControl sendFlightControlData:ctrlData withResult:nil];
}

#pragma mark - Delegate

-(void) droneOnConnectionStatusChanged:(DJIConnectionStatus)status
{
    if (status == ConnectionSucceeded) {
        NSLog(@"Connection Successed!");
    }
    else
    {
        NSLog(@"Connection Broken!");
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

-(void) mainController:(DJIMainController*)mc didUpdateSystemState:(DJIMCSystemState*)state
{
}

@end
