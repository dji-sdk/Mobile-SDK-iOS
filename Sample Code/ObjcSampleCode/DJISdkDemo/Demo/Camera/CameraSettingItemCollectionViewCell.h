//
//  CameraSettingItemCollectionViewCell.h
//  DJISdkDemo
//
//  Created by ethan.jiang on 2020/5/20.
//  Copyright © 2020 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraSettingItemCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;

@end

NS_ASSUME_NONNULL_END
