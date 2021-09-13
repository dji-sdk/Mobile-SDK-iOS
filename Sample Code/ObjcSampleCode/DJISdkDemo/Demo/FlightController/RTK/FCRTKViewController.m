//
//  FCRTKViewController.m
//  DJISdkDemo
//
//  Created by neo.xu on 2021/9/13.
//  Copyright © 2021 DJI. All rights reserved.
//

#import "FCRTKViewController.h"
#import "DemoComponentHelper.h"
#import "DemoAlertView.h"
#import <DJISDK/DJISDK.h>
#import "DemoUtilityMacro.h"
#import "DemoUtility.h"

@interface FCRTKViewController () <DJIRTKDelegate, DJIFlightControllerDelegate>

- (IBAction)onRTKEnableButtonClicked:(id)sender;
- (IBAction)onRTKReferenceStationSourceButtonClicked:(id)sender;
- (IBAction)onInputRTKNetworkServiceSettingsButtonClicked:(id)sender;
- (IBAction)onNetworkServiceButtonClicked:(id)sender;
- (IBAction)onFCStatusButtonClicked:(id)sender;
- (IBAction)onRTKStatusButtonClicked:(id)sender;

@property(nonatomic) DemoScrollView* fcStatusTextView;
@property (nonatomic) NSMutableString *rtkUpdateStatusContent;
@property (nonatomic) NSMutableString *serviceStatusContent;
@property(nonatomic) DemoScrollView* RTKStatusTextView;

@end

@implementation FCRTKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.rtkUpdateStatusContent = [NSMutableString string];
    self.serviceStatusContent = [NSMutableString string];
    
    self.RTKStatusTextView = [DemoScrollView viewWithViewController:self];
    [self.RTKStatusTextView setHidden:YES];
    
    self.fcStatusTextView = [DemoScrollView viewWithViewController:self];
    [self.fcStatusTextView setHidden:YES];
    
}

- (void)viewWillAppear:(BOOL)animated {
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc == nil) {
        return;
    }
    fc.RTK.delegate = self;
    fc.delegate = self;
    
    WeakRef(target);
    [[DJISDKManager rtkNetworkServiceProvider] addNetworkServiceStateListener:self queue:dispatch_get_main_queue() block:^(DJIRTKNetworkServiceState * _Nonnull state) {
        WeakReturn(target);
        [target handleRTKServiceState:state];
    }];
}

- (IBAction)onRTKEnableButtonClicked:(id)sender {
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc == nil) {
        return;
    }
    if (fc.RTK == nil) {
        ShowResult(@"RTK Not Support!");
        return;
    }
    [fc.RTK getEnabledWithCompletion:^(BOOL enabled, NSError * _Nullable error) {
        if (error) {
            ShowResult(@"Get RTK Enabled Error: %@", error);
            return;
        }
        NSString *message = [NSString stringWithFormat:@"Current RTK Enabled State: %@", @(enabled)];
        [DemoAlertView showAlertViewWithMessage:message titles:@[@"Cancel", @"OK"] textFields:@[@"0: disable 1: enable"] action:^(NSArray<UITextField *> * _Nullable textFields, NSUInteger buttonIndex) {
            if (buttonIndex == 0) {
                return;
            }
            [fc.RTK setEnabled:textFields[0].text.boolValue withCompletion:^(NSError * _Nullable error) {
                if (!error) {
                    ShowResult(@"Success");
                } else {
                    ShowResult(@"Set RTK :%@", error.localizedDescription);
                }
            }];
        }];
    }];
}

- (IBAction)onRTKReferenceStationSourceButtonClicked:(id)sender {
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    NSString *signalStr = @"0:BaseStation\n 1:CustomNetworkService\n 2:NetworkRTK";
    [DemoAlertView showAlertViewWithMessage:signalStr titles:@[@"Cancel", @"OK"] textFields:@[@"new signal type"] action:^(NSArray<UITextField *> * _Nullable textFields, NSUInteger buttonIndex) {
        if (buttonIndex == 0) {
            return;
        }
        [fc.RTK setReferenceStationSource:(DJIRTKReferenceStationSource)textFields[0].text.integerValue withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"set RTK Signal error: %@", error.description);
            } else {
                ShowResult(@"Success");
            }
        }];
    }];
}

