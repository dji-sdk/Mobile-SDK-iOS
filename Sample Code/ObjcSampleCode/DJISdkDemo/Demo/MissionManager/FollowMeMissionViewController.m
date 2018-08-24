//
//  FollowMeMissionViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates the process to start a follow-me mission. In this demo, a running man is simulated. The running man starts
 *  from the aircraft's initial position. The man first goes north for RUNNING_DISTANCE_IN_METER meters.
 *  Once reaching the target, the man runs backward. After the man reaches the start point, he will repeat again. The aircraft will 
 *  follow the running man during the demo.
 *
 *  In order to make the follow-me mission take effect, user needs to call updateFollowMeCoordinate:withCompletion: continously. The
 *  recommended frequency is 10 Hz.
 *
 *  CAUTION: the follow-me mission cannot be executed in the simulator environment. Therefore, when user try to test this sample outdoor, 
 *  please ensure that there is enough space for the aircraft to follow the target, or user can adjust RUNNING_DISTANCE_IN_METER.
 */
#import <DJISDK/DJISDK.h>
#import "FollowMeMissionViewController.h"
#import "DemoAlertView.h"
#import "DemoUtilityMacro.h"

#define RUNNING_DISTANCE_IN_METER   (10)
#define ONE_METER_OFFSET            (0.00000901315)

@interface FollowMeMissionViewController ()

@property (nonatomic, strong) NSTimer* updateTimer;
@property (nonatomic) CLLocationCoordinate2D currentTarget;
@property (nonatomic) CLLocationCoordinate2D target1;
@property (nonatomic) CLLocationCoordinate2D target2;
@property (nonatomic) CLLocationCoordinate2D prevTarget;
@property (nonatomic) BOOL isGoingToNorth;
@property (nonatomic, weak) DJIFollowMeMissionOperator *followMeOperator;

@end

@implementation FollowMeMissionViewController

@synthesize aircraftLocation = _aircraftLocation;

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Follow-me mission required the aircraft location before initializing the mission
    // Therefore, we disable the prepare button until the aircraft location is valid
    self.followMeOperator = [[DJISDKManager missionControl] followMeMissionOperator];
}

-(void)setAircraftLocation:(CLLocationCoordinate2D)aircraftLocation {
    _aircraftLocation = aircraftLocation;
    self.prepareButton.enabled = NO;
    self.pauseButton.enabled = NO;
    self.resumeButton.enabled = NO;
    self.downloadButton.enabled = NO;
}

-(DJIMission*) initializeMission {
    DJIFollowMeMission* mission = [[DJIFollowMeMission alloc] init];
    mission.followMeCoordinate = self.aircraftLocation;
    mission.heading = DJIFollowMeHeadingTowardFollowPosition;
    
    return mission;
}

/**
 *  According to the description for updateFollowMeCoordinate:withCompletion:, we need to update the follow-me target
 *  continuously. Therefore, we use a timer to update the coordinate. 
 *  The updating frequency is 10Hz. The offset for each interval is 0.1 meter. Therefore, the following target is moving
 *  at speed 1.0 m/s.
 */
-(void) startUpdateTimer {
    if (self.updateTimer == nil) {
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onUpdateTimerTicked:) userInfo:nil repeats:YES];
    }
    
    [self.updateTimer fire];
}

-(void) pauseUpdateTimer {
    if (self.updateTimer) {
        [self.updateTimer setFireDate:[NSDate distantFuture]];
    }
}

