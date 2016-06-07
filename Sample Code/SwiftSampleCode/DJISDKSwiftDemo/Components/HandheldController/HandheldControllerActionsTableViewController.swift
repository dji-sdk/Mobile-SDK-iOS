//
//  HandheldControllerActionsTableViewController.swift
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
import DJISDK

class HandheldControllerActionsTableViewController: DemoTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sectionNames = ["General"]
        self.connectedComponent = ConnectedProductManager.sharedInstance.fetchHandheldController()
        self.showComponentVersionSn = true
        
        self.items.append([DemoSettingItem(name:"Sleep Mode", andClass:SleepModeViewController.self)])
    }
    
}