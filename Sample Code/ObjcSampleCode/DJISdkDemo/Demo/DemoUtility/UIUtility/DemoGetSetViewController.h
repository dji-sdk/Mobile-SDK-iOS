//
//  DemoGetSetViewController.h
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DemoGetSetViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *getValueTextField;
@property (weak, nonatomic) IBOutlet UITextField *setValueTextField;
@property (weak, nonatomic) IBOutlet UIButton *getValueButton;
@property (weak, nonatomic) IBOutlet UIButton *setValueButton;
@property (weak, nonatomic) IBOutlet UILabel *rangeLabel;

- (IBAction)onGetButtonClicked:(id)sender;

- (IBAction)onSetButtonClicked:(id)sender;

@end
