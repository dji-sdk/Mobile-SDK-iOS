//
//  PanoramaMissionViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates the process to start a panorama mission. 
 *  Currently, the panorama mission is only supported by Osmo.
 */
#import <DJISDK/DJISDK.h>
#import "PanoramaMissionViewController.h"
#import "DemoUtilityMacro.h"
#import "DemoAlertView.h"

@interface PanoramaMissionViewController ()
@property (nonatomic, weak) DJIPanoramaMissionOperator *panoramaOperator;
@end

@implementation PanoramaMissionViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.panoramaOperator = [[DJISDKManager missionControl] panoramaMissionOperator];
    self.pauseButton.enabled = NO;
    self.downloadButton.enabled = NO;
    self.resumeButton.enabled = NO;
}

/**
 *  Panorama mission doesn't require user to create a DJIMission instance.
 */
-(DJIMission *) initializeMission {
    return nil;
}

#pragma mark - Execution

- (IBAction)onPrepareButtonClicked:(id)sender
{
    [self.panoramaOperator setupWithMode:DJIPanoramaModeFullCircle withCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"Setup Mission Failed:%@", error.description);
        } else {
            ShowResult(@"Mission Setuped");
        }
    }];
}

- (IBAction)onStartButtonClicked:(id)sender
{
    [self.panoramaOperator startMissionWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"ERROR: startWithCompletion:. %@", error.description);
        }
        else {
            ShowResult(@"SUCCESS: startWithCompletion:. ");
        }
    }];
    
    WeakRef(target);
    [self.panoramaOperator addListenerToEvents:self withQueue:dispatch_get_main_queue() andBlock:^(DJIPanoramaMissionEvent * _Nonnull event) {
        [target showPanoramaMissionStatus:event];
    }];
}

- (IBAction)onStopButtonClicked:(id)sender
{
    WeakRef(target);
 	[self.panoramaOperator stopMissionWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"ERROR: stopWithCompletion:. %@", error.description);
        }
        else {
            [target.panoramaOperator removeListener:self];
            ShowResult(@"SUCCESS: stopWithCompletion:. ");
        }
    }];
}

-(void) showPanoramaMissionStatus:(DJIPanoramaMissionEvent*)event {
    
    if (event.error) {
        ShowResult(@"Mission Executing Error:%@", event.error);
        [self.panoramaOperator removeListener:self];
    } else {
        NSMutableString* statusString = [NSMutableString new];
        [statusString appendFormat:@"Prev State:%@\n", [[self class] descriptionForState:event.previousState ]];
        [statusString appendFormat:@"Cur State:%@\n", [[self class] descriptionForState:event.currentState]];
        [statusString appendFormat:@"total:%tu curShot:%tu, curSaved:%tu\n",
                                    event.executionState.totalNumber,
                                    event.executionState.currentShotNumber,
                                    event.executionState.currentSavedNumber];
        self.statusLabel.text = statusString;
    }
}

+(NSString *)descriptionForState:(DJIPanoramaMissionState)state {
    switch (state) {
        case DJIPanoramaMissionStateUnknown:
            return @"Unknown";
        case DJIHotpointMissionStateExecuting:
            return @"Executing";
        case DJIPanoramaMissionStateReadyToExecute:
            return @"ReadyToExecute";
        case DJIHotpointMissionStateDisconnected:
            return @"Disconnected";
        case DJIPanoramaMissionStateNotSupported:
            return @"NotSupported";
        case DJIPanoramaMissionStateReadyToSetup:
            return @"ReadyToSetup";
        case DJIPanoramaMissionStateSettingUp:
            return @"Setuping";
    }
    
    return nil;
}
@end
