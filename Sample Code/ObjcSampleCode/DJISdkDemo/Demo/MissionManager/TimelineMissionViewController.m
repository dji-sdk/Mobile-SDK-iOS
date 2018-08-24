//
//  TimelineMissionViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates the process to start a timeline mission.
 *
 *  CAUTION: it is highly recommended to run this sample using the simulator.
 */
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"
#import "TimelineMissionViewController.h"

#define ONE_METER_OFFSET (0.00000901315)

@interface TimelineMissionViewController ()

@property(nonatomic, strong) NSMutableArray* actions;

@end

@implementation TimelineMissionViewController

@synthesize homeLocation = _homeLocation;

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Timeline mission required the home location before initializing the mission
    // Therefore, we disable the prepare button until the home location is valid
    [self.prepareButton setEnabled:CLLocationCoordinate2DIsValid(self.homeLocation)];
    self.downloadButton.enabled = NO;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[DJISDKManager missionControl] removeListener:self];
}

-(void)setHomeLocation:(CLLocationCoordinate2D)homeLocation {
    _homeLocation = homeLocation;
    [self.prepareButton setEnabled:CLLocationCoordinate2DIsValid(self.homeLocation)];
    self.downloadButton.enabled = NO;
}

- (void)initializeActionsWithCompletion:(void(^)())completion {
    if (self.actions == nil) {
        self.actions = [[NSMutableArray alloc] init];
    }
    
    WeakRef(target);
    
    // Step 1: take off from the ground
    void (^addTakeOffAction)() = ^() {
        DJITakeOffAction* takeoffAction = [[DJITakeOffAction alloc] init];
        [target.actions addObject:takeoffAction];
    };
    
    void (^addHotpointAction)(float radius, float angularVelocity) = ^(float radius, float angularVelocity) {
        DJIHotpointMission* hotpointMission = [[DJIHotpointMission alloc] init];
        hotpointMission.hotpoint = _homeLocation;
        hotpointMission.altitude = 15;
        hotpointMission.radius = radius;
        hotpointMission.angularVelocity = angularVelocity;
        hotpointMission.startPoint = DJIHotpointStartPointNearest;
        hotpointMission.heading = DJIHotpointHeadingTowardHotpoint;
        DJIHotpointAction* hotpointAction = [[DJIHotpointAction alloc] initWithMission:hotpointMission];
        [self.actions addObject:hotpointAction];
    };
    
    // Step 3: shoot 3 photos with 5 seconds interval between each
    void (^addShootPhotoAction)() = ^() {
        DJIShootPhotoAction* shootPhotoAction = [[DJIShootPhotoAction alloc] initWithPhotoCount:3 timeInterval:10.0 waitUntilFinish:YES];
        [target.actions addObject:shootPhotoAction];
    };
    
    // Step 4: start recording video
    void (^addRecordVideoAction)() = ^() {
        DJIRecordVideoAction* recordVideoAction = [[DJIRecordVideoAction alloc] initWithStartRecordVideo];
        [target.actions addObject:recordVideoAction];
    };
    
    // Step 5: start a waypoint mission while the aircraft is still recording the video
    void (^addWaypointMission)() = ^() {
        DJIWaypointMission *waypointAction = [target initializeWaypointMissonStep];
        [target.actions addObject:waypointAction];
    };
    
    // Step 6: go to the target location
    void (^addGoToAction)() = ^() {
        DJIGoToAction* gotoAction = [[DJIGoToAction alloc] initWithCoordinate:CLLocationCoordinate2DMake(target.homeLocation.latitude + 40 * ONE_METER_OFFSET, target.homeLocation.longitude + 50 * ONE_METER_OFFSET) altitude:40.0];
        [target.actions addObject:gotoAction];
    };
    
    // Step 2: reset the gimbal to horizontal angle
    void (^addGimbalAttitudeAction)() = ^() {
        DJIGimbalAttitude atti = {-10, 0, 0};
        DJIGimbalAttitudeAction* gimbalAttiAction = [[DJIGimbalAttitudeAction alloc] initWithAttitude:atti];
        [target.actions addObject:gimbalAttiAction];
    };
    
    // Step 7: stop the recording when the waypoint mission is finished
    void (^addStopRecordVideoAction)() = ^() {
        DJIRecordVideoAction* recordVideoAction = [[DJIRecordVideoAction alloc] initWithStopRecordVideo];
        [target.actions addObject:recordVideoAction];
    };
    
    // Step 8: go back home
    void (^addGoHomeAction)() = ^() {
        DJIGoHomeAction* gohomeAction = [[DJIGoHomeAction alloc] init];
        [target.actions addObject:gohomeAction];
    };
    
    double radius = 10;
    [DJIHotpointMissionOperator getMaxAngularVelocityForRadius:radius withCompletion:^(float angularVelocity, NSError * _Nullable error) {
        addTakeOffAction();
        
        if (!error) {
            addHotpointAction(radius, angularVelocity);
        }
        
        addShootPhotoAction();
        addRecordVideoAction();
        addWaypointMission();
        addGoToAction();
        addGimbalAttitudeAction();
        addStopRecordVideoAction();
        addGoHomeAction();
        
        if (completion) {
            completion();
        }
    }];
}

