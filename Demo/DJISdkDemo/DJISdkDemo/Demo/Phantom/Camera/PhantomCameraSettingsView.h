//
//  CameraSettingsView.h
//  DJISdkDemo
//
//  Created by Ares on 14-7-14.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>

@interface SettingsItem : NSObject

@property(nonatomic, retain) NSMutableArray* subSettings;
@property(nonatomic, retain) NSString* itemName;
@property(nonatomic, retain) NSValue* itemValue;
@property(nonatomic, assign) SEL itemAction;
@property(nonatomic, assign) BOOL isSubItem;

-(id) initWithItemName:(NSString*)name;

@end

@interface CustomTableViewCell : UITableViewCell

@property(nonatomic, retain) SettingsItem* settingItem;

@end

@interface PhantomCameraSettingsView : UIView<UITableViewDataSource, UITableViewDelegate>
{
    UITableView* _tableView1;
    UITableView* _tableView2;
    
    NSMutableArray* _mainSettingItems;
    SettingsItem* _selectedItem;
    DJICamera* _cameraManager;
    
    CameraRecordingFovType _fovType;
    CameraRecordingResolutionType _resolutionType;
}

@property(nonatomic, assign) CameraCaptureMode captureMode;

-(void) setCamera:(DJICamera*)cameraManager;

@end
