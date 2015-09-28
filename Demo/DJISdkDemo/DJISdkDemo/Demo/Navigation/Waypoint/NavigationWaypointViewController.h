//
//  GroundStationTestViewController.h
//  DJISdkDemo
//
//  Created by Ares on 14-7-16.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <DJISDK/DJISDK.h>
#import "DJILogerViewController.h"
#import "DJIDemoHelper.h"
#import "NavigationWaypointConfigView.h"
#import "DJIBaseViewController.h"

@interface NavigationWaypointViewController : DJIBaseViewController<DJIDroneDelegate, GroundStationDelegate, DJIMainControllerDelegate, DJINavigationDelegate, MKMapViewDelegate, NavigationWaypointConfigViewDelegate>
{
    DJIDrone* _drone;
    UILabel* _connectionStatusLabel;
    
    BOOL _isPOIMissionStarted;
    BOOL _isPOIMissionPaused;
    
    CLLocationCoordinate2D mCurrentDroneCoordinate;
}

@property(nonatomic, strong) UILabel* statusLabelLeft;

@property(nonatomic, weak) NSObject<DJINavigation>* navigationManager;
@property(nonatomic, weak) NSObject<DJIWaypointMission>* waypointMission;

@property(nonatomic, strong) DJIMCSystemState * mcSystemState;

@property(nonatomic, weak) IBOutlet MKMapView* mapView;

@property(nonatomic, strong) UIAlertView* progressAlertView;

-(id) initWithDroneType:(DJIDroneType)type;

-(IBAction) onEnterNavigationButtonClicked:(id)sender;

-(IBAction) onExitNavigationButtonClicked:(id)sender;

-(IBAction) onUploadMissionButtonClicked:(id)sender;

-(IBAction) onDownloadMissionButtonClicked:(id)sender;

-(IBAction) onStartMissionButtonClicked:(id)sender;

-(IBAction) onStopMissionButtonClicked:(id)sender;

-(IBAction) onPauseMissionButtonClicked:(id)sender;

-(IBAction) onResumeMissionButtonClicked:(id)sender;

-(IBAction) onBackButtonClicked:(id)sender;

-(IBAction) onMissionConfigButtonClicked:(id)sender;

-(IBAction) onWaypointConfigButtonClicked:(id)sender;

-(IBAction) onEditButtonClicked:(id)sender;

@end
