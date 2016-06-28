//
//  DemoTableViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 12/17/15.
//  Copyright © 2015 DJI. All rights reserved.
//
import UIKit
import DJISDK

let HeaderHeight:CGFloat = 30

class DemoTableViewController: UITableViewController, DJIBaseProductDelegate {
    var sectionNames:[String] = []
    var items:[AnyObject] = []
    var connectedComponent:DJIBaseComponent? = nil
    
    var showComponentVersionSn:Bool = false
    var version:String? = nil
    var serialNumber:String? = nil
    var versionSerialLabel:UILabel = UILabel(frame: CGRectZero)

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (self.sectionNames.count <= 1) {
            return 1
        } else {
            return self.sectionNames.count
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.sectionNames.count <= 1 {
            return self.items.count
        }
        else if (section < self.items.count) {
            let items:[AnyObject]? = self.items[section] as? [AnyObject]
            if (items != nil) {
                return items!.count
            }
        }
        
        return 0;
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionNames.count > section ? self.sectionNames[section] : nil
        
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return HeaderHeight
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier: String = "Cell"
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: CellIdentifier)
        }
        let section: Int = indexPath.section
        let row: Int = indexPath.row
        var item: DemoSettingItem? = nil
        if self.sectionNames.count <= 1 {
            item = self.items[row] as? DemoSettingItem
            if (item == nil) {
                let sectionItems = self.items[0] as? [DemoSettingItem]
                if (sectionItems?.count > row) {
                    item = sectionItems![row]
                }
            }
        }
        else {
            let sectionItems = self.items[section] as? [DemoSettingItem]
            if (sectionItems?.count > row) {
                item = sectionItems![row]
            }
        }
        cell?.textLabel!.text = item?.itemName
        cell?.textLabel?.font = UIFont(name:"Helvetica Neue Light", size:18)
        cell?.accessoryType = .DisclosureIndicator
        return cell!
    }

    func canPerformSegueWithIdentifier(identifier: NSString) -> Bool {
        let templates:NSArray? = self.valueForKey("storyboardSegueTemplates") as? NSArray
    
        let predicate:NSPredicate = NSPredicate(format: "identifier=%@", identifier)
        
        let filteredtemplates = templates?.filteredArrayUsingPredicate(predicate)
        return (filteredtemplates?.count>0)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Navigation logic may go here. Create and push another view controller.
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let section: Int = indexPath.section
        let row: Int = indexPath.row
        var item: DemoSettingItem? = nil
        if self.sectionNames.count <= 1 {
            item = self.items[row] as? DemoSettingItem
            if (item == nil) {
                let sectionItems = self.items[0] as? [DemoSettingItem]
                if (sectionItems?.count > row) {
                    item = sectionItems![row]
                }
            }
        }
        else {
            let sectionItems = self.items[section] as? [DemoSettingItem]
            if (sectionItems?.count > row) {
                item = sectionItems![row]
            }
        }
        
        if (item != nil) {
            // If the view controller exists in stroy board, excuting the segue first
            if (self.canPerformSegueWithIdentifier(item!.itemName)) {
                self.performSegueWithIdentifier(item!.itemName, sender: self)
            } else if (item!.viewControllerClass != nil) {
                let controllerObject = item!.viewControllerClass!.init()
                controllerObject.title = item?.itemName
                self.navigationController!.pushViewController(controllerObject, animated: true)
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func product(product: DJIBaseProduct, connectivityChanged isConnected: Bool) {
        if isConnected {
            NSLog("\(product.model) connected. ")
            ConnectedProductManager.sharedInstance.connectedProduct = product
            ConnectedProductManager.sharedInstance.setDelegate(self)
        }
        else {
            NSLog("Product disconnected. ")
            if (ConnectedProductManager.sharedInstance.connectedProduct != nil) {
                ConnectedProductManager.sharedInstance.connectedProduct = nil
            }
        }
    }
    
    func updateSerialNumber() {
        if (connectedComponent != nil) {
            connectedComponent!.getSerialNumberWithCompletion { (serialNumber, error) -> Void in
                self.serialNumber = serialNumber
                self.updateVersionSerialNumber()
            }
        }
    }
    
    func updateFirmwareVersion() {
        if (connectedComponent != nil) {
            connectedComponent!.getFirmwareVersionWithCompletion { (version, error) -> Void in
                self.version = version
                self.updateVersionSerialNumber()
            }
        }
    }
    
    func updateVersionSerialNumber()
    {
        var array : [String] = []
        if version != nil
        {
            array.append("Firmware Version: \(version!)")
        }
        if serialNumber != nil
        {
            array.append("Serial Number: \(serialNumber!)")
        }
        versionSerialLabel.text = (array as NSArray).componentsJoinedByString("   ")
       
    }
    
    override func viewWillAppear(animated: Bool) {
        
        ConnectedProductManager.sharedInstance.setDelegate(self)
        
        if (self.showComponentVersionSn) {
            versionSerialLabel.frame = CGRectMake(0, 0, tableView.bounds.width, 30)
            versionSerialLabel.textAlignment = NSTextAlignment.Center
            versionSerialLabel.font = UIFont.italicSystemFontOfSize(10)
            versionSerialLabel.textColor = UIColor(white: 0.5, alpha: 1.0)
            tableView.tableFooterView = versionSerialLabel
            //Updates the component's serial number
            updateSerialNumber()
            
            //Updates the component's firmware version
            updateFirmwareVersion()
        }
    }
    
    func component(component: DJIBaseComponent, connectivityChanged isConnected: Bool) {
        if(isConnected) {
            
            //Updates the component's serial number
            updateSerialNumber()
            
            //Updates the component's firmware version
            updateFirmwareVersion()
        }
    }

}
