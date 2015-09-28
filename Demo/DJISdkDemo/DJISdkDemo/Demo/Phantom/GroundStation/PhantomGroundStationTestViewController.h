//
//  GroundStationTestViewController.h
//  DJISdkDemo
//
//  Created by Ares on 14-7-16.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>

@interface PhantomGroundStationTestViewController : UIViewController<DJIDroneDelegate, GroundStationDelegate>
{
    DJIDrone* _drone;
    id<DJIGroundStation> _groundStation;
    UILabel* _connectionStatusLabel;
    
    CLLocationCoordinate2D _homeLocation;
}

@property(nonatomic, strong) IBOutlet UILabel* satelliteLabel;
@property(nonatomic, strong) IBOutlet UILabel* homeLocationLabel;
@property(nonatomic, strong) IBOutlet UILabel* droneLocationLabel;
@property(nonatomic, strong) IBOutlet UILabel* contrlModeLabel;

-(IBAction) onOpenButtonClicked:(id)sender;

-(IBAction) onCloseButtonClicked:(id)sender;

-(IBAction) onUploadTaskClicked:(id)sender;

-(IBAction) onDownloadTaskClicked:(id)sender;

-(IBAction) onStartTaskButtonClicked:(id)sender;

-(IBAction) onPauseTaskButtonClicked:(id)sender;

-(IBAction) onContinueTaskButtonClicked:(id)sender;

-(IBAction) onGoHomeButtonClicked:(id)sender;

@end
