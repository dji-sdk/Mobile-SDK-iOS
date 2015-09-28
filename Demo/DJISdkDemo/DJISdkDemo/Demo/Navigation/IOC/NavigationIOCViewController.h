//
//  DJIIOCViewController.h
//  DJISdkDemo
//
//  Created by Ares on 15/7/1.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import <MapKit/MapKit.h>
#import "DJIBaseViewController.h"

@interface NavigationIOCViewController : DJIBaseViewController<DJIDroneDelegate, DJIMainControllerDelegate, DJICameraDelegate, MKMapViewDelegate, DJINavigationDelegate>

@property(nonatomic, strong) DJIDrone* drone;

@property(nonatomic, weak) NSObject<DJINavigation>* navigationManager;

@property(nonatomic, assign) BOOL isRecording;

-(id) initWithDroneType:(DJIDroneType)type;

@end
