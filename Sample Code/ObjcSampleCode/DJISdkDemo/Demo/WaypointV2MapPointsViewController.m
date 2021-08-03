//
//  WaypointV2MapPointsViewController.m
//  DJISdkDemo
//
//  Created by ethan.jiang on 2020/5/8.
//  Copyright © 2020 DJI. All rights reserved.
//

#import "WaypointV2MapPointsViewController.h"
#import "DJIMapView.h"
#import <DJISDK/DJISDK.h>
#import "DemoAlertView.h"
#import "DemoUtilityMacro.h"
#import "WaypointV2ConfigrationViewController.h"
#import "WaypointV2PointConfigViewController.h"

@interface WaypointV2MapPointsViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UISlider *autoSpeedSlider;
@property (weak, nonatomic) IBOutlet UIButton *activeFocusButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadActionButton;
@property (weak, nonatomic) IBOutlet UIButton *startPathShootingButton;
@property (weak, nonatomic) IBOutlet UIButton *stopPathShootingButton;

@property (nonatomic, assign) BOOL configFinished;
@property (nonatomic, strong) NSMutableArray <DJIWaypointV2 *> *waypoints;
@property (nonatomic, strong) NSMutableArray *waypointAnnotations;

@property (nonatomic, strong) DJIFlightControllerState *currentState;
@property (nonatomic, strong) DJIMutableWaypointV2Mission *waypointMission;
@property (nonatomic, assign) CLLocationCoordinate2D aircraftLocation;
@property (nonatomic, strong) DJIAircraftAnnotation *aircraftAnnotation;
@property (nonatomic, strong) DJIMapView *djiMapView;

@property(nonatomic, strong) NSMutableArray* actionList;

@end

@interface DJIGimbalRotation ()

@property (nonatomic, assign, readwrite) DJIGimbalRotationMode mode;
@property (nonatomic, strong, nullable, readwrite) NSNumber *pitch;
@property (nonatomic, assign, readwrite) NSTimeInterval time;

@end

static NSUInteger kMissionId = 1001;

@implementation WaypointV2MapPointsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.configFinished = NO;
    self.djiMapView = [[DJIMapView alloc] initWithMap:self.mapView];
    self.waypoints = [[NSMutableArray alloc] init];
    self.waypointAnnotations = [[NSMutableArray alloc] init];
    
    self.uploadButton.enabled = NO;
    self.startButton.enabled = NO;
    self.stopButton.enabled = NO;
    self.resetButton.enabled = NO;
    self.autoSpeedSlider.value = self.missionConfig.autoFlightSpeed;
    self.actionList = [NSMutableArray array];
    
    WeakRef(target);
    [[[DJISDKManager missionControl] waypointV2MissionOperator] addListenerToUploadEvent:self withQueue:dispatch_get_main_queue() andBlock:^(DJIWaypointV2MissionUploadEvent * _Nonnull event) {
        WeakReturn(target);
        if (event.error) {
            ShowResult(@"Upload Error:%@", event.error.description);
        } else {
            target.tipLabel.text = @"ready to start mission";
            target.startButton.enabled = YES;
            target.resetButton.enabled = NO;
        }
    }];
    
    [[[DJISDKManager missionControl] waypointV2MissionOperator] addListenerToStopped:self withQueue:dispatch_get_main_queue() andBlock:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"User stop mission failed: %@", error.description);
        } else {
            target.finishButton.enabled = NO;
            target.finishButton.backgroundColor = [UIColor lightGrayColor];
            target.uploadButton.enabled = YES;
            target.resetButton.enabled = YES;
            target.configFinished = YES;
            target.tipLabel.text = @"Mission stopped";
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DJIBaseProduct *product = [DJISDKManager product];
    if (product && [product isKindOfClass:[DJIAircraft class]]) {
        [(DJIAircraft *)product flightController].delegate = self;
        DJIFlightController *fc = [(DJIAircraft *)product flightController];
        if (!fc || fc.simulator.isSimulatorActive) {
            return;
        }
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(22.53, 113.95);
        WeakRef(target);
        [fc.simulator startWithLocation:location updateFrequency:20 GPSSatellitesNumber:20 withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"Start flight simulator error:%@", error.description);
            } else {
                WeakReturn(target);
                [target.djiMapView refreshMapViewRegion];
                [target.djiMapView forceRefreshLimitSpaces];
            }
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    DJIBaseProduct *product = [DJISDKManager product];
    if (product && [product isKindOfClass:[DJIAircraft class]]) {
        if ([(DJIAircraft *)product flightController].delegate == self) {
            [(DJIAircraft *)product flightController].delegate = nil;
            DJIFlightController *fc = [(DJIAircraft *)product flightController];
            if (fc.simulator.isSimulatorActive) {
                [fc.simulator stopWithCompletion:nil];
            }
        }
    }
    [[[DJISDKManager missionControl] waypointV2MissionOperator] removeListener:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"waypointsConfig"]) {
        WaypointV2PointConfigViewController *vc = segue.destinationViewController;
        vc.waypoints = self.waypoints;
    }
}

