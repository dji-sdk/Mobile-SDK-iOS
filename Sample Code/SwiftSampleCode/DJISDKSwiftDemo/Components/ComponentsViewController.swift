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
    let componentsDict:Dictionary<String, AnyObject.Type> = [DJIBatteryComponentKey: BatteryActionsTableViewController.self,
                                                        DJIGimbalComponentKey:GimbalActionsTableTableViewController.self,
                                                        DJICameraComponentKey:CameraActionsTableViewController.self,
                                                        DJIAirLinkComponentKey:AirLinkActionsTableViewController.self,
                                                        DJIRemoteControllerComponentKey:RCActionsTableViewController.self,
                                                        DJIHandheldControllerComponentKey:HandheldControllerActionsTableViewController.self]
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Components & Missions"
        self.sectionNames = ["Components", "Missions"]
        self.initializeComponentSection()
        self.initializeMissionSection()
    }
    

   func initializeComponentSection() {
        var components: [AnyObject] = [AnyObject]()
    
        if let _ = ConnectedProductManager.sharedInstance.fetchAircraft() {
            components.append(DemoSettingItem(name:"Flight Controller", andClass:nil))
        }
    
        if let connectedProduct = ConnectedProductManager.sharedInstance.connectedProduct,
           let componentsInConnectedProduct = connectedProduct.components
        {
            for name: String in componentsInConnectedProduct.keys {
                let componentObjectType:AnyObject.Type? = componentsDict[name]
                if (componentObjectType != nil) {
                    components.append(DemoSettingItem(name: name.capitalizedString, andClass: componentObjectType as? UIViewController.Type))
                }

            }
        }
        self.items.append(components)
    }

    func initializeMissionSection() {
        var identifiers: [String] // Identifier is the view controller in the storyboard

        if let _ = ConnectedProductManager.sharedInstance.fetchHandheldController() {
            identifiers = ["Panorama Mission"]
        } else {
            identifiers = ["Custom Mission", "Followme Mission", "Waypoint Mission", "Hotpoint Mission"]
        }

        let components = identifiers.map { DemoSettingItem(name: $0, andClass:nil) }
        self.items.append( components )
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? DJIBaseViewController where segue.identifier != "Flight Controller" {
            vc.moduleTitle = segue.identifier?.capitalizedString
        }
    }

    func componentWithKey(key: String, changedFrom oldComponent: DJIBaseComponent?, to newComponent: DJIBaseComponent?) {
        if oldComponent == nil && newComponent != nil {
            // a new component is connected
            if let anyObjectType = componentsDict[key] as? UIViewController.Type {
                self.items.append(DemoSettingItem(name:key, andClass:anyObjectType))
            }
            
            self.tableView.reloadData()
            return
        }

    }
}
