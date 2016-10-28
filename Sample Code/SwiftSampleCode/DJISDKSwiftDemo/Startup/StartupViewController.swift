//
//  StartupViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 11/13/15.
//  Copyright © 2015 DJI. All rights reserved.
//

import UIKit
import DJISDK

class StartupViewController: DJIBaseViewController {
    
    @IBOutlet weak var productConnectionStatus: UILabel!
    @IBOutlet weak var productModel: UILabel!
    @IBOutlet weak var productFirmwarePackageVersion: UILabel!
    @IBOutlet weak var openComponents: UIButton!
    @IBOutlet weak var bluetoothConnectorButton: UIButton!
    @IBOutlet weak var sdkVersionLabel: UILabel!
    
    var connectedProduct:DJIBaseProduct?=nil
    var componentDictionary = Dictionary<String, Array<DJIBaseComponent>>()
    
    let APP_KEY = ""//Please enter App Key Here
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI();

        guard !APP_KEY.isEmpty else {
            showAlert("Please enter your app key.")
            return
        }
        
        DJISDKManager.registerApp(APP_KEY, with: self)
    }
    
    func initUI() {
        self.title = "DJI iOS SDK Sample"
        sdkVersionLabel.text = "DJI SDK Version: \(DJISDKManager.getSDKVersion())"
        openComponents.isEnabled = false;
        bluetoothConnectorButton.isEnabled = true;
        productModel.isHidden = true
        productFirmwarePackageVersion.isHidden = true
        
    }
    
    func showAlert(_ msg: String?) {
        // create the alert
        let alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onBluetoothConnectorButtonClicked(_ sender: AnyObject) {

    }
    
}

extension StartupViewController : DJISDKManagerDelegate
{
    func sdkManagerDidRegisterAppWithError(_ error: Error?) {
        
        guard error == nil  else {
             self.showAlertResult("Error:\(error!.localizedDescription)")
            return
        }
        
        logDebug("Registered!")
        #if arch(i386) || arch(x86_64)
            //Simulator
            DJISDKManager.enterDebugMode(withDebugId: "10.128.129.28")
        #else
            //Device
            DJISDKManager.startConnectionToProduct()
            
        #endif
       
    }
     
    func sdkManagerProductDidChange(from oldProduct: DJIBaseProduct?, to newProduct: DJIBaseProduct?) {
        
        guard let newProduct = newProduct else
        {
            productConnectionStatus.text = "Status: No Product Connected"
            ConnectedProductManager.sharedInstance.connectedProduct = nil
            openComponents.isEnabled = false;
            openComponents.alpha = 0.8;
            logDebug("Product Disconnected")
            return
        }
        
        //Updates the product's model
        productModel.text = "Model: \((newProduct.model)!)"
        productModel.isHidden = false
        if let oldProduct = oldProduct {
            logDebug("Product changed from: \(oldProduct.model) to \((newProduct.model)!)")
        }
        //Updates the product's firmware version - COMING SOON
        newProduct.getFirmwarePackageVersion{ (version:String?, error:Error?) -> Void in
            
            self.productFirmwarePackageVersion.text = "Firmware Package Version: \(version ?? "Unknown")"
            
            if let _ = error {
                self.productFirmwarePackageVersion.isHidden = true
            }else{
                self.productFirmwarePackageVersion.isHidden = false
            }
            
            logDebug("Firmware package version is: \(version ?? "Unknown")")
        } 
        
        //Updates the product's connection status
        productConnectionStatus.text = "Status: Product Connected"
        
        ConnectedProductManager.sharedInstance.connectedProduct = newProduct
        openComponents.isEnabled = true;
        openComponents.alpha = 1.0;
        logDebug("Product Connected")

    }
    
    override func product(_ product: DJIBaseProduct, connectivityChanged isConnected: Bool) {
        if isConnected {
            productConnectionStatus.text = "Status: Product Connected"
            logDebug("Product Connected")
        } else {
            productConnectionStatus.text = "Status: No Product Connected"
            logDebug("Product Disconnected")
        }
    }

    
}





