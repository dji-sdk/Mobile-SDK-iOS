//
//  NavigationWaypointConfigView.m
//  DJISdkDemo
//
//  Created by Ares on 15/8/4.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "NavigationWaypointConfigView.h"
#import "DJIDemoHelper.h"

@interface NavigationWaypointConfigView ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation NavigationWaypointConfigView

-(instancetype) initWithNib
{
    NSArray* objs = [[NSBundle mainBundle] loadNibNamed:@"NavigationWaypointConfigView" owner:self options:nil];
    UIView* mainView = [objs objectAtIndex:0];
    self = [super initWithFrame:mainView.bounds];
    if (self) {
        mainView.layer.cornerRadius = 5.0;
        mainView.layer.masksToBounds = YES;
        [self addSubview:mainView];
        
        [self.waypointTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"WAYPOINT_REUSE_IDENTIFY"];
        [self.waypointTableView reloadData];
    }
    
    return self;
}

-(void) setWaypointList:(NSMutableArray *)waypointList
{
    _waypointList = waypointList;
    [self.waypointTableView reloadData];
}

-(void) setSelectedWaypoint:(DJIWaypoint *)selectedWaypoint
{
    _selectedWaypoint = selectedWaypoint;
    [self.actionTableView reloadData];
}

-(void) onActionViewOkButtonClicked:(id)sender
{
    self.actionView.center = self.center;
    [UIView animateWithDuration:0.25 animations:^{
        self.actionView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            if (self.selectedWaypoint) {
                DJIWaypointActionType actionType = (DJIWaypointActionType)self.actionView.actionType.selectedSegmentIndex;
                int16_t actionParam = [self.actionView.actionParam.text intValue];
                DJIWaypointAction* wpAction = [[DJIWaypointAction alloc] initWithActionType:actionType param:actionParam];
                [self.selectedWaypoint addAction:wpAction];
                [self.actionTableView reloadData];
            }
        }
    }];
}

-(IBAction) onAddActionButtonClicked:(id)sender
{
    if (self.selectedWaypoint) {
        if (self.selectedWaypoint.waypointActions.count > DJIMaxActionCount) {
            ShowResult(@"Action already reached maximum");
        }
        else
        {
            if (self.actionView == nil) {
                self.actionView = [[NavigationWaypointActionView alloc] initWithNib];
                [self.actionView.okButton addTarget:self action:@selector(onActionViewOkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                self.actionView.alpha = 0;
                [self.superview addSubview:self.actionView];
                self.actionView.center = self.superview.center;
            }
            
            [UIView animateWithDuration:0.25 animations:^{
                self.actionView.alpha = 1.0;
            }];
        }
    }
    else
    {
        ShowResult(@"Please select a waypoint first!");
    }
}

-(IBAction) onDelActionButtonClicked:(id)sender
{
    if (self.selectedWaypoint && self.selectedAction) {
        [self.selectedWaypoint removeAction:self.selectedAction];
        [self.actionTableView reloadData];
    }
}

-(IBAction) onDelAllWaypointButtonClicked:(id)sender
{
    [self.waypointList removeAllObjects];
    if (self.delegate) {
        [self.delegate configViewDidDeleteAllWaypoints];
    }
    self.selectedWaypoint = nil;
    self.selectedAction = nil;
    [self.waypointTableView reloadData];
    [self.actionTableView reloadData];
}

-(IBAction) onTurnModeSwitchValueChanged:(id)sender
{
    [self updateWaypoint];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.waypointTableView) {
        return self.waypointList.count;
    }
    else
    {
        if (self.selectedWaypoint) {
            return self.selectedWaypoint.waypointActions.count;
        }
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* waypointReuseIdentifier = @"waypointReuseIdentifier";
    static NSString* actionReusedIdentifier = @"actionReusedIdentifier";
    UITableViewCell* cell = nil;
    if (tableView == self.waypointTableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:waypointReuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:waypointReuseIdentifier];
        }
        
        DJIWaypoint* wp = [self.waypointList objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"Waypoint %d", (int)(indexPath.row + 1)];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"{%f, %f}", wp.coordinate.latitude, wp.coordinate.longitude];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:8];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:actionReusedIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:actionReusedIdentifier];
        }
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:8];
        DJIWaypointAction* action = [self.selectedWaypoint.waypointActions objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"Action %d", (int)(indexPath.row + 1)];
        if (action.actionType == DJIWaypointActionStay) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Stay"];
        }
        else if (action.actionType == DJIWaypointActionStartTakePhoto)
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Take Photo"];
        }
        else if (action.actionType == DJIWaypointActionStartRecord)
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Start Record"];
        }
        else if (action.actionType == DJIWaypointActionStopRecord)
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Stop Record"];
        }
        else if (action.actionType == DJIWaypointActionRotateAircraft)
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Rotate Aircraft"];
        }
        else if (action.actionType == DJIWaypointActionRotateGimbalPitch)
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Rotate Gimbal Pitch"];
        }
        
    }

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.waypointTableView) {
        self.selectedWaypoint = [self.waypointList objectAtIndex:indexPath.row];
        [self updateValue];
    }
    else
    {
        if (self.selectedWaypoint) {
            self.selectedAction = [self.selectedWaypoint.waypointActions objectAtIndex:indexPath.row];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"Delete";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        if (self.delegate) {
            [self.delegate configViewDidDeleteWaypointAtIndex:(int)indexPath.row];
        }
        [self.waypointList removeObjectAtIndex:indexPath.row];
        self.selectedWaypoint = nil;
        self.selectedAction = nil;
        [self.waypointTableView reloadData];
        [self updateValue];
    }
}

-(void) updateValue
{
    if (self.selectedWaypoint) {
        self.altitudeTextField.text = [NSString stringWithFormat:@"%0.1f", self.selectedWaypoint.altitude];
        self.headingTextField.text = [NSString stringWithFormat:@"%0.1f", self.selectedWaypoint.heading];
        self.repeatTimeTextField.text = [NSString stringWithFormat:@"%d", (int)self.selectedWaypoint.actionRepeatTimes];
        [self.turnModeSwitch setOn:(self.selectedWaypoint.turnMode == DJIWaypointTurnClockwise)];
    }
    else
    {
        self.altitudeTextField.text = @"";
        self.headingTextField.text = @"";
        self.repeatTimeTextField.text = @"";
        [self.turnModeSwitch setOn:NO];
    }
}

-(void) updateWaypoint
{
    if (self.selectedWaypoint) {
        self.selectedWaypoint.altitude = [self.altitudeTextField.text floatValue];
        self.selectedWaypoint.heading = [self.headingTextField.text floatValue];
        self.selectedWaypoint.actionRepeatTimes = [self.repeatTimeTextField.text intValue];
        self.selectedWaypoint.turnMode = self.turnModeSwitch.isOn ? DJIWaypointTurnClockwise : DJIWaypointTurnCounterClockwise;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    [self updateWaypoint];
    return YES;
}
@end
