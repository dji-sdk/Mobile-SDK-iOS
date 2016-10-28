//
//  CameraISOViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 12/18/15.
//  Copyright © 2015 DJI. All rights reserved.
//
import DJISDK
extension NSArray {
    func horizontalDescription() -> String {
        let string: NSMutableString = NSMutableString()
        string.append("(")
        for i in 0 ..< self.count {
            if i != 0 {
                string.append(",")
            }
            if (self[i] is [AnyObject]) {
                string.appendFormat("\((self[i] as! NSArray).horizontalDescription())" as NSString)
            }
            else {
                string.appendFormat("\(self[i])" as NSString)
            }
        }
        if self.count == 0 {
            string.append("Not supported")
        }
        string.append(")")
        return string as String
    }
}

class CameraISOViewController: DemoGetSetViewController {

    var STATE_CHECKING_CAMERA_MODE: String = "Checking camera's mode..."
    var STATE_SETTING_CAMERA_MODE: String = "Setting camera's mode..."
    var STATE_CHECKING_EXPOSURE_MODE: String = "Checking camera's exposure mode..."
    var STATE_SETTING_EXPOSURE_MODE: String = "Setting camera's exposure mode..."
    var STATE_WAIT_FOR_INPUT: String = "The input should be an integer. "

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Camera's ISO"
        self.rangeLabel.text = ""
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // disable the set/get button first.
        self.getValueButton.isEnabled = false
        self.setValueButton.isEnabled = false
        self.getCameraMode()
    }
    /**
     *  Check if the camera's mode is DJICameraMode.ShootPhoto or DJICameraMode.RecordVideo.
     *  If the mode is not one of them, we need to set it to be ShootPhoto or RecordVideo.
     *  If the mode is already one of them, we check the exposure mode. 
     */

    func getCameraMode() {
        self.rangeLabel.text = STATE_CHECKING_CAMERA_MODE
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            
            camera!.getModeWithCompletion({[weak self](mode: DJICameraMode, error: Error?) -> Void in
                
                if error != nil {
                    self?.rangeLabel.text = "ERROR: getCameraModeWithCompletion:. \(error!)"
                }
                else if mode == DJICameraMode.shootPhoto || mode == DJICameraMode.recordVideo {
                    // the first pre-condition is satisfied. Check the second one.
                    self?.getExposureMode()
                }
                else {
                    self?.setCameraMode()
                }

            })
        }
    }
    /**
     *  Set the camera's mode to DJICameraMode.ShootPhoto.
     *  If it succeeds, we check the exposure mode.
     */

    func setCameraMode() {
        self.rangeLabel.text = STATE_SETTING_CAMERA_MODE
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            
            camera?.setCameraMode(DJICameraMode.shootPhoto, withCompletion: {[weak self](error: Error?) -> Void in
                
                if error != nil {
                    self?.rangeLabel.text = "ERROR: setCameraMode:withCompletion:. \(error!)"
                }
                else {
                    // Normally, once an operation is finished, the camera still needs some time to finish up
                    // all the work. It is safe to delay the next operation after an operation is finished.
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {() -> Void in
                        
                        self?.getExposureMode()
                    })
                }
            })
        }
    }
    /**
     *  Check if current exposure mdoe is DJIExposureModeManual. For most of the products, ISO can only be set when
     *  the exposure mode is DJIExposureModeManual. 
     *  If the exposure mode is correct, enable the set/get buttons. 
     *  If the exposure mode is not DJIExposureModeManual, change the exposure mode.
     */

    func getExposureMode() {
        self.rangeLabel.text = STATE_CHECKING_EXPOSURE_MODE
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            
            camera?.getExposureMode(completion: {[weak self](expMode: DJICameraExposureMode, error: Error?) -> Void in
                
                if error != nil {
                    self?.rangeLabel.text = "ERROR: getExposureModeWithCompletion:. \(error!)"
                }
                else if expMode == DJICameraExposureMode.manual {
                    self?.enableGetSetISO()
                }
                else {
                    self?.setExposureMode()
                }

            })
        }
    }
    /**
     *  Set the exposure mode to DJICameraExposureModeManual. 
     *  If it succeeds, we enable the get/set buttons.
     */

    func setExposureMode() {
        self.rangeLabel.text = STATE_SETTING_EXPOSURE_MODE
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            
            camera?.setExposureMode(DJICameraExposureMode.manual, withCompletion: {[weak self](error: Error?) -> Void in
                
                if error != nil {
                    self?.rangeLabel.text = "ERROR: setExposureMode:withCompletion:. \(error!)"
                }
                else {
                    // all the pre-conditions are satisfied.
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {() -> Void in
                        self?.enableGetSetISO()
                    })
                }
            })
        }
    }

    func enableGetSetISO() {
        self.getValueButton.isEnabled = true
        self.setValueButton.isEnabled = true
        self.updateValidISORange()
    }
    /**
     *  We provide a utility class called DJICameraParameters to check what the valid range for a parameter is.
     */

    func updateValidISORange() {
        let str: NSMutableString = NSMutableString(string: STATE_WAIT_FOR_INPUT)
        str.append("\n the valid range: \n")
        let range:NSArray? = DJICameraParameters.sharedInstance().supportedCameraISORange() as NSArray?
        
        if (range != nil) {
            str.append(range!.horizontalDescription())
        }
        self.rangeLabel.text = str as String
    }

    @IBAction override func onGetButtonClicked(_ sender: AnyObject) {
        self.updateISO()
    }

    func updateISO() {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            
            camera?.getISOWithCompletion({[weak self](iso: DJICameraISO, error: Error?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("ERROR: getISO:\(error!)")
                }
                else {
                    self?.getValueTextField.text = "\(iso.rawValue)"
                }
            })
        }
    }

    @IBAction override func onSetButtonClicked(_ sender: AnyObject) {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            let iso: DJICameraISO = DJICameraISO(rawValue: UInt((self.setValueTextField.text! as NSString).intValue))!
            camera?.setISO(iso, withCompletion: {[weak self](error: Error?) -> Void in
                if error != nil {
                    self?.showAlertResult("ERROR: setISO:\(error!)")
                }
                else {
                    self?.showAlertResult("Success. ")
                }
            })
        }
    }
}

