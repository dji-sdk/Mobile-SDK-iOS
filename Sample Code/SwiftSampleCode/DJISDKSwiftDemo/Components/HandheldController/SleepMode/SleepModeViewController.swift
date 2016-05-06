//
//  SleepModeViewController.swift
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
import DJISDK

class SleepModeViewController: DJIBaseViewController, DJIHandheldControllerDelegate {
    @IBOutlet weak var sleepButton: UIButton!
    @IBOutlet weak var awakeButton: UIButton!
    @IBOutlet weak var shutdownButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard let handheld = self.fetchHandheldController() else {
            self.showAlertResult("There is no handheld controller. ")
            self.sleepButton.enabled = false
            self.awakeButton.enabled = false
            self.shutdownButton.enabled = false
            return
        }
        handheld.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let handheld = self.fetchHandheldController() where handheld.delegate === self {
            handheld.delegate = nil
        }
    }
    
    @IBAction func onSleepButtonClicked(sender: AnyObject) {
        if let _ = self.fetchHandheldController() {
            self.sleepButton.enabled = false
            self.sendPowerMode(DJIHandheldPowerMode.Sleeping)
        }
    }
    
    @IBAction func onAwakeButtonClicked(sender: AnyObject) {
        if let _ = self.fetchHandheldController() {
            self.awakeButton.enabled = false
            self.sendPowerMode(DJIHandheldPowerMode.Awake)
        }
    }
    
    @IBAction func onShutdownButtonClicked(sender: AnyObject) {
        if let _ = self.fetchHandheldController() {
            self.shutdownButton.enabled = false
            self.sendPowerMode(DJIHandheldPowerMode.PowerOff)
        }
    }
    
    func sendPowerMode(mode: DJIHandheldPowerMode) {
        if let handheld = self.fetchHandheldController() {
            handheld.setHandheldPowerMode(mode, withCompletion: {[weak self](error: NSError?) -> Void in
                if error != nil {
                    self?.showAlertResult("ERROR: setHandheldPowerMode failed: \(error!.description)")
                }
                else {
                    self?.showAlertResult("SUCCESS: setHandheldPowerMode. ")
                }
            })
        }
    }
    
    func handheldController(controller: DJIHandheldController, didUpdatePowerMode powerMode: DJIHandheldPowerMode) {
        switch powerMode {
        case .Sleeping:
            self.sleepButton.enabled = false
            self.awakeButton.enabled = true
            self.shutdownButton.enabled = true
        case .Awake:
            self.sleepButton.enabled = true
            self.awakeButton.enabled = false
            self.shutdownButton.enabled = true
        case .PowerOff:
            self.sleepButton.enabled = false
            self.awakeButton.enabled = false
            self.shutdownButton.enabled = false
        default:
            break
        }
        
    }
}