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
#import "CameraMediaPlaybackViewController.h"
#import "In2P4PCameraPlayBackViewController.h"
#import "XT2CameraViewController.h"

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

    if ([DemoXT2Helper isXT2Camera]) {
        [self.sectionNames insertObject:@"XT2" atIndex:2];
        [self.items addObject:@[[DemoSettingItem itemWithName:@"XT2 Camera" andClass:[XT2CameraViewController class]]]];
    }
    // Shoot Photo
    [self.items addObject:@[[DemoSettingItem itemWithName:@"Shoot Single Photo" andClass:[CameraShootSinglePhotoViewController class]]]];
    
    // Record Video
    [self.items addObject:@[[DemoSettingItem itemWithName:@"Record video" andClass:[CameraRecordVideoViewController class]]]];
    
    // Playback
    [self.items addObject:@[[DemoSettingItem itemWithName:@"Playback Push Info" andClass:[CameraPlaybackPushInfoViewController class]],
                            [DemoSettingItem itemWithName:@"Playback commands" andClass:[CameraPlaybackCommandViewController class]],
                            [DemoSettingItem itemWithName:@"Playback Download" andClass:[CameraPlaybackDownloadViewController class]]]];

    // Media Download
    NSMutableArray *medias = [NSMutableArray arrayWithObject:[DemoSettingItem itemWithName:@"Fetch media" andClass:[CameraFetchMediaViewController class]]];
    DJIBaseProduct *product = [DemoComponentHelper fetchProduct];
    if ([product.model isEqualToString:DJIAircraftModelNamePhantom4Pro] ||
        [product.model isEqualToString:DJIAircraftModelNameInspire2]) {
        [medias addObject:[DemoSettingItem itemWithName:@"Media playback" andClass:[In2P4PCameraPlayBackViewController class]]];
    }
    else {
        [medias addObject:[DemoSettingItem itemWithName:@"Media playback" andClass:[CameraMediaPlaybackViewController class]]];
    }
    [self.items addObject:medias];
    
}

-(DJIBaseComponent *)getComponent {
    return [DemoComponentHelper fetchCamera];
}

// Override parent's delegate to handle the special case for CameraMediaPlaybackViewController.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];

    DemoSettingItem* item = nil;
    if (self.sectionNames.count == 0) {
        item = [self.items objectAtIndex:row];
    }
    else {
        item = [[self.items objectAtIndex:section] objectAtIndex:row];
    }

    UIViewController * vc = [[item.viewControllerClass alloc] init];
    vc.title = item.itemName;
    if ([vc.title isEqual:@"Media playback"] && [vc isKindOfClass:[CameraMediaPlaybackViewController class]]) {
        // Media Playback view controller only supports landscape orientation.
        // Use presentViewController: instead of navigationController. 
        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController;
        }
        if (topController != vc) {
            [topController presentViewController:vc animated:YES completion:nil];
        }
    }
    else {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
