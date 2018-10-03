//
//  WaypointMissionViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates the process to start a waypoint mission. In this demo,
 *  the aircraft will go to four waypoints, shoot photos and record videos.
 *  The flight speed can be controlled by calling the class method
 *  setAutoFlightSpeed:withCompletion:. In this demo, when the aircraft will
 *  change the speed right after it reaches the second point (point with index 1).
 *
 *  CAUTION: it is highly recommended to run this sample using the simulator.
 */
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"
#import "WaypointMissionViewController.h"

#define ONE_METER_OFFSET (0.00000901315)

@interface WaypointMissionViewController ()

@property (nonatomic) DJIWaypointMissionOperator *wpOperator;
@property (nonatomic) DJIWaypointMission *downloadMission;

@end

@implementation WaypointMissionViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.wpOperator = [[DJISDKManager missionControl] waypointMissionOperator];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.wpOperator removeListenerOfExecutionEvents:self];
}

/**
 *  Because waypoint mission is refactored and uses a different interface design
 *  from the other missions, we need to override the UI actions.
 */
-(void)onPrepareButtonClicked:(id)sender {
    DJIWaypointMission *wp = (DJIWaypointMission *)[self initializeMission];

    NSError *error = [self.wpOperator loadMission:wp];
    if (error) {
        ShowResult(@"Prepare Mission Failed:%@", error);
        return;
    }
    
    WeakRef(target);
    [self.wpOperator addListenerToUploadEvent:self withQueue:nil andBlock:^(DJIWaypointMissionUploadEvent * _Nonnull event) {
        WeakReturn(target);
        [target onUploadEvent:event];
    }];
    
    [self.wpOperator uploadMissionWithCompletion:^(NSError * _Nullable error) {
        WeakReturn(target);
        if (error) {
            ShowResult(@"ERROR: uploadMission:withCompletion:. %@", error.description);
        }
        else {
            ShowResult(@"SUCCESS: uploadMission:withCompletion:.");
        }
    }];
}

- (IBAction)onStartButtonClicked:(id)sender {
    
    WeakRef(target);
    [self.wpOperator addListenerToExecutionEvent:self withQueue:nil andBlock:^(DJIWaypointMissionExecutionEvent * _Nonnull event) {
        [target showWaypointMissionProgress:event];
    }];
    
    [self.wpOperator startMissionWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"ERROR: startMissionWithCompletion:. %@", error.description);
        }
        else {
            ShowResult(@"SUCCESS: startMissionWithCompletion:. ");
        }
        [self missionDidStart:error];
    }];
}

-(void)onStopButtonClicked:(id)sender {
    WeakRef(target);
    [self.wpOperator stopMissionWithCompletion:^(NSError * _Nullable error) {
        WeakReturn(target);
        if (error) {
            ShowResult(@"ERROR: stopMissionExecutionWithCompletion:. %@", error.description);
        }
        else {
            ShowResult(@"SUCCESS: stopMissionExecutionWithCompletion:. ");
        }
        [target missionDidStop:error];
    }];
}

-(void)onDownloadButtonClicked:(id)sender {
    
    self.downloadMission = nil;
    WeakRef(target);
    [self.wpOperator addListenerToDownloadEvent:self
                                      withQueue:nil
                                       andBlock:^(DJIWaypointMissionDownloadEvent * _Nonnull event)
     {

         if (event.progress.downloadedWaypointIndex == event.progress.totalWaypointCount) {
             ShowResult(@"SUCCESS: the waypoint mission is downloaded. ");
             target.downloadMission = target.wpOperator.loadedMission;
             [target.wpOperator removeListenerOfDownloadEvents:target];
             [target.progressBar setHidden:YES];
             [target mission:target.downloadMission didDownload:event.error];
         }
         else if (event.error) {
             ShowResult(@"Download Mission Failed:%@", event.error);
             [target.progressBar setHidden:YES];
             [target mission:target.downloadMission didDownload:event.error];
             [target.wpOperator removeListenerOfDownloadEvents:target];
         } else {
             [target.progressBar setHidden:NO];
             float progress = ((float)event.progress.downloadedWaypointIndex + 1) / (float)event.progress.totalWaypointCount;
             NSLog(@"Download Progress:%d%%", (int)(progress*100));
             [target.progressBar setProgress:progress];
         }
     }];
    
    [self.wpOperator downloadMissionWithCompletion:^(NSError * _Nullable error) {
        WeakReturn(target);
        if (error) {
            ShowResult(@"ERROR: downloadMissionWithCompletion:withCompletion:. %@", error.description);
        }
        else {
            ShowResult(@"SUCCESS: downloadMissionWithCompletion:withCompletion:.");
        }
    }];
}

