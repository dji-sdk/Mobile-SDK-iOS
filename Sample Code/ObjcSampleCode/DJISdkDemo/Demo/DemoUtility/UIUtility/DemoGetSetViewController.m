//
//  DemoGetSetViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  A UI base view controller that is used for setting and getting a parameter of a component. A view controller for a component can inherit
 *  this class for convenience.
 */
#import "DemoGetSetViewController.h"

@interface DemoGetSetViewController ()

@end

@implementation DemoGetSetViewController

-(instancetype)init {
    return [super initWithNibName:@"DemoGetSetViewController"  bundle:[NSBundle mainBundle]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // The getValueTextField is only used for displaying, not interaction is required.
    [self.getValueTextField setUserInteractionEnabled:NO];
}

- (IBAction)onGetButtonClicked:(id)sender {
}

- (IBAction)onSetButtonClicked:(id)sender {
}
@end
