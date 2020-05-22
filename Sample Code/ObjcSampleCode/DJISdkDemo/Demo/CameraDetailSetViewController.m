//
//  CameraDetailSetViewController.m
//  DJISdkDemo
//
//  Created by ethan.jiang on 2020/5/19.
//  Copyright © 2020 DJI. All rights reserved.
//

#import "CameraDetailSetViewController.h"
#import "CameraSettingItemCollectionViewCell.h"
#import "DemoUtilityMacro.h"
#import "DemoAlertView.h"

@interface CameraDetailSetViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, copy) NSArray <NSString *> *titles;
@property (nonatomic, copy) NSString *currentItem;
@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation CameraDetailSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.tabBarController) {
        self.type = MultilensCameraSettingTypeThermal;
        [self fetchCameraAndLens];
    }
    self.titles = [[self generateTitles] copy];
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CameraSettingItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.nameLabel.text = self.titles[indexPath.item];
    cell.inputTextField.delegate = self;
    cell.layer.borderWidth = 1.0f;
    cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titles.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CameraSettingItemCollectionViewCell *cell = (CameraSettingItemCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSString *itemTitle = self.titles[indexPath.item];
    self.currentItem = [itemTitle copy];
    self.selectedIndex = indexPath.item;
    [UIView transitionWithView:cell.contentView duration:1 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        if (cell.nameLabel.hidden) {
            cell.nameLabel.hidden = NO;
            cell.tipLabel.hidden = YES;
            cell.inputTextField.hidden = YES;
        } else {
            cell.nameLabel.hidden = YES;
            cell.tipLabel.hidden = NO;
            cell.inputTextField.hidden = NO;
        }
    } completion:^(BOOL finished) {
        WeakRef(target);
        switch (self.type) {
            case MultilensCameraSettingTypeLensIrrelevant: {
                if (indexPath.item == 0) {
                    GET_CAMERA_SETTING(FlatMode, DJIFlatCameraMode);
                } else {
                    GET_CAMERA_SETTING(CameraVideoStreamSource, DJICameraVideoStreamSource);
                }
                
            }
                return;
            case MultilensCameraSettingType3A: {
                if (indexPath.item == 0) {
                    GET_LENS_SETTING(ISO, DJICameraISO);
                } else if (indexPath.item == 1) {
                    GET_LENS_SETTING(ExposureMode, DJICameraExposureMode);
                }
            }
                return;
            case MultilensCameraSettingTypeFocus: {
                
                GET_LENS_SETTING(FocusMode, DJICameraFocusMode);
            }
                return;
            case MultilensCameraSettingTypeZoom: {
                
                GET_LENS_SCALAR_SETTING(HybridZoomFocalLength);
            }
                return;
            case MultilensCameraSettingTypeThermal: {
                
                GET_LENS_SETTING(ThermalFFCMode, DJICameraThermalFFCMode);
            }
                return;
            default:
                return;
        }
    }];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(SCREEN_WIDTH / 3.f - 10.f, SCREEN_WIDTH / 3.f - 10.f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(4, 4, 4, 4);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    WeakRef(target);
    NSInteger input = [textField.text integerValue];
    switch (self.type) {
        case MultilensCameraSettingTypeLensIrrelevant: {
            if (self.selectedIndex == 0) {
                SET_CAMERA_SETTING(FlatMode, input);
            } else {
                SET_CAMERA_SETTING(CameraVideoStreamSource, input);
            }
            
        }
            return YES;
        case MultilensCameraSettingType3A: {
            if (self.selectedIndex == 0) {
                SET_LENS_SETTING(ISO, input);
            } else if (self.selectedIndex == 1) {
                SET_LENS_SETTING(ExposureMode, input);
            }
        }
            return YES;
        case MultilensCameraSettingTypeFocus: {
            
            SET_LENS_SETTING(FocusMode, input);
        }
            return YES;
        case MultilensCameraSettingTypeZoom: {
            
            SET_LENS_SETTING(HybridZoomFocalLength, input);
        }
            return YES;
        case MultilensCameraSettingTypeThermal: {
            
            SET_LENS_SETTING(ThermalFFCMode, input);
        }
            return YES;
        default:
            return YES;
    }
}

#pragma mark - helper
- (NSArray <NSString *> *)generateTitles {
    switch (self.type) {
        case MultilensCameraSettingTypeLensIrrelevant:
            return @[@"FlatMode", @"CameraVideoStreamSource"];
        case MultilensCameraSettingType3A:
            return @[@"ISO", @"ExposureMode", @"Aperture", @"ExposureCompensation"];
        case MultilensCameraSettingTypeFocus:
            return @[@"FocusMode"];
        case MultilensCameraSettingTypeZoom:
            return @[@"FocalLength"];
        default:
            return @[@"ThermalFFCMode"];
    }
}

- (void)fetchCameraAndLens {
    DJIAircraft *aircraft = (DJIAircraft *)[DJISDKManager product];
    for (DJICamera *camera in [aircraft cameras]) {
        if ([camera.displayName isEqualToString:self.tabBarController.title]) {
            self.camera = camera;
            self.lens = camera.lenses.lastObject;
        }
    }
}

DESCRIPTION_FOR_ENUM(DJIFlatCameraMode, FlatMode,
                     DJIFlatCameraModeVideoNormal,
                     DJIFlatCameraModePhotoTimeLapse,
                     DJIFlatCameraModePhotoAEB,
                     DJIFlatCameraModePhotoSingle,
                     DJIFlatCameraModePhotoBurst,
                     DJIFlatCameraModePhotoHDR,
                     DJIFlatCameraModePhotoInterval,
                     DJIFlatCameraModePhotoHyperLight,
                     DJIFlatCameraModePhotoPanorama,
                     DJIFlatCameraModePhotoEHDR,
                     DJIFlatCameraModeUnknown
                     );


DESCRIPTION_FOR_ENUM(DJICameraVideoStreamSource, CameraVideoStreamSource,
                     DJICameraVideoStreamSourceDefault,
                     DJICameraVideoStreamSourceWide,
                     DJICameraVideoStreamSourceZoom,
                     DJICameraVideoStreamSourceInfraredThermal,
                     DJICameraVideoStreamSourceUnknown
                     );

DESCRIPTION_FOR_ENUM(DJICameraISO, ISO,
                     DJICameraISOAuto,
                     DJICameraISO100,
                     DJICameraISO200,
                     DJICameraISO400,
                     DJICameraISO800,
                     DJICameraISO1600,
                     DJICameraISO3200,
                     DJICameraISO6400,
                     DJICameraISO12800,
                     DJICameraISO25600,
                     DJICameraISOFixed,
                     DJICameraISOUnknown
                     );

DESCRIPTION_FOR_ENUM(DJICameraExposureMode, ExposureMode,
                     DJICameraExposureModeProgram,
                     DJICameraExposureModeShutterPriority,
                     DJICameraExposureModeAperturePriority,
                     DJICameraExposureModeManual,
                     DJICameraExposureModeUnknown
                     );

DESCRIPTION_FOR_ENUM(DJICameraFocusMode, FocusMode,
                     DJICameraFocusModeManual,
                     DJICameraFocusModeAuto,
                     DJICameraFocusModeAFC,
                     DJICameraFocusModeUnknown
                     );

DESCRIPTION_FOR_ENUM(DJICameraThermalFFCMode, ThermalFFCMode,
                     DJICameraThermalFFCModeAuto,
                     DJICameraThermalFFCModeManual,
                     DJICameraThermalFFCModeUnknown
                     );



@end
