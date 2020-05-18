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

@property (nonatomic, assign) BOOL configFinished;
@property (nonatomic, strong) NSMutableArray <DJIWaypointV2 *> *waypoints;
@property (nonatomic, strong) NSMutableArray *waypointAnnotations;

@property (nonatomic, strong) DJIFlightControllerState *currentState;
@property (nonatomic, strong) DJIMutableWaypointV2Mission *waypointMission;
@property (nonatomic, assign) CLLocationCoordinate2D aircraftLocation;
@property (nonatomic, strong) DJIAircraftAnnotation *aircraftAnnotation;
@property (nonatomic, strong) DJIMapView *djiMapView;

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

@end