#pragma mark - user interactive
- (IBAction)onFinishClicked:(id)sender {
    if (self.waypoints.count <= 1) {
        ShowResult(@"Please add some waypoints before clicking finish");
        return;
    }
    self.finishButton.enabled = NO;
    self.finishButton.backgroundColor = [UIColor lightGrayColor];
    self.uploadButton.enabled = YES;
    self.resetButton.enabled = YES;
    self.configFinished = YES;
    self.tipLabel.text = @"ready to upload";
}

- (IBAction)onUploadClicked:(id)sender {
    if (!self.configFinished) {
        ShowResult(@"Please accomplish configration before uploading");
        return;
    }
    
    [self updateMission];
    
    DJIMutableWaypointV2Mission *wp = [DJIMutableWaypointV2Mission new];
    
    wp.maxFlightSpeed = self.waypointMission.maxFlightSpeed;
    wp.autoFlightSpeed = self.waypointMission.autoFlightSpeed;
    wp.finishedAction = self.waypointMission.finishedAction;
    wp.repeatTimes = self.waypointMission.repeatTimes;
    wp.missionID = self.waypointMission.missionID;
    wp.autoFlightSpeed = self.waypointMission.autoFlightSpeed;
    wp.waypointCount = self.waypointMission.waypointCount;
    wp.exitMissionOnRCSignalLost = self.waypointMission.exitMissionOnRCSignalLost;
    wp.gotoFirstWaypointMode = self.waypointMission.gotoFirstWaypointMode;
    
    [wp addWaypoints:self.waypoints];
    WeakRef(target);
    [[[DJISDKManager missionControl] waypointV2MissionOperator] loadMission:wp withCompletion:^(NSError * _Nullable error) {
        WeakReturn(target);
        dispatch_async(dispatch_get_main_queue(), ^{
            target.tipLabel.text = @"waiting upload ...";
        });
        if (error) {
            ShowResult(@"loadMission Failed: %@", error.description);
            dispatch_async(dispatch_get_main_queue(), ^{
                target.tipLabel.text = @"ready to upload";
            });
        } else {
            [[[DJISDKManager missionControl] waypointV2MissionOperator] uploadMissionWithCompletion:^(NSError * _Nullable error) {
                if (error) {
                    ShowResult(@"Upload Mission Failed: %@", error.description);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        target.tipLabel.text = @"ready to upload";
                    });
                }
            }];
        }
    }];
}

- (IBAction)onStartClicked:(id)sender {
    WeakRef(target);
    [[[DJISDKManager missionControl] waypointV2MissionOperator] startMissionWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"Start Mission Failed: %@", error.description);
        } else {
            WeakReturn(target);
            dispatch_async(dispatch_get_main_queue(), ^{
                target.tipLabel.text = @"Mission started";
                target.startButton.enabled = NO;
                target.stopButton.enabled = YES;
            });
        }
    }];
}

