//
//  KeyedInterfaceViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 2/7/17.
//  Copyright © 2017 DJI. All rights reserved.
//

import UIKit
import DJISDK

class KeyedInterfaceViewController: UIViewController {
    
    var cameraStorageLocation: DJICameraStorageLocation = .unknown

    override func viewDidLoad() {
        super.viewDidLoad()
        if let cameraStorageLocationKey = DJICameraKey(param: DJICameraParamStorageLocation) {
            DJISDKManager.keyManager()?.getValueFor(cameraStorageLocationKey, withCompletion: { (value: DJIKeyedValue?, error: Error?) in
                guard error == nil && value != nil else {
                    // Insert graceful error handling here.
                    
                    self.cameraStorageLocationLabel.text = "Error"
                    return
                }
                
                self.cameraStorageLocation = DJICameraStorageLocation(rawValue: (value?.value as! NSNumber).uintValue)!
                
                if self.cameraStorageLocation == .sdCard {
                    self.cameraStorageLocationLabel.text = "SD Card"
                } else if self.cameraStorageLocation == .internalStorage {
                    self.cameraStorageLocationLabel.text = "Internal Storage"
                } else {
                    self.cameraStorageLocationLabel.text = "Uknown"
                }
            })
        }
        //We need to get the product type then listen for changes on the product type to determine if we should show the UI for SDCard and Internal Storage which is only supported on Mavic Air.
        if let productKey = DJIProductKey.modelName() {
            
            DJISDKManager.keyManager()?.getValueFor(productKey, withCompletion: { (value: DJIKeyedValue?, error: Error?) in
                guard error == nil && value != nil else {
                    // Insert graceful error handling here.
                    return
                }
                if let productName = value?.stringValue {
                    self.changeUIForProduct(productName: productName)
                }
            })
            
            DJISDKManager.keyManager()?.startListeningForChanges(on: productKey, withListener: self, andUpdate: { (oldValue: DJIKeyedValue?, newValue: DJIKeyedValue?) in
                
                if let productName = newValue?.stringValue {
                    self.changeUIForProduct(productName: productName)
                }
            })
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeUIForProduct(productName: String) {
        if productName != DJIAircraftModelNameMavicAir {
            self.cameraStorageLocationLabel.isHidden = true
            self.toggleCameraStorageLocationButton.isHidden = true
        } else {
            self.cameraStorageLocationLabel.isHidden = false
            self.toggleCameraStorageLocationButton.isHidden = false
        }
    }
    
    @IBOutlet weak var getBatteryLevelButton: UIButton!
    @IBOutlet weak var getBatteryLevelLabel: UILabel!
    @IBAction func getBatteryLevel(_ sender: Any) {
        let batteryLevelKey = DJIBatteryKey(param: DJIBatteryParamChargeRemainingInPercent)
        DJISDKManager.keyManager()?.getValueFor(batteryLevelKey!, withCompletion: { [unowned self] (value: DJIKeyedValue?, error: Error?) in
            guard error == nil && value != nil else {
                // Insert graceful error handling here
                
                self.getBatteryLevelLabel.text = "Error";
                return
            }
            // DJIBatteryParamChargeRemainingInPercent is associated with a uint8_t value
            self.getBatteryLevelLabel.text = "\(value!.unsignedIntegerValue) %"
        })
    }
    
    @IBOutlet weak var setCameraModeButton: UIButton!
    @IBOutlet weak var setCameraModeLabel: UILabel!
    @IBAction func setCameraMode(_ sender: Any) {
        if let cameraModeKey = DJICameraKey(param: DJICameraParamMode) {
            if let keyManager = DJISDKManager.keyManager() {
                var currentMode = DJICameraMode.shootPhoto // Default value.
                var newMode = DJICameraMode.recordVideo
                
                // Sometimes you want to get the value that is cached inside the keyed interface rather
                // than fetching it from the connected product. To do so, you may call getValueForKey:
                if let currentCameraMode = keyManager.getValueFor(cameraModeKey) {
                    currentMode = DJICameraMode(rawValue: (currentCameraMode.value as! NSNumber).uintValue)!
                    if currentMode == .recordVideo {
                        newMode = .shootPhoto
                    }
                }
                
                keyManager.setValue(NSNumber(value:newMode.rawValue),
                                             for: cameraModeKey, withCompletion: { (error: Error?) in
                guard error == nil else {
                    // Insert here more graceful error handling.
                    self.setCameraModeLabel.text = error?.localizedDescription
                    return
                }
                
                self.setCameraModeLabel.text = newMode == DJICameraMode.shootPhoto ? "DJICameraModeShootPhoto" : "DJICameraModeRecordVideo";
                })
            }
        }
    }
    
    
    @IBOutlet weak var listeningCoordinatesButton: UIButton!
    @IBOutlet weak var listeningCoordinatesLabel: UILabel!

    var isListening = false
    
    @IBAction func startStopListeningCoordinates(_ sender: Any) {
        let locationKey = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation)
        
        if isListening {
            // At anytime, you may stop listening to a key or to all key for a given listener
            DJISDKManager.keyManager()?.stopListening(on: locationKey!, ofListener: self)
            self.listeningCoordinatesLabel.text = "Stopped";
        } else {
            // Start listening is as easy as passing a block with a key.
            // Note that start listening won't do a get. Your block will be executed
            // the next time the associated data is being pulled.
            DJISDKManager.keyManager()?.startListeningForChanges(on: locationKey!, withListener: self, andUpdate: { (oldValue: DJIKeyedValue?, newValue: DJIKeyedValue?) in
                if newValue != nil {
                    // DJIFlightControllerParamAircraftLocation is associated with a DJISDKLocation object
                    let aircraftCoordinates = newValue!.value! as! CLLocation
                    
                    self.listeningCoordinatesLabel.text = "Lat: \(aircraftCoordinates.coordinate.latitude) - Long: \(aircraftCoordinates.coordinate.longitude)"
                }
            })
            self.listeningCoordinatesLabel.text = "Started...";
        }
        isListening = !isListening
    }
    
    @IBOutlet weak var getExposureSettingsButton: UIButton!
    @IBOutlet weak var getExposureSettingsLabel: UILabel!
    @IBAction func getExposureSettings(_ sender: Any) {
        let exposureKey = DJICameraKey(param: DJICameraParamExposureSettings)
        
        DJISDKManager.keyManager()?.getValueFor(exposureKey!, withCompletion: { (value: DJIKeyedValue?, error: Error?) in
            guard error == nil && value != nil else {
                // Insert graceful error handling here.
            
                self.getExposureSettingsLabel.text = "Error"
                return
            }
            
            // DJICameraParamExposureSettings is associated with DJICameraExposureSettings struct.
            // Structs are stored inside an NSValue when carried by a DJIKeyedValue object.
            var exposureSettings = DJICameraExposureSettings()
            
            let nsvalue = value!.value as! NSValue
            nsvalue.getValue(&exposureSettings)
            
            self.getExposureSettingsLabel.text = "ISO: \(exposureSettings.ISO)\nAperture: \(exposureSettings.aperture.rawValue)\nEV: \(exposureSettings.exposureCompensation.rawValue)\nShutter:\(exposureSettings.shutterSpeed.rawValue)"
        })
        
    }
    
    @IBOutlet weak var cameraStorageLocationLabel: UILabel!
    
    @IBOutlet weak var toggleCameraStorageLocationButton: UIButton!
    @IBAction func toggleCameraStorageLocationPressed(_ sender: Any) {
        let newCameraStorageLocation:DJICameraStorageLocation
        if self.cameraStorageLocation == .sdCard {
            newCameraStorageLocation = .internalStorage
        } else {
            newCameraStorageLocation = .sdCard
        }
        if let cameraStorageLocationKey = DJICameraKey(param: DJICameraParamStorageLocation) {
            DJISDKManager.keyManager()?.setValue(NSNumber(value:newCameraStorageLocation.rawValue), for: cameraStorageLocationKey, withCompletion: { (error: Error?) in
                guard error == nil else {
                    // Insert graceful error handling here.
                    self.cameraStorageLocationLabel.text = "Error"
                    return
                }
                self.cameraStorageLocation = newCameraStorageLocation
                if self.cameraStorageLocation == .sdCard {
                    self.cameraStorageLocationLabel.text = "SD Card"
                } else if self.cameraStorageLocation == .internalStorage {
                    self.cameraStorageLocationLabel.text = "Internal Storage"
                } else {
                    self.cameraStorageLocationLabel.text = "Uknown"
                }
            })
        }
    }
    
}
