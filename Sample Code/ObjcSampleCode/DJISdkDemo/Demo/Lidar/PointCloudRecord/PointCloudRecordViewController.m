//
//  PointCloudRecordViewController.m
//  DJISdkDemo
//
//  Created by neo.xu on 2021/8/2.
//  Copyright © 2021 DJI. All rights reserved.
//

#import "PointCloudRecordViewController.h"
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"

@interface PointCloudRecordViewController () <DJILidarDelegate>

@property (weak, nonatomic) IBOutlet UIButton *startRecordButton;
@property (weak, nonatomic) IBOutlet UIButton *stopRecordButton;
@property (weak, nonatomic) IBOutlet UIButton *startReadLiveViewDataButton;
@property (weak, nonatomic) IBOutlet UIButton *stopReadLiveViewDataButton;
@property (weak, nonatomic) IBOutlet UILabel *liveViewDataLabel;
@property (nonatomic, assign) NSUInteger receivedPointNum;

@end

@implementation PointCloudRecordViewController

- (DJILidar *)lidar {
    return [DemoComponentHelper fetchLidar];
}

- (void)viewWillAppear:(BOOL)animated {
    [[self lidar] addPointCloudStatusListener:self withQueue:nil];
    [[self lidar] addPointCloudLiveViewDataListener:self withQueue:nil];
}

- (IBAction)onStartRecordButtonClicked:(id)sender {
    WeakRef(target);
    [self.lidar pointCloudRecord:DJILidarPointCloudRecordStart
                  withCompletion:^(NSError *_Nullable error) {
                    WeakReturn(target);
                    if (error == nil) {
                        ShowResult(@"Send Point Cloud Record Command Success");
                    } else {
                        ShowResult(@"Error: %@", error.description);
                    }
                  }];
}

- (IBAction)onStopRecordButtonClicked:(id)sender {
    WeakRef(target);
    [self.lidar pointCloudRecord:DJILidarPointCloudRecordStop
                  withCompletion:^(NSError *_Nullable error) {
                    WeakReturn(target);
                    if (error == nil) {
                        ShowResult(@"Send Point Cloud Record Command Success");
                    } else {
                        ShowResult(@"Error: %@", error.description);
                    }
                  }];
}

- (IBAction)onStartReadLiveViewDataButtonClicked:(id)sender {
    self.receivedPointNum = 0;
    [[self lidar] startReadPointCloudLiveViewDataWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"lidar start read point cloud fail:%@", error.description);
        } else {
            ShowResult(@"lidar start read point cloud success");
        }
    }];
}

- (IBAction)onStopReadLiveViewDataButtonClicked:(id)sender {
    [[self lidar] stopReadPointCloudLiveViewDataWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"lidar stop read point cloud fail:%@", error.description);
        } else {
            ShowResult(@"lidar stop read point cloud success");
        }
    }];
}

- (void)lidar:(DJILidar *)lidar didReceiveLiveViewData:(NSArray<DJILidarPointCloudLiveViewData *> *)pointCloudLiveViewData {
    self.receivedPointNum += pointCloudLiveViewData.count;
    NSString *dataString = [NSString stringWithFormat:@"receive point num:%lu\n, last point x:%.3f\n y:%.3f\n z:%.3f\n", (unsigned long)self.receivedPointNum, [pointCloudLiveViewData lastObject].x, [pointCloudLiveViewData lastObject].y, [pointCloudLiveViewData lastObject].z];
    self.liveViewDataLabel.text = dataString;
}



- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
