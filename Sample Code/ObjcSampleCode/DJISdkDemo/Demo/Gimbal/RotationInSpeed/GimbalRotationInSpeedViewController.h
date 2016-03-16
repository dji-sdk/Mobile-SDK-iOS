//
//  GimbalRotationInSpeedViewController.h
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GimbalRotationInSpeedViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *upButton;
@property (weak, nonatomic) IBOutlet UIButton *downButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;


- (IBAction)onUpButtonClicked:(id)sender;
- (IBAction)onDownButtonClicked:(id)sender;
- (IBAction)onStopButtonClicked:(id)sender;

@end