- (IBAction)onStopClicked:(id)sender {
    [[[DJISDKManager missionControl] waypointV2MissionOperator] stopMissionWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"Stop Mission Failed: %@", error.description);
        }
    }];
}

- (IBAction)onResetClicked:(id)sender {
    if (!self.startButton.enabled) {
        return;
    }
    [self.mapView removeAnnotations:self.waypointAnnotations];
    [self.waypoints removeAllObjects];
    [self.waypointAnnotations removeAllObjects];
    
    self.configFinished = NO;
    self.finishButton.enabled = YES;
    self.finishButton.backgroundColor = [UIColor systemBlueColor];
    self.startButton.enabled = NO;
    self.uploadButton.enabled = NO;
    self.stopButton.enabled = NO;
    self.resetButton.enabled = NO;
}

- (IBAction)onSpeedValueChanged:(UISlider *)sender {
    [[[DJISDKManager missionControl] waypointV2MissionOperator] setAutoFlightSpeed:sender.value withCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"Change auto flight speed failed: %@", error.description);
        }
    }];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.configFinished) {
        return NO;
    }
    return YES;
}

- (IBAction)tapGestureRecognized:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self.mapView];
    CLLocationCoordinate2D touchedCoordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    
    DJIWaypointV2 *waypoint = [[DJIWaypointV2 alloc] initWithCoordinate:touchedCoordinate];
    //default setting
    waypoint.altitude = 30;
    waypoint.autoFlightSpeed = 8;
    waypoint.maxFlightSpeed = 12;
    waypoint.flightPathMode = DJIWaypointV2FlightPathModeGoToPointInAStraightLineAndStop;
    waypoint.headingMode = DJIWaypointV2HeadingModeAuto;
    [self.waypoints addObject:waypoint];
    DJIWaypointAnnotation *wpAnnotation = [[DJIWaypointAnnotation alloc] init];
    [wpAnnotation setCoordinate:waypoint.coordinate];
    wpAnnotation.text = [NSString stringWithFormat:@"%d",(int)self.waypoints.count - 1];
    
    [self.mapView addAnnotations:@[wpAnnotation]];
    [self.waypointAnnotations addObjectsFromArray:@[wpAnnotation]];
}

- (IBAction)onActionBarItem:(id)sender {
    if (self.waypoints.count == 0) {
        ShowResult(@"Please add one waypoints before configration!");
        return;
    }
    [self performSegueWithIdentifier:@"waypointsConfig" sender:self];
}


#pragma mark - mission
- (void)updateMission {
    if (!self.waypointMission) {
        self.waypointMission = [[DJIMutableWaypointV2Mission alloc] init];
    }
    self.waypointMission.missionID = kMissionId;

    self.waypointMission.maxFlightSpeed = self.missionConfig.maxFlightSpeed;
    self.waypointMission.autoFlightSpeed = self.missionConfig.autoFlightSpeed;
    self.waypointMission.finishedAction = self.missionConfig.finishedAction;
    self.waypointMission.exitMissionOnRCSignalLost = self.missionConfig.exitOnRCSignalLostAction == DJIWaypointV2MissionRCLostActionStopMission;
    self.waypointMission.repeatTimes = (int)self.missionConfig.repeatTimes;
    self.waypointMission.waypointCount = self.waypoints.count;
    self.waypointMission.gotoFirstWaypointMode = self.missionConfig.gotoFirstWaypointAction;
    [self.waypointMission removeAllWaypoints];

    [self.waypointMission addWaypoints:self.waypoints];
}

