//
//  GimbalActionsTableTableViewController.h
//  DJISdkDemo
//
//  Created by DJI on 12/17/15.
//  Copyright © 2015 DJI. All rights reserved.
//

import DJISDK

class GimbalActionsTableTableViewController: DemoTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.connectedComponent = ConnectedProductManager.sharedInstance.fetchGimbal()
        self.showComponentVersionSn = true
        
        self.items.append(DemoSettingItem(name: "Push Data", andClass: GimbalPushInfoViewController.self))
        self.items.append(DemoSettingItem(name: "Rotation with speed", andClass: GimbalRotationInSpeedViewController.self))
        self.items.append(DemoSettingItem(name: "Gimbal Capability", andClass: GimbalCapabilityViewController.self))
    }
}
