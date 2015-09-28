//
//  InspireRemoteControllerTestViewController.m
//  DJISdkDemo
//
//  Created by Ares on 15/4/9.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "Phantom3AdvancedRemoteControllerTestViewController.h"

#define RCControlSpeedTestView  (1000)
#define RCWorkModeTestView      (1001)
#define RCControlModeTestView   (1002)
#define RCParingModeTestView    (1003)
#define RCHardwareTestView      (1004)

@interface RemoteControllerFunctionItem2 : NSObject

@property(nonatomic, readonly) NSString* itemName;
@property(nonatomic, strong) UIView* displayView;
@property(nonatomic, assign) SEL action;

-(id) initWithName:(NSString*)itemName;

@end

@implementation RemoteControllerFunctionItem2

-(id) initWithName:(NSString *)itemName
{
    self = [super init];
    if (self) {
        _itemName = itemName;
    }
    return self;
}

@end

@interface Phantom3AdvancedRemoteControllerTestViewController ()
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

@implementation Phantom3AdvancedRemoteControllerTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray* subViews = [[NSBundle mainBundle] loadNibNamed:@"Phantom3AdvancedRemoteControllerSubViews" owner:self options:nil];
    for (int i = 0; i < subViews.count; i++) {
        [self.subContentView addSubview:[subViews objectAtIndex:i]];
    }
    
    [self.subContentView bringSubviewToFront:subViews[0]];
    
    mRCList = [[NSMutableArray alloc] init];
    [self initTestItems];
    [self initView];
    
    if (self.connectedDrone) {
        mDrone = self.connectedDrone;
    }
    else
    {
        mDrone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom3Advanced];
    }
    mRemoteController = (DJIPhantom3AdvancedRemoteController*)mDrone.remoteController;
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
    RemoteControllerFunctionItem2* item1 = [[RemoteControllerFunctionItem2 alloc] initWithName:@"RC Control Mode Test"];
    item1.displayView = [self.subContentView viewWithTag:RCControlModeTestView];
    item1.action = @selector(willStartControlModeTest);
    
    RemoteControllerFunctionItem2* item2 = [[RemoteControllerFunctionItem2 alloc] initWithName:@"RC Paring Mode Test"];
    item2.displayView = [self.subContentView viewWithTag:RCParingModeTestView];
    
    RemoteControllerFunctionItem2* item3 = [[RemoteControllerFunctionItem2 alloc] initWithName:@"RC Hardware State Test"];
    item3.displayView = [self.subContentView viewWithTag:RCHardwareTestView];
    
    mTestItems = [[NSMutableArray alloc] init];
    [mTestItems addObject:item1];
    [mTestItems addObject:item2];
    [mTestItems addObject:item3];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    mRemoteController.delegate = self;
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

-(void) willStartControlModeTest
{
    [self.controlModeSegmentedControl removeAllSegments];
    [self.controlModeSegmentedControl insertSegmentWithTitle:@"Japanese" atIndex:0 animated:YES];
    [self.controlModeSegmentedControl insertSegmentWithTitle:@"American" atIndex:1 animated:YES];
    [self.controlModeSegmentedControl insertSegmentWithTitle:@"Chinese" atIndex:2 animated:YES];
    [self.controlModeSegmentedControl insertSegmentWithTitle:@"Custom" atIndex:3 animated:YES];
}

#pragma mark - Action

-(IBAction) onRCControlModeSegmentedControlValueChanged:(UISegmentedControl*)sender
{
    DJIRCControlMode controlMode = {0};
    controlMode.mControlStyle = (DJIRCControlStyle)sender.selectedSegmentIndex;
    
    if (controlMode.mControlStyle == RCControlStyleCustom) {
        controlMode.mControlChannel[0].mChannel = RCControlChannelAileron;
        controlMode.mControlChannel[0].mReverse = YES;
        controlMode.mControlChannel[1].mChannel = RCControlChannelThrottle;
        controlMode.mControlChannel[1].mReverse = YES;
    }
    
    [mRemoteController setRCControlMode:controlMode withResult:^(DJIError *error) {
        ShowResult(@"Set RC Control Mode:%@", error.errorDescription);
    }];
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

#pragma mark - DJIRemoteControllerDelegate

-(void) remoteController:(DJIRemoteController*)rc didUpdateHardwareState:(DJIRCHardwareState)state
{
    if (memcmp(&mLastHardwareState, &state, sizeof(DJIRCHardwareState)) != 0) {
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
    }
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
        
        RemoteControllerFunctionItem2* item = [mTestItems objectAtIndex:indexPath.row];
        cell.textLabel.text = item.itemName;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RemoteControllerFunctionItem2* item = [mTestItems objectAtIndex:indexPath.row];
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

@end