- (IBAction)onPrepareButtonClicked:(id)sender
{
    WeakRef(target);
    [self initializeActionsWithCompletion:^{
        NSError *error = [[DJISDKManager missionControl] scheduleElements:target.actions];
        if (error) {
            ShowResult(@"Schedule Timeline Actions Failed:%@", error.description);
        } else {
            ShowResult(@"Actions schedule succeed!");
        }
    }];
}

- (IBAction)onStartButtonClicked:(id)sender
{
    
    [[DJISDKManager missionControl] addListener:self
                    toTimelineProgressWithBlock:^(DJIMissionControlTimelineEvent event, id<DJIMissionControlTimelineElement>  _Nullable element, NSError * _Nullable error, id  _Nullable info)
     {
         NSMutableString *statusStr = [NSMutableString new];
         [statusStr appendFormat:@"Current Event:%@\n", [[self class] timelineEventString:event]];
         [statusStr appendFormat:@"Element:%@\n", [element description]];
         [statusStr appendFormat:@"Info:%@\n", info];
         if (error) {
         	[statusStr appendFormat:@"Error:%@\n", error.description];
         }
         self.statusLabel.text = statusStr;
         if (error) {
            [[DJISDKManager missionControl] stopTimeline];
         	[[DJISDKManager missionControl] unscheduleEverything];
         }
     }];
    
    [[DJISDKManager missionControl] startTimeline];
}

- (IBAction)onStopButtonClicked:(id)sender
{
    [[DJISDKManager missionControl] stopTimeline];
    [[DJISDKManager missionControl] unscheduleEverything];
    [[DJISDKManager missionControl] removeListener:self];
}

- (IBAction)onPauseButtonClicked:(id)sender
{
    [[DJISDKManager missionControl] pauseTimeline];
}

- (IBAction)onResumeButtonClicked:(id)sender
{
    [[DJISDKManager missionControl] resumeTimeline];
}


- (DJIWaypointMission*)initializeWaypointMissonStep {
    DJIMutableWaypointMission* mission = [[DJIMutableWaypointMission alloc] init];
    
    // prepare waypoint
    CLLocationCoordinate2D northPoint;
    CLLocationCoordinate2D eastPoint;
    CLLocationCoordinate2D southPoint;
    CLLocationCoordinate2D westPoint;
    
    CLLocationDegrees currentLatitude = self.aircraftLocation.latitude;
    CLLocationDegrees currentLongitude = self.aircraftLocation.longitude;
    
    northPoint = CLLocationCoordinate2DMake(currentLatitude + 10 * ONE_METER_OFFSET, currentLongitude);
    eastPoint = CLLocationCoordinate2DMake(currentLatitude, currentLongitude + 10 * ONE_METER_OFFSET);
    southPoint = CLLocationCoordinate2DMake(currentLatitude - 10 * ONE_METER_OFFSET, currentLongitude);
    westPoint = CLLocationCoordinate2DMake(currentLatitude, currentLongitude - 10 * ONE_METER_OFFSET);
    
    DJIWaypoint* northWP = [[DJIWaypoint alloc] initWithCoordinate:northPoint];
    northWP.altitude = 10.0;
    DJIWaypoint* eastWP = [[DJIWaypoint alloc] initWithCoordinate:eastPoint];
    eastWP.altitude = 20.0;
    DJIWaypoint* southWP = [[DJIWaypoint alloc] initWithCoordinate:southPoint];
    southWP.altitude = 30.0;
    DJIWaypoint* westWP = [[DJIWaypoint alloc] initWithCoordinate:westPoint];
    westWP.altitude = 40.0;
    
    [mission addWaypoint:northWP];
    [mission addWaypoint:eastWP];
    [mission addWaypoint:southWP];
    [mission addWaypoint:westWP];
    
    [mission setFinishedAction:DJIWaypointMissionFinishedNoAction];
    
    DJIWaypointMission* action = [[DJIWaypointMission alloc] initWithMission:mission];
    
    return action;
}

+ (NSString*)timelineEventString:(DJIMissionControlTimelineEvent)event
{
    NSString *eventString = @"N/A";
    
    switch (event) {
        case DJIMissionControlTimelineEventPaused:
            eventString = @"Paused";
            break;
        case DJIMissionControlTimelineEventResumed:
            eventString = @"Resumed";
            break;
        case DJIMissionControlTimelineEventStarted:
            eventString = @"Started";
            break;
        case DJIMissionControlTimelineEventStopped:
            eventString = @"Stopped";
            break;
        case DJIMissionControlTimelineEventFinished:
            eventString = @"Finished";
            break;
        case DJIMissionControlTimelineEventStopError:
            eventString = @"Stop Error";
            break;
        case DJIMissionControlTimelineEventPauseError:
            eventString = @"Pause Error";
            break;
        case DJIMissionControlTimelineEventProgressed:
            eventString = @"Progressed";
            break;
        case DJIMissionControlTimelineEventStartError:
            eventString = @"Start Error";
            break;
        case DJIMissionControlTimelineEventResumeError:
            eventString = @"Resume Error";
            break;
        case DJIMissionControlTimelineEventUnknown:
            eventString = @"Unknown";
            break;
        default:
            break;
    }
    return eventString;
}

@end