-(void) resumeUpdateTimer {
    if (self.updateTimer) {
        [self.updateTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    }
}

-(void) stopUpdateTimer {
    if (self.updateTimer) {
        [self.updateTimer invalidate];
        self.updateTimer = nil;
    }
}

-(void) onUpdateTimerTicked:(id)sender
{
    float offset = 0.0;
    if (self.currentTarget.latitude == self.target1.latitude) {
        offset = -0.1 * ONE_METER_OFFSET;
    }
    else {
        offset = 0.1 * ONE_METER_OFFSET;
    }
    
    CLLocationCoordinate2D target = CLLocationCoordinate2DMake(self.prevTarget.latitude + offset, self.prevTarget.longitude);
    [self.followMeOperator updateFollowMeCoordinate:target];
    
    self.prevTarget = target;
    
    [self changeDirectionIfFarEnough];
}

-(void) changeDirectionIfFarEnough {
    CLLocationDistance distance = [FollowMeMissionViewController calculateDistanceBetweenPoint:self.prevTarget andPoint:self.currentTarget];

    // close enough. Change the direction.
    if (distance < 0.2) {
        if (self.currentTarget.latitude == self.target1.latitude) {
            self.currentTarget = self.target2;
        }
        else {
            self.currentTarget = self.target1;
        }
    }
}

+ (CLLocationDistance) calculateDistanceBetweenPoint:(CLLocationCoordinate2D)point1 andPoint:(CLLocationCoordinate2D)point2 {
    CLLocation* location1 = [[CLLocation alloc] initWithLatitude:point1.latitude longitude:point1.longitude];
    CLLocation* location2 = [[CLLocation alloc] initWithLatitude:point2.latitude longitude:point2.longitude];
    
    return [location1 distanceFromLocation:location2];
}

#pragma mark - Execution

- (IBAction)onStartButtonClicked:(id)sender
{
    WeakRef(target);
    DJIFollowMeMission* mission = (DJIFollowMeMission*)[self initializeMission];
    [self.followMeOperator startMission:mission withCompletion:^(NSError * _Nullable error) {
       	if (error) {
            ShowResult(@"Start Mission Failed:%@", error);
        } else {
            [target missionDidStart:error];
        }
    }];
    
    [self.followMeOperator addListenerToEvents:self withQueue:nil andBlock:^(DJIFollowMeMissionEvent * _Nonnull event) {
        [target onReciviedFollowMeEvent:event];
    }];
}

- (IBAction)onStopButtonClicked:(id)sender
{
    WeakRef(target);
    [self.followMeOperator stopMissionWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"Stop Mission Failed:%@", error.description);
        } else {
            [target startUpdateTimer];
            [target.followMeOperator removeListener:self];
        }
    }];
}


-(void)onReciviedFollowMeEvent:(DJIFollowMeMissionEvent*)event
{
    NSMutableString *statusStr = [NSMutableString new];
    [statusStr appendFormat:@"previousState:%@\n", [[self class] descriptionForState:event.previousState]];
    [statusStr appendFormat:@"currentState:%@\n", [[self class] descriptionForState:event.currentState]];
    [statusStr appendFormat:@"distanceToFollowMeCoordinate:%f\n", event.distanceToFollowMeCoordinate];
    
    if (event.error) {
        [statusStr appendFormat:@"Mission Executing Error:%@", event.error.description];
    }
    [self.statusLabel setText:statusStr];
}

-(void)missionDidStart:(NSError *)error {
    // Only starts the updating if the mission is started successfully.
    if (error) return;
    
    self.prevTarget = self.aircraftLocation;
    self.target1 = self.aircraftLocation;
    self.target2 = CLLocationCoordinate2DMake(self.target1.latitude + RUNNING_DISTANCE_IN_METER * ONE_METER_OFFSET, self.target1.longitude);
    self.currentTarget = self.target2;
    
    [self startUpdateTimer];
}

+(NSString *)descriptionForState:(DJIFollowMeMissionState)state {
    switch (state) {
        case DJIFollowMeMissionStateUnknown:
            return @"Unknown";
        case DJIFollowMeMissionStateExecuting:
            return @"Executing";
        case DJIFollowMeMissionStateRecovering:
            return @"Recovering";
        case DJIFollowMeMissionStateDisconnected:
            return @"Disconnected";
        case DJIFollowMeMissionStateNotSupported:
            return @"NotSupported";
        case DJIFollowMeMissionStateReadyToStart:
            return @"ReadyToStart";
    }
}

@end
