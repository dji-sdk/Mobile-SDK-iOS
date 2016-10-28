//
//  RCActionsTableViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 16/1/6.
//  Copyright © 2016 DJI. All rights reserved.
//

import DJISDK
class RCActionsTableViewController: DemoTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.connectedComponent = ConnectedProductManager.sharedInstance.fetchRemoteController()
        self.showComponentVersionSn = true
        
        self.sectionNames = ["General"]
        let item1: DemoSettingItem = DemoSettingItem(name: "RCHardwareState", andClass: RCHardwareStateViewController.self)
        let item2: DemoSettingItem = DemoSettingItem(name: "RCParing", andClass: RCParingViewController.self)
        self.items.append([item1])
        self.items.append([item2])
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
