//
//  DJIBaseViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 15/9/9.
//  Copyright © 2015 DJI. All rights reserved.
//
import UIKit
import DJISDK

protocol DJIProductObjectProtocol {
    func fetchAircraft() -> DJIAircraft?
    func fetchCamera() -> DJICamera?
    func fetchGimbal() -> DJIGimbal?
    func fetchFlightController() -> DJIFlightController?
    func fetchRemoteController() -> DJIRemoteController?
    func fetchBattery() -> DJIBattery?
    func fetchAirLink() -> DJIAirLink?
    func fetchHandheldController() -> DJIHandheldController?
}

class ConnectedProductManager: DJIProductObjectProtocol {
    static let sharedInstance = ConnectedProductManager()
    
    var connectedProduct:DJIBaseProduct? = nil
    
    func fetchAircraft() -> DJIAircraft? {
        if (self.connectedProduct == nil) {
            return nil
        }
        if (self.connectedProduct is DJIAircraft) {
            return (self.connectedProduct as! DJIAircraft)
        }
        return nil
    }
    
    func fetchCamera() -> DJICamera? {
        if (self.connectedProduct == nil) {
            return nil
        }
        if (self.connectedProduct is DJIAircraft) {
            return (self.connectedProduct as! DJIAircraft).camera
        }
        else if (self.connectedProduct is DJIHandheld) {
            return (self.connectedProduct as! DJIHandheld).camera
        }
        
        return nil
    }
    
    func fetchGimbal() -> DJIGimbal? {
        if (self.connectedProduct == nil) {
            return nil
        }
        if (self.connectedProduct is DJIAircraft) {
            return (self.connectedProduct as! DJIAircraft).gimbal
        }
        else if (self.connectedProduct is DJIHandheld) {
            return (self.connectedProduct as! DJIHandheld).gimbal
        }
        
        return nil
    }
    
    func fetchFlightController() -> DJIFlightController? {
        if (self.connectedProduct == nil) {
            return nil
        }
        if (self.connectedProduct is DJIAircraft) {
            return (self.connectedProduct as! DJIAircraft).flightController
        }
        return nil
    }
    
    func fetchRemoteController() -> DJIRemoteController? {
        if (self.connectedProduct == nil) {
            return nil
        }
        if (self.connectedProduct is DJIAircraft) {
            return (self.connectedProduct as! DJIAircraft).remoteController
        }
        return nil
    }
    
    func fetchBattery() -> DJIBattery? {
        if (self.connectedProduct == nil) {
            return nil
        }
        if (self.connectedProduct is DJIAircraft) {
            return (self.connectedProduct as! DJIAircraft).battery
        }
        else if (self.connectedProduct is DJIHandheld) {
            return (self.connectedProduct as! DJIHandheld).battery
        }
        
        return nil
    }
    
    func fetchAirLink() -> DJIAirLink? {
        if (self.connectedProduct == nil) {
            return nil
        }
        if (self.connectedProduct is DJIAircraft) {
            return (self.connectedProduct as! DJIAircraft).airLink
        }
        else if (self.connectedProduct is DJIHandheld) {
            return (self.connectedProduct as! DJIHandheld).airLink
        }
        
        return nil
    }
    
    func fetchHandheldController() -> DJIHandheldController? {
        if (self.connectedProduct == nil) {
            return nil
        }
        if (self.connectedProduct is DJIHandheld) {
            return (self.connectedProduct as! DJIHandheld).handheldController
        }
        return nil
    }
    
    func setDelegate(_ delegate:DJIBaseProductDelegate?) {
        self.connectedProduct?.delegate = delegate
    }

}

class DJIBaseViewController: UIViewController, DJIBaseProductDelegate, DJIProductObjectProtocol {
    
    //var connectedProduct:DJIBaseProduct?=nil
    var moduleTitle:String?=nil

    override func viewDidLoad() {
        super.viewDidLoad()
        if (moduleTitle != nil) {
            self.title = moduleTitle
        }
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (ConnectedProductManager.sharedInstance.connectedProduct != nil) {
            ConnectedProductManager.sharedInstance.setDelegate(self)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (ConnectedProductManager.sharedInstance.connectedProduct != nil &&
            ConnectedProductManager.sharedInstance.connectedProduct?.delegate === self) {
            ConnectedProductManager.sharedInstance.setDelegate(nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func product(_ product: DJIBaseProduct, connectivityChanged isConnected: Bool) {
        if isConnected {
            NSLog("\(product.model) connected. ")
            ConnectedProductManager.sharedInstance.connectedProduct = product
            ConnectedProductManager.sharedInstance.setDelegate(self)

        }
        else {
            NSLog("Product disconnected. ")
            ConnectedProductManager.sharedInstance.connectedProduct = nil
        }
    }

    func component(withKey key: String, changedFrom oldComponent: DJIBaseComponent?, to newComponent: DJIBaseComponent?) {
       //     (newComponent as? DJICamera)?.delegate = self
        if ((newComponent is DJICamera) == true && (self is DJICameraDelegate) == true) {
            (newComponent as! DJICamera).delegate = self as? DJICameraDelegate
            
        }
        if ((newComponent is DJICamera) == true && (self is DJIPlaybackDelegate) == true) {
            (newComponent as! DJICamera).playbackManager?.delegate = self as? DJIPlaybackDelegate
        }
        
        if ((newComponent is DJIFlightController) == true && (self is DJIFlightControllerDelegate) == true) {
            (newComponent as! DJIFlightController).delegate = self as? DJIFlightControllerDelegate
        }
        
        if ((newComponent is DJIBattery) == true && (self is DJIBatteryDelegate) == true) {
            (newComponent as! DJIBattery).delegate = self as? DJIBatteryDelegate
        }
        
        if ((newComponent is DJIGimbal) == true && (self is DJIGimbalDelegate) == true) {
            (newComponent as! DJIGimbal).delegate = self as? DJIGimbalDelegate
        }
        
        if ((newComponent is DJIRemoteController) == true && (self is DJIRemoteControllerDelegate) == true) {
            (newComponent as! DJIRemoteController).delegate = self as? DJIRemoteControllerDelegate
        }
        
    }
    
    
    func showAlertResult(_ info:String) {
        // create the alert
        var message:String? = info
        
        if info.hasSuffix(":nil") {
            message = info.replacingOccurrences(of: ":nil", with: " success")
        }
        
        let alert = UIAlertController(title: "Message", message: "\(message ?? "")", preferredStyle: UIAlertControllerStyle.alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }

    
    func fetchAircraft() -> DJIAircraft?{
        return ConnectedProductManager.sharedInstance.fetchAircraft()
    }
    
    func fetchCamera() -> DJICamera? {
        return ConnectedProductManager.sharedInstance.fetchCamera()
    }
    
    func fetchGimbal() -> DJIGimbal? {
        return ConnectedProductManager.sharedInstance.fetchGimbal()
    }
    
    func fetchFlightController() -> DJIFlightController? {
        return ConnectedProductManager.sharedInstance.fetchFlightController()
    }
    
    func fetchRemoteController() -> DJIRemoteController? {
        return ConnectedProductManager.sharedInstance.fetchRemoteController()
    }
    
    func fetchBattery() -> DJIBattery? {
        return ConnectedProductManager.sharedInstance.fetchBattery()
    }
    func fetchAirLink() -> DJIAirLink? {
        return ConnectedProductManager.sharedInstance.fetchAirLink()
    }
    func fetchHandheldController() -> DJIHandheldController?{
        return ConnectedProductManager.sharedInstance.fetchHandheldController()
    }
}
