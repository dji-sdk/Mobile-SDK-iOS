//
//  InspireRemoteControllerTestViewController.m
//  DJISdkDemo
//
//  Created by Ares on 15/4/9.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "InspireRemoteControllerTestViewController.h"

#define RCControlSpeedTestView  (1000)
#define RCWorkModeTestView      (1001)
#define RCControlModeTestView   (1002)
#define RCParingModeTestView    (1003)
#define RCHardwareTestView      (1004)

@interface RemoteControllerFunctionItem : NSObject

@property(nonatomic, readonly) NSString* itemName;
@property(nonatomic, strong) UIView* displayView;
@property(nonatomic, assign) SEL action;

-(id) initWithName:(NSString*)itemName;

@end

@implementation RemoteControllerFunctionItem

-(id) initWithName:(NSString *)itemName
{
    self = [super init];
    if (self) {
        _itemName = itemName;
    }
    return self;
}

@end

@interface InspireRemoteControllerTestViewController ()
@property (weak, nonatomic) IBOutlet UISlider *leftWheel;
@property (weak, nonatomic) IBOutlet UISlider *rightWheel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSwitch;
@property (weak, nonatomic) IBOutlet UILabel *throttle;
@property (weak, nonatomic) IBOutlet UILabel *elevator;
@property (weak, nonatomic) IBOutlet UILabel *aileron;
@property (weak, nonatomic) IBOutlet UILabel *rudder;
@property (weak, nonatomic) IBOutlet UILabel *cameraRecord;
@property (weak, nonatomic) IBOutlet UILabel *cameraShutter;
@property (weak, nonatomic) IBOutlet UILabel *cameraPlayback;
@property (weak, nonatomic) IBOutlet UILabel *goHomeButton;
@property (weak, nonatomic) IBOutlet UILabel *customButton1;
@property (weak, nonatomic) IBOutlet UILabel *customButton2;
@property (weak, nonatomic) IBOutlet UISwitch *transformSwitch;

@end

@implementation InspireRemoteControllerTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray* subViews = [[NSBundle mainBundle] loadNibNamed:@"InspireRemoteControllerSubViews" owner:self options:nil];
    for (int i = 0; i < subViews.count; i++) {
        [self.subContentView addSubview:[subViews objectAtIndex:i]];
    }
    
    self.rcNameLabel.layer.cornerRadius = 4.0;
    self.rcNameLabel.layer.borderColor = [UIColor blackColor].CGColor;
    self.rcNameLabel.layer.borderWidth = 1.2;
    self.rcNameLabel.layer.masksToBounds = YES;
    
    self.rcPasswordLabel.layer.cornerRadius = 4.0;
    self.rcPasswordLabel.layer.borderColor = [UIColor blackColor].CGColor;
    self.rcPasswordLabel.layer.borderWidth = 1.2;
    self.rcPasswordLabel.layer.masksToBounds = YES;
    
    [self.subContentView bringSubviewToFront:subViews[0]];
    
    mRCList = [[NSMutableArray alloc] init];
    [self initTestItems];
    [self initView];
    
    if (self.connectedDrone) {
        mDrone = self.connectedDrone;
    }
    else
    {
        mDrone = [[DJIDrone alloc] initWithType:DJIDrone_Inspire];
    }
    
    mRemoteController = (DJIInspireRemoteController*)mDrone.remoteController;
    mRemoteController.delegate = self;
    
    [self.navigationController setNavigationBarHidden:NO];
}

