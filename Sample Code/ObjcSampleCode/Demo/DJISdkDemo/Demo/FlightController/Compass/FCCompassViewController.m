//
//  FCCompassViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates how to use compass calibration of DJIFlightController. 
 */
#import "FCCompassViewController.h"
#import "DemoComponentHelper.h"
#import "DemoAlertView.h"
#import <DJISDK/DJISDK.h>

@interface FCCompassViewController () <DJIFlightControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *headingLabel;
@property (weak, nonatomic) IBOutlet UILabel *calibratingLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

- (IBAction)onCompassCalibrationButtonClicked:(id)sender;
@end

@implementation FCCompassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        fc.delegate = self;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onCompassCalibrationButtonClicked:(UIButton*)sender {
    const int STOP_TAG = 100;
    const int START_TAG = 101;
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        if (sender.tag == STOP_TAG) {
            [fc.compass stopCalibrationWithCompletion:^(NSError * _Nullable error) {
                if (error) {
                    ShowResult(@"Stop Calibration:%@", error.localizedDescription);
                }
                else
                {
                    [sender setTitle:@"Start Calibration" forState:UIControlStateNormal];
                    sender.tag = START_TAG;
                }
            }];
        }
        else
        {
            [fc.compass startCalibrationWithCompletion:^(NSError * _Nullable error) {
                if (error) {
                    ShowResult(@"Start Calibration:%@", error.localizedDescription);
                }
                else
                {
                    [sender setTitle:@"Stop Calibration" forState:UIControlStateNormal];
                    sender.tag = STOP_TAG;
                }
            }];
        }
    }
    else
    {
        ShowResult(@"Component Not Exist.");
    }
}

- (void)flightController:(DJIFlightController *)fc didUpdateSystemState:(DJIFlightControllerCurrentState *)state
{
    self.headingLabel.text = [NSString stringWithFormat:@"%0.1f", fc.compass.heading];
    self.calibratingLabel.text = fc.compass.isCalibrating ? @"YES" : @"NO";
    self.statusLabel.text = [self stringWithCalibrationStatus:fc.compass.calibrationStatus];
}

-(NSString*) stringWithCalibrationStatus:(DJICompassCalibrationStatus)status
{
    if (status == DJICompassCalibrationStatusNone) {
        return @"None";
    }
    else if (status == DJICompassCalibrationStatusHorizontal)
    {
        return @"Horizontal";
    }
    else if (status == DJICompassCalibrationStatusVertical)
    {
        return @"Vertical";
    }
    else if (status == DJICompassCalibrationStatusSucceeded)
    {
        return @"Succeeded";
    }
    else if (status == DJICompassCalibrationStatusFailed)
    {
        return @"Failed";
    }
    else
    {
        return @"Unknown";
    }
}
@end
