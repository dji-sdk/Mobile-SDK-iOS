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

#define RUNNING_DISTANCE_IN_METER   (10)
#define ONE_METER_OFFSET            (0.00000901315)

@interface FollowMeMissionViewController ()

@property (nonatomic, strong) NSTimer* updateTimer;
@property (nonatomic) CLLocationCoordinate2D currentTarget;
@property (nonatomic) CLLocationCoordinate2D target1;
@property (nonatomic) CLLocationCoordinate2D target2;
@property (nonatomic) CLLocationCoordinate2D prevTarget;
@property (nonatomic) BOOL isGoingToNorth;

@end

@implementation FollowMeMissionViewController

@synthesize aircraftLocation = _aircraftLocation;

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Follow-me mission required the aircraft location before initializing the mission
    // Therefore, we disable the prepare button until the aircraft location is valid
    [self.prepareButton setEnabled:CLLocationCoordinate2DIsValid(self.homeLocation)];
}

-(void)setAircraftLocation:(CLLocationCoordinate2D)aircraftLocation {
    _aircraftLocation = aircraftLocation;
    [self.prepareButton setEnabled:CLLocationCoordinate2DIsValid(self.aircraftLocation)];
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
    [DJIFollowMeMission updateFollowMeCoordinate:target withCompletion:nil];
    
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

#pragma mark - Override Methods
-(void)missionManager:(DJIMissionManager *)manager missionProgressStatus:(DJIMissionProgressStatus *)missionProgress {
    if ([missionProgress isKindOfClass:[DJIFollowMeMissionStatus class]]) {
        DJIFollowMeMissionStatus* fmStatus = (DJIFollowMeMissionStatus*)missionProgress;
        
        [self showFollowMeMissionStatus:fmStatus];
    }
}

/**
 *  Method to display the current status of the follow-me mission.
 */
-(void) showFollowMeMissionStatus:(DJIFollowMeMissionStatus*)fmStatus {
    NSMutableString* statusStr = [NSMutableString stringWithFormat:@"HorizontalDistance: %f\n", fmStatus.horizontalDistance];
    [statusStr appendFormat:@"ExecutionState: %u", (unsigned int)fmStatus.executionState];
    
    [self.statusLabel setText:statusStr];
}

-(void)mission:(DJIMission *)mission didDownload:(NSError *)error {
    if (error) return;
    if ([mission isKindOfClass:[DJIFollowMeMission class]]) {
        // Display information of the downloaded follow-me mission.
        [self showFollowMeMission:(DJIFollowMeMission*)mission];
    }
}

-(void) showFollowMeMission:(DJIFollowMeMission*)fmMission {
    NSMutableString* missionInfo = [NSMutableString stringWithString:@"The follow-me mission is downloaded successfully: \n"];
    [missionInfo appendFormat:@"Follow-me Coordinate: (%f, %f)\n", fmMission.followMeCoordinate.latitude, fmMission.followMeCoordinate.longitude];
    [missionInfo appendFormat:@"Altitude: %f\n", fmMission.followMeAltitude];
    [missionInfo appendString:[NSString stringWithFormat:@"Heading: %u\n", (unsigned int)fmMission.heading]];
    [self.statusLabel setText:missionInfo];
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

-(void)missionWillPause {
    [self pauseUpdateTimer];
}

-(void)missionDidResume:(NSError *)error {
    // Only resume the updating if the mission is resumed successfully.
    if (error) return;
    
    [self resumeUpdateTimer];
}

-(void)missionDidStop:(NSError *)error {
    [self stopUpdateTimer];
}

@end
