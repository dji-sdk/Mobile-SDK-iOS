//
//  CameraSettingsView.h
//  DJISdkDemo
//
//  Created by Ares on 14-7-14.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import "PhantomCameraSettingsView.h"
#import "DJILogerView.h"

@interface InspireCameraSettingsView : UIView<UITableViewDataSource, UITableViewDelegate>
{
    UITableView* _tableView1;
    UITableView* _tableView2;
    
    NSMutableArray* _mainSettingItems;
    SettingsItem* _selectedItem;
    DJICamera* _camera;
    
    CameraRecordingFovType _fovType;
    CameraRecordingResolutionType _resolutionType;
}

@property(nonatomic, assign) CameraCaptureMode captureMode;

-(void) setCamera:(DJICamera*)camera;

@end
