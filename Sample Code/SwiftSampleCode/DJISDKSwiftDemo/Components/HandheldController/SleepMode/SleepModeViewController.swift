//
//  SleepModeViewController.m
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
        let handheld: DJIHandheldController? = self.fetchHandheldController()
        if handheld != nil {
            handheld!.delegate = self
        }
        else {
            self.showAlertResult("There is no handheld controller. ")
            self.sleepButton.enabled = false
            self.awakeButton.enabled = false
            self.shutdownButton.enabled = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let handheld: DJIHandheldController? = self.fetchHandheldController()
        if handheld?.delegate === self {
            handheld!.delegate = nil
        }
    }
    
    @IBAction func onSleepButtonClicked(sender: AnyObject) {
        let handheld: DJIHandheldController? = self.fetchHandheldController()
        if handheld != nil {
            self.sleepButton.enabled = false
            self.sendPowerMode(DJIHandheldPowerMode.Sleeping)
        }
    }
    
    @IBAction func onAwakeButtonClicked(sender: AnyObject) {
        let handheld: DJIHandheldController? = self.fetchHandheldController()
        if handheld != nil {
            self.awakeButton.enabled = false
            self.sendPowerMode(DJIHandheldPowerMode.Awake)
        }
    }
    
    @IBAction func onShutdownButtonClicked(sender: AnyObject) {
        let handheld: DJIHandheldController? = self.fetchHandheldController()
        if handheld != nil {
            self.shutdownButton.enabled = false
            self.sendPowerMode(DJIHandheldPowerMode.PowerOff)
        }
    }
    
    func sendPowerMode(mode: DJIHandheldPowerMode) {
        let handheld: DJIHandheldController? = self.fetchHandheldController()
        if handheld != nil {
            handheld!.setHandheldPowerMode(mode, withCompletion: {[weak self](error: NSError?) -> Void in
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
        case DJIHandheldPowerMode.Sleeping:
            self.sleepButton.enabled = false
            self.awakeButton.enabled = true
            self.shutdownButton.enabled = true
        case DJIHandheldPowerMode.Awake:
            self.sleepButton.enabled = true
            self.awakeButton.enabled = false
            self.shutdownButton.enabled = true
        case DJIHandheldPowerMode.PowerOff:
            self.sleepButton.enabled = false
            self.awakeButton.enabled = false
            self.shutdownButton.enabled = false
        default:
            break
        }
        
    }
}