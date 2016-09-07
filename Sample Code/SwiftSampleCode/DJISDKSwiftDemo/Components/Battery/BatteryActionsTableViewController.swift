//
//  BatteryActionsTableViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 12/17/15.
//  Copyright © 2015 DJI. All rights reserved.
//

import DJISDK

class BatteryActionsTableViewController: DemoTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.connectedComponent = ConnectedProductManager.sharedInstance.fetchBattery()
        self.showComponentVersionSn = true
        self.sectionNames=["Battery"]
        self.items.append(DemoSettingItem(name: "Set/Get Self-discharge Day", andClass:BatterySelfDischargeViewController.self))
    }    
}
