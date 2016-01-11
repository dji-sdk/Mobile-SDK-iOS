//
//  FCActionsTableViewController.m
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
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configeItems () {
    
        self.sectionNames = ["General", "Orientation Mode", "Virtural Stick"]
        //General
        let item0:DemoSettingItem = DemoSettingItem(name: "General Control", andClass: FCGeneralControlViewController.self)
        let item1:DemoSettingItem = DemoSettingItem(name: "Compass", andClass: FCCompassViewController.self)
        let item2:DemoSettingItem = DemoSettingItem(name: "Flight Limitation", andClass: FCFlightLimitationViewController.self)
        
        let fc: DJIFlightController? = self.connectedComponent as? DJIFlightController
        
        let landingGear = fc?.landingGear
        if (fc != nil && landingGear != nil) {
            
            let  movable:Bool = landingGear!.isLandingGearMovable()
            
            if (movable == true) {
                let item3: DemoSettingItem = DemoSettingItem(name: "Landing Gear", andClass: FCCompassViewController.self)
                self.items.append([item0, item1, item2, item3])
            }else{
                self.items.append([item0, item1, item2])
            }
        }
        // Orientation Mode in storyboard
        self.items.append([DemoSettingItem(name:"Intelligent Orientation", andClass:nil)])
        // Virtual Stick in storyboard
        self.items.append([DemoSettingItem(name:"Virtual Stick", andClass:nil)])
    
    }
    
    //Passes an instance of the current component selected to IndividualComponentViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier != "openComponentInfo") {
            let vc = segue.destinationViewController as! DJIBaseViewController
            vc.moduleTitle = segue.identifier
        }
    }
}