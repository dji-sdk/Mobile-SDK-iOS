//
//  ComponentsViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 11/30/15.
//  Copyright © 2015 DJI. All rights reserved.
//

import Foundation
import UIKit
import DJISDK



class ComponentsViewController: DemoTableViewController {
    
    var components = Array<String>()
    var currentComponentSelected : DJIBaseComponent?
  
    // Flight controller is handled specially just because its view controller is in storyboard
    let componentsDict:Dictionary<String, AnyObject.Type> = [DJIBatteryComponent: BatteryActionsTableViewController.self,
                                                        DJIGimbalComponent:GimbalActionsTableTableViewController.self,
                                                        DJICameraComponent:CameraActionsTableViewController.self,
                                                        DJIAirLinkComponent:AirLinkActionsTableViewController.self,
                                                        DJIRemoteControllerComponent:RCActionsTableViewController.self,
                                                        DJIHandheldControllerComponent:HandheldControllerActionsTableViewController.self]
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Components & Missions"
        self.sectionNames = ["Components", "Missions"]
        self.initializeComponentSection()
        self.initializeMissionSection()
    }
    

   func initializeComponentSection() {
        var components = [DemoSettingItem]()
    
        if (ConnectedProductManager.sharedInstance.fetchAircraft() != nil){
            components.append(DemoSettingItem(name:"Flight Controller", andClass:nil))
        }
    
        if (ConnectedProductManager.sharedInstance.connectedProduct != nil) {
            for name: String in (ConnectedProductManager.sharedInstance.connectedProduct!.components?.keys)! {
                let componentObjectType:AnyObject.Type? = componentsDict[name]
                if (componentObjectType != nil) {
                    components.append(DemoSettingItem(name: name.capitalizedString, andClass: componentObjectType as? UIViewController.Type))
                }
            }
        }
        self.items.append(components)
    }

    func initializeMissionSection() {
        var components = [DemoSettingItem]()
        
        if (ConnectedProductManager.sharedInstance.fetchHandheldController() != nil) {
            components.append(DemoSettingItem(name:"Panorama Mission", andClass:nil))
        }else {
            let missions = ["Custom Mission", "Followme Mission", "Waypoint Mission", "Hotpoint Mission"]
            for identifier: String in missions {
                // Identifier is the view controller in the storyboard
                components.append(DemoSettingItem(name: identifier, andClass:nil))
            }
        }

        self.items.append(components)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier != "Flight Controller") {
            let vc = segue.destinationViewController as! DJIBaseViewController
            vc.moduleTitle = segue.identifier?.capitalizedString
        }
    }

    func componentWithKey(key: String, changedFrom oldComponent: DJIBaseComponent?, to newComponent: DJIBaseComponent?) {
        if oldComponent == nil && newComponent != nil {
            // a new component is connected
            let anyObjectType = componentsDict[key] as? UIViewController.Type
            
            if (anyObjectType != nil) {
                self.items.append(DemoSettingItem(name:key, andClass:anyObjectType))
            }
            
            self.tableView.reloadData()
            return
        }

    }
}
