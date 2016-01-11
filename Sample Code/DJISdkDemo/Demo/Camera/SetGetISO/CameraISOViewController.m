//
//  CameraISOViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

/**
 *  This file shows how to set a parameter of DJICamera. The parameter selected in this sample is ISO. For different parameters, 
 *  there are different pre-conditions. For ISO, the pre-conditions are as follows:
 *  1. The camera mode should be either DJICameraModeShootPhoto or DJICameraModeRecordMode. 
 *  2. For products except Inpire 1 Pro, ISO is only adjustable when the exposure mode is DJICameraExposureModeManual. 
 *
 *  The valid range for a parameter is different for different products. Even for the same product, the range may be
 *  different when the camera is in different condition. Therefore, SDK provides a utility class DJICameraParameters to 
 *  query the current valid range for a parameter. 
*/

#import <DJISDK/DJISDK.h>
#import "DemoUtilityMacro.h"
#import "DemoComponentHelper.h"
#import "DemoAlertView.h"
#import "CameraISOViewController.h"

@implementation NSArray (TestArray)

- (NSString *)horizontalDescription{
    NSMutableString *string = [[NSMutableString alloc] init];
    [string appendString:@"("];
    for (int i = 0;i < self.count;i++) {
        if(i != 0){
            [string appendString:@","];
        }
        if([[self objectAtIndex:i] isKindOfClass:[NSArray class]]){
            [string appendFormat:@"%@",[(NSArray *)[self objectAtIndex:i] horizontalDescription]];
        }
        else{
            [string appendFormat:@"%@",[self objectAtIndex:i]];
        }
    }
    if(self.count == 0){
        [string appendString:@"Not supported"];
    }
    [string appendString:@")"];
    return string;
}

@end

@interface CameraISOViewController ()

@end

@implementation CameraISOViewController

static NSString* STATE_CHECKING_CAMERA_MODE = @"Checking camera's mode...";
static NSString* STATE_SETTING_CAMERA_MODE = @"Setting camera's mode...";
static NSString* STATE_CHECKING_EXPOSURE_MODE = @"Checking camera's exposure mode...";
static NSString* STATE_SETTING_EXPOSURE_MODE = @"Setting camera's exposure mode...";
static NSString* STATE_WAIT_FOR_INPUT = @"The input should be an integer. ";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Camera's ISO";
    self.rangeLabel.text = @"";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // disable the set/get button first.
    [self.getValueButton setEnabled:NO];
    [self.setValueButton setEnabled:NO];
    
    [self getCameraMode];
}

/**
 *  Check if the camera's mode is DJICameraModeShootPhoto or DJICameraModeRecordVideo.
 *  If the mode is not one of them, we need to set it to be ShootPhoto or RecordVideo.
 *  If the mode is already one of them, we check the exposure mode. 
 */
-(void) getCameraMode {
    self.rangeLabel.text = STATE_CHECKING_CAMERA_MODE;
    DJICamera* camera = [DemoComponentHelper fetchCamera];
    
    if (camera) {
        WeakRef(target);
        [camera getCameraModeWithCompletion:^(DJICameraMode mode, NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                target.rangeLabel.text = [NSString stringWithFormat:@"ERROR: getCameraModeWithCompletion:. %@", error.description];
            }
            else if (mode == DJICameraModeShootPhoto || mode == DJICameraModeRecordVideo) {
                // the first pre-condition is satisfied. Check the second one.
                [target getExposureMode];
            }
            else {
                [target setCameraMode];
            }
        }];
    }
}

/**
 *  Set the camera's mode to DJICameraModeShootPhoto.
 *  If it succeeds, we check the exposure mode.
 */
-(void) setCameraMode {
    self.rangeLabel.text = STATE_SETTING_CAMERA_MODE;
    DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        WeakRef(target);
        [camera setCameraMode:DJICameraModeShootPhoto withCompletion:^(NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                target.rangeLabel.text = [NSString stringWithFormat:@"ERROR: setCameraMode:withCompletion:. %@", error.description];
            }
            else {
                // Normally, once an operation is finished, the camera still needs some time to finish up
                // all the work. It is safe to delay the next operation after an operation is finished.
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    WeakReturn(target);
                    [target getExposureMode];
                });
            }
        }];
    }
}

/**
 *  Check if current exposure mdoe is DJIExposureModeManual. For most of the products, ISO can only be set when
 *  the exposure mode is DJIExposureModeManual. 
 *  If the exposure mode is correct, enable the set/get buttons. 
 *  If the exposure mode is not DJIExposureModeManual, change the exposure mode.
 */
-(void) getExposureMode {
    self.rangeLabel.text = STATE_CHECKING_EXPOSURE_MODE;
    DJICamera* camera = [DemoComponentHelper fetchCamera];
    
    if (camera) {
        WeakRef(target);
        [camera getExposureModeWithCompletion:^(DJICameraExposureMode expMode, NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                target.rangeLabel.text = [NSString stringWithFormat:@"ERROR: getExposureModeWithCompletion:. %@", error.description];
            }
            else if (expMode == DJICameraExposureModeManual) {
                [target enableGetSetISO];
            }
            else {
                [target setExposureMode];
            }
        }];
    }
}

/**
 *  Set the exposure mode to DJICameraExposureModeManual. 
 *  If it succeeds, we enable the get/set buttons.
 */
-(void) setExposureMode {
    self.rangeLabel.text = STATE_SETTING_EXPOSURE_MODE;
    DJICamera* camera = [DemoComponentHelper fetchCamera];
    
    if (camera) {
        WeakRef(target);
        [camera setExposureMode:DJICameraExposureModeManual withCompletion:^(NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                target.rangeLabel.text = [NSString stringWithFormat:@"ERROR: setExposureMode:withCompletion:. %@", error.description];
            }
            else {
                // all the pre-conditions are satisfied.
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [target enableGetSetISO];
                });
            }
        }];
    }
}

-(void) enableGetSetISO {
    [self.getValueButton setEnabled:YES];
    [self.setValueButton setEnabled:YES];
    [self updateValidISORange];
    
}

/**
 *  We provide a utility class called DJICameraParameters to check what the valid range for a parameter is.
 */
-(void) updateValidISORange {
    NSMutableString* str = [NSMutableString stringWithString:STATE_WAIT_FOR_INPUT];
    [str appendString:@"\n the valid range: \n"];
    [str appendString:[DJICameraParameters sharedInstance].supportedCameraISORange.horizontalDescription];
    self.rangeLabel.text = str;
}

- (IBAction)onGetButtonClicked:(id)sender {
    DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        WeakRef(target);
        [camera getISOWithCompletion:^(DJICameraISO iso, NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"ERROR: getISO. %@", error.description);
            }
            else {
                NSString* getTextString = [NSString stringWithFormat:@"%u", (unsigned int)iso];
                target.getValueTextField.text = getTextString;
            }
        }];
    }
}

- (IBAction)onSetButtonClicked:(id)sender {
    DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        DJICameraISO iso = (DJICameraISO)[self.setValueTextField.text intValue];
        
        [camera setISO:iso withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"ERROR: setISO. %@. ", error.description);
            }
            else {
                ShowResult(@"Succeed. ");
            }
        }];
    }
}

@end
