//
//  JoystickTestViewController.h
//  DJISdkDemo
//
//  Created by Ares on 14-10-27.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import "JoyStickView.h"

@interface JoystickTestViewController : UIViewController<DJICameraDelegate, DJIDroneDelegate, GroundStationDelegate>
{
    DJIDrone* _drone;
    id<DJIGroundStation> _groundStation;
    CLLocationCoordinate2D _homeLocation;
    CLLocationCoordinate2D _droneLocation;
    NSMutableArray* _logText;
}

@property(nonatomic, strong) UIView* videoPreviewView;
@property(nonatomic, strong) IBOutlet JoyStickView* joystickLeft;
@property(nonatomic, strong) IBOutlet JoyStickView* joystickRight;
@property(nonatomic, strong) IBOutlet UILabel* gpsLabel;
@property(nonatomic, strong) IBOutlet UILabel* locationLabel;
@property(nonatomic, strong) IBOutlet UILabel* logLabel;
@property(nonatomic, strong) IBOutlet UIScrollView* scrollView;

-(IBAction) onBackButtonClicked:(id)sender;

-(IBAction) onEnterNavigationButtonClicked:(id)sender;

@end