-(void)onPauseButtonClicked:(id)sender {
    [self missionWillPause];
    [self.wpOperator pauseMissionWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"ERROR: pauseMissionWithCompletion:. %@", error.description);
        }
        else {
            ShowResult(@"SUCCESS: pauseMissionWithCompletion:. ");
        }
    }];
}

-(void)onResumeButtonClicked:(id)sender {
    WeakRef(target);
    [self.wpOperator resumeMissionWithCompletion:^(NSError * _Nullable error) {
        WeakReturn(target);
        if (error) {
            ShowResult(@"ERROR: resumeMissionWithCompletion:. %@", error.description);
        }
        else {
            ShowResult(@"SUCCESS: resumeMissionWithCompletion:. ");
        }
        [target missionDidResume:error];
    }];
}

/**
 *  Prepare the waypoint mission. The basic workflow is:
 *  1. Create an instance of DJIWaypointMission.
 *  2. Create coordinates.
 *  3. Use the coordinate to create an instance of DJIWaypoint.
 *  4. Add actions for each waypoint.
 *  5. Add the waypoints into the mission.
 */
-(DJIMission*) initializeMission {
    // Step 1: create mission
    DJIMutableWaypointMission* mission = [[DJIMutableWaypointMission alloc] init];
    mission.maxFlightSpeed = 15.0;
    mission.autoFlightSpeed = 4.0;


    // Step 2: prepare coordinates
    CLLocationCoordinate2D northPoint;
    CLLocationCoordinate2D eastPoint;
    CLLocationCoordinate2D southPoint;
    CLLocationCoordinate2D westPoint;
    northPoint = CLLocationCoordinate2DMake(self.homeLocation.latitude + 10 * ONE_METER_OFFSET, self.homeLocation.longitude);
    eastPoint = CLLocationCoordinate2DMake(self.homeLocation.latitude, self.homeLocation.longitude + 10 * ONE_METER_OFFSET);
    southPoint = CLLocationCoordinate2DMake(self.homeLocation.latitude - 10 * ONE_METER_OFFSET, self.homeLocation.longitude);
    westPoint = CLLocationCoordinate2DMake(self.homeLocation.latitude, self.homeLocation.longitude - 10 * ONE_METER_OFFSET);

    // Step 3: create waypoints
    DJIWaypoint* northWP = [[DJIWaypoint alloc] initWithCoordinate:northPoint];
    northWP.altitude = 10.0;
    DJIWaypoint* eastWP = [[DJIWaypoint alloc] initWithCoordinate:eastPoint];
    eastWP.altitude = 20.0;
    DJIWaypoint* southWP = [[DJIWaypoint alloc] initWithCoordinate:southPoint];
    southWP.altitude = 30.0;
    DJIWaypoint* westWP = [[DJIWaypoint alloc] initWithCoordinate:westPoint];
    westWP.altitude = 40.0;
    
    // Step 4: add actions
    [northWP addAction:[[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeRotateGimbalPitch param:-60]];
    [northWP addAction:[[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeShootPhoto param:0]];
    [eastWP addAction:[[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeShootPhoto param:0]];
    [southWP addAction:[[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeRotateAircraft param:60]];
    [southWP addAction:[[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeStartRecord param:0]];
    [westWP addAction:[[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeStopRecord param:0]];

    // Step 5: add waypoints into the mission
    [mission addWaypoint:northWP];
    [mission addWaypoint:eastWP];
    [mission addWaypoint:southWP];
    [mission addWaypoint:westWP]; 
    
    return mission; 
}


- (void)onUploadEvent:(DJIWaypointMissionUploadEvent *) event
{
    
    if (event.currentState == DJIWaypointMissionStateReadyToExecute) {
        ShowResult(@"SUCCESS: the whole waypoint mission is uploaded.");
        [self.progressBar setHidden:YES];
        [self.wpOperator removeListenerOfUploadEvents:self];
    }
    else if (event.error) {
        ShowResult(@"ERROR: waypoint mission uploading failed. %@", event.error.description);
        [self.progressBar setHidden:YES];
    	[self.wpOperator removeListenerOfUploadEvents:self];
    }
    else if (event.currentState == DJIWaypointMissionStateReadyToUpload ||
             event.currentState == DJIWaypointMissionStateNotSupported ||
             event.currentState == DJIWaypointMissionStateDisconnected) {
        ShowResult(@"ERROR: waypoint mission uploading failed. %@", event.error.description);
        [self.progressBar setHidden:YES];
        [self.wpOperator removeListenerOfUploadEvents:self];
    } else if (event.currentState == DJIWaypointMissionStateUploading) {
        [self.progressBar setHidden:NO];
        DJIWaypointUploadProgress *progress = event.progress;
        float progressInPercent = progress.uploadedWaypointIndex / progress.totalWaypointCount;
        [self.progressBar setProgress:progressInPercent];
    }
}

-(void) showWaypointMissionProgress:(DJIWaypointMissionExecutionEvent *)event {
    NSMutableString* statusStr = [NSMutableString new];
    [statusStr appendFormat:@"previousState:%@\n", [[self class] descriptionForMissionState:event.previousState]];
    [statusStr appendFormat:@"currentState:%@\n", [[self class] descriptionForMissionState:event.currentState]];
    
    [statusStr appendFormat:@"Target Waypoint Index: %zd\n", (long)event.progress.targetWaypointIndex];
    [statusStr appendString:[NSString stringWithFormat:@"Is Waypoint Reached: %@\n",
                             event.progress.isWaypointReached ? @"YES" : @"NO"]];
    [statusStr appendString:[NSString stringWithFormat:@"Execute State: %@\n", [[self class] descriptionForExecuteState:event.progress.execState]]];
    if (event.error) {
        [statusStr appendString:[NSString stringWithFormat:@"Execute Error: %@", event.error.description]];
        [self.wpOperator removeListenerOfExecutionEvents:self];
    }
    
    [self.statusLabel setText:statusStr];
}

/**
 *  Display the information of the mission if it is downloaded successfully.
 */
-(void)mission:(DJIMission *)mission didDownload:(NSError *)error {
    if (error) return;
    
    if ([mission isKindOfClass:[DJIWaypointMission class]]) {
        // Display information of waypoint mission.
        [self showWaypointMission:(DJIWaypointMission*)mission];
    }
}

-(void) showWaypointMission:(DJIWaypointMission*)wpMission {
    NSMutableString* missionInfo = [NSMutableString stringWithString:@"The waypoint mission is downloaded successfully: \n"];
    [missionInfo appendString:[NSString stringWithFormat:@"RepeatTimes: %d\n", wpMission.repeatTimes]];
    [missionInfo appendString:[NSString stringWithFormat:@"HeadingMode: %u\n", (unsigned int)wpMission.headingMode]];
    [missionInfo appendString:[NSString stringWithFormat:@"FinishedAction: %u\n", (unsigned int)wpMission.finishedAction]];
    [missionInfo appendString:[NSString stringWithFormat:@"FlightPathMode: %u\n", (unsigned int)wpMission.flightPathMode]];
    [missionInfo appendString:[NSString stringWithFormat:@"MaxFlightSpeed: %f\n", wpMission.maxFlightSpeed]];
    [missionInfo appendString:[NSString stringWithFormat:@"AutoFlightSpeed: %f\n", wpMission.autoFlightSpeed]];
    [missionInfo appendString:[NSString stringWithFormat:@"There are %zd waypoint(s). ", wpMission.waypointCount]];
    [self.statusLabel setText:missionInfo];
}

+(NSString *)descriptionForMissionState:(DJIWaypointMissionState)state {
    switch (state) {
        case DJIWaypointMissionStateUnknown:
            return @"Unknown";
        case DJIWaypointMissionStateExecuting:
            return @"Executing";
        case DJIWaypointMissionStateUploading:
            return @"Uploading";
        case DJIWaypointMissionStateRecovering:
            return @"Recovering";
        case DJIWaypointMissionStateDisconnected:
            return @"Disconnected";
        case DJIWaypointMissionStateNotSupported:
            return @"NotSupported";
        case DJIWaypointMissionStateReadyToUpload:
            return @"ReadyToUpload";
        case DJIWaypointMissionStateReadyToExecute:
            return @"ReadyToExecute";
        case DJIWaypointMissionStateExecutionPaused:
            return @"ExecutionPaused";
    }
    
    return @"Unknown";
}

+(NSString *)descriptionForExecuteState:(DJIWaypointMissionExecuteState)state {
    switch (state) {
        case DJIWaypointMissionExecuteStateInitializing:
            return @"Initializing";
            break;
        case DJIWaypointMissionExecuteStateMoving:
            return @"Moving";
        case DJIWaypointMissionExecuteStatePaused:
            return @"Paused";
        case DJIWaypointMissionExecuteStateBeginAction:
            return @"BeginAction";
        case DJIWaypointMissionExecuteStateDoingAction:
            return @"Doing Action";
        case DJIWaypointMissionExecuteStateFinishedAction:
            return @"Finished Action";
        case DJIWaypointMissionExecuteStateCurveModeMoving:
            return @"CurveModeMoving";
        case DJIWaypointMissionExecuteStateCurveModeTurning:
            return @"CurveModeTurning";
        case DJIWaypointMissionExecuteStateReturnToFirstWaypoint:
            return @"Return To first Point";
        default:
            break;
	}
    return @"Unknown";
}

@end
