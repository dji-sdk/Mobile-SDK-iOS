//
//  FCActionsTableViewController.swift
//  DJISdkDemo
//
//  Created by DJI on 16/1/4.
//  Copyright © 2016 DJI. All rights reserved.
//

import DJISDK

class FCActionsTableViewController: DemoTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Flight Controller"
        self.connectedComponent = ConnectedProductManager.sharedInstance.fetchFlightController()
        self.showComponentVersionSn = true
        
        self.configeItems()
    }
    
    func configeItems () {
    
        self.sectionNames = ["General", "Orientation Mode", "Virtural Stick", "Intelligent Assistant"]

        //General
        var general = [ DemoSettingItem(name: "General Control", andClass: FCGeneralControlViewController.self),
                        DemoSettingItem(name: "Compass", andClass: FCCompassViewController.self),
                        DemoSettingItem(name: "Flight Limitation", andClass: FCFlightLimitationViewController.self) ]
        if let fc = self.connectedComponent as? DJIFlightController where fc.isLandingGearMovable() {
            general.append(DemoSettingItem(name: "Landing Gear", andClass: FCLandingGearViewController.self))
        }
        self.items.append(general)

        // Orientation Mode in storyboard
        self.items.append([DemoSettingItem(name:"Intelligent Orientation", andClass:nil)])

        // Virtual Stick in storyboard
        self.items.append([DemoSettingItem(name:"Virtual Stick", andClass:nil)])

        // Intelligent Assistant in storyboard
        if let fc = self.connectedComponent as? DJIFlightController, _ = fc.intelligentFlightAssistant {
            self.items.append([DemoSettingItem(name:"Intelligent Assistant", andClass:FCIntelligentAssistantViewController.self)])
        }
    }
    
    //Passes an instance of the current component selected to IndividualComponentViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? DJIBaseViewController where segue.identifier != "openComponentInfo" {
            vc.moduleTitle = segue.identifier
        }
    }
}