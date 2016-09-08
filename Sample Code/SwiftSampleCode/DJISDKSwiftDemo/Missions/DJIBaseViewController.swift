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
        guard let connectedProduct = self.connectedProduct as? DJIAircraft else { return nil }
        return connectedProduct
    }
    
    func fetchCamera() -> DJICamera? {
        guard let connectedProduct = self.connectedProduct else { return nil }
        if let aircraft = connectedProduct as? DJIAircraft {
            return aircraft.camera
        }
        if let handheld = connectedProduct as? DJIHandheld {
            return handheld.camera
        }
        return nil
    }
    
    func fetchGimbal() -> DJIGimbal? {
        guard let connectedProduct = self.connectedProduct else { return nil }
        if let aircraft = connectedProduct as? DJIAircraft {
            return aircraft.gimbal
        }
        if let handheld = connectedProduct as? DJIHandheld {
            return handheld.gimbal
        }
        return nil
    }
    
    func fetchFlightController() -> DJIFlightController? {
        guard let connectedProduct = self.connectedProduct as? DJIAircraft else { return nil }
        return connectedProduct.flightController
    }
    
    func fetchRemoteController() -> DJIRemoteController? {
        guard let connectedProduct = self.connectedProduct as? DJIAircraft else { return nil }
        return connectedProduct.remoteController
    }
    
    func fetchBattery() -> DJIBattery? {
        guard let connectedProduct = self.connectedProduct else { return nil }
        if let aircraft = connectedProduct as? DJIAircraft {
            return aircraft.battery
        }
        if let handheld = connectedProduct as? DJIHandheld {
            return handheld.battery
        }
        return nil
    }
    
    func fetchAirLink() -> DJIAirLink? {
        guard let connectedProduct = self.connectedProduct else { return nil }
        if let aircraft = connectedProduct as? DJIAircraft {
            return aircraft.airLink
        }
        if let handheld = connectedProduct as? DJIHandheld {
            return handheld.airLink
        }
        return nil
    }
    
    func fetchHandheldController() -> DJIHandheldController? {
        guard let connectedProduct = self.connectedProduct as? DJIHandheld else { return nil }
        return connectedProduct.handheldController
    }
    
    func setDelegate(delegate:DJIBaseProductDelegate?) {
        self.connectedProduct?.delegate = delegate
    }

}

class DJIBaseViewController: UIViewController, DJIBaseProductDelegate, DJIProductObjectProtocol {
    
    var moduleTitle:String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = moduleTitle
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if ConnectedProductManager.sharedInstance.connectedProduct != nil {
            ConnectedProductManager.sharedInstance.setDelegate(self)
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let connectedProduct = ConnectedProductManager.sharedInstance.connectedProduct where connectedProduct.delegate === self {
            ConnectedProductManager.sharedInstance.setDelegate(nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func product(product: DJIBaseProduct, connectivityChanged isConnected: Bool) {
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

    func componentWithKey(key: String, changedFrom oldComponent: DJIBaseComponent?, to newComponent: DJIBaseComponent?) {
        if let camera = newComponent as? DJICamera, cameraDelegate = self as? DJICameraDelegate {
            camera.delegate = cameraDelegate
        }

        if let camera = newComponent as? DJICamera, playbackDelegate = self as? DJIPlaybackDelegate {
            camera.playbackManager?.delegate = playbackDelegate
        }
        
        if let controller = newComponent as? DJIFlightController, controllerDelegate = self as? DJIFlightControllerDelegate {
            controller.delegate = controllerDelegate
        }
        
        if let battery = newComponent as? DJIBattery, batteryDelegate = self as? DJIBatteryDelegate {
            battery.delegate = batteryDelegate
        }
        
        if let gimbal = newComponent as? DJIGimbal, gimbalDelegate = self as? DJIGimbalDelegate {
            gimbal.delegate = gimbalDelegate
        }

        
        if let remote = newComponent as? DJIRemoteController, remoteDelegate = self as? DJIRemoteControllerDelegate {
            remote.delegate = remoteDelegate
        }        
    }
    
    
    func showAlertResult(info:String) {
        // create the alert
        var message:String? = info
        
        if info.hasSuffix(":nil") {
            message = info.stringByReplacingOccurrencesOfString(":nil", withString: " success")
        }
        
        let alert = UIAlertController(title: "Message", message: "\(message ?? "")", preferredStyle: UIAlertControllerStyle.Alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        // show the alert
        self.presentViewController(alert, animated: true, completion: nil)
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
