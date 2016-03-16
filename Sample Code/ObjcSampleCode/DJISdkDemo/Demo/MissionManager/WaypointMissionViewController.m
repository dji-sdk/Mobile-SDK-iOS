//
//  WaypointMissionViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates the process to start a waypoint mission. In this demo, the aircraft will go to four waypoints, shoot photos
 *  and record videos. 
 *  The flight speed can be controlled by calling the class method setAutoFlightSpeed:withCompletion:. In this demo, when the aircraft
 *  will change the speed right after it reaches the second point (point with index 1).
 *
 *  CAUTION: it is highly recommended to run this sample using the simulator.
 */
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"
#import "WaypointMissionViewController.h"

#define ONE_METER_OFFSET (0.00000901315)

@interface WaypointMissionViewController ()

@property (nonatomic) NSInteger lastWPIndex;

@end

@implementation WaypointMissionViewController

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
    DJIWaypointMission* mission = [[DJIWaypointMission alloc] init];
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

#pragma mark - Override Methods
-(void)missionManager:(DJIMissionManager *)manager missionProgressStatus:(DJIMissionProgressStatus *)missionProgress {
    if ([missionProgress isKindOfClass:[DJIWaypointMissionStatus class]]) {
        DJIWaypointMissionStatus* wpStatus = (DJIWaypointMissionStatus*)missionProgress;
        
        [self showWaypointMissionStatus:wpStatus];
        
        // Change the flight speed
        if (wpStatus.targetWaypointIndex == 2 && self.lastWPIndex == 1) {
            [DJIWaypointMission setAutoFlightSpeed:10 withCompletion:^(NSError * _Nullable error) {
                if (error) {
                    ShowResult(@"ERROR: setAutoFlightSpeed:withCompletion:. %@", error.description);
                }
                else {
                    ShowResult(@"SUCCESS: setAutoFlightSpeed:withCompletion:. ");
                }
                [self missionDidStop:error];
            }];
        }
        
        self.lastWPIndex = wpStatus.targetWaypointIndex;
    }
}

-(void) showWaypointMissionStatus:(DJIWaypointMissionStatus*)wpStatus {
    NSMutableString* statusStr = [NSMutableString stringWithFormat:@"Target Waypoint Index: %tu\n", (long)wpStatus.targetWaypointIndex];
    [statusStr appendString:[NSString stringWithFormat:@"Is Waypoint Reached: %u\n", wpStatus.isWaypointReached]];
    [statusStr appendString:[NSString stringWithFormat:@"Execute State: %u", wpStatus.execState]];
    if (wpStatus.error) {
        [statusStr appendString:[NSString stringWithFormat:@"\nExecute Error: %@", wpStatus.error.description]];
    }
    
    [self.statusLabel setText:statusStr];
}

-(void)missionDidStart:(NSError *)error {
    // reset the property value
    self.lastWPIndex = -1;
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
    [missionInfo appendString:[NSString stringWithFormat:@"There are %d waypoint(s). ", wpMission.waypointCount]];
    [self.statusLabel setText:missionInfo];
}


@end
