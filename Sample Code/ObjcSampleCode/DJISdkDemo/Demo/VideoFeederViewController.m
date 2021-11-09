//
//  VideoFeederViewController.m
//  DJISdkDemo
//
//  Created by neo.xu on 2021/11/9.
//  Copyright © 2021 DJI. All rights reserved.
//

#import "VideoFeederViewController.h"
#import "DemoUtility.h"
#import "VideoPreviewerSDKAdapter.h"
#import <DJIWidget/DJIVideoPreviewer.h>
#import <DJISDK/DJISDK.h>

@interface VideoFeederViewController ()<UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *primaryView;
@property (nonatomic) DJIVideoPreviewer *primaryVideoPreviewer;
@property (nonatomic) VideoPreviewerSDKAdapter *primaryAdapter;

@property (weak, nonatomic) IBOutlet UIView *secondaryView;
@property (nonatomic) DJIVideoPreviewer *secondaryVideoPreviewer;
@property (nonatomic) VideoPreviewerSDKAdapter *secondaryAdapter;

@property (weak, nonatomic) IBOutlet UIPickerView *physicalSource;

@end

@implementation VideoFeederViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupVideoPreviewer];
    self.physicalSource.dataSource = self;
    self.physicalSource.delegate = self;
}

#pragma mark - Video Feed

- (void)setupVideoPreviewer {
    self.primaryVideoPreviewer = [[DJIVideoPreviewer alloc] init];
    self.primaryView.backgroundColor = [UIColor blackColor];
    [DJIVideoPreviewer instance].type = DJIVideoPreviewerTypeAutoAdapt;
    [self.primaryVideoPreviewer start];
    [self.primaryVideoPreviewer reset];
    [self.primaryVideoPreviewer setView:self.primaryView];
    self.primaryAdapter = [VideoPreviewerSDKAdapter adapterWithVideoPreviewer:self.primaryVideoPreviewer
                                                                 andVideoFeed:self.primaryVideoFeed];
    [self.primaryAdapter start];
    [self.primaryAdapter setupFrameControlHandler];
    
    
    self.secondaryVideoPreviewer = [[DJIVideoPreviewer alloc] init];
    self.secondaryView.backgroundColor = [UIColor blackColor];
    [DJIVideoPreviewer instance].type = DJIVideoPreviewerTypeAutoAdapt;
    [self.secondaryVideoPreviewer start];
    [self.secondaryVideoPreviewer reset];
    [self.secondaryVideoPreviewer setView:self.secondaryView];
    self.secondaryAdapter = [VideoPreviewerSDKAdapter adapterWithVideoPreviewer:self.secondaryVideoPreviewer
                                                                   andVideoFeed:self.secondaryVideoFeed];
    [self.secondaryAdapter start];
    [self.secondaryAdapter setupFrameControlHandler];
}

-(DJIVideoFeed *)primaryVideoFeed {
    return [DJISDKManager videoFeeder].primaryVideoFeed;
}

-(DJIVideoFeed *)secondaryVideoFeed {
    return [DJISDKManager videoFeeder].secondaryVideoFeed;
}

-(DJIVideoFeeder *)videoFeeder {
    return [DJISDKManager videoFeeder];
}

- (DJIOcuSyncLink *)link {
    return [DemoComponentHelper fetchAirLink].ocuSyncLink;
}

#pragma mark - UIPickerView
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 5;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (row) {
        case 0:
            return @"left";
        case 1:
            return @"right";
        case 2:
            return @"top";
        case 3:
            return @"fpv";
        default:
            return @"unknown";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        return;
    }
    NSInteger primaryIndex = [pickerView selectedRowInComponent:0];
    NSInteger secondaryIndex = [pickerView selectedRowInComponent:1];
    DJIVideoFeedPhysicalSource primary = DJIVideoFeedPhysicalSourceUnknown;
    DJIVideoFeedPhysicalSource second = DJIVideoFeedPhysicalSourceUnknown;
    switch (primaryIndex) {
        case 0:
            primary = DJIVideoFeedPhysicalSourceLeftCamera;
            break;
        case 1:
            primary = DJIVideoFeedPhysicalSourceRightCamera;
            break;
        case 2:
            primary = DJIVideoFeedPhysicalSourceTopCamera;
            break;
        case 3:
            primary = DJIVideoFeedPhysicalSourceFPVCamera;
            break;
        default:
            break;
    }
    switch (secondaryIndex) {
        case 0:
            second = DJIVideoFeedPhysicalSourceLeftCamera;
            break;
        case 1:
            second = DJIVideoFeedPhysicalSourceRightCamera;
            break;
        case 2:
            second = DJIVideoFeedPhysicalSourceTopCamera;
            break;
        case 3:
            second = DJIVideoFeedPhysicalSourceFPVCamera;
            break;
        default:
            break;
    }
    [self.link assignSourceToPrimaryChannel:primary secondaryChannel:second withCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"allocation error: %@", error.description);
        } else {
            ShowResult(@"success");
        }
    }];
}

@end
