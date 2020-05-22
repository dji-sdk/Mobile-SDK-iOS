//
//  CameraSettingsViewController.m
//  DJISdkDemo
//
//  Created by ethan.jiang on 2020/5/19.
//  Copyright © 2020 DJI. All rights reserved.
//

#import "CameraSettingsViewController.h"
#import "CameraDetailSetViewController.h"
#import "DemoComponentHelper.h"

@interface CameraSettingsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray <NSArray <NSString*> *> *settingItems;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) DJICamera *camera;
@property (nonatomic, strong) DJILens *lens;
@property (nonatomic, strong) NSString *cameraName;

@end

@implementation CameraSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.cameraName = [[NSUserDefaults standardUserDefaults] valueForKey:@"currentCameraName"];
    NSUInteger selectedIndex = [self.tabBarController.viewControllers indexOfObject:self];
    self.index = selectedIndex;
    [self fetchCameraAndLens];
    [self generateSettingItems:selectedIndex];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.settingItems.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.settingItems[section] firstObject];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"settingCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSArray *configArray = self.settingItems[indexPath.section];
    cell.textLabel.text = [configArray objectAtIndex:indexPath.row + 1];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.settingItems[section].count - 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"CameraParamSetting" bundle:[NSBundle mainBundle]];
    CameraDetailSetViewController *detailVC = [board instantiateViewControllerWithIdentifier:@"detailSetting"];
    detailVC.type = indexPath.section;
    detailVC.camera = self.camera;
    detailVC.lens = self.lens;
    NSArray *configArray = self.settingItems[indexPath.section];
    detailVC.title = [configArray objectAtIndex:indexPath.row + 1];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)generateSettingItems:(NSUInteger)index {
    NSArray *settings;
    if (index == 0) {//zoom
        NSArray *cameraSettings = @[@"Camera Setting", @"Mode & Liveview"];
        NSArray *basicSettings = @[@"Basic Parameter", @"Set Parameters"];
        NSArray *focusSettings = @[@"Focus", @"Focus Mode"];
        NSArray *zoomSettings = @[@"Zoom", @"Focal Length"];
        settings = @[cameraSettings, basicSettings, focusSettings, zoomSettings];
    } else {//wide
        NSArray *basicSettings = @[@"Basic Parameter", @"Set Parameters"];
        NSArray *focusSettings = @[@"Focus", @"Focus Mode"];
        settings = @[basicSettings, focusSettings];
    }
    self.settingItems = [settings copy];
}

- (void)fetchCameraAndLens {
    for (DJICamera *camera in [DemoComponentHelper fetchCameras]) {
        if ([camera.displayName isEqualToString:self.cameraName]) {
            self.camera = camera;
            self.lens = camera.lenses[self.index];
        }
    }
}

@end