-(void) initView
{
    self.throttle.layer.cornerRadius = 4.0;
    self.throttle.layer.borderColor = [UIColor blackColor].CGColor;
    self.throttle.layer.borderWidth = 1.2;
    self.throttle.layer.masksToBounds = YES;
    
    self.elevator.layer.cornerRadius = 4.0;
    self.elevator.layer.borderColor = [UIColor blackColor].CGColor;
    self.elevator.layer.borderWidth = 1.2;
    self.elevator.layer.masksToBounds = YES;
    
    self.aileron.layer.cornerRadius = 4.0;
    self.aileron.layer.borderColor = [UIColor blackColor].CGColor;
    self.aileron.layer.borderWidth = 1.2;
    self.aileron.layer.masksToBounds = YES;
    
    self.rudder.layer.cornerRadius = 4.0;
    self.rudder.layer.borderColor = [UIColor blackColor].CGColor;
    self.rudder.layer.borderWidth = 1.2;
    self.rudder.layer.masksToBounds = YES;
    
    self.cameraRecord.layer.cornerRadius = self.cameraRecord.frame.size.width * 0.5;
    self.cameraRecord.layer.borderColor = [UIColor blackColor].CGColor;
    self.cameraRecord.layer.borderWidth = 1.2;
    self.cameraRecord.layer.masksToBounds = YES;
    
    self.cameraShutter.layer.cornerRadius = self.cameraShutter.frame.size.width * 0.5;
    self.cameraShutter.layer.borderColor = [UIColor blackColor].CGColor;
    self.cameraShutter.layer.borderWidth = 1.2;
    self.cameraShutter.layer.masksToBounds = YES;
    
    self.cameraPlayback.layer.cornerRadius = self.cameraPlayback.frame.size.width * 0.5;
    self.cameraPlayback.layer.borderColor = [UIColor blackColor].CGColor;
    self.cameraPlayback.layer.borderWidth = 1.2;
    self.cameraPlayback.layer.masksToBounds = YES;
    
    self.goHomeButton.layer.cornerRadius = self.goHomeButton.frame.size.width * 0.5;
    self.goHomeButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.goHomeButton.layer.borderWidth = 1.2;
    self.goHomeButton.layer.masksToBounds = YES;
    
    self.customButton1.layer.cornerRadius = self.customButton1.frame.size.width * 0.5;
    self.customButton1.layer.borderColor = [UIColor blackColor].CGColor;
    self.customButton1.layer.borderWidth = 1.2;
    self.customButton1.layer.masksToBounds = YES;
    
    self.customButton2.layer.cornerRadius = self.customButton2.frame.size.width * 0.5;
    self.customButton2.layer.borderColor = [UIColor blackColor].CGColor;
    self.customButton2.layer.borderWidth = 1.2;
    self.customButton2.layer.masksToBounds = YES;
    
    float width = self.navigationController.navigationBar.frame.size.width;
    float hegight = self.navigationController.navigationBar.frame.size.height;
    self.topBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, hegight)];
    self.topBarLabel.backgroundColor = [UIColor clearColor];
    self.topBarLabel.textAlignment = NSTextAlignmentCenter;
    self.topBarLabel.font = [UIFont systemFontOfSize:14];
    self.topBarLabel.text = @"N/A";
    
    [self.navigationController.navigationBar addSubview:self.topBarLabel];
}

