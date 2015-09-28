//
//  JoystickTestViewController.h
//  DJISdkDemo
//
//  Created by Ares on 14-10-27.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <DJISDK/DJISDK.h>
#import "JoyStickView.h"
#import "DJILogerViewController.h"
#import "DJIDemoHelper.h"
#import "DJIBaseViewController.h"

@interface NavigationJoystickViewController : DJIBaseViewController<DJICameraDelegate, DJIDroneDelegate, GroundStationDelegate, DJIMainControllerDelegate>
{
    DJIDrone* _drone;
    CLLocationCoordinate2D _homeLocation;
    CLLocationCoordinate2D _droneLocation;
    NSMutableArray* _logText;
}

@property(nonatomic, strong) UIView* videoPreviewView;
@property(nonatomic, strong) IBOutlet JoyStickView* joystickLeft;
@property(nonatomic, strong) IBOutlet JoyStickView* joystickRight;

-(id) initWithDroneType:(DJIDroneType)type;

-(IBAction) onBackButtonClicked:(id)sender;

-(IBAction) onEnterNavigationButtonClicked:(id)sender;

-(IBAction) onTakeoffButtonClicked:(id)sender;
@end
