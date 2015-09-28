//
//  AppDelegate.h
//  DJISdkDemo
//
//  Created by Ares on 14-7-27.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJIAppManager.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, DJIAppManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
