//
//  NavigationWaypointConfigView.h
//  DJISdkDemo
//
//  Created by Ares on 15/8/4.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import "NavigationWaypointActionView.h"

@protocol NavigationWaypointConfigViewDelegate <NSObject>

@required

-(void) configViewDidDeleteWaypointAtIndex:(int)index;

-(void) configViewDidDeleteAllWaypoints;

@end

@interface NavigationWaypointConfigView : UIView<UITextFieldDelegate>

@property(nonatomic, weak) id<NavigationWaypointConfigViewDelegate> delegate;

@property(nonatomic, strong) IBOutlet UITableView* waypointTableView;
@property(nonatomic, strong) IBOutlet UITableView* actionTableView;
@property(nonatomic, strong) IBOutlet UITextField* altitudeTextField;
@property(nonatomic, strong) IBOutlet UITextField* headingTextField;
@property(nonatomic, strong) IBOutlet UITextField* repeatTimeTextField;
@property(nonatomic, strong) IBOutlet UISwitch* turnModeSwitch;
@property(nonatomic, strong) IBOutlet UIButton* okButton;

@property(nonatomic, strong) NavigationWaypointActionView* actionView;

@property(nonatomic, weak) NSMutableArray* waypointList;
@property(nonatomic, strong) DJIWaypoint* selectedWaypoint;
@property(nonatomic, strong) DJIWaypointAction* selectedAction;

-(IBAction) onAddActionButtonClicked:(id)sender;

-(IBAction) onDelActionButtonClicked:(id)sender;

-(IBAction) onDelAllWaypointButtonClicked:(id)sender;

-(IBAction) onTurnModeSwitchValueChanged:(id)sender;

-(instancetype) initWithNib;

@end
