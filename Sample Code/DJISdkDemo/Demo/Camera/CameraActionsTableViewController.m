//
//  CameraActionsTableViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"
#import "CameraActionsTableViewController.h"
#import "CameraPushInfoViewController.h"
#import "CameraISOViewController.h"
#import "CameraShootSinglePhotoViewController.h"
#import "CameraRecordVideoViewController.h"
#import "CameraPlaybackPushInfoViewController.h"
#import "CameraPlaybackCommandViewController.h"
#import "CameraPlaybackDownloadViewController.h"
#import "CameraFetchMediaViewController.h"
#import "CameraFPVViewController.h"

@interface CameraActionsTableViewController ()

@end

@implementation CameraActionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sectionNames = [NSMutableArray arrayWithArray:@[@"General", @"FPV", @"Shoot Photo", @"Record Video", @"Playback", @"Media Download"]];
    
    // General
    [self.items addObject:@[[DemoSettingItem itemWithName:@"Push Info" andClass:[CameraPushInfoViewController class]],
                            [DemoSettingItem itemWithName:@"Set/Get ISO" andClass:[CameraISOViewController class]]]];
    // FPV
    [self.items addObject:@[[DemoSettingItem itemWithName:@"First Person View (FPV)" andClass:[CameraFPVViewController class]]]];
    
    // Shoot Photo
    [self.items addObject:@[[DemoSettingItem itemWithName:@"Shoot Single Photo" andClass:[CameraShootSinglePhotoViewController class]]]];
    
    // Record Video
    [self.items addObject:@[[DemoSettingItem itemWithName:@"Record video" andClass:[CameraRecordVideoViewController class]]]];
    
    // Playback
    [self.items addObject:@[[DemoSettingItem itemWithName:@"Playback Push Info" andClass:[CameraPlaybackPushInfoViewController class]],
                            [DemoSettingItem itemWithName:@"Playback commands" andClass:[CameraPlaybackCommandViewController class]],
                            [DemoSettingItem itemWithName:@"Playback Download" andClass:[CameraPlaybackDownloadViewController class]]]];

    // Media Download
    [self.items addObject:@[[DemoSettingItem itemWithName:@"Fetch media" andClass:[CameraFetchMediaViewController class]]]];
    
}

-(DJIBaseComponent *)getComponent {
    return [DemoComponentHelper fetchCamera];
}

@end