- (void)addWaypointAnnotations {
    for (int index = 0; index < self.waypoints.count; ++index) {
        DJIWaypointV2 *waypoint = self.waypoints[index];

        DJIWaypointAnnotation* wpAnnotation = [[DJIWaypointAnnotation alloc] init];
        [wpAnnotation setCoordinate:waypoint.coordinate];
        wpAnnotation.text = [NSString stringWithFormat:@"%d",index];
        [self.mapView addAnnotation:wpAnnotation];
        [self.waypointAnnotations addObject:wpAnnotation];
    }
}

- (void)recoverCurrentWaypointMission:(DJIMutableWaypointV2Mission*)newMission {
    self.waypointMission = newMission;
    self.waypoints = [[NSMutableArray alloc] initWithArray:newMission.allWaypoints];
    
    for (int i = 0; i < self.waypointAnnotations.count; i++) {
        DJIWaypointAnnotation* wpAnno = [self.waypointAnnotations objectAtIndex:i];
        [self.mapView removeAnnotation:wpAnno];
    }
    
    [self.waypointAnnotations removeAllObjects];
    [self addWaypointAnnotations];
}

- (void)flightController:(DJIFlightController *)fc didUpdateState:(DJIFlightControllerState *)state {
    self.currentState = state;
    self.aircraftLocation = state.aircraftLocation.coordinate;
    self.djiMapView.simulating = fc.simulator.isSimulatorActive;

    if (CLLocationCoordinate2DIsValid(state.aircraftLocation.coordinate)) {
        double heading = RADIAN(state.attitude.yaw);
        [self.djiMapView updateAircraftLocation:state.aircraftLocation.coordinate withHeading:heading];
        [self.djiMapView refreshMapViewRegion];
    }
    
    if (CLLocationCoordinate2DIsValid(state.homeLocation.coordinate)) {
        [self.djiMapView updateHomeLocation:state.homeLocation.coordinate];
    }

}

- (IBAction)onUploadActionButtonClicked:(id)sender {
    [[[DJISDKManager missionControl] waypointV2MissionOperator] uploadWaypointActions:self.actionList withCompletion:^(NSError * _Nullable error) {
        ShowResult(@"Upload Action:%@", error.description);
        if (error == nil) {
            [self.actionList removeAllObjects];
        }
    }];
}

- (IBAction)OnActiveFocusButtonClicked:(id)sender {
    int pointIndex = 0;
    int actionID = 0;
    float gimbalPitch = 0;
    [self.actionList addObject:[self getStopFlyActionWithPointIndex:pointIndex actionID:actionID]];
    actionID++;
    [self.actionList addObject:[self getSerialActionWithPreActionID:actionID - 1 actuator:[self getGimbalActuatorWithPitch:-90 gimbalIndex:0] actionID:actionID]];
    actionID++;
    [self.actionList addObject:[self getSerialDelayActionWithPreActionID:actionID - 1 delayTime:1 actuator:[self getCameraFocusModeActuatorWithCameraFocusMode:DJIWaypointV2CameraFocusMode_Auto cameraIndex:0] actionID:actionID]];
    actionID++;
    [self.actionList addObject:[self getSerialDelayActionWithPreActionID:actionID - 1 delayTime:1 actuator:[self getCameraRectFocusActuatorWithCameraIndex:0] actionID:actionID]];
    actionID++;
    [self.actionList addObject:[self getSerialDelayActionWithPreActionID:actionID - 1 delayTime:1 actuator:[self getCameraFocusModeActuatorWithCameraFocusMode:DJIWaypointV2CameraFocusMode_Manual cameraIndex:0] actionID:actionID]];
    actionID++;
    [self.actionList addObject:[self getSerialActionWithPreActionID:actionID - 1 actuator:[self getGimbalActuatorWithPitch:gimbalPitch gimbalIndex:0] actionID:actionID]];
    actionID++;
    [self.actionList addObject:[self getSerialDelayActionWithPreActionID:actionID - 1 delayTime:2 actuator:[self getStayStartActuator] actionID:actionID]];
    ShowResult(@"current action count:%d",self.actionList.count);
}