- (IBAction)onInputRTKNetworkServiceSettingsButtonClicked:(id)sender {
    NSString *message = @"Input RTK Network Service Settings";
    [DemoAlertView showAlertViewWithMessage:message titles:@[@"Cancel", @"OK"] textFields:@[@"serverAddress", @"port", @"user name", @"password", @"mountpoint"] action:^(NSArray<UITextField *> * _Nullable textFields, NSUInteger buttonIndex) {
        if (buttonIndex == 0) {
            return;
        }
        DJIMutableRTKNetworkServiceSettings *setting = [[DJIMutableRTKNetworkServiceSettings alloc] init];
        setting.serverAddress = textFields[0].text;
        setting.port = textFields[1].text.intValue;
        setting.userName = textFields[2].text;
        setting.password = textFields[3].text;
        setting.mountpoint = textFields[4].text;
        [[DJISDKManager rtkNetworkServiceProvider] setNetworkServiceSettings:setting];
        ShowResult(@"Set Custom Network Success");
    }];
}

- (IBAction)onNetworkServiceButtonClicked:(id)sender {
    [DemoAlertView showAlertViewWithMessage:@"NetworkService" titles:@[@"Cancel", @"Start", @"Stop"]  action:^(NSUInteger buttonIndex) {
        switch (buttonIndex) {
            case 1:
            {
                [[DJISDKManager rtkNetworkServiceProvider] startNetworkServiceWithCompletion:^(NSError * _Nullable error) {
                    if (error) {
                        ShowResult(@"Start RTKService error: %@", error.description);
                    } else {
                        ShowResult(@"Start RTKService Successfully.");
                    }
                }];
            }
                break;
            case 2:
            {
                [[DJISDKManager rtkNetworkServiceProvider] stopNetworkServiceWithCompletion:^(NSError * _Nullable error) {
                    if (error) {
                        ShowResult(@"Stop RTKService failed error: %@", error.description);
                    } else {
                        ShowResult(@"Stop RTKService Success");
                    }
                }];
            }
                break;
                
            default:
                break;
        }
    }];
}

- (IBAction)onFCStatusButtonClicked:(id)sender {
    [self.fcStatusTextView setHidden:NO];
    [self.fcStatusTextView show];
}
- (IBAction)onRTKStatusButtonClicked:(id)sender {
    [self.RTKStatusTextView setHidden:NO];
    [self.RTKStatusTextView show];
}

