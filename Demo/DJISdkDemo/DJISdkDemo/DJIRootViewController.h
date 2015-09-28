//
//  DJIRootViewController.h
//  DJISdkDemo
//
//  Created by Ares on 15/2/9.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>

@interface DJIRootViewController : UIViewController<DJIAppManagerDelegate>

-(IBAction) onPhantomButtonClicked:(id)sender;

-(IBAction) onInspireButtonClicked:(id)sender;

-(IBAction) onPhantom3AdvancedButtonClicked:(id)sender;

@end
