//
//  WaypointV2PointConfigViewController.m
//  DJISdkDemo
//
//  Created by ethan.jiang on 2020/5/12.
//  Copyright © 2020 DJI. All rights reserved.
//

#import "WaypointV2PointConfigViewController.h"
#import <DJISDK/DJISDK.h>
#import "DemoUtilityMacro.h"

@interface WaypointV2PointConfigViewController () <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *pointsTableView;
@property (weak, nonatomic) IBOutlet UITextField *altitudeTextfield;
@property (weak, nonatomic) IBOutlet UITextField *maxSpeedTextfield;
@property (weak, nonatomic) IBOutlet UITextField *autoSpeedTextfield;
@property (weak, nonatomic) IBOutlet UISwitch *useMaxSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *clockwiseSwitch;
@property (weak, nonatomic) IBOutlet UIPickerView *pathModePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *headingModePicker;

@property (nonatomic, strong) DJIWaypointV2 *selectedWaypoint;
@end

@implementation WaypointV2PointConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.waypoints.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Waypoints";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *waypointReuseIdentifier = @"pointCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:waypointReuseIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:waypointReuseIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d", (int)(indexPath.row + 1)];
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedWaypoint = self.waypoints[indexPath.row];
    
    self.selectedWaypoint.altitude = [self.altitudeTextfield.text floatValue];
    self.selectedWaypoint.isUsingWaypointMaxFlightSpeed = self.useMaxSwitch.isOn;
    self.selectedWaypoint.turnMode = self.clockwiseSwitch.isOn ? DJIWaypointTurnClockwise : DJIWaypointTurnCounterClockwise;
    self.selectedWaypoint.maxFlightSpeed = [self.maxSpeedTextfield.text floatValue];
    self.selectedWaypoint.autoFlightSpeed = [self.autoSpeedTextfield.text floatValue];
    self.selectedWaypoint.heading = 0;
    self.selectedWaypoint.flightPathMode = [self.pathModePicker selectedRowInComponent:0];
    self.selectedWaypoint.dampingDistance = 0;
    self.selectedWaypoint.headingMode = [self.headingModePicker selectedRowInComponent:0];
    self.selectedWaypoint.isUsingWaypointAutoFlightSpeed = self.autoSpeedTextfield.text.length ? YES : NO;
}

#pragma mark - UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.pathModePicker || pickerView == self.headingModePicker) {
        return 6;
    } else {
        return 3;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.pathModePicker) {
        self.selectedWaypoint.flightPathMode = (DJIWaypointV2FlightPathMode)row;
    } else {
        self.selectedWaypoint.headingMode = (DJIWaypointV2HeadingMode)row;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == self.pathModePicker) {
        return [[self class] descriptionForWaypointV2FlightPathMode:row];
    } else {
        return [[self class] descriptionForWaypointV2HeadingMode:row];
    }
}

#pragma mark - UITextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    
    if (textField == self.altitudeTextfield) {
        self.selectedWaypoint.altitude = [textField.text floatValue];
    } else if (textField == self.maxSpeedTextfield) {
        self.selectedWaypoint.maxFlightSpeed = [textField.text floatValue];
    } else {
        self.selectedWaypoint.autoFlightSpeed = [textField.text floatValue];
    }
    return YES;
}

#pragma mark - user action

- (IBAction)onUseMaxChanged:(UISwitch *)sender {
    self.selectedWaypoint.isUsingWaypointMaxFlightSpeed = sender.isOn;
}

- (IBAction)onClockwiseChanged:(UISwitch *)sender {
    self.selectedWaypoint.turnMode = sender.isOn ? DJIWaypointV2TurnModeClockwise : DJIWaypointV2TurnModeCounterClockwise;
}

#pragma mark - helper
DESCRIPTION_FOR_ENUM(DJIWaypointV2FlightPathMode, WaypointV2FlightPathMode,
                     DJIWaypointV2FlightPathModeGoToPointAlongACurve,
                     DJIWaypointV2FlightPathModeGoToPointAlongACurveAndStop,
                     DJIWaypointV2FlightPathModeGoToPointInAStraightLineAndStop,
                     DJIWaypointV2FlightPathModeCoordinateTurn,
                     DJIWaypointV2FlightPathModeGoToFirstPointAlongAStraightLine,
                     DJIWaypointV2FlightPathModeStraightOut
                     );

DESCRIPTION_FOR_ENUM(DJIWaypointV2HeadingMode, WaypointV2HeadingMode,
                     DJIWaypointV2HeadingModeAuto,
                     DJIWaypointV2HeadingModeFixed,
                     DJIWaypointV2HeadingModeManual,
                     DJIWaypointV2HeadingModeWaypointCustom,
                     DJIWaypointV2HeadingModeTowardPointOfInterest,
                     DJIWaypointV2HeadingModeGimbalYawFollow
                     );

@end
