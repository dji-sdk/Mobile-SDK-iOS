//
//  SleepModeViewController.swift
//  DJISDKSwiftDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
import DJISDK

class SleepModeViewController: DJIBaseViewController, DJIHandheldControllerDelegate {
    @IBOutlet weak var sleepButton: UIButton!
    @IBOutlet weak var awakeButton: UIButton!
    @IBOutlet weak var shutdownButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let handheld: DJIHandheldController? = self.fetchHandheldController()
        if handheld != nil {
            handheld!.delegate = self
        }
        else {
            self.showAlertResult("There is no handheld controller. ")
            self.sleepButton.isEnabled = false
            self.awakeButton.isEnabled = false
            self.shutdownButton.isEnabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let handheld: DJIHandheldController? = self.fetchHandheldController()
        if handheld?.delegate === self {
            handheld!.delegate = nil
        }
    }
    
    @IBAction func onSleepButtonClicked(_ sender: AnyObject) {
        let handheld: DJIHandheldController? = self.fetchHandheldController()
        if handheld != nil {
            self.sleepButton.isEnabled = false
            self.sendPowerMode(DJIHandheldPowerMode.sleeping)
        }
    }
    
    @IBAction func onAwakeButtonClicked(_ sender: AnyObject) {
        let handheld: DJIHandheldController? = self.fetchHandheldController()
        if handheld != nil {
            self.awakeButton.isEnabled = false
            self.sendPowerMode(DJIHandheldPowerMode.awake)
        }
    }
    
    @IBAction func onShutdownButtonClicked(_ sender: AnyObject) {
        let handheld: DJIHandheldController? = self.fetchHandheldController()
        if handheld != nil {
            self.shutdownButton.isEnabled = false
            self.sendPowerMode(DJIHandheldPowerMode.powerOff)
        }
    }
    
    func sendPowerMode(_ mode: DJIHandheldPowerMode) {
        let handheld: DJIHandheldController? = self.fetchHandheldController()
        if handheld != nil {
            handheld!.setHandheldPowerMode(mode, withCompletion: {[weak self](error: Error?) -> Void in
                if error != nil {
                    self?.showAlertResult("ERROR: setHandheldPowerMode failed: \(error!)")
                }
                else {
                    self?.showAlertResult("SUCCESS: setHandheldPowerMode. ")
                }
            })
        }
    }
    
    func handheldController(_ controller: DJIHandheldController, didUpdate powerMode: DJIHandheldPowerMode) {
        switch powerMode {
        case DJIHandheldPowerMode.sleeping:
            self.sleepButton.isEnabled = false
            self.awakeButton.isEnabled = true
            self.shutdownButton.isEnabled = true
        case DJIHandheldPowerMode.awake:
            self.sleepButton.isEnabled = true
            self.awakeButton.isEnabled = false
            self.shutdownButton.isEnabled = true
        case DJIHandheldPowerMode.powerOff:
            self.sleepButton.isEnabled = false
            self.awakeButton.isEnabled = false
            self.shutdownButton.isEnabled = false
        default:
            break
        }
        
    }
}
