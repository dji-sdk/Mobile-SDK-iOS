//
//  NavigationViewController.h
//  DJISdkDemo
//
//  Created by Ares on 15/7/2.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import "DJIBaseViewController.h"

@interface NavigationViewController : DJIBaseViewController

@property(nonatomic, readonly) DJIDroneType droneType;

-(id) initWithDroneType:(DJIDroneType)type;

@end
