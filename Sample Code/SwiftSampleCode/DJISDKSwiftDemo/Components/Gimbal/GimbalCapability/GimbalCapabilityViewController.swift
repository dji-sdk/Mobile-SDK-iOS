//
//  GimbalCapabilityViewController
//  DJISdkDemo
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
*  A feature is represented by a key with DJIGimbalKey prefix. The value in the gimbalCapability dictionary is an istance of
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
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setupButtons()
        self.setupRotationStructs()
        self.enablePitchExtensionIfPossible()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func setupButtons() {
        let gimbal : DJIGimbal? = self.fetchGimbal()
        if (gimbal == nil) {
            self.pitchMinButton.enabled = false
            self.pitchMaxButton.enabled = false
            self.yawMinButton.enabled = false
            self.yawMaxButton.enabled = false
            self.rollMinButton.enabled = false
            self.rollMaxButton.enabled = false
        }else {
            self.pitchMinButton.enabled = gimbal!.isFeatureSupported(DJIGimbalKeyAdjustPitch)
            self.pitchMaxButton.enabled = gimbal!.isFeatureSupported(DJIGimbalKeyAdjustPitch)
            self.yawMinButton.enabled = gimbal!.isFeatureSupported(DJIGimbalKeyAdjustYaw)
            self.yawMaxButton.enabled = gimbal!.isFeatureSupported(DJIGimbalKeyAdjustYaw)
            self.rollMinButton.enabled = gimbal!.isFeatureSupported(DJIGimbalKeyAdjustRoll)
            self.rollMaxButton.enabled = gimbal!.isFeatureSupported(DJIGimbalKeyAdjustRoll)
        }
    }
    
    func setupRotationStructs() {
        let gimbal: DJIGimbal? = self.fetchGimbal()
        self.pitchRotation.enabled = ObjCBool(false)
        self.yawRotation.enabled = ObjCBool(false)
        self.rollRotation.enabled = ObjCBool(false)
        
        if (gimbal != nil) {
            self.pitchRotation.enabled = ObjCBool(gimbal!.isFeatureSupported(DJIGimbalKeyAdjustPitch))
            self.yawRotation.enabled = ObjCBool(gimbal!.isFeatureSupported(DJIGimbalKeyAdjustYaw))
            self.rollRotation.enabled = ObjCBool(gimbal!.isFeatureSupported(DJIGimbalKeyAdjustRoll))
        }
    }
    
    func enablePitchExtensionIfPossible() {
        let gimbal: DJIGimbal? = self.fetchGimbal()
        if (gimbal == nil) {
            return
        }
        let isPossible: Bool = gimbal!.isFeatureSupported(DJIGimbalKeyPitchRangeExtension)
        if isPossible {
            gimbal!.setPitchRangeExtensionEnabled(true, withCompletion: nil)
        }
    }
    
    @IBAction func rotateGimbalToMin(sender: AnyObject) {
        let gimbal: DJIGimbal? = self.fetchGimbal()
        if gimbal == nil {
            return
        }
        let key: String = self.getCorrespondingKeyWithButton((sender as! UIButton))!
        let min: Int? = gimbal!.getParamMin(key)
        if (key == DJIGimbalKeyAdjustPitch && min != nil) {
            self.pitchRotation.direction = DJIGimbalRotateDirection.Clockwise
            self.pitchRotation.angle = Float(min!)
        }
        else if (key == DJIGimbalKeyAdjustYaw && min != nil) {
            self.yawRotation.direction = DJIGimbalRotateDirection.Clockwise
            self.yawRotation.angle = Float(min!)
        }
        else if (key == DJIGimbalKeyAdjustRoll && min != nil) {
            self.rollRotation.direction = DJIGimbalRotateDirection.Clockwise
            self.rollRotation.angle = Float(min!)
        }
        
        self.sendRotateGimbalCommand()
    }
    
    @IBAction func rotateGimbalToMax(sender: AnyObject) {
        let gimbal: DJIGimbal? = self.fetchGimbal()
        if gimbal == nil {
            return
        }
        let key: String = self.getCorrespondingKeyWithButton((sender as! UIButton))!
        let max: Int? = gimbal!.getParamMax(key)
        if (key == DJIGimbalKeyAdjustPitch && max != nil) {
            self.pitchRotation.direction = DJIGimbalRotateDirection.Clockwise
            self.pitchRotation.angle = Float(max!)
        }
        else if (key == DJIGimbalKeyAdjustYaw && max != nil) {
            self.yawRotation.direction = DJIGimbalRotateDirection.Clockwise
            self.yawRotation.angle = Float(max!)
        }
        else if (key == DJIGimbalKeyAdjustRoll && max != nil) {
            self.rollRotation.direction = DJIGimbalRotateDirection.Clockwise
            self.rollRotation.angle = Float(max!)
        }
        
        self.sendRotateGimbalCommand()
    }
    
    @IBAction func resetGimbal(sender: AnyObject) {
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
        gimbal!.rotateGimbalWithAngleMode(DJIGimbalRotateAngleMode.AngleModeAbsoluteAngle, pitch: self.pitchRotation, roll: self.rollRotation, yaw: self.yawRotation, withCompletion: {(error: NSError?) -> Void in
            if error != nil {
                self.showAlertResult("rotateGimbalWithAngleMode failed: \(error!.description)")
            }
        })
    }
    
    func getCorrespondingKeyWithButton(button: UIButton) -> String? {
        if button == self.pitchMinButton || button == self.pitchMaxButton {
            return DJIGimbalKeyAdjustPitch
        }
        else if button == self.yawMinButton || button == self.yawMaxButton {
            return DJIGimbalKeyAdjustYaw
        }
        else if button == self.rollMinButton || button == self.rollMaxButton {
            return DJIGimbalKeyAdjustRoll
        }
        
        return ""
    }
}