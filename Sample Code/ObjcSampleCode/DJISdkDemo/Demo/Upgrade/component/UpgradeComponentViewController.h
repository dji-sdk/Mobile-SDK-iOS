//
//  UpgradeComponentViewController.h
//  DJISdkDemo
//
//  Copyright © 2019 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface UpgradeComponentViewController : UIViewController

- (instancetype)initWithComponent:(DJIUpgradeComponent *)component;

@end

NS_ASSUME_NONNULL_END