/**
 * @param trigger  指定Trigger 触发器
 * @param actuator 指定actuator 执行器
 * @param actionId 动作ID
 */
- (DJIWaypointV2Action *)getActionWithTrigger:(DJIWaypointV2Trigger *)trigger actuator:(DJIWaypointV2Actuator *)actuator actionID:(NSUInteger)actionId {
    DJIWaypointV2Action *res = [[DJIWaypointV2Action alloc] init];
    res.trigger = trigger;
    res.actuator = actuator;
    res.actionId = actionId;
    return res;
}

- (DJIWaypointV2Action *)getStopFlyActionWithPointIndex:(NSUInteger)index actionID:(NSUInteger)actionId {
    return [self getActionWithTrigger:[self getSimpleReachPointTriggerWithPointIndex:index] actuator:[self getStayActuator] actionID:actionId];
}

/**
 * 串行动作连接
 *
 * @param preActionId 前一个动作的ID
 * @param actuator        执行器
 * @param actionId        动作ID
 */
- (DJIWaypointV2Action *)getSerialActionWithPreActionID:(NSUInteger)preActionId actuator:(DJIWaypointV2Actuator *)actuator actionID:(NSUInteger)actionId {
    return [self getActionWithTrigger:[self getSerialTriggerWithActionID:preActionId] actuator:actuator actionID:actionId];
}

/**
 * 串行动作连接
 *
 * @param preActionId 前一个动作的ID
 * @param time                 delay time in Seconds
 * @param actuator        执行器
 * @param actionId        动作ID
 */
- (DJIWaypointV2Action *)getSerialDelayActionWithPreActionID:(NSUInteger)preActionId delayTime:(NSUInteger)time actuator:(DJIWaypointV2Actuator *)actuator actionID:(NSUInteger)actionId {
    return [self getActionWithTrigger:[self getSerialWaitTriggerWithActionID:preActionId waitTime:time] actuator:actuator actionID:actionId];
}

/**
 * 到点触发器
 */
- (DJIWaypointV2Trigger *)getSimpleReachPointTriggerWithPointIndex:(NSUInteger)index {
    DJIWaypointV2Trigger *res = [[DJIWaypointV2Trigger alloc] init];
    res.actionTriggerType = DJIWaypointV2ActionTriggerTypeReachPoint;
    DJIWaypointV2ReachPointTriggerParam *param = [[DJIWaypointV2ReachPointTriggerParam alloc] init];
    param.startIndex = index;
    res.reachPointTriggerParam = param;
    return res;
}

/**
 * 串行触发器
 */
- (DJIWaypointV2Trigger *)getSerialTriggerWithActionID:(NSUInteger)actionId {
    DJIWaypointV2Trigger *res = [[DJIWaypointV2Trigger alloc] init];
    res.actionTriggerType = DJIWaypointV2ActionTriggerTypeActionAssociated;
    DJIWaypointV2AssociateTriggerParam *associateTriggerParam = [[DJIWaypointV2AssociateTriggerParam alloc] init];
    associateTriggerParam.actionAssociatedType = DJIWaypointV2TriggerAssociatedTimingTypeAfterFinished;
    associateTriggerParam.actionIdAssociated = actionId;
    res.associateTriggerParam = associateTriggerParam;
    return res;
}

/**
 * 串行延时触发器
 */
- (DJIWaypointV2Trigger *)getSerialWaitTriggerWithActionID:(NSUInteger)actionId waitTime:(NSUInteger)time {
    DJIWaypointV2Trigger *res = [[DJIWaypointV2Trigger alloc] init];
    res.actionTriggerType = DJIWaypointV2ActionTriggerTypeActionAssociated;
    DJIWaypointV2AssociateTriggerParam *associateTriggerParam = [[DJIWaypointV2AssociateTriggerParam alloc] init];
    associateTriggerParam.actionIdAssociated = actionId;
    associateTriggerParam.actionAssociatedType = DJIWaypointV2TriggerAssociatedTimingTypeAfterFinished;
    associateTriggerParam.waitingTime = time;
    res.associateTriggerParam = associateTriggerParam;
    return res;
}

