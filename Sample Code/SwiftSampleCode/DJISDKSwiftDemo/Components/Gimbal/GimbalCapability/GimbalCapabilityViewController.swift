//
//  GimbalCapabilityViewController.swift
//  DJISDKSwiftDemo
//
//  Copyright © 2016 DJI. All rights reserved.
//
/**
*  This file demonstrates how to use gimbal capability to check if a feature is supported by the connected gimbal and the valid range for
*  the feature. This demo will do the following steps:
*  1. Enable/disable buttons according to the supported features.
*  2. For products that support pitch range extension, the program will enable this feature.
*  3. When a button is pressed, this demo will get the min or max valid value and rotate the gimbal to the value.
*
*  A feature is represented by a key with DJIGimbalParam prefix. The value in the gimbalCapability dictionary is an istance of
*  DJIParamCapability or its subclass. A category, capabilityCheck, of DJIGimbal is provided in this demo.
*/

import DJISDK

class GimbalCapabilityViewController: DJIBaseViewController{
    @IBOutlet weak var pitchMinButton:UIButton!
    @IBOutlet weak var pitchMaxButton:UIButton!
    @IBOutlet weak var yawMinButton:UIButton!
    @IBOutlet weak var yawMaxButton:UIButton!
    @IBOutlet weak var rollMinButton:UIButton!
    @IBOutlet weak var rollMaxButton:UIButton!
    
    var pitchRotation : DJIGimbalAngleRotation! = DJIGimbalAngleRotation()
    var yawRotation : DJIGimbalAngleRotation! = DJIGimbalAngleRotation()
    var rollRotation : DJIGimbalAngleRotation! = DJIGimbalAngleRotation()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupButtons()
        self.setupRotationStructs()
        self.enablePitchExtensionIfPossible()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func setupButtons() {
        let gimbal : DJIGimbal? = self.fetchGimbal()
        if (gimbal == nil) {
            self.pitchMinButton.isEnabled = false
            self.pitchMaxButton.isEnabled = false
            self.yawMinButton.isEnabled = false
            self.yawMaxButton.isEnabled = false
            self.rollMinButton.isEnabled = false
            self.rollMaxButton.isEnabled = false
        }else {
            self.pitchMinButton.isEnabled = gimbal!.isFeatureSupported(DJIGimbalParamAdjustPitch)
            self.pitchMaxButton.isEnabled = gimbal!.isFeatureSupported(DJIGimbalParamAdjustPitch)
            self.yawMinButton.isEnabled = gimbal!.isFeatureSupported(DJIGimbalParamAdjustYaw)
            self.yawMaxButton.isEnabled = gimbal!.isFeatureSupported(DJIGimbalParamAdjustYaw)
            self.rollMinButton.isEnabled = gimbal!.isFeatureSupported(DJIGimbalParamAdjustRoll)
            self.rollMaxButton.isEnabled = gimbal!.isFeatureSupported(DJIGimbalParamAdjustRoll)
        }
    }
    
    func setupRotationStructs() {
        let gimbal: DJIGimbal? = self.fetchGimbal()
        self.pitchRotation.enabled = ObjCBool(false)
        self.yawRotation.enabled = ObjCBool(false)
        self.rollRotation.enabled = ObjCBool(false)
        
        if (gimbal != nil) {
            self.pitchRotation.enabled = ObjCBool(gimbal!.isFeatureSupported(DJIGimbalParamAdjustPitch))
            self.yawRotation.enabled = ObjCBool(gimbal!.isFeatureSupported(DJIGimbalParamAdjustYaw))
            self.rollRotation.enabled = ObjCBool(gimbal!.isFeatureSupported(DJIGimbalParamAdjustRoll))
        }
    }
    
    func enablePitchExtensionIfPossible() {
        let gimbal: DJIGimbal? = self.fetchGimbal()
        if (gimbal == nil) {
            return
        }
        let isPossible: Bool = gimbal!.isFeatureSupported(DJIGimbalParamPitchRangeExtensionEnabled)
        if isPossible {
            gimbal!.setPitchRangeExtensionEnabled(true, withCompletion: nil)
        }
    }
    
    @IBAction func rotateGimbalToMin(_ sender: AnyObject) {
        let gimbal: DJIGimbal? = self.fetchGimbal()
        if gimbal == nil {
            return
        }
        let key: String = self.getCorrespondingKeyWithButton((sender as! UIButton))!
        let min: Int? = gimbal!.getParamMin(key)
        if (key == DJIGimbalParamAdjustPitch && min != nil) {
            self.pitchRotation.direction = DJIGimbalRotateDirection.clockwise
            self.pitchRotation.angle = Float(min!)
        }
        else if (key == DJIGimbalParamAdjustYaw && min != nil) {
            self.yawRotation.direction = DJIGimbalRotateDirection.clockwise
            self.yawRotation.angle = Float(min!)
        }
        else if (key == DJIGimbalParamAdjustRoll && min != nil) {
            self.rollRotation.direction = DJIGimbalRotateDirection.clockwise
            self.rollRotation.angle = Float(min!)
        }
        
        self.sendRotateGimbalCommand()
    }
    
    @IBAction func rotateGimbalToMax(_ sender: AnyObject) {
        let gimbal: DJIGimbal? = self.fetchGimbal()
        if gimbal == nil {
            return
        }
        let key: String = self.getCorrespondingKeyWithButton((sender as! UIButton))!
        let max: Int? = gimbal!.getParamMax(key)
        if (key == DJIGimbalParamAdjustPitch && max != nil) {
            self.pitchRotation.direction = DJIGimbalRotateDirection.clockwise
            self.pitchRotation.angle = Float(max!)
        }
        else if (key == DJIGimbalParamAdjustYaw && max != nil) {
            self.yawRotation.direction = DJIGimbalRotateDirection.clockwise
            self.yawRotation.angle = Float(max!)
        }
        else if (key == DJIGimbalParamAdjustRoll && max != nil) {
            self.rollRotation.direction = DJIGimbalRotateDirection.clockwise
            self.rollRotation.angle = Float(max!)
        }
        
        self.sendRotateGimbalCommand()
    }
    
    @IBAction func resetGimbal(_ sender: AnyObject) {
        self.pitchRotation.angle = 0
        self.yawRotation.angle = 0
        self.rollRotation.angle = 0
        self.sendRotateGimbalCommand()
    }
    
    func sendRotateGimbalCommand() {
        let gimbal: DJIGimbal? = self.fetchGimbal()
        if gimbal == nil {
            return
        }
        gimbal!.rotateGimbal(with: DJIGimbalRotateAngleMode.angleModeAbsoluteAngle, pitch: self.pitchRotation, roll: self.rollRotation, yaw: self.yawRotation, withCompletion: {(error: Error?) -> Void in
            if error != nil {
                self.showAlertResult("rotateGimbalWithAngleMode failed: \(error!)")
            }
        })
    }
    
    func getCorrespondingKeyWithButton(_ button: UIButton) -> String? {
        if button == self.pitchMinButton || button == self.pitchMaxButton {
            return DJIGimbalParamAdjustPitch
        }
        else if button == self.yawMinButton || button == self.yawMaxButton {
            return DJIGimbalParamAdjustYaw
        }
        else if button == self.rollMinButton || button == self.rollMaxButton {
            return DJIGimbalParamAdjustRoll
        }
        
        return ""
    }
}
