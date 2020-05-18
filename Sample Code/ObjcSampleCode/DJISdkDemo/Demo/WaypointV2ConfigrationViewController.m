//
//  WaypointV2ConfigrationViewController.m
//  DJISdkDemo
//
//  Created by ethan.jiang on 2020/5/8.
//  Copyright © 2020 DJI. All rights reserved.
//

#import "WaypointV2ConfigrationViewController.h"
#import "WaypointV2MapPointsViewController.h"
#import <DJISDK/DJIWaypointV2MissionTypes.h>
#import "DemoUtilityMacro.h"
#import "DemoAlertView.h"

@implementation WaypointV2ConfigItem

@end

@interface WaypointV2ConfigrationViewController ()
@property (weak, nonatomic) IBOutlet UITextField *avgSpeedTextfield;
@property (weak, nonatomic) IBOutlet UITextField *maxSpeedTextfield;
@property (weak, nonatomic) IBOutlet UITextField *repeatTimesTextfield;
@property (weak, nonatomic) IBOutlet UIPickerView *finishActionPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *firstPointPicker;
@property (weak, nonatomic) IBOutlet UISwitch *exitSwitch;

@property (nonatomic, strong) WaypointV2ConfigItem *missionConfig;

@end


@implementation WaypointV2ConfigrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.missionConfig = [[WaypointV2ConfigItem alloc] init];
    self.missionConfig.maxFlightSpeed = 10.f;
    self.missionConfig.autoFlightSpeed = 5.f;
    self.missionConfig.finishedAction = DJIWaypointV2MissionFinishedActionNoAction;
    self.missionConfig.gotoFirstWaypointAction = DJIWaypointV2MissionGotoFirstWaypointModeSafely;
    self.missionConfig.exitOnRCSignalLostAction = DJIWaypointV2MissionRCLostActionStopMission;
    self.missionConfig.repeatTimes = 1;
    [self.exitSwitch setOn:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.avgSpeedTextfield addTarget:self action:@selector(textFieldContentDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.maxSpeedTextfield addTarget:self action:@selector(textFieldContentDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.avgSpeedTextfield removeTarget:self action:@selector(textFieldContentDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.maxSpeedTextfield removeTarget:self action:@selector(textFieldContentDidChange:) forControlEvents:UIControlEventEditingChanged];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    WaypointV2MapPointsViewController *vc = [segue destinationViewController];
    vc.missionConfig = self.missionConfig;
}

#pragma mark - textfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldContentDidChange:(UITextField *)textField {
    if (textField == self.avgSpeedTextfield) {
        if ([textField.text floatValue] > 15.f || [textField.text floatValue] < -15.f) {
            ShowResult(@"Illegal speed value, it should between -15m/s to 15m/s");
            return;
        }
        self.missionConfig.autoFlightSpeed = [textField.text floatValue];
    } else {
        if ([textField.text floatValue] > 15.f || [textField.text floatValue] < 2.f) {
            ShowResult(@"Illegal speed value, it should between -15m/s to 15m/s");
            return;
        }
        self.missionConfig.maxFlightSpeed = [textField.text floatValue];
    }
}

#pragma mark - UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([pickerView isEqual:self.finishActionPicker]) {
        return 5;
    } else if ([pickerView isEqual:self.firstPointPicker]) {
        return 2;
    }
    return 0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([pickerView isEqual:self.finishActionPicker]) {
        self.missionConfig.finishedAction = (DJIWaypointV2MissionFinishedAction)row;
    } else if ([pickerView isEqual:self.firstPointPicker]) {
        self.missionConfig.gotoFirstWaypointAction = (DJIWaypointV2MissionGotoFirstWaypointMode)row;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([pickerView isEqual:self.finishActionPicker]) {
        return [[self class] descriptionForFinishedAction:row];
    } else if ([pickerView isEqual:self.firstPointPicker]) {
        return [[self class] descriptionForGotoFirstWaypointMode:row];
    }
    return @"";
}

DESCRIPTION_FOR_ENUM(DJIWaypointV2MissionFinishedAction, FinishedAction,
                     DJIWaypointV2MissionFinishedActionNoAction,
                     DJIWaypointV2MissionFinishedActionGoHome,
                     DJIWaypointV2MissionFinishedActionAutoLanding,
                     DJIWaypointV2MissionFinishedActionGoToFirstWaypoint,
                     DJIWaypointV2MissionFinishedActionContinueUntilStop
                     );

DESCRIPTION_FOR_ENUM(DJIWaypointV2MissionGotoFirstWaypointMode, GotoFirstWaypointMode,
                     DJIWaypointV2MissionGotoFirstWaypointModeSafely,
                     DJIWaypointV2MissionGotoFirstWaypointModePointToPoint
                     );


@end