-(void) initTestItems
{
    RemoteControllerFunctionItem* item0 = [[RemoteControllerFunctionItem alloc] initWithName:@"RC Control Speed Test"];
    item0.displayView = [self.subContentView viewWithTag:RCControlSpeedTestView];
    item0.action = @selector(willStartWorkModeTest);
    
    RemoteControllerFunctionItem* item1 = [[RemoteControllerFunctionItem alloc] initWithName:@"RC Work Mode Test"];
    item1.displayView = [self.subContentView viewWithTag:RCWorkModeTestView];
    item1.action = @selector(willStartWorkModeTest);
    
    RemoteControllerFunctionItem* item2 = [[RemoteControllerFunctionItem alloc] initWithName:@"RC Control Mode Test"];
    item2.displayView = [self.subContentView viewWithTag:RCControlModeTestView];
    item2.action = @selector(willStartControlModeTest);
    
    RemoteControllerFunctionItem* item3 = [[RemoteControllerFunctionItem alloc] initWithName:@"RC Paring Mode Test"];
    item3.displayView = [self.subContentView viewWithTag:RCParingModeTestView];
    
    RemoteControllerFunctionItem* item4 = [[RemoteControllerFunctionItem alloc] initWithName:@"RC Hardware State Test"];
    item4.displayView = [self.subContentView viewWithTag:RCHardwareTestView];
    
    mTestItems = [[NSMutableArray alloc] init];
    [mTestItems addObject:item0];
    [mTestItems addObject:item1];
    [mTestItems addObject:item2];
    [mTestItems addObject:item3];
    [mTestItems addObject:item4];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [mDrone connectToDrone];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.topBarLabel removeFromSuperview];
    [mDrone disconnectToDrone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Item Action

-(void) willStartWorkModeTest
{
    WeakRef(obj);
    [mRemoteController getRCWorkModeWithResult:^(DJIRCWorkMode workMode, BOOL isConnected, DJIError *error) {
        if (error.errorCode == ERR_Succeeded) {
            WeakReturn(obj);
            [obj.workModeSegmentedControl setSelectedSegmentIndex:(int)workMode];
            [obj setCurrentWorkMode:workMode];
        }
    }];
}

-(void) willStartControlModeTest
{
    WeakRef(obj);
    [mRemoteController getRCWorkModeWithResult:^(DJIRCWorkMode workMode, BOOL isConnected, DJIError *error) {
        if (error.errorCode == ERR_Succeeded) {
            WeakReturn(obj);
            mCurrentWorkMode = workMode;
            if (workMode == RCWorkModeSlave) {
                [obj.controlModeSegmentedControl removeAllSegments];
                [obj.controlModeSegmentedControl insertSegmentWithTitle:@"Default" atIndex:0 animated:YES];
                [obj.controlModeSegmentedControl insertSegmentWithTitle:@"Custom" atIndex:1 animated:YES];
            }
            else
            {
                [obj.controlModeSegmentedControl removeAllSegments];
                [obj.controlModeSegmentedControl insertSegmentWithTitle:@"Japanese" atIndex:0 animated:YES];
                [obj.controlModeSegmentedControl insertSegmentWithTitle:@"American" atIndex:1 animated:YES];
                [obj.controlModeSegmentedControl insertSegmentWithTitle:@"Chinese" atIndex:2 animated:YES];
                [obj.controlModeSegmentedControl insertSegmentWithTitle:@"Custom" atIndex:3 animated:YES];
                [obj getRCControlMode];
            }
        }
    }];
}

-(void) getRCControlMode
{
    WeakRef(obj);
    [mRemoteController getRCControlModeWithResult:^(DJIRCControlMode mode, DJIError *error) {
        WeakReturn(obj);
        if (error.errorCode == ERR_Succeeded) {
            [obj.controlModeSegmentedControl setSelectedSegmentIndex:(int)mode.mControlStyle];
        }
        else
        {
            ShowResult(@"Get Control Mode Error:%@", error.errorDescription);
        }
    }];
}

#pragma mark - Action

-(IBAction) onSpeedControlSliderValueChanged:(UISlider*)sender
{
//    if (mCurrentWorkMode == RCWorkModeSlave) {
//        DJIRCGimbalControlSpeed speed = { sender.value };
//        [mRemoteController setSlaveJoystickControlGimbalSpeed:speed withResult:^(DJIError *error) {
//            NSLog(@"SetControlSpeedResult:%lu", (unsigned long)error.errorCode);
//        }];
//    }
//    else
//    {
//        ShowResult(@"Functionality is for RC Slave.");
//    }
}

-(IBAction) onSpeedControlSliderDragExit:(UISlider*)sender
{
    if (mCurrentWorkMode == RCWorkModeSlave) {
        DJIRCGimbalControlSpeed speed;
        speed.mPitchSpeed = sender.value;
        speed.mRollSpeed = sender.value;
        speed.mYawSpeed = sender.value;
        [mRemoteController setSlaveJoystickControlGimbalSpeed:speed withResult:^(DJIError *error) {
            ShowResult(@"SetControlSpeedResult(%d):%@", (int)(sender.value), error.errorDescription);
        }];
    }
    else
    {
        ShowResult(@"Functionality is for RC Slave.");
    }
//    if (mCurrentWorkMode == RCWorkModeSlave) {
//        [mRemoteController getSlaveJoystickControlGimbalSpeedWithResult:^(DJIRCGimbalControlSpeed speed, DJIError *error) {
//            ShowResult(@"Last Speed Value:%d,  Result:%@", speed.mPitchSpeed, error.errorDescription);
//        }];
//    }
}

-(IBAction) onSensitivityControlSlicerValueChanged:(UISlider*)sender
{

}

-(IBAction) onSensitivityControlSlicerDragExit:(UISlider*)sender
{
    uint8_t sensitivity = (uint8_t)sender.value;
    [mRemoteController setRCWheelControlGimbalSpeed:sensitivity withResult:^(DJIError *error) {
        ShowResult(@"Set Speed :%d, Result:%@", sensitivity, error.errorDescription);
    }];
//    [mRemoteController getRCWheelControlGimbalSpeedWithResult:^(uint8_t speed, DJIError *error) {
//        ShowResult(@"Last Sensitivity:%d, Result:%@", speed, error.errorDescription);
//    }];
}

-(IBAction) onWorkModeSegmentedControlValueChanged:(UISegmentedControl*)sender
{
    DJIRCWorkMode workMode = (DJIRCWorkMode)sender.selectedSegmentIndex;
    WeakRef(obj);
    [mRemoteController setRCWorkMode:workMode withResult:^(DJIError *error) {
        ShowResult(@"Set Work Mode:%d Result:%@", sender.selectedSegmentIndex, error.errorDescription);
        if (error.errorCode == ERR_Succeeded) {
            WeakReturn(obj);
            [obj setCurrentWorkMode:workMode];
        }
    }];
}

-(IBAction) onRCControlModeSegmentedControlValueChanged:(UISegmentedControl*)sender
{
    DJIRCControlMode controlMode = {0};
    controlMode.mControlStyle = (DJIRCControlStyle)sender.selectedSegmentIndex;
    if (mCurrentWorkMode == RCWorkModeSlave) {
        if (controlMode.mControlStyle == RCSlaveControlStyleCustom) {
            controlMode.mControlChannel[0].mChannel = RCControlChannelPitch;
            controlMode.mControlChannel[0].mReverse = YES;
        }
        
        [mRemoteController setSlaveControlMode:controlMode withResult:^(DJIError *error) {
            ShowResult(@"Set Slave Control Mode:%@", error.errorDescription);
        }];
    }
    else
    {
        if (controlMode.mControlStyle == RCControlStyleCustom) {
            controlMode.mControlChannel[0].mChannel = RCControlChannelAileron;
            controlMode.mControlChannel[0].mReverse = YES;
            controlMode.mControlChannel[1].mChannel = RCControlChannelThrottle;
            controlMode.mControlChannel[1].mReverse = YES;
        }
        
        [mRemoteController setRCControlMode:controlMode withResult:^(DJIError *error) {
            ShowResult(@"Set Master Control Mode:%@", error.errorDescription);
        }];
    }
}

-(IBAction) onRequestControlPermissionButtonClicked:(id)sender
{
    if (mCurrentWorkMode == RCWorkModeSlave) {
        [mRemoteController requestGimbalControlRightWithResult:^(DJIRCRequestGimbalControlResult result, DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                if (result == RCRequestGimbalControlResultDeny) {
                    ShowResult(@"Fuck");
                }
                else if (result == RCRequestGimbalControlResultAgree || result == RCRequestGimbalControlResultAuthorized)
                {
                    ShowResult(@"Had Right");
                }
                else if (result == RCRequestGimbalControlResultTimeout)
                {
                    ShowResult(@"Timeout");
                }
                else
                {
                    ShowResult(@"Unknown");
                }
            }
        }];
    }
    else
    {
        ShowResult(@"Not A Slave");
    }
}

