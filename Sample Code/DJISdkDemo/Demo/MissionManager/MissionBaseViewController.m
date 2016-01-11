//
//  MissionBaseViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates the interaction with DJIMissionManager. The DJIMissionManager uses the singleton pattern. User can
 *  access it by fetching the sharedInstance. Different types of missions can be executed by DJIMissionManager. The missions have 
 *  a common workflow. The basic workflow to execute a mission is as follow:
 *  1. Create an isntance of a specific mission. See initializeMission. 
 *  2. Insert the mission into DJIMissionManager by calling prepareMission:withProgress:withCompletion:. 
 *  3. After DJIMissionManager finishes the preparation, user should call startMissionExecutionWithCompletion: to start the mission. 
 *     The completion block is called after the mission is started. 
 *  4. To keep track of the progress of the mission, user needs to set itself as the delegate of DJIMissionManager. Then the delegate
 *     can receive the updated progress and execution result.
 *  5. During the execution, user can also stop the mission. Some missions can even be paused, resumed or downloaded. 
 *  
 *  MissionBaseViewController includes the basic workflow for DJIMissionManager. A specific mission may have other requried operations.
 *  Those specific operations are implemented in the sub-class of MissionBaseViewController.
 */
#import "DemoUtility.h"
#import "MissionBaseViewController.h"

@implementation MissionBaseViewController

-(instancetype)init {
    self = [super initWithNibName:@"MissionBaseViewController"  bundle:[NSBundle mainBundle]];
    if (self) {
        _homeLocation = kCLLocationCoordinate2DInvalid;
    }
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    // hide progress bar first
    [self.progressBar setHidden:YES];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // set the delegate
    [[DJIMissionManager sharedInstance] setDelegate:self];
    if ([DemoComponentHelper fetchAircraft] != nil) { // the product is an aircraft
        if ([DemoComponentHelper fetchFlightController]) {
            [[DemoComponentHelper fetchFlightController] setDelegate:self];
        }
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // unset the delegate
    if ([DemoComponentHelper fetchAircraft] != nil) { // the product is an aircraft
        DJIFlightController* flightController = [DemoComponentHelper fetchFlightController];
        if (flightController != nil && flightController.delegate == self) {
            [flightController setDelegate:nil];
        }
    }
    if ([DJIMissionManager sharedInstance].delegate == self) {
        [[DJIMissionManager sharedInstance] setDelegate:nil];
    }
}

#pragma mark - UI Actions
- (IBAction)onPrepareButtonClicked:(id)sender {
    
    self.mission = [self initializeMission];
    
    if (self.mission == nil) return; // initialization failed

    WeakRef(target);
    [[DJIMissionManager sharedInstance] prepareMission:self.mission withProgress:^(float progress) {
        WeakReturn(target);
        
        [target.progressBar setHidden:NO];
        [target.progressBar setProgress:progress];
        
    } withCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"ERROR: prepareMission:withProgress:withCompletion:. %@", error.description);
        }
        else {
            ShowResult(@"SUCCESS: prepareMission:withProgress:withCompletion:.");
        }
        
        [target.progressBar setHidden:YES];
    }];
}

/**
 *  Before start the mission, user need to confirm the pre-condition for the mission is fulfilled. 
 *  For example: before starting a follow-me mission, the aircraft should be in the air and the altitude is not lower than 10m.
 */
- (IBAction)onStartButtonClicked:(id)sender {
    [[DJIMissionManager sharedInstance] startMissionExecutionWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"ERROR: startMissionExecutionWithCompletion:. %@", error.description);
        }
        else {
            ShowResult(@"SUCCESS: startMissionExecutionWithCompletion:. ");
        }
        [self missionDidStart:error];
    }];
}

- (IBAction)onStopButtonClicked:(id)sender {
    [[DJIMissionManager sharedInstance] stopMissionExecutionWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"ERROR: stopMissionExecutionWithCompletion:. %@", error.description);
        }
        else {
            ShowResult(@"SUCCESS: stopMissionExecutionWithCompletion:. ");
        }
        [self missionDidStop:error];
    }];
}