-(void)flightController:(DJIFlightController *)fc didUpdateState:(DJIFlightControllerState *)state {
    NSMutableString* MCSystemStateString = [[NSMutableString alloc] init];
    CLLocationCoordinate2D homeLocation     = state.homeLocation ? state.homeLocation.coordinate : kCLLocationCoordinate2DInvalid;
    CLLocationCoordinate2D aircraftLocation = state.aircraftLocation ? state.aircraftLocation.coordinate : kCLLocationCoordinate2DInvalid;
    [MCSystemStateString appendFormat:@"homeLocation = {%f, %f}\n", homeLocation.latitude, homeLocation.longitude];
    [MCSystemStateString appendFormat:@"droneLocation = {%f, %f}\n", aircraftLocation.latitude, aircraftLocation.longitude];
    [MCSystemStateString appendFormat:@"velocityX = %f m/s\n", state.velocityX];
    [MCSystemStateString appendFormat:@"velocityY = %f m/s\n", state.velocityY];
    [MCSystemStateString appendFormat:@"velocityZ = %f m/s\n", state.velocityZ];
    [MCSystemStateString appendFormat:@"altitude = %f m\n", state.altitude];
    [MCSystemStateString appendFormat:@"DJIAttitude  = {%f, %f , %f}\n", state.attitude.pitch ,state.attitude.roll , state.attitude.yaw];
    [MCSystemStateString appendFormat:@"Remaining Battery = %d\n", state.batteryThresholdBehavior];
    [MCSystemStateString appendFormat:@"isFlying = %d\n", state.isFlying];
    [MCSystemStateString appendFormat:@"RemainTimeForFlight = %d min\n", (int)state.goHomeAssessment.remainingFlightTime / 60];
    [MCSystemStateString appendFormat:@"timeForGoHome = %d s\n", (int)state.goHomeAssessment.timeNeededToGoHome];
    [MCSystemStateString appendFormat:@"timeForLanding = %d s\n", (int)state.goHomeAssessment.timeNeededToLandFromCurrentHeight];
    [MCSystemStateString appendFormat:@"powerPercentForGoHome = %d%%\n", (int)state.goHomeAssessment.batteryPercentageNeededToGoHome];
    [MCSystemStateString appendFormat:@"powerPercentForLanding = %d%%\n", (int)state.goHomeAssessment.batteryPercentageNeededToLandFromCurrentHeight];
    [MCSystemStateString appendFormat:@"radiusForGoHome = %d m\n", (int)state.goHomeAssessment.maxRadiusAircraftCanFlyAndGoHome];
    [MCSystemStateString appendFormat:@"Smart RTH state = %u\n", state.goHomeAssessment.smartRTHState];
    [MCSystemStateString appendFormat:@"Smart RTH Countdown = %zd\n", state.goHomeAssessment.smartRTHCountdown];

    [MCSystemStateString appendFormat:@"isFailsafe = %d\n", state.isFailsafeEnabled];
    [MCSystemStateString appendFormat:@"isIMUPreheating = %d\n", state.isIMUPreheating];
    [MCSystemStateString appendFormat:@"isUltrasonicBeingUsed = %d\n", state.isUltrasonicBeingUsed];
    [MCSystemStateString appendFormat:@"isVisionSensorBeingUsed = %d\n", state.isVisionPositioningSensorBeingUsed];
    [MCSystemStateString appendFormat:@"areMotorsOn = %d\n", state.areMotorsOn];
    [MCSystemStateString appendFormat:@"goHomeExecutionStatus = %lu\n", (unsigned long)state.goHomeExecutionState];

    [MCSystemStateString appendFormat:@"hasReachedMaxFlightHeight:%@\n", state.hasReachedMaxFlightHeight ? @"YES" : @"NO" ];
    [MCSystemStateString appendFormat:@"hasReachedMaxFlightRadius:%@\n", state.hasReachedMaxFlightRadius ? @"YES" : @"NO"];
    [MCSystemStateString appendFormat:@"isActiveBrakeEngaged: %@\n", state.isActiveBrakeEngaged ? @"YES" : @"NO"];
    [MCSystemStateString appendFormat:@"windWarning:%lu\n", (unsigned long)state.windWarning];
    
    [self.fcStatusTextView writeStatus:MCSystemStateString];
}

#pragma mark - DJIRTKDelegate