-(IBAction) onEnterParingModeButtonClicked:(id)sender
{
    [mRemoteController enterRCPairingModeWithResult:^(DJIError *error) {
        ShowResult(@"Enter Paring Mode Result:%@", error.errorDescription);
    }];
}

-(IBAction) onExitParingModeButtonClicked:(id)sender
{
    [mRemoteController exitRCParingModeWithResult:^(DJIError *error) {
        ShowResult(@"Exit Paring Mode Result:%@", error.errorDescription);
    }];
}

#pragma mark - Private

-(void) setCurrentWorkMode:(DJIRCWorkMode)workMode
{
    WeakRef(obj);
    if (mCurrentWorkMode != workMode) {
        mCurrentWorkMode = workMode;
        if (mCurrentWorkMode == RCWorkModeClosed) {
            [self stopFetchAvailableMasterTimer];
            WeakReturn(obj);
            obj.rcNameLabel.text = nil;
            obj.rcPasswordLabel.text = nil;
        }
        else if (mCurrentWorkMode == RCWorkModeMaster)
        {
            [self stopFetchAvailableMasterTimer];
            [mRemoteController getRCNameWithResult:^(DJIRCName name, DJIError *error) {
                if (ERR_Succeeded == error.errorCode) {
                    WeakReturn(obj);
                    obj.rcNameLabel.text = [NSString stringWithUTF8String:name.mBuffer];
                }
            }];
            
            [mRemoteController getRCPasswordWithResult:^(DJIRCPassword password, DJIError *error) {
                if (error.errorCode == ERR_Succeeded) {
                    WeakReturn(obj);
                    obj.rcPasswordLabel.text = [NSString stringWithFormat:@"%d", password.mPassword];
                }
            }];
            
            [self getSlaveList];
        }
        else if (mCurrentWorkMode == RCWorkModeSlave)
        {
            obj.rcPasswordLabel.text = nil;
            
            [mRemoteController getRCNameWithResult:^(DJIRCName name, DJIError *error) {
                if (ERR_Succeeded == error.errorCode) {
                    WeakReturn(obj);
                    obj.rcNameLabel.text = [NSString stringWithUTF8String:name.mBuffer];
                }
            }];
            
            [mRemoteController startSearchMasterWithResult:^(DJIError *error) {
                ShowResult(@"Start Search Master:%@", error.errorDescription);
                if (ERR_Succeeded == error.errorCode) {
                    [obj startFetchAvailableMasterTimer];
                }
            }];
        }
    }
}