- (IBAction)onDownloadButtonClicked:(id)sender {
    WeakRef(target);
    [[DJIMissionManager sharedInstance] downloadMissionWithProgress:^(float progress) {
        WeakReturn(target);
        
        [target.progressBar setHidden:NO];
        [target.progressBar setProgress:progress];
        
    } withCompletion:^(DJIMission * _Nullable newMission, NSError * _Nullable error) {
        WeakReturn(target);
        if (error) {
            ShowResult(@"ERROR: downloadMissionWithProgress:withCompletion:. %@", error.description);
        }
        else {
            ShowResult(@"SUCCESS: downloadMissionWithProgress:withCompletion:. ");
        }
        [target mission:newMission didDownload:error];
        [target.progressBar setHidden:YES];
    }];
}

/**
 *  Only some types of missions support pause. For custom mission, not all the steps can be paused.
 */
- (IBAction)onPauseButtonClicked:(id)sender {
    [self missionWillPause];
    
    if ([self.mission isPausable]) {
        [[DJIMissionManager sharedInstance] pauseMissionExecutionWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"ERROR: pauseMissionExecutionWithCompletion:. %@", error.description);
            }
            else {
                ShowResult(@"SUCCESS: pauseMissionExecutionWithCompletion:. ");
            }
        }];
    }
}

- (IBAction)onResumeButtonClicked:(id)sender {
    // Only missions that support pause can be resumed.
    if ([self.mission isPausable]) {
        WeakRef(target);
        [[DJIMissionManager sharedInstance] resumeMissionExecutionWithCompletion:^(NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"ERROR: resumeMissionExecutionWithCompletion:. %@", error.description);
            }
            else {
                ShowResult(@"SUCCESS: resumeMissionExecutionWithCompletion:. ");
            }
            [target missionDidResume:error];
        }];
    }
}

#pragma mark - DJIFlightControllerDelegate
/**
 *  Some missions need the aircraft's current location and the home point location.
 */
-(void)flightController:(DJIFlightController *)fc didUpdateSystemState:(DJIFlightControllerCurrentState *)state {
    self.aircraftLocation = state.aircraftLocation;
    self.homeLocation = state.homeLocation;
}


#pragma mark - Methods to Override
/**
 *  The sub-class will override initializeMission to create the specific mission.
 */
-(DJIMission*) initializeMission {
    return [[DJIMission alloc] init];
}

/**
 *  Method that is called inside the completion block of startMissionWithCompletion:.
 *  Sub-class can override it to do other tasks after the mission is started.
 */
-(void)missionDidStart:(NSError *)error {
    
}

/**
 *  Method that is called before calling pauseMissionWithCompletion:.
 *  Sub-class can override it to do other tasks before the mission is paused.
 */
-(void)missionWillPause {
    
}

/**
 *  Method that is called inside the completion block of resumeMissionWithCompletion:.
 *  Sub-class can override it to do other tasks after the mission is resumed.
 */
-(void)missionDidResume:(NSError *)error {
    
}

/**
 *  Method that is called inside the completion block of stopMissionWithCompletion:.
 *  Sub-class can override it to do other tasks after the mission is stopped.
 */
-(void)missionDidStop:(NSError *)error {
    
}

/**
 *  Method that is called inside the completion block of downloadMissionWithProgress:withCompletion:.
 *  Sub-class can override it to do other tasks after a mission is downloaded.
 */
-(void)mission:(DJIMission *)mission didDownload:(NSError *)error {
    
}


#pragma mark DJIMissionManagerDelegate
/**
 *  Method that tells the view controller when the mission's execution is finished.
 *  Sub-class can override it to do other tasks after a mission is finished.
 */
-(void)missionManager:(DJIMissionManager *)manager didFinishMissionExecution:(NSError *)error {
    if (error) {
        ShowResult(@"ERROR: missionManager:didFinishMissionExecution:. %@", error.description);
    }
    else {
        ShowResult(@"SUCCESS: missionManager:didFinishMissionExecution:."); 
    }
}

/**
 *  The method will tell the view controller about the current progress of the executing mission. DJIMissionProgressStatus is 
 *  an abstract class. A specific mission will have the corresponding status, which inherits from DJIMissionProgressStatus. 
 *  In order to get the information from missionProgress variable, user need to do type-casting and convert it into the specific 
 *  mission's status.
 *  For more information, please refer to WaypointMissionViewController.m etc.
 */
-(void)missionManager:(DJIMissionManager *)manager missionProgressStatus:(DJIMissionProgressStatus *)missionProgress {
    
}




@end
