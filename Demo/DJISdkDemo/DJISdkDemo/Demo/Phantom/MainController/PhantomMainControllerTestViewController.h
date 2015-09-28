//
//  MainControllerTestViewController.h
//  DJISdkDemo
//
//  Created by Ares on 14-7-16.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>

@interface PhantomMainControllerTestViewController : UIViewController<DJIDroneDelegate, DJIMainControllerDelegate>
{
    DJIDrone* _drone;
    UILabel* _connectionStatusLabel;
    
}

@property(nonatomic, strong) IBOutlet UILabel* errorLabel;
@property(nonatomic, strong) IBOutlet UITextView* statusTextView;
@end
