//
//  FCOrientationViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"
#import "FCOrientationViewController.h"
/**
 *  User can change the advanced orientation modes to control the aircraft's heading. SDK provides the capability to change the orientation
 *  modes. This file demonstrates how to change the mode to course lock, home lock or the default mode. It also demonstrates how to get 
 *  the current orientation mode by listening to the push data from DJIFlightController.
 */
@interface FCOrientationViewController () <DJIFlightControllerDelegate>

@property(nonatomic, assign) DJIFlightOrientationMode orientationMode;
@property (weak, nonatomic) IBOutlet UILabel *orientationModeLabel;

- (IBAction)onCourseLockButtonClicked:(id)sender;
- (IBAction)onHomeLockButtonClicked:(id)sender;
- (IBAction)onDefaultButtonClicked:(id)sender;

@end

@implementation FCOrientationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.orientationMode = DJIFlightOrientationModeAircraftHeading;
    self.orientationModeLabel.text = [self stringWithOrientationMode:_orientationMode];
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        fc.delegate = self;
    }
}

- (IBAction)onCourseLockButtonClicked:(id)sender
{
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        [fc setFlightOrientationMode:DJIFlightOrientationModeCourseLock withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"Course Lock:%@", error.localizedDescription);
            }
        }];
    }
    else
    {
        ShowResult(@"Component Not Exist.");
    }
}

- (IBAction)onHomeLockButtonClicked:(id)sender
{
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        [fc setFlightOrientationMode:DJIFlightOrientationModeHomeLock withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"Home Lock:%@", error.localizedDescription);
            }
        }];
    }
    else
    {
        ShowResult(@"Component Not Exist.");
    }
}

- (IBAction)onDefaultButtonClicked:(id)sender
{
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        [fc setFlightOrientationMode:DJIFlightOrientationModeAircraftHeading withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"Default:%@", error.localizedDescription);
            }
        }];
    }
    else
    {
        ShowResult(@"Component Not Exist.");
    }
}

#pragma mark - System State Updates
-(void)flightController:(DJIFlightController *)fc didUpdateState:(DJIFlightControllerState *)state
{
    if (_orientationMode != state.orientationMode) {
        _orientationMode = state.orientationMode;
        self.orientationModeLabel.text = [self stringWithOrientationMode:_orientationMode];
    }
}

-(NSString*) stringWithOrientationMode:(DJIFlightOrientationMode)mode
{
    if (mode == DJIFlightOrientationModeCourseLock) {
        return @"Course Lock";
    }
    else if (mode == DJIFlightOrientationModeHomeLock)
    {
        return @"Home Lock";
    }
    else
    {
        return @"Default";
    }
}
@end
