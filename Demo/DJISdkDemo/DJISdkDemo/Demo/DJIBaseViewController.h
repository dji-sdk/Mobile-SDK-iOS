//
//  DJIBaseViewController.h
//  DJISdkDemo
//
//  Created by Ares on 15/9/9.
//  Copyright © 2015年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import "DJILogerViewController.h"
#import "VideoPreviewer.h"

@interface DJIBaseViewController : DJILogerViewController

@property(nonatomic, readonly) DJIDrone* connectedDrone;

-(id) initWithDrone:(DJIDrone*)drone;

-(int) dataSourceFromDroneType:(DJIDroneType)type;

@end
