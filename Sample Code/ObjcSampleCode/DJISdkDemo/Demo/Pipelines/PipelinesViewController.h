//
//  PipelinesViewController.h
//  DJISdkDemo
//
//  Copyright © 2020 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const PipelinesKey;

@interface PipelinesViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *pipelineId;
@property (weak, nonatomic) IBOutlet UISegmentedControl *deviceType;
@property (weak, nonatomic) IBOutlet UISegmentedControl *transmissionType;
@property (weak, nonatomic) IBOutlet UITableView *existPipelines;
@property (weak, nonatomic) IBOutlet UITextView *logView;

@end

NS_ASSUME_NONNULL_END
