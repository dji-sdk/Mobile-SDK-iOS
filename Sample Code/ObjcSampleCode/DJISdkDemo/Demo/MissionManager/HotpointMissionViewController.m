//
//  HotpointMissionViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates the process to start a hotpoint mission. In this demo, the aircraft will use the home location as the hotpoint. 
 *  Therefore, before the home location is ready, the prepare button will not be enabled.
 *
 *  CAUTION: it is highly recommended to run this sample using the simulator.
 */
#import <DJISDK/DJISDK.h>
#import "HotpointMissionViewController.h"
#import "DemoAlertView.h"
#import "DemoUtilityMacro.h"

@interface HotpointMissionViewController ()

@property(nonatomic, weak)DJIHotpointMissionOperator *hotpointOperator;

@end

@implementation HotpointMissionViewController

@synthesize homeLocation = _homeLocation;

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Hotpoint mission required the aircraft location before initializing the mission
    // Therefore, we disable the prepare button until the aircraft location is valid
    [self.prepareButton setEnabled:CLLocationCoordinate2DIsValid(self.homeLocation)];
    self.hotpointOperator = [[DJISDKManager missionControl] hotpointMissionOperator];
}

-(void)setHomeLocation:(CLLocationCoordinate2D)homeLocation {
    _homeLocation = homeLocation;
	self.prepareButton.enabled = NO;
}


/**
 *  Prepare the hotpoint mission. 
 */
-(DJIMission*) initializeMission {
    DJIHotpointMission* mission = [[DJIHotpointMission alloc] init];
    mission.hotpoint = self.homeLocation;
    mission.altitude = 20.0;
    mission.radius = 10.0;
    mission.angularVelocity = 5.0;
    
    return mission;
}

#pragma mark - Execution

- (IBAction)onStartButtonClicked:(id)sender
{
    WeakRef(target);
    [self.hotpointOperator startMission:(DJIHotpointMission*)[self initializeMission] withCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"ERROR: startMissionExecutionWithCompletion:%@", error.description);
            [target.hotpointOperator removeListenerOfEvents:target];

        }
        else {
            ShowResult(@"SUCCESS: startMissionExecutionWithCompletion");
        }
    }];
    
    [self.hotpointOperator addListenerToEvents:self withQueue:nil andBlock:^(DJIHotpointMissionEvent * _Nonnull event) {
        [target showHotpointMissionStatus:event];
    }];
}

- (IBAction)onStopButtonClicked:(id)sender
{
    WeakRef(target);
    [self.hotpointOperator stopMissionWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"ERROR: stopMissionExecutionWithCompletion:. %@", error.description);
        }
        else {
            ShowResult(@"SUCCESS: stopMissionExecutionWithCompletion");
            [target.hotpointOperator removeListenerOfEvents:target];
        }
    }];
}

- (IBAction)onDownloadButtonClicked:(id)sender
{
    WeakRef(target);
    [self.hotpointOperator getExecutingMissionWithCompletion:^(DJIHotpointMission * _Nullable mission, NSError * _Nullable error) {
        if (error) {
            ShowResult(@"get Executing Mission Error:%@", error.description);
        } else {
            [target showHotpointMission:mission];
        }
    }];
}

- (IBAction)onPauseButtonClicked:(id)sender
{
 	[self.hotpointOperator pauseMissionWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"ERROR: pauseMissionWithCompletion:%@", error.description);
        }
        else {
            ShowResult(@"SUCCESS: pauseMissionWithCompletion");
        }
    }];
}

- (IBAction)onResumeButtonClicked:(id)sender
{
    [self.hotpointOperator resumeMissionWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"ERROR: resumeMissionWithCompletion: %@", error.description);
        }
        else {
            ShowResult(@"SUCCESS: resumeMissionWithCompletion ");
        }
    }];
}


/**
 *  Method to display the current status of the hotpoint mission.
 */
-(void) showHotpointMissionStatus:(DJIHotpointMissionEvent*)event {
    
    NSMutableString* statusStr = [NSMutableString new];
    [statusStr appendFormat:@"previousState:%@\n", [[self class] descriptionForState:event.previousState]];
    [statusStr appendFormat:@"currentState:%@\n", [[self class] descriptionForState:event.currentState]];
    [statusStr appendFormat:@"Current radius: %f\n", event.radius];
    
    if (event.error) {
        ShowResult(@"Hotpoint Mission Executing Error:%@", event.error.description);
        [self.hotpointOperator removeListenerOfEvents:self];
    }
    
    [self.statusLabel setText:statusStr];
}

-(void) showHotpointMission:(DJIHotpointMission*)hpMission {
    NSMutableString* missionInfo = [NSMutableString stringWithString:@"The hotpoint mission is downloaded successfully: \n"];
    [missionInfo appendString:[NSString stringWithFormat:@"Hotpoint: (%f, %f)\n", hpMission.hotpoint.latitude, hpMission.hotpoint.longitude]];
    [missionInfo appendString:[NSString stringWithFormat:@"Altitude: %f\n", hpMission.altitude]];
    [missionInfo appendString:[NSString stringWithFormat:@"Radius: %f\n", hpMission.radius]];
    [missionInfo appendString:[NSString stringWithFormat:@"AngularVelocity: %ld\n", (long)hpMission.angularVelocity]];
    [self.statusLabel setText:missionInfo];

}

+(NSString *)descriptionForState:(DJIHotpointMissionState)state {
    switch (state) {
        case DJIHotpointMissionStateExecutionPaused:
            return @"Paused";
        case DJIHotpointMissionStateUnknown:
            return @"Unknown";
        case DJIHotpointMissionStateExecuting:
            return @"Executing";
        case DJIHotpointMissionStateRecovering:
            return @"Recovering";
        case DJIHotpointMissionStateDisconnected:
            return @"Disconnected";
        case DJIHotpointMissionStateNotSupported:
            return @"NotSupported";
        case DJIHotpointMissionStateReadyToStart:
            return @"ReadyToStart";
        case DJIHotpointMissionStateExecutingInitialPhase:
            return @"Initial Phase";
    }
    
    return nil;
}


@end