-(void) getSlaveList
{
    WeakRef(obj);
    [mRemoteController getSlaveListWithResult:^(NSArray *slaveList, DJIError *error) {
        if (ERR_Succeeded == error.errorCode) {
            WeakReturn(obj);
            [mRCList removeAllObjects];
            [mRCList addObjectsFromArray:slaveList];
            [obj reloadData];
        }
    }];
}

-(void) startFetchAvailableMasterTimer
{
    if (mFetchAvailableMasterTimer == nil) {
        mFetchAvailableMasterTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onFetchAvailableMasterTimerTicked:) userInfo:nil repeats:YES];
    }
}

-(void) stopFetchAvailableMasterTimer
{
    if (mFetchAvailableMasterTimer) {
        [mFetchAvailableMasterTimer invalidate];
        mFetchAvailableMasterTimer = nil;
    }
    
    [mRCList removeAllObjects];
    [self reloadData];
}

-(void) onFetchAvailableMasterTimerTicked:(id)sender
{
    WeakRef(obj);
    [mRemoteController getAvailableMastersWithResult:^(NSArray *masters, DJIError *error) {
        if (error.errorCode == ERR_Succeeded) {
            WeakReturn(obj);
            [mRCList removeAllObjects];
            [mRCList addObjectsFromArray:masters];
            [obj reloadData];
        }
    }];
}

