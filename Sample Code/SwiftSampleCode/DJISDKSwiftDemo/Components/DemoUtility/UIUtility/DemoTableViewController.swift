//
//  DemoTableViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 12/17/15.
//  Copyright © 2015 DJI. All rights reserved.
//
import UIKit
import DJISDK
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


let HeaderHeight:CGFloat = 30

class DemoTableViewController: UITableViewController, DJIBaseProductDelegate {
    var sectionNames:[String] = []
    var items:[[DemoSettingItem]] = []
    var connectedComponent:DJIBaseComponent? = nil
    
    var showComponentVersionSn:Bool = false
    var version:String? = nil
    var serialNumber:String? = nil
    var versionSerialLabel:UILabel = UILabel(frame: CGRect.zero)

     init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if (self.sectionNames.count <= 1) {
            return 1
        } else {
            return self.sectionNames.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.sectionNames.count <= 1 {
            return self.items.count
        }
        else if (section < self.items.count) {
            let items:[DemoSettingItem]? = self.items[section]
            if (items != nil) {
                return items!.count
            }
        }
        
        return 0;
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionNames.count > section ? self.sectionNames[section] : nil
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return HeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier: String = "Cell"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: CellIdentifier)
        }
        let section: Int = (indexPath as NSIndexPath).section
        let row: Int = (indexPath as NSIndexPath).row
        var item: DemoSettingItem? = nil
        if self.sectionNames.count <= 1 {
            item = self.items[row].first
        }
        else {
            let sectionItems = self.items[section]
            if (sectionItems.count > row) {
                item = sectionItems[row]
            }
        }
        cell?.textLabel!.text = item?.itemName
        cell?.textLabel?.font = UIFont(name:"Helvetica Neue Light", size:18)
        cell?.accessoryType = .disclosureIndicator
        return cell!
    }

    func canPerformSegueWithIdentifier(_ identifier: NSString) -> Bool {
        let templates:NSArray? = self.value(forKey: "storyboardSegueTemplates") as? NSArray
    
        let predicate:NSPredicate = NSPredicate(format: "identifier=%@", identifier)
        
        let filteredtemplates = templates?.filtered(using: predicate)
        return (filteredtemplates?.count>0)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Navigation logic may go here. Create and push another view controller.
        tableView.deselectRow(at: indexPath, animated: true)
        let section: Int = (indexPath as NSIndexPath).section
        let row: Int = (indexPath as NSIndexPath).row
        var item: DemoSettingItem? = nil
        if self.sectionNames.count <= 1 {
            item = self.items[row].first
        }
        else {
            let sectionItems = self.items[section]
            if (sectionItems.count > row) {
                item = sectionItems[row]
            }
        }
        
        if (item != nil) {
            // If the view controller exists in stroy board, excuting the segue first
            if (self.canPerformSegueWithIdentifier(item!.itemName as NSString)) {
                self.performSegue(withIdentifier: item!.itemName, sender: self)
            } else if (item!.viewControllerClass != nil) {
                let controllerObject = item!.viewControllerClass!.init()
                controllerObject.title = item?.itemName
                self.navigationController!.pushViewController(controllerObject, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func product(_ product: DJIBaseProduct, connectivityChanged isConnected: Bool) {
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
            connectedComponent!.getSerialNumber { (serialNumber, error) -> Void in
                self.serialNumber = serialNumber
                self.updateVersionSerialNumber()
            }
        }
    }
    
    func updateFirmwareVersion() {
        if (connectedComponent != nil) {
            connectedComponent!.getFirmwareVersion { (version, error) -> Void in
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
        versionSerialLabel.text = (array as NSArray).componentsJoined(by: "   ")
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        ConnectedProductManager.sharedInstance.setDelegate(self)
        
        if (self.showComponentVersionSn) {
            versionSerialLabel.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30)
            versionSerialLabel.textAlignment = NSTextAlignment.center
            versionSerialLabel.font = UIFont.italicSystemFont(ofSize: 10)
            versionSerialLabel.textColor = UIColor(white: 0.5, alpha: 1.0)
            tableView.tableFooterView = versionSerialLabel
            //Updates the component's serial number
            updateSerialNumber()
            
            //Updates the component's firmware version
            updateFirmwareVersion()
        }
    }
    
    func component(_ component: DJIBaseComponent, connectivityChanged isConnected: Bool) {
        if(isConnected) {
            
            //Updates the component's serial number
            updateSerialNumber()
            
            //Updates the component's firmware version
            updateFirmwareVersion()
        }
    }

}