/**
 * 悬停执行器
 */
- (DJIWaypointV2Actuator *)getStayActuator {
    DJIWaypointV2Actuator *res = [[DJIWaypointV2Actuator alloc] init];
    res.type = DJIWaypointV2ActionActuatorTypeAircraftControl;
    DJIWaypointV2AircraftControlParam *param = [[DJIWaypointV2AircraftControlParam alloc] init];
    param.operationType = DJIWaypointV2ActionActuatorAircraftControlOperationTypeFlyingControl;
    DJIWaypointV2AircraftControlFlyingParam *flyParam = [[DJIWaypointV2AircraftControlFlyingParam alloc] init];
    flyParam.isStartFlying = NO;
    param.flyControlParam = flyParam;
    res.aircraftControlActuatorParam = param;
    return res;
}

/**
 * 悬停结束执行器
 */
- (DJIWaypointV2Actuator *)getStayStartActuator {
    DJIWaypointV2Actuator *res = [[DJIWaypointV2Actuator alloc] init];
    res.type = DJIWaypointV2ActionActuatorTypeAircraftControl;
    DJIWaypointV2AircraftControlParam *aircraftControlActuatorParam = [[DJIWaypointV2AircraftControlParam alloc] init];
    DJIWaypointV2AircraftControlFlyingParam *flyControlParam = [[DJIWaypointV2AircraftControlFlyingParam alloc] init];
    flyControlParam.isStartFlying = YES;
    aircraftControlActuatorParam.operationType = DJIWaypointV2ActionActuatorAircraftControlOperationTypeFlyingControl;
    aircraftControlActuatorParam.flyControlParam = flyControlParam;
    res.aircraftControlActuatorParam = aircraftControlActuatorParam;
    return res;
}

/**
 * 云台 pitch 角执行器
 */
- (DJIWaypointV2Actuator *)getGimbalActuatorWithPitch:(float)pitch gimbalIndex:(NSUInteger)gimbalIndex {
    DJIWaypointV2Actuator *res = [[DJIWaypointV2Actuator alloc] init];
    res.type = DJIWaypointV2ActionActuatorTypeGimbal;
    res.actuatorIndex = gimbalIndex;
    DJIGimbalRotation *rotation = [[DJIGimbalRotation alloc] init];
    rotation.pitch = @(pitch);
    rotation.time = 2;
    rotation.mode = DJIGimbalRotationModeRelativeAngle;
    DJIWaypointV2GimbalActuatorParam *gimbalActuatorParam = [[DJIWaypointV2GimbalActuatorParam alloc] init];
    gimbalActuatorParam.operationType = DJIWaypointV2ActionActuatorGimbalOperationTypeRotateGimbal;
    gimbalActuatorParam.rotation = rotation;
    res.gimbalActuatorParam = gimbalActuatorParam;
    return res;
}

/**
 * 对焦模式执行器
 */
- (DJIWaypointV2Actuator *)getCameraFocusModeActuatorWithCameraFocusMode:(DJIWaypointV2CameraFocusModeType)mode cameraIndex:(NSUInteger)cameraIndex {
    DJIWaypointV2Actuator *res = [[DJIWaypointV2Actuator alloc] init];
    res.type = DJIWaypointV2ActionActuatorTypeCamera;
    res.actuatorIndex = cameraIndex;
    DJIWaypointV2CameraActuatorParam *cameraActuatorParam = [[DJIWaypointV2CameraActuatorParam alloc] init];
    DJIWaypointV2CameraFocusModeParam *focusModeParam = [[DJIWaypointV2CameraFocusModeParam alloc] init];
    focusModeParam.focusModeType = (DJIWaypointV2CameraFocusModeType)mode;
    cameraActuatorParam.operationType = DJIWaypointV2ActionActuatorCameraOperationTypeFocusMode;
    cameraActuatorParam.focusModeParam = focusModeParam;
    res.cameraActuatorParam = cameraActuatorParam;
    return res;
}

