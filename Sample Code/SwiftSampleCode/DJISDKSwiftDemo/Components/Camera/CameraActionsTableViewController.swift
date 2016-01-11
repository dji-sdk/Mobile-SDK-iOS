//
//  CameraActionsTableViewController.h
//  DJISdkDemo
//
//  Created by DJI on 12/18/15.
//  Copyright © 2015 DJI. All rights reserved.
//

import DJISDK
class CameraActionsTableViewController: DemoTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.connectedComponent = ConnectedProductManager.sharedInstance.fetchCamera()
        self.showComponentVersionSn = true
        
        self.sectionNames = ["General", "FPV", "Shoot Photo", "Record Video", "Playback", "Media Download"]
        // General
        self.items.append([DemoSettingItem(name: "Push Info", andClass: CameraPushInfoViewController.self), DemoSettingItem(name: "Set/Get ISO", andClass: CameraISOViewController.self )])
        
        // FPV
        self.items.append([DemoSettingItem(name: "First Person View (FPV)", andClass: CameraFPVViewController.self)])
        
        // Shoot Photo
        self.items.append([DemoSettingItem(name: "Shoot Single Photo", andClass: CameraShootSinglePhotoViewController.self)])
        
        // Record Video
        self.items.append([DemoSettingItem(name: "Record video", andClass: CameraRecordVideoViewController.self)])
        
        // Playback
        self.items.append([DemoSettingItem(name: "Playback Push Info", andClass: CameraPlaybackPushInfoViewController.self), DemoSettingItem(name: "Playback commands", andClass: CameraPlaybackCommandViewController.self), DemoSettingItem(name: "Playback Download", andClass: CameraPlaybackDownloadViewController.self)])
       
        // Media Download
        self.items.append([DemoSettingItem(name: "Fetch media", andClass: CameraFetchMediaViewController.self)])
    }
}