-(void)rtk:(DJIRTK *)rtk didUpdateState:(DJIRTKState *)state {
    self.rtkUpdateStatusContent = [NSMutableString string];
    NSMutableString* rtkLog1 = [[NSMutableString alloc] init];
    
    [rtkLog1 appendFormat:@"positioning Solution: %@\n", [[self class] descriptionForPositioningSolution:state.positioningSolution]];
    [rtkLog1 appendFormat:@"Error: %@\n", state.error.localizedDescription];
    [rtkLog1 appendFormat:@"mobile Station Location: {%f, %f}\n", state.mobileStationLocation.latitude, state.mobileStationLocation.longitude];
    [rtkLog1 appendFormat:@"mobile Station Altitude: %f\n", state.mobileStationAltitude];
    
    [rtkLog1 appendFormat:@"Base Station Location: {%f, %f}\n", state.baseStationLocation.latitude, state.baseStationLocation.longitude];
    [rtkLog1 appendFormat:@"Base Station Altitude: %f\n", state.baseStationAltitude];
    [rtkLog1 appendFormat:@"Heading:%f\n", state.heading];
    [rtkLog1 appendFormat:@"Heading Solution:%d\n", state.headingSolution];
    [rtkLog1 appendFormat:@"is RTKBeing Used:%d\n", state.isRTKBeingUsed];
    [rtkLog1 appendFormat:@"mobileStation Fusion Heading:%f\n", state.mobileStationFusionHeading];
    [rtkLog1 appendFormat:@"mobileStation Fusion Altitude:%f\n", state.mobileStationFusionAltitude];
    [rtkLog1 appendFormat:@"mobileStation Fusion Location:{%f, %f}\n", state.mobileStationFusionLocation.latitude, state.mobileStationFusionLocation.longitude];
    [rtkLog1 appendFormat:@"Distance to Home Point Data Source:%d\n", state.distanceToHomePointDataSource];
    [rtkLog1 appendFormat:@"Home Point Data Source:%d\n", state.homePointDataSource];
    [rtkLog1 appendFormat:@"Has set Takeoff Altitude:%d\n", state.isTakeoffAltitudeRecorded];
    [rtkLog1 appendFormat:@"Satellite Count:%d\n", state.satelliteCount];
    [rtkLog1 appendFormat:@"Home Point Location:{%f, %f}\n", state.homePointLocation.latitude, state.homePointLocation.longitude];
    [rtkLog1 appendFormat:@"Takeoff Altitude:%f\n", state.takeoffAltitude];
    [rtkLog1 appendFormat:@"Distance To Home Point:%f\n", state.distanceToHomePoint];
    [rtkLog1 appendFormat:@"Ellipsoid Height:%f\n", state.ellipsoidHeight];
    [rtkLog1 appendFormat:@"Aircraft Altitude:%f\n", state.aircraftAltitude];
    [rtkLog1 appendFormat:@"isMaintainingPositionAccurary:%d\n", state.isMaintainingPositionAccuracy];
    
    [self.rtkUpdateStatusContent appendString:@"========= log1 ======== \n"];
    [self.rtkUpdateStatusContent appendString:rtkLog1];
    
    [self updatePanel];
}

- (void)handleRTKServiceState:(DJIRTKNetworkServiceState *)serviceState {
    self.serviceStatusContent = [NSMutableString string];
    [self.serviceStatusContent appendString:@"========= RTKServiceState ======== \n"];
    [self.serviceStatusContent appendFormat:@"state: %@\n", [[self class] descriptionForServiceConnectState:serviceState.channelState]];
    [self.serviceStatusContent appendFormat:@"error: %@", serviceState.error.description];
    [self updatePanel];
}

- (void)updatePanel {
    NSMutableString *panelStr = [NSMutableString string];
    [panelStr appendFormat:@"%@\n", self.rtkUpdateStatusContent];
    [panelStr appendFormat:@"%@\n", self.serviceStatusContent];

    [self.RTKStatusTextView writeStatus:panelStr];
}

#pragma mark - Utils

DESCRIPTION_FOR_ENUM(DJIRTKNetworkServiceChannelState, ServiceConnectState,
                     DJIRTKNetworkServiceChannelStateUnknown,
                     DJIRTKNetworkServiceChannelStateDisabled,
                     DJIRTKNetworkServiceChannelStateLoginFailure,
                     DJIRTKNetworkServiceChannelStateTransmitting,
                     DJIRTKNetworkServiceChannelStateDisconnected,
                     DJIRTKNetworkServiceChannelStateNetworkNotReachable,
                     DJIRTKNetworkServiceChannelStateAircraftDisconnected,
                     DJIRTKNetworkServiceChannelStateReady,
                     DJIRTKNetworkServiceChannelStateConnecting,
                     DJIRTKNetworkServiceChannelStateAccountError,
                     DJIRTKNetworkServiceChannelStateInvalidRequest,
                     DJIRTKNetworkServiceChannelStateServiceSuspension,
                     DJIRTKNetworkServiceChannelStateServerNotReachable);

DESCRIPTION_FOR_ENUM(DJIRTKPositioningSolution, PositioningSolution,
                     DJIRTKPositioningSolutionNone,
                     DJIRTKPositioningSolutionSinglePoint,
                     DJIRTKPositioningSolutionFloat,
                     DJIRTKPositioningSolutionFixedPoint);

@end
