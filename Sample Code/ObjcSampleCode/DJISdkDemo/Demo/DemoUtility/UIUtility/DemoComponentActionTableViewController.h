//
//  DemoComponentActionTableViewController.h
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import "DemoTableViewController.h"

@class DJIBaseComponent;

@interface DemoComponentActionTableViewController : DemoTableViewController

@property(nonatomic, strong) NSString* version;
@property(nonatomic, strong) NSString* serialNumber;

-(DJIBaseComponent*)getComponent;

@end
