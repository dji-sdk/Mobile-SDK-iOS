//
//  InspireFollowMeViewController.h
//  DJISdkDemo
//
//  Created by Ares on 15/3/5.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <DJISDK/DJISDK.h>
#import "DJILogerViewController.h"
#import "DJIDemoHelper.h"
#import "DJIBaseViewController.h"

@interface NavigationFollowMeViewController : DJIBaseViewController<CLLocationManagerDelegate, DJINavigationDelegate, DJIMainControllerDelegate, DJICameraDelegate>
{
    CLLocationManager* mLocationManager;
    NSTimer* mUpdateTimer;
}

@property(nonatomic, strong) DJIDrone* drone;
@property(nonatomic, weak) NSObject<DJINavigation>* navigationManager;

@property(nonatomic, strong) IBOutlet UILabel* locationLabel;
@property(nonatomic, strong) IBOutlet UILabel* accuracyLabel;
@property(nonatomic, strong) IBOutlet UISegmentedControl* headingControl;

@property(nonatomic, strong) IBOutlet UIView* previewView;

@property(nonatomic, assign) CLLocationCoordinate2D userLocation;
@property(nonatomic, assign) CLLocationCoordinate2D droneLocation;

@property(nonatomic, assign) BOOL followMeStarted;

-(id) initWithDroneType:(DJIDroneType)type;

-(IBAction) onEnterNavigationButtonClicked:(id)sender;

-(IBAction) onExitNavigationButtonClicked:(id)sender;

-(IBAction) onFollowMeStart:(id)sender;

-(IBAction) onFollowMeStop:(id)sender;

-(IBAction) onFollowMePause:(id)sender;

-(IBAction) onFollowMeResume:(id)sender;

@end
