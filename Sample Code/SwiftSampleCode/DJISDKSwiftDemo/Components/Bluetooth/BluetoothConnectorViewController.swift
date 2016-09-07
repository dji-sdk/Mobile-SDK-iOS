//
//  BluetoothConnectorViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 16/9/1.
//  Copyright © 2016年 DJI. All rights reserved.
//


import DJISDK
import CoreBluetooth

class BluetoothConnectorViewController: DJIBaseViewController, UITableViewDelegate, DJIBluetoothProductConnectorDelegate{

    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var bluetoothDevicesTableView: UITableView!
    var bluetoothProducts: [CBPeripheral]?
    var selectedIndex: NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bluetoothProducts = []
        self.updateConnectButtonState()
        bluetoothConnector()?.delegate = self
    }
    
    func bluetoothConnector() -> DJIBluetoothProductConnector? {
        return DJISDKManager.bluetoothConnector()
    }
    
    @IBAction func onBluetoothSearchButtonClicked(sender: AnyObject) {
        self.bluetoothConnector()?.searchBluetoothProductsWithCompletion { [weak self](error:NSError?) in
            if let _ = error {
                self!.showAlertResult("Search Bluetooth product failed:\(error!.description)")
            }
        }
    }
    
    @IBAction func onBluetoothConnectButtonClicked(sender: AnyObject) {
        if isBluetoothProductConnected() {
            self.disconnectBluetooth();
        } else {
            self.connectBluetooth();
        }
    }
    
    func updateConnectButtonState() -> Void {
        if isBluetoothProductConnected() {
            self.connectButton.setTitle("Disconnect", forState: .Normal)
        } else {
            self.connectButton.setTitle("Connect", forState: .Normal)
        }
    }
    
    func isBluetoothProductConnected() -> Bool {
        let product: DJIBaseProduct? = ConnectedProductManager.sharedInstance.connectedProduct
        if product != nil {
            if (product?.model == DJIHandheldModelNameOsmoMobile) {
                return true;
            }
        }
        return false;
    }
    
    func connectBluetooth() -> Void {
        
        if self.bluetoothProducts?.isEmpty == true ||
           self.selectedIndex == nil {
            return
        }
        
        let curSelectedPer = self.bluetoothProducts?[self.selectedIndex.row]
        
        self.bluetoothConnector()?.connectProduct(curSelectedPer) { [weak self](error:NSError?) in
            if let _ = error {
                self!.showAlertResult("Connect Bluetooth product failed:\(error!.description)")
            } else {
                self!.bluetoothProducts?.removeAll();
                self!.bluetoothDevicesTableView.reloadData()
                self!.connectButton.setTitle("Disconnect", forState: .Normal)
            }
        }
    }
    
    func disconnectBluetooth() -> Void {
        self.bluetoothConnector()?.disconnectProductWithCompletion { [weak self](error:NSError?) in
            if let _ = error {
                self!.showAlertResult("Disconnect Bluetooth product failed:\(error!.description)")
            } else {
                self!.connectButton.setTitle("Connect", forState: .Normal)
                self!.bluetoothDevicesTableView.reloadData()
            }
        }
    }
    
    
    func connectorDidFindProducts(peripherals: [CBPeripheral]?) {
        self.bluetoothProducts = peripherals
        self.bluetoothDevicesTableView.reloadData()
    }
    
    
    //UITableView Delegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.bluetoothProducts?.count)!
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier: String = "BluetoothCellReuseKey"
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: CellIdentifier)
        }
        
        let peripheral = self.bluetoothProducts![indexPath.row]
        cell?.textLabel!.text = peripheral.name
        if (peripheral.state == .Connected) {
            cell?.backgroundColor = UIColor.init(red: 0, green: 0, blue: 1, alpha: 0.4)
        } else {
            cell?.backgroundColor = UIColor.whiteColor()
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Navigation logic may go here. Create and push another view controller.
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.selectedIndex = indexPath
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        if  self.selectedIndex != nil && self.selectedIndex.row < self.bluetoothProducts?.count {
            let preCell:UITableViewCell = tableView.cellForRowAtIndexPath(self.selectedIndex)!
            preCell.backgroundColor = UIColor.whiteColor()
        }
        
        let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.backgroundColor = UIColor.grayColor()
    }
}