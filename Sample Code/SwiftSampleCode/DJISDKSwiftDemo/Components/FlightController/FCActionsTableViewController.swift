//
//  FCActionsTableViewController.swift
//  DJISDKSwiftDemo
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
        let item0:DemoSettingItem = DemoSettingItem(name: "General Control", andClass: FCGeneralControlViewController.self)
        let item1:DemoSettingItem = DemoSettingItem(name: "Compass", andClass: FCCompassViewController.self)
        let item2:DemoSettingItem = DemoSettingItem(name: "Flight Limitation", andClass: FCFlightLimitationViewController.self)
        
        let fc: DJIFlightController? = self.connectedComponent as? DJIFlightController
        
        if (fc != nil) {
            
            let  movable:Bool = fc!.isLandingGearMovable()
            
            if (movable == true) {
                let item3: DemoSettingItem = DemoSettingItem(name: "Landing Gear", andClass: FCLandingGearViewController.self)
                self.items.append([item0, item1, item2, item3])
            }else{
                self.items.append([item0, item1, item2])
            }
        }
        // Orientation Mode in storyboard
        self.items.append([DemoSettingItem(name:"Intelligent Orientation", andClass:nil)])
        // Virtual Stick in storyboard
        self.items.append([DemoSettingItem(name:"Virtual Stick", andClass:nil)])
        // Intelligent Assistent in storyboard
        if (fc != nil && fc?.intelligentFlightAssistant != nil){
            self.items.append([DemoSettingItem(name:"Intelligent Assistant", andClass:FCIntelligentAssistantViewController.self)])
        }
    }
    
    //Passes an instance of the current component selected to IndividualComponentViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier != "openComponentInfo") {
            let vc = segue.destinationViewController as! DJIBaseViewController
            vc.moduleTitle = segue.identifier
        }
    }
}