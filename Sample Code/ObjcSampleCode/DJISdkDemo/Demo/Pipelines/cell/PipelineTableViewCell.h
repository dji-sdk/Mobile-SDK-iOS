//
//  PipelineTableViewCell.h
//  DJISdkDemo
//
//  Copyright © 2020 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PipelineTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UIButton *download;
@property (weak, nonatomic) IBOutlet UIButton *upload;
@property (weak, nonatomic) IBOutlet UIButton *disconnect;

@end

NS_ASSUME_NONNULL_END