-(void) reloadData
{
    UIView* subView = [self.subContentView viewWithTag:9000];
    if (subView && [subView isKindOfClass:[UITableView class]]) {
        UITableView* tableView = (UITableView*)subView;
        [tableView reloadData];
    }
}

#pragma mark - DJIRemoteControllerDelegate

-(void) remoteController:(DJIRemoteController*)rc didUpdateHardwareState:(DJIRCHardwareState)state
{
//    if (memcmp(&mLastHardwareState, &state, sizeof(DJIRCHardwareState)) != 0) {
        mLastHardwareState = state;
        self.aileron.text = [NSString stringWithFormat:@"%d", mLastHardwareState.mAileron.mValue];
        self.elevator.text = [NSString stringWithFormat:@"%d", mLastHardwareState.mElevator.mValue];
        self.throttle.text = [NSString stringWithFormat:@"%d", mLastHardwareState.mThrottle.mValue];
        self.rudder.text = [NSString stringWithFormat:@"%d", mLastHardwareState.mRudder.mValue];
        
        [self.leftWheel setValue:mLastHardwareState.mLeftWheel.mValue animated:YES];
        
        int sign = mLastHardwareState.mRightWheel.mWheelOffsetSign ? 1 : -1;
        int offset = mLastHardwareState.mRightWheel.mWheelOffset * sign;
        mWheelOffset += offset;
        if (mWheelOffset > 20) {
            mWheelOffset = -20;
        }
        if (mWheelOffset < -20) {
            mWheelOffset = 20;
        }
        [self.rightWheel setValue:mWheelOffset animated:YES];
        
        [self.modeSwitch setSelectedSegmentIndex:mLastHardwareState.mModeSwitch.mMode];
        
        UIColor* pressedColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        UIColor* normalColor = [UIColor whiteColor];

        [self.cameraRecord setBackgroundColor:(mLastHardwareState.mRecordButton.mButtonDown ? pressedColor : normalColor)];
        
        [self.cameraShutter setBackgroundColor:(mLastHardwareState.mShutterButton.mButtonDown ? pressedColor : normalColor)];
        
        [self.cameraPlayback setBackgroundColor:(mLastHardwareState.mPlaybackButton.mButtonDown ? pressedColor : normalColor)];
        
        [self.goHomeButton setBackgroundColor:(mLastHardwareState.mGoHomeButton.mButtonDown ? pressedColor : normalColor)];
        
        [self.customButton1 setBackgroundColor:(mLastHardwareState.mCustomButton1.mButtonDown ? pressedColor : normalColor)];
        [self.customButton2 setBackgroundColor:(mLastHardwareState.mCustomButton2.mButtonDown ? pressedColor : normalColor)];
        
        BOOL isTranforam = mLastHardwareState.mTransformButton.mLandingGearState == RCHardwareLandingGearAscend;
        [self.transformSwitch setOn:isTranforam animated:YES];
//    }
}

-(void) remoteController:(DJIRemoteController*)rc didUpdateGpsData:(DJIRCGPSData)gpsData
{
    NSString* info = [NSString stringWithFormat:@"Loc{%0.6f, %0.6f}\tGPS:%d\tPower:%d%%", gpsData.mLatitude, gpsData.mLongitude, gpsData.mSatelliteCount, mRCBatteryInfo.mRemainPowerPercent];
    self.topBarLabel.text = info;
}

-(void) remoteController:(DJIRemoteController *)rc didUpdateBatteryState:(DJIRCBatteryInfo)batteryInfo
{
    mRCBatteryInfo = batteryInfo;
}