/**
 * 矩形对焦执行器
 * point：对应屏幕起点
 * width, height 对应区域大小
 */
- (DJIWaypointV2Actuator *)getCameraRectFocusActuatorWithCameraIndex:(NSUInteger)cameraIndex {
    DJIWaypointV2Actuator *res = [[DJIWaypointV2Actuator alloc] init];
    res.type = DJIWaypointV2ActionActuatorTypeCamera;
    res.actuatorIndex = cameraIndex;
    DJIWaypointV2CameraActuatorParam *cameraActuatorParam = [[DJIWaypointV2CameraActuatorParam alloc] init];
    DJIWaypointV2CameraFocusParam *focusParam = [[DJIWaypointV2CameraFocusParam alloc] init];
    DJIWaypointV2CameraFocusRectangleTargetParam *rectangleTargetParam = [[DJIWaypointV2CameraFocusRectangleTargetParam alloc] init];
    CGPoint point = {0.25, 0.25};
    rectangleTargetParam.referencePoint = point;
    rectangleTargetParam.height = 0.5;
    rectangleTargetParam.width = 0.5;
    focusParam.focusRegionType = DJIWaypointV2CameraFocusRegionType_Rectangle;
    focusParam.rectangleTargetParam = rectangleTargetParam;
    cameraActuatorParam.operationType = DJIWaypointV2ActionActuatorCameraOperationTypeFocus;
    cameraActuatorParam.focusParam = focusParam;
    res.cameraActuatorParam = cameraActuatorParam;
    return res;
}

- (IBAction)OnStartPathShootingButtonClicked:(id)sender {
    DJIWaypointV2Action *res = [[DJIWaypointV2Action alloc] init];
    res.trigger = [self getSimpleReachPointTriggerWithPointIndex:0];
    DJIWaypointV2Actuator* actuator = [[DJIWaypointV2Actuator alloc] init];
    actuator.type = DJIWaypointV2ActionActuatorTypeGimbal;
    actuator.actuatorIndex = 0;
    DJIWaypointV2GimbalActuatorParam* gimbalParam = [[DJIWaypointV2GimbalActuatorParam alloc] init];
    gimbalParam.operationType = DJIWaypointV2ActionActuatorGimbalOperationTypePathShooting;
    DJIWaypointV2GimbalPathShootingParam *pathShootingParam = [[DJIWaypointV2GimbalPathShootingParam alloc] init];
    pathShootingParam.pathShootingType = DJIWaypointV2GimbalStartPathShooting;
    pathShootingParam.startPathShootingParam = [self getStartFiveWayPoseParamWithGimbalPitch:0];
    gimbalParam.pathShootingParam =pathShootingParam;
    actuator.gimbalActuatorParam = gimbalParam;
    res.actuator = actuator;
    res.actionId = self.actionList.count;
    [self.actionList addObject:res];
    ShowResult(@"current action count:%d",self.actionList.count);
}

