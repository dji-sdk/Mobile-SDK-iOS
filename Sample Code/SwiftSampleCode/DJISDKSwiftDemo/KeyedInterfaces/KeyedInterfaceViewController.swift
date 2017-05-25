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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBOutlet weak var getBatteryLevelButton: UIButton!
    @IBOutlet weak var getBatteryLevelLabel: UILabel!
    @IBAction func getBatteryLevel(_ sender: Any) {
        let batteryLevelKey = DJIBatteryKey(param: DJIBatteryParamChargeRemainingInPercent)
        DJISDKManager.keyManager()?.getValueFor(batteryLevelKey!, withCompletion: { [unowned self] (value: DJIKeyedValue?, error: Error?) in
            guard error == nil && value != nil else {
                // Insert gracefule error handling here
                
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
        let cameraModeKey = DJICameraKey(param: DJICameraParamMode)
        var currentMode = DJICameraMode.shootPhoto // Default value.
        var newMode = DJICameraMode.recordVideo
        
        // Sometimes you want to get the value that is cached inside the keyed interface rather
        // than fetching it from the connected product. To do so, you may call getValueForKey:
        let currentCameraMode = DJISDKManager.keyManager()?.getValueFor(cameraModeKey!)
        
        if currentCameraMode != nil {
            // DJICameraParamMode is associated with DJICameraMode enum values
            let nsNumberValue = currentCameraMode!.value as! NSNumber
            currentMode = DJICameraMode(rawValue: nsNumberValue.uintValue)!
            if currentMode == .recordVideo {
                newMode = .shootPhoto
            }
        }
        
        DJISDKManager.keyManager()?.setValue(NSNumber(value:newMode.rawValue), for: cameraModeKey!, withCompletion: { [unowned self] (error: Error?) in
            guard error == nil else {
                // Insert here gracefule error handling.
                
                self.setCameraModeLabel.text = "error"
                return
            }
            self.setCameraModeLabel.text = newMode == DJICameraMode.shootPhoto ? "DJICameraModeShootPhoto" : "DJICameraModeRecordVideo";

        })
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
    
}
