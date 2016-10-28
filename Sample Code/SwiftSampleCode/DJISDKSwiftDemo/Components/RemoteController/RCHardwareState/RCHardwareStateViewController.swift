//
//  RCHardwareStateViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 16/1/6.
//  Copyright © 2016 DJI. All rights reserved.
//

import DJISDK
class RCHardwareStateViewController:DJIBaseViewController, DJIRemoteControllerDelegate{
    
    @IBOutlet weak var leftWheel:UISlider!
    @IBOutlet weak var rightWheel:UISlider!
    @IBOutlet weak var modeSwitch:UISegmentedControl!
    @IBOutlet weak var leftVertical:UILabel!
    @IBOutlet weak var rightVertical:UILabel!
    @IBOutlet weak var rightHorizontal:UILabel!
    @IBOutlet weak var leftHorizontal:UILabel!
    @IBOutlet weak var cameraRecord:UILabel!
    @IBOutlet weak var cameraShutter:UILabel!
    @IBOutlet weak var cameraPlayback:UILabel!
    @IBOutlet weak var goHomeButton:UILabel!
    @IBOutlet weak var customButton1:UILabel!
    @IBOutlet weak var customButton2:UILabel!
    @IBOutlet weak var transformSwitch:UISwitch!
    var wheelOffset: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        self.initUI()
        let rc: DJIRemoteController? = self.fetchRemoteController()
        if rc != nil {
            rc!.delegate = self
        }
    }
    
    func initUI() {
        self.leftVertical.layer.cornerRadius = 4.0
        self.leftVertical.layer.borderColor = UIColor.black.cgColor
        self.leftVertical.layer.borderWidth = 1.2
        self.leftVertical.layer.masksToBounds = true
        
        self.rightVertical.layer.cornerRadius = 4.0
        self.rightVertical.layer.borderColor = UIColor.black.cgColor
        self.rightVertical.layer.borderWidth = 1.2
        self.rightVertical.layer.masksToBounds = true
        
        self.rightHorizontal.layer.cornerRadius = 4.0
        self.rightHorizontal.layer.borderColor = UIColor.black.cgColor
        self.rightHorizontal.layer.borderWidth = 1.2
        self.rightHorizontal.layer.masksToBounds = true
        
        self.leftHorizontal.layer.cornerRadius = 4.0
        self.leftHorizontal.layer.borderColor = UIColor.black.cgColor
        self.leftHorizontal.layer.borderWidth = 1.2
        self.leftHorizontal.layer.masksToBounds = true
        
        self.cameraRecord.layer.cornerRadius = self.cameraRecord.frame.size.width * 0.5
        self.cameraRecord.layer.borderColor = UIColor.black.cgColor
        self.cameraRecord.layer.borderWidth = 1.2
        self.cameraRecord.layer.masksToBounds = true
        self.cameraShutter.layer.cornerRadius = self.cameraShutter.frame.size.width * 0.5
        self.cameraShutter.layer.borderColor = UIColor.black.cgColor
        self.cameraShutter.layer.borderWidth = 1.2
        self.cameraShutter.layer.masksToBounds = true
        self.cameraPlayback.layer.cornerRadius = self.cameraPlayback.frame.size.width * 0.5
        self.cameraPlayback.layer.borderColor = UIColor.black.cgColor
        self.cameraPlayback.layer.borderWidth = 1.2
        self.cameraPlayback.layer.masksToBounds = true
        self.goHomeButton.layer.cornerRadius = self.goHomeButton.frame.size.width * 0.5
        self.goHomeButton.layer.borderColor = UIColor.black.cgColor
        self.goHomeButton.layer.borderWidth = 1.2
        self.goHomeButton.layer.masksToBounds = true
        self.customButton1.layer.cornerRadius = self.customButton1.frame.size.width * 0.5
        self.customButton1.layer.borderColor = UIColor.black.cgColor
        self.customButton1.layer.borderWidth = 1.2
        self.customButton1.layer.masksToBounds = true
        self.customButton2.layer.cornerRadius = self.customButton2.frame.size.width * 0.5
        self.customButton2.layer.borderColor = UIColor.black.cgColor
        self.customButton2.layer.borderWidth = 1.2
        self.customButton2.layer.masksToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func remoteController(_ rc: DJIRemoteController, didUpdate state: DJIRCHardwareState) {
        self.rightHorizontal.text =  "\(state.rightHorizontal.value)"
        self.rightVertical.text = "\(state.rightVertical.value)"
        self.leftVertical.text = "\(state.leftVertical.value)"
        self.leftHorizontal.text = "\(state.leftHorizontal.value)"
        
        self.leftWheel.setValue(Float(state.leftWheel.value), animated: true)
        let sign:Int = state.rightWheel.wheelDirection.boolValue ? 1 : -1
        let offset:Int = Int(state.rightWheel.value) * sign
        self.wheelOffset += offset
        if self.wheelOffset > 20 {
            self.wheelOffset = -20
        }
        if self.wheelOffset < -20 {
            self.wheelOffset = 20
        }
        self.rightWheel.setValue(Float(self.wheelOffset), animated: true)
        self.modeSwitch.selectedSegmentIndex = Int(state.flightModeSwitch.mode.rawValue)
        let pressedColor: UIColor = UIColor.red.withAlphaComponent(0.5)
        let normalColor: UIColor = UIColor.white
        self.cameraRecord.backgroundColor = (state.recordButton.buttonDown.boolValue ? pressedColor : normalColor)
        self.cameraRecord.isHidden = state.recordButton.isPresent.boolValue
        self.cameraShutter.backgroundColor = (state.shutterButton.buttonDown.boolValue ? pressedColor : normalColor)
        self.cameraShutter.isHidden = !state.shutterButton.isPresent.boolValue
        self.cameraPlayback.backgroundColor = (state.playbackButton.buttonDown.boolValue ? pressedColor : normalColor)
        self.cameraPlayback.isHidden = !state.shutterButton.isPresent.boolValue
        self.goHomeButton.backgroundColor = (state.goHomeButton.buttonDown.boolValue ? pressedColor : normalColor)
        self.goHomeButton.isHidden = !state.shutterButton.isPresent.boolValue
        self.customButton1.backgroundColor = (state.customButton1.buttonDown.boolValue ? pressedColor : normalColor)
        self.customButton1.isHidden = !state.shutterButton.isPresent.boolValue
        self.customButton2.backgroundColor = (state.customButton2.buttonDown.boolValue ? pressedColor : normalColor)
        self.customButton2.isHidden = !state.shutterButton.isPresent.boolValue
        let isTranforam: Bool = state.transformationSwitch.transformationSwitchState == DJIRCHardwareTransformationSwitchState.retract
        self.transformSwitch.setOn(isTranforam, animated: true)
    }
}
