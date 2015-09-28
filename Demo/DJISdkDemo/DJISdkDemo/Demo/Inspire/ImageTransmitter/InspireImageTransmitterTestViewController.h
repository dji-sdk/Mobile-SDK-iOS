//
//  InspireOFDMTestViewController.h
//  DJISdkDemo
//
//  Created by Ares on 15/4/9.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import "DJIDemoHelper.h"
#import "DJILogerViewController.h"
#import "DJIBaseViewController.h"

@interface InspireImageTransmitterTestViewController : DJIBaseViewController<DJIImageTransmitterDelegate, DJIDroneDelegate>
{
    DJIDrone* mDrone;
    DJIImageTransmitter* mImageTransmitter;
    
    NSMutableArray* mChannels;
}

@property(nonatomic, strong) IBOutlet UILabel* rcSignalPercentLabel;
@property(nonatomic, strong) IBOutlet UILabel* videoSignalPercentLabel;

@end
