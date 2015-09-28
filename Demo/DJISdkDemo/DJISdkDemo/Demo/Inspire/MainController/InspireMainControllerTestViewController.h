//
//  MainControllerTestViewController.h
//  DJISdkDemo
//
//  Created by Ares on 14-7-16.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <DJISDK/DJISDK.h>
#import "DJILogerViewController.h"
#import "DJIBaseViewController.h"
#import "DJIDemoHelper.h"

@interface InspireMainControllerTestViewController : DJIBaseViewController<DJIDroneDelegate, DJIMainControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate>
{
    DJIDrone* _drone;
    UILabel* _connectionStatusLabel;
    
    CLLocationManager* mLocationManager;
    CLLocationCoordinate2D mLastDeviceCoordinate;
    CLLocationCoordinate2D mLastDroneCoordinate;
    
    DJIMCSystemState* mLastSystemState;
    
    DJIInspireMainController* mInspireMainController;
}

@property(nonatomic, strong) IBOutlet UILabel* errorLabel;
@property(nonatomic, strong) IBOutlet UIScrollView* scrollView;
@property(nonatomic, strong) IBOutlet UILabel* statusTextView;
@end
