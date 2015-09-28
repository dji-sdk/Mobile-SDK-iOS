//
//  InspireHotPointTestViewController.h
//  DJISdkDemo
//
//  Created by Ares on 15/4/27.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <DJISDK/DJISDK.h>
#import "DJIDemoHelper.h"
#import "DJIAircraftAnnotation.h"
#import "HotPointConfigView.h"
#import "DJIBaseViewController.h"

@interface NavigationHotPointViewController : DJIBaseViewController<MKMapViewDelegate, DJINavigationDelegate, DJIMainControllerDelegate, DJIDroneDelegate, HotPointConfigViewDelegate, DJICameraDelegate>
{
    CLLocationCoordinate2D mCurrentHotpointCoordinate;
    DJIDrone* mDrone;
    NSObject<DJINavigation>* mNavigationManager;
    
    BOOL mIsMissionStarted;
    BOOL mIsMissionPaused;
    
    BOOL _isNeedMissionSync;
    BOOL _isRecording;
}

@property(nonatomic, strong) IBOutlet MKMapView* mapView;
@property(nonatomic, strong) UILabel* titleLabel;
@property(nonatomic, strong) IBOutlet UIView* topContentView;
@property(nonatomic, strong) IBOutlet UIButton* startStopButton;
@property(nonatomic, strong) IBOutlet UIButton* recordButton;
@property(nonatomic, strong) IBOutlet UIView* previewView;

@property(nonatomic, strong) DJIMCSystemState* systemState;

@property(nonatomic, strong) MKPointAnnotation* hotPointAnnotation;
@property(nonatomic, strong) DJIAircraftAnnotation* aircraftAnnotation;

@property(nonatomic, strong) HotPointConfigView* configView;

-(id) initWithDroneType:(DJIDroneType)type;

@end
