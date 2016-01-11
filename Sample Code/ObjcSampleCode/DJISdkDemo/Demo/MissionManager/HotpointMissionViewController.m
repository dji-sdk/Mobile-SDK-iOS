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

@interface HotpointMissionViewController ()

@end

@implementation HotpointMissionViewController

@synthesize homeLocation = _homeLocation;

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Hotpoint mission required the aircraft location before initializing the mission
    // Therefore, we disable the prepare button until the aircraft location is valid
    [self.prepareButton setEnabled:CLLocationCoordinate2DIsValid(self.homeLocation)];
}

-(void)setHomeLocation:(CLLocationCoordinate2D)homeLocation {
    _homeLocation = homeLocation;
    [self.prepareButton setEnabled:CLLocationCoordinate2DIsValid(self.homeLocation)];
}


/**
 *  Prepare the hotpoint mission. 
 */
-(DJIMission*) initializeMission {
    DJIHotPointMission* mission = [[DJIHotPointMission alloc] init];
    mission.hotPoint = self.homeLocation;
    mission.altitude = 20.0;
    mission.radius = 10.0;
    mission.angularVelocity = 5.0;
    mission.isClockwise = YES; 
    
    return mission;
}

-(void)missionManager:(DJIMissionManager *)manager missionProgressStatus:(DJIMissionProgressStatus *)missionProgress {
    if ([missionProgress isKindOfClass:[DJIHotPointMissionStatus class]]) {
        DJIHotPointMissionStatus* hpStatus = (DJIHotPointMissionStatus*)missionProgress;
        
        [self showHotpointMissionStatus:hpStatus];
    }
}

/**
 *  Method to display the current status of the hotpoint mission.
 */
-(void) showHotpointMissionStatus:(DJIHotPointMissionStatus*)hpStatus {
    NSMutableString* statusStr = [NSMutableString stringWithFormat:@"Current Distance to hotpoint: %f\n", hpStatus.currentDistanceToHotpoint];
    [statusStr appendString:[NSString stringWithFormat:@"Execution State: %u", hpStatus.executionState]];
    [self.statusLabel setText:statusStr];
}

-(void)mission:(DJIMission *)mission didDownload:(NSError *)error {
    if (error) return;
    if ([mission isKindOfClass:[DJIHotPointMission class]]) {
        // Display information of the downloaded hotpoint mission.
        [self showHotpointMission:(DJIHotPointMission*)mission];
    }
}

-(void) showHotpointMission:(DJIHotPointMission*)hpMission {
    NSMutableString* missionInfo = [NSMutableString stringWithString:@"The hotpoint mission is downloaded successfully: \n"];
    [missionInfo appendString:[NSString stringWithFormat:@"Hotpoint: (%f, %f)\n", hpMission.hotPoint.latitude, hpMission.hotPoint.longitude]];
    [missionInfo appendString:[NSString stringWithFormat:@"Altitude: %f\n", hpMission.altitude]];
    [missionInfo appendString:[NSString stringWithFormat:@"Radius: %f\n", hpMission.radius]];
    [missionInfo appendString:[NSString stringWithFormat:@"IsClockwise: %u\n", hpMission.isClockwise]];
    [missionInfo appendString:[NSString stringWithFormat:@"AngularVelocity: %f\n", hpMission.angularVelocity]];
    [self.statusLabel setText:missionInfo];

}

@end
