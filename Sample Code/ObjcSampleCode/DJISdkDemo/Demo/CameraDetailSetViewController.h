//
//  CameraDetailSetViewController.h
//  DJISdkDemo
//
//  Created by ethan.jiang on 2020/5/19.
//  Copyright © 2020 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MultilensCameraSettingType) {
    MultilensCameraSettingTypeLensIrrelevant, // storage/mode/liveviewSource
    //the following are all sent to the lens
    MultilensCameraSettingType3A, // whiteBalance/aperture/exposure/iso etc.
    MultilensCameraSettingTypeFocus,
    MultilensCameraSettingTypeZoom,
    MultilensCameraSettingTypeThermal,

};

@interface CameraDetailSetViewController : UIViewController

@property (nonatomic, assign) MultilensCameraSettingType type;
@property (nonatomic, strong) DJICamera *camera;
@property (nonatomic, strong) DJILens *lens;

@end

NS_ASSUME_NONNULL_END
