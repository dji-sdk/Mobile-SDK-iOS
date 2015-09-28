//
//  Phantom3MediaTestTableViewController.h
//  DJISdkDemo
//
//  Created by Ares on 15/5/19.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import "MBProgressHUD.h"
#import <pthread.h>
#import "DJIBaseViewController.h"

@interface Phantom3MediaTestTableViewController : UIViewController<DJIDroneDelegate, DJICameraDelegate, UITableViewDataSource, UITableViewDelegate>

-(id) initWithDrone:(DJIDrone*)drone;
-(id) initWithDroneType:(DJIDroneType)type;

@end
