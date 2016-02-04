//
//  CustomMissionViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates the process to start a custom mission. 
 *
 *  CAUTION: it is highly recommended to run this sample using the simulator.
 */
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"
#import "CustomMissionViewController.h"

#define ONE_METER_OFFSET (0.00000901315)

@interface CustomMissionViewController ()

@property(nonatomic, strong) NSMutableArray* steps;

@end

@implementation CustomMissionViewController

@synthesize homeLocation = _homeLocation;

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Custom mission required the home location before initializing the mission
    // Therefore, we disable the prepare button until the home location is valid
    [self.prepareButton setEnabled:CLLocationCoordinate2DIsValid(self.homeLocation)];
}

-(void)setHomeLocation:(CLLocationCoordinate2D)homeLocation {
    _homeLocation = homeLocation;
    [self.prepareButton setEnabled:CLLocationCoordinate2DIsValid(self.homeLocation)];
}

-(DJIMission*) initializeMission {
    if (self.steps == nil) {
        self.steps = [[NSMutableArray alloc] init];
    }
    
    // Step 1: take off from the ground
    DJIMissionStep* step = [[DJITakeoffStep alloc] init];
    [self.steps addObject:step];
    
    // Step 2: reset the gimbal to horizontal angle
    DJIGimbalAttitude atti = {0, 0 ,0};
    step = [[DJIGimbalAttitudeStep alloc] initWithAttitude:atti];
    [self.steps addObject:step];
    
    // Step 3: shoot 3 photos with 5 seconds interval between each
    step = [[DJIShootPhotoStep alloc] initWithPhotoCount:3 timeInterval:5.0];
    [self.steps addObject:step];
    
    // Step 4: start recording video
    step = [[DJIRecordVideoStep alloc] initWithStartRecordVideo];
    [self.steps addObject:step];
    
    // Step 5: start a waypoint mission while the aircraft is still recording the video
    step = [self initializeWaypointMissonStep];
    [self.steps addObject:step];
    
    // Step 6: go to the target location
    step = [[DJIGoToStep alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.homeLocation.latitude + 40 * ONE_METER_OFFSET, self.homeLocation.longitude + 50 * ONE_METER_OFFSET) altitude:40.0];
    [self.steps addObject:step];
    
    // Step 7: stop the recording when the waypoint mission is finished
    step = [[DJIRecordVideoStep alloc] initWithStopRecordVideo];
    [self.steps addObject:step];
    
    // Step 8: go back home
    step = [[DJIGoHomeStep alloc] init];
    [self.steps addObject:step];
    
    DJICustomMission* mission = [[DJICustomMission alloc] initWithSteps:self.steps];
    
    return mission; 
}

-(DJIMissionStep*) initializeWaypointMissonStep {
    DJIWaypointMission* mission = [[DJIWaypointMission alloc] init];
    
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
    
    DJIMissionStep* step = [[DJIWaypointStep alloc] initWithWaypointMission:mission];
    
    return step;
}

#pragma mark - Override Methods
-(void)missionManager:(DJIMissionManager *)manager missionProgressStatus:(DJIMissionProgressStatus *)missionProgress {
    if ([missionProgress isKindOfClass:[DJICustomMissionStatus class]]) {
        DJICustomMissionStatus* cmStatus = (DJICustomMissionStatus*)missionProgress;
        
        [self showCustomMissionStatus:cmStatus];
    }
}

/**
 *  Method to display the current status of the custom mission.
 */
-(void) showCustomMissionStatus:(DJICustomMissionStatus*)cmStatus {
    int i = 0;
    for (; i < self.steps.count; i++) {
        DJIMissionStep* step = self.steps[i];
        if (step == cmStatus.currentExecutingStep) {
            break;
        }
    }
    
    NSMutableString* statusStr = [NSMutableString stringWithString:@""];
    if (i < self.steps.count) {
        [statusStr appendString:[NSString stringWithFormat:@"It is running Step %u\n", i+1]];
    }
    else {
        [statusStr appendString:@"The running step is not recognized. \n"];
    }
    
    [self.statusLabel setText:statusStr]; 
}

@end
