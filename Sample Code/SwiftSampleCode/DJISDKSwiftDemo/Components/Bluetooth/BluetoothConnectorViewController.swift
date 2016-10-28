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


class BluetoothConnectorViewController: DJIBaseViewController, UITableViewDelegate, DJIBluetoothProductConnectorDelegate, UITableViewDataSource {

    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var bluetoothDevicesTableView: UITableView!
    var bluetoothProducts: [CBPeripheral]?
    var selectedIndex: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bluetoothProducts = []
        self.updateConnectButtonState()
        bluetoothConnector()?.delegate = self
    }
    
    func bluetoothConnector() -> DJIBluetoothProductConnector? {
        return DJISDKManager.bluetoothConnector()
    }
    
    @IBAction func onBluetoothSearchButtonClicked(_ sender: AnyObject) {
        self.bluetoothConnector()?.searchBluetoothProducts { [weak self](error:Error?) in
            if let _ = error {
                self!.showAlertResult("Search Bluetooth product failed:\(error!)")
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
        
        self.bluetoothConnector()?.connectProduct(curSelectedPer) { [weak self](error:Error?) in
            if let _ = error {
                self!.showAlertResult("Connect Bluetooth product failed:\(error!)")
            } else {
                self!.bluetoothProducts?.removeAll();
                self!.bluetoothDevicesTableView.reloadData()
                self!.connectButton.setTitle("Disconnect", for: UIControlState())
            }
        }
    }
    
    func disconnectBluetooth() -> Void {
        self.bluetoothConnector()?.disconnectProduct { [weak self](error:Error?) in
            if let _ = error {
                self!.showAlertResult("Disconnect Bluetooth product failed:\(error!)")
            } else {
                self!.connectButton.setTitle("Connect", for: UIControlState())
                self!.bluetoothDevicesTableView.reloadData()
            }
        }
    }
    
    
    func connectorDidFindProducts(_ peripherals: [CBPeripheral]?) {
        self.bluetoothProducts = peripherals
        self.bluetoothDevicesTableView.reloadData()
    }
    
    
    //UITableView Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.bluetoothProducts?.count)!
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier: String = "BluetoothCellReuseKey"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: CellIdentifier)
        }
        
        let peripheral = self.bluetoothProducts![(indexPath as NSIndexPath).row]
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
        if  self.selectedIndex != nil && self.selectedIndex.row < self.bluetoothProducts?.count {
            let preCell:UITableViewCell = tableView.cellForRow(at: self.selectedIndex)!
            preCell.backgroundColor = UIColor.white
        }
        
        let cell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        cell.backgroundColor = UIColor.gray
    }
}
