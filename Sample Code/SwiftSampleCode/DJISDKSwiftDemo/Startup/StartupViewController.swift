//
//  StartupViewController.swift
//  DJISDKSwiftDemo
//
//  Created by Dhanush Balachandran on 11/13/15.
//  Copyright © 2015 DJI. All rights reserved.
//

import UIKit
import DJISDK

class StartupViewController: UIViewController {
    
    @IBOutlet weak var productConnectionStatus: UILabel!
    @IBOutlet weak var productModel: UILabel!
    @IBOutlet weak var productFirmwarePackageVersion: UILabel!
    @IBOutlet weak var openComponents: UIButton!
    @IBOutlet weak var sdkVersionLabel: UILabel!
    
    var connectedProduct:DJIBaseProduct?=nil
    var componentDictionary = Dictionary<String, Array<DJIBaseComponent>>()
    
    let APP_KEY = "Please enter App Key Here"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if APP_KEY == "Please enter App Key Here"
        {
            let alert = UIAlertController(title: "Message", message: "Please enter App Key", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            DJISDKManager.registerApp(APP_KEY, withDelegate: self)
        }
        
        openComponents.enabled = false;

        sdkVersionLabel.text = "DJI SDK Version: \(DJISDKManager.getSDKVersion())"
        
        self.title = "DJI iOS SDK Sample"
        productModel.hidden = true
        productFirmwarePackageVersion.hidden = true
    }
}

extension StartupViewController : DJISDKManagerDelegate
{
    func sdkManagerDidRegisterAppWithError(error: NSError?) {
        
        guard error == nil  else {
            logError("Error:\(error!.localizedDescription)")
            return
        }
        
        logDebug("Registered!")
        #if arch(i386) || arch(x86_64)
            //Simulator
            DJISDKManager.enterDebugModeWithDebugId("192.168.1.161")
        #else
            //Device
            DJISDKManager.startConnectionToProduct()
            
        #endif
       
    }
     
    func sdkManagerProductDidChangeFrom(oldProduct: DJIBaseProduct?, to newProduct: DJIBaseProduct?) {
        
        guard newProduct != nil else
        {
            productConnectionStatus.text = "Status: No Product Connected"
            openComponents.enabled = false;
            openComponents.alpha = 0.8;
            logDebug("Product Disconnected")
            return
        }
        
        //Updates the product's model
        productModel.text = "Model: \((newProduct?.model)!)"
        productModel.hidden = false
        if (oldProduct != nil) {
            logDebug("Product changed from: \(oldProduct?.model) to \((newProduct?.model)!)")
        }
        //Updates the product's firmware version - COMING SOON
        newProduct?.getFirmwarePackageVersionWithCompletion({ (version:String?, error:NSError?) -> Void in
            self.productFirmwarePackageVersion.text = "Firmware Package Version: \(version ?? "Unknown")"
            self.productFirmwarePackageVersion.hidden = false
            logDebug("Firmware package version is: \(version ?? "Unknown")")
        })
        
        //Updates the product's connection status
        productConnectionStatus.text = "Status: Product Connected"
        
        ConnectedProductManager.sharedInstance.connectedProduct = newProduct
        openComponents.enabled = true;
        openComponents.alpha = 1.0;
        logDebug("Product Connected")

    }
}

extension StartupViewController : DJIBaseProductDelegate {

    func product(product: DJIBaseProduct, connectivityChanged isConnected: Bool) {
        if(isConnected) {
            productConnectionStatus.text = "Status: Product Connected"
            logDebug("Product Connected")
        } else {
            productConnectionStatus.text = "Status: No Product Connected"
            logDebug("Product Disconnected")
        }
    }
    
}




