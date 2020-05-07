//
//  BluetoothConnectorViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 16/9/1.
//  Copyright © 2016年 DJI. All rights reserved.
//

import DJISDK
import CoreBluetooth

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

class BluetoothConnectorViewController: UIViewController, UITableViewDelegate, DJIBluetoothProductConnectorDelegate, UITableViewDataSource {

    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var bluetoothDevicesTableView: UITableView!
    var bluetoothProducts = [CBPeripheral]()
    var selectedIndex: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateConnectButtonState()
        guard let blConnector = bluetoothConnector() else {
            return;
        }
            
        blConnector.delegate = self
    }
    
    func bluetoothConnector() -> DJIBluetoothProductConnector? {
        return DJISDKManager.bluetoothProductConnector()
    }
    
    @IBAction func onBluetoothSearchButtonClicked(_ sender: AnyObject) {
        guard let blConnector = self.bluetoothConnector() else {
            return;
        }
            
        blConnector.searchBluetoothProducts { (error: Error?) in
            if error != nil {
                self.showAlert("Search Bluetooth product failed:\(error!)")
            }
        }
    }
    
    @IBAction func onBluetoothConnectButtonClicked(_ sender: AnyObject) {
        if isBluetoothProductConnected() {
            self.disconnectBluetooth();
        } else {
            self.connectBluetooth();
        }
    }
    
    func updateConnectButtonState() -> Void {
        if isBluetoothProductConnected() {
            self.connectButton.setTitle("Disconnect", for: UIControlState())
        } else {
            self.connectButton.setTitle("Connect", for: UIControlState())
        }
    }
    
    func isBluetoothProductConnected() -> Bool {
        guard let product = DJISDKManager.product() else {
            return false;
        }
        if (product.model == DJIHandheldModelNameOsmoMobile) {
            return true;
        }
        return false;
    }
    
    func connectBluetooth() -> Void {
        
        if self.bluetoothProducts.isEmpty == true ||
           self.selectedIndex == nil {
            return
        }
        
        
        guard let blConnector = self.bluetoothConnector() else {
            return;
        }
        
        let curSelectedPer = self.bluetoothProducts[self.selectedIndex.row]
        blConnector.connectProduct(curSelectedPer) { (error:Error?) in
            if let _ = error {
                self.showAlert("Connect Bluetooth product failed:\(error!)")
            } else {
                self.bluetoothProducts.removeAll();
                self.bluetoothDevicesTableView.reloadData()
                self.connectButton.setTitle("Disconnect", for: UIControlState())
            }
        }
    }
    
    func disconnectBluetooth() -> Void {
        self.bluetoothConnector()?.disconnectProduct { [weak self](error:Error?) in
            if let _ = error {
                self!.showAlert("Disconnect Bluetooth product failed:\(error!)")
            } else {
                self!.connectButton.setTitle("Connect", for: UIControlState())
                self!.bluetoothDevicesTableView.reloadData()
            }
        }
    }
    
    
    func connectorDidFindProducts(_ peripherals: [CBPeripheral]?) {
        guard peripherals != nil else {
            return;
        }
        self.bluetoothProducts = peripherals!
        self.bluetoothDevicesTableView.reloadData()
    }
    
    
    //MARK : UITableView Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bluetoothProducts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier: String = "BluetoothCellReuseKey"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: CellIdentifier)
        }
        
        let peripheral = self.bluetoothProducts[(indexPath as NSIndexPath).row]
        cell?.textLabel!.text = peripheral.name
        if (peripheral.state == .connected) {
            cell?.backgroundColor = UIColor.init(red: 0, green: 0, blue: 1, alpha: 0.4)
        } else {
            cell?.backgroundColor = UIColor.white
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Navigation logic may go here. Create and push another view controller.
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.selectedIndex = indexPath
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if  self.selectedIndex != nil && self.selectedIndex.row < self.bluetoothProducts.count {
            let preCell:UITableViewCell = tableView.cellForRow(at: self.selectedIndex)!
            preCell.backgroundColor = UIColor.white
        }
        
        let cell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        cell.backgroundColor = UIColor.gray
    }
    
    // MARK : Convenience

    func showAlert(_ msg: String?) {
        // create the alert
        let alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}