-(void) remoteController:(DJIRemoteController *)rc didReceivedGimbalControlRequestFormSlave:(DJIRCInfo*)slave
{
    mControlPermissionRequester = slave;
    NSString* message = [NSString stringWithFormat:@"\"%@\" Request for Gimbal Control, do you agree?", [slave RCName]];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Deny" otherButtonTitles:@"Agree", nil];
    alertView.tag = 9090;
    [alertView show];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 9000) {
        if (mRCList) {
            return mRCList.count;
        }
        return 0;
    }
    else
    {
        return mTestItems.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 9000) {
        static NSString* s_reuseCellIdentifier2 = @"ReusableCellWithIdentifier2";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:s_reuseCellIdentifier2];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:s_reuseCellIdentifier2];
        }
        
        DJIRCInfo* info = [mRCList objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithUTF8String:info.name.mBuffer];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        
        return cell;
    }
    else
    {
        static NSString* s_reuseCellIdentifier1 = @"ReusableCellWithIdentifier1";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:s_reuseCellIdentifier1];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:s_reuseCellIdentifier1];
        }
        
        RemoteControllerFunctionItem* item = [mTestItems objectAtIndex:indexPath.row];
        cell.textLabel.text = item.itemName;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 9000) {
        mCurrentRCInfo = [mRCList objectAtIndex:indexPath.row];
        if (mCurrentWorkMode == RCWorkModeSlave) {
            NSString* message = [NSString stringWithFormat:@"Are you sure conneect to %@", [mCurrentRCInfo RCName]];
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            alertView.tag = 8080;
            [alertView show];
        }
        if (mCurrentWorkMode == RCWorkModeMaster) {
            NSString* message = [NSString stringWithFormat:@"Are you sure remove slave %@", [mCurrentRCInfo RCName]];
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove", nil];
            alertView.tag = 7070;
            [alertView show];
        }
    }
    else
    {
        RemoteControllerFunctionItem* item = [mTestItems objectAtIndex:indexPath.row];
        if (item.displayView) {
            if (item.displayView != [self.subContentView.subviews lastObject]) {
                CATransition *animation = [CATransition animation];
                animation.duration = 0.3f;
                animation.timingFunction = UIViewAnimationCurveEaseInOut;
                animation.fillMode = kCAFillModeForwards;
                animation.type = @"cube";
                [self.subContentView.layer addAnimation:animation forKey:@"animation"];
                [self.subContentView bringSubviewToFront:item.displayView];
            }
        }
        
        if (item.action) {
            [self performSelectorOnMainThread:item.action withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 7070) {
        if (buttonIndex == 1) {
            WeakRef(obj);
            [mRemoteController removeSlave:mCurrentRCInfo.identifier withResult:^(DJIError *error) {
                if (error.errorCode == ERR_Succeeded) {
                    WeakReturn(obj);
                    [obj getSlaveList];
                    ShowResult(@"Remove Slave %@ Successed", [mCurrentRCInfo RCName]);
                }
            }];
        }
    }
    if (alertView.tag == 8080) {
        if (buttonIndex == 1) {
            UITextField* textField = [alertView textFieldAtIndex:0];
            NSString* password = textField.text;
            if (password && password.length <= 4) {
                DJIRCPassword rcPassword = {[password intValue]};
                [mRemoteController joinMasterWithID:mCurrentRCInfo.identifier masterName:mCurrentRCInfo.name masterPassword:rcPassword withResult:^(DJIRCJoinMasterResult result, DJIError *error) {
                    ShowResult(@"Connect Master Result:[%@ | %@ | %@] %d",[mCurrentRCInfo RCIdentifier], [mCurrentRCInfo RCName], password, result);
                }];
            }
        }
    }
    if (alertView.tag == 9090) {
        BOOL isAgree = buttonIndex;
        [mRemoteController responseRequester:mControlPermissionRequester.identifier forGimbalControlRight:isAgree];
    }
}

@end