- (IBAction)OnStopPathShootingButtonClicked:(id)sender {
    DJIWaypointV2Action *res = [[DJIWaypointV2Action alloc] init];
    res.trigger = [self getSimpleReachPointTriggerWithPointIndex:1];
    DJIWaypointV2Actuator* actuator = [[DJIWaypointV2Actuator alloc] init];
    actuator.type = DJIWaypointV2ActionActuatorTypeGimbal;
    actuator.actuatorIndex = 0;
    DJIWaypointV2GimbalActuatorParam* gimbalParam = [[DJIWaypointV2GimbalActuatorParam alloc] init];
    gimbalParam.operationType = DJIWaypointV2ActionActuatorGimbalOperationTypePathShooting;
    DJIWaypointV2GimbalPathShootingParam *pathShootingParam = [[DJIWaypointV2GimbalPathShootingParam alloc] init];
    pathShootingParam.pathShootingType = DJIWaypointV2GimbalStopPathShooting;
    pathShootingParam.stopPathShootingParam = [self getStopFiveWayPoseParam];
    gimbalParam.pathShootingParam =pathShootingParam;
    actuator.gimbalActuatorParam = gimbalParam;
    res.actuator = actuator;
    res.actionId = self.actionList.count;
    [self.actionList addObject:res];
    ShowResult(@"current action count:%d",self.actionList.count);
}

/**
 * 开始五向摆拍Param
 */
- (DJIWaypointV2GimbalStartPathShootingParam *)getStartFiveWayPoseParamWithGimbalPitch:(float)gimbalPitch {
    DJIWaypointV2GimbalStartPathShootingParam *startPathShootingParam = [[DJIWaypointV2GimbalStartPathShootingParam alloc] init];
    NSMutableArray<DJIWaypointV2GimbalPathPointInfo *> *pointInfo = [[NSMutableArray alloc] init];
    DJIWaypointV2GimbalPathPointInfo *pointInfoSingleOne = [[DJIWaypointV2GimbalPathPointInfo alloc] init];
    pointInfoSingleOne.stayTime = 0;
    pointInfoSingleOne.eulerPitch = gimbalPitch;
    [pointInfo addObject:pointInfoSingleOne];
    DJIWaypointV2GimbalPathPointInfo *pointInfoSingleTwo = [[DJIWaypointV2GimbalPathPointInfo alloc] init];
    pointInfoSingleTwo.stayTime = 0;
    pointInfoSingleTwo.eulerPitch = -90;
    pointInfoSingleTwo.eulerRoll = 90 + gimbalPitch;
    [pointInfo addObject:pointInfoSingleTwo];
    DJIWaypointV2GimbalPathPointInfo *pointInfoSingleThree = [[DJIWaypointV2GimbalPathPointInfo alloc] init];
    pointInfoSingleThree.stayTime = 0;
    pointInfoSingleThree.eulerPitch = -180 - gimbalPitch;
    [pointInfo addObject:pointInfoSingleThree];
    DJIWaypointV2GimbalPathPointInfo *pointInfoSingleFour = [[DJIWaypointV2GimbalPathPointInfo alloc] init];
    pointInfoSingleFour.stayTime = 0;
    pointInfoSingleFour.eulerPitch = -90;
    pointInfoSingleFour.eulerRoll = -(90 + gimbalPitch);
    [pointInfo addObject:pointInfoSingleFour];
    DJIWaypointV2GimbalPathPointInfo *pointInfoSingleFive = [[DJIWaypointV2GimbalPathPointInfo alloc] init];
    pointInfoSingleFive.stayTime = 0;
    pointInfoSingleFive.eulerPitch = -90;
    [pointInfo addObject:pointInfoSingleFive];
    startPathShootingParam.pathCycleMode = DJIWaypointV2ActionActuatorGimbalPathCycleModeUnlimited;
    startPathShootingParam.pointInfo = pointInfo.copy;
    startPathShootingParam.pointNum = 5;
    return startPathShootingParam;
}

/**
 * 停止五向摆拍Param
 */
- (DJIWaypointV2GimbalStopPathShootingParam *)getStopFiveWayPoseParam {
    DJIWaypointV2GimbalStopPathShootingParam *stopPathShootingParam = [[DJIWaypointV2GimbalStopPathShootingParam alloc] init];
    stopPathShootingParam.pathCycleMode = DJIWaypointV2ActionActuatorGimbalPathCycleModeUnlimited;
    return stopPathShootingParam;
}

@end
