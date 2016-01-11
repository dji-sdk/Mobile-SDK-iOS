//
//  FCLandingGearViewController.m
//  DJISdkDemo
//
//  Created by DJI on 16/1/5.
//  Copyright © 2016 DJI. All rights reserved.
//

import DJISDK
class FCLandingGearViewController: DJIBaseViewController, DJIFlightControllerDelegate {
    
    
    var landingGearMode: DJILandingGearMode = .Unknown
    var landingGearStatus: DJILandingGearStatus = .Unknown
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var modeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        self.landingGearMode = DJILandingGearMode.Unknown
        self.landingGearStatus = DJILandingGearStatus.Unknown
        let fc: DJIFlightController? = self.fetchFlightController()
        if fc != nil {
            fc?.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onTurnOnButtonClicked(sender: AnyObject) {
        let fc: DJIFlightController? = self.fetchFlightController()
        
        if (fc != nil) {
            let landingGear: DJILandingGear? = fc!.landingGear
            if landingGear != nil {
                landingGear?.turnOnAutoLandingGearWithCompletion({[weak self](error: NSError?) -> Void in
                    if error != nil {
                        self?.showAlertResult("Turn on:\(error?.localizedDescription)")
                    }
                })
            }
            else {
                self.showAlertResult("Component Not Exist.")
            }
        }
    }
    
    @IBAction func onTurnOffButtonClicked(sender: AnyObject) {
        let fc: DJIFlightController? = self.fetchFlightController()
        
        if (fc != nil) {
            let landingGear: DJILandingGear? = fc!.landingGear
            if landingGear != nil {
                landingGear!.turnOffAutoLandingGearWithCompletion({[weak self](error: NSError?) -> Void in
                    if error != nil {
                        self?.showAlertResult("Turn Off:\(error?.localizedDescription)")
                    }
                })
            }
            else {
                self.showAlertResult("Component Not Exist.")
            }
        }
    }
    
    @IBAction func onEnterTransportButtonClicked(sender: AnyObject) {
        let fc: DJIFlightController? = self.fetchFlightController()
        
        if (fc == nil) {
            return
        }
        
        let landingGear: DJILandingGear? = fc!.landingGear
        if landingGear != nil {
            landingGear!.enterTransportModeWithCompletion({[weak self](error: NSError?) -> Void in
                if error != nil {
                    self?.showAlertResult("Enter Transport: \(error?.localizedDescription)")
                }
            })
        }
        else {
            self.showAlertResult("Component Not Exist.")
        }
    }
    
    @IBAction func onExitTransportButtonClicked(sender: AnyObject) {
        let fc: DJIFlightController? = self.fetchFlightController()
        if (fc == nil) {
            return
        }
        
        let landingGear: DJILandingGear? = fc?.landingGear
        if landingGear != nil {
            landingGear!.exitTransportModeWithCompletion({[weak self](error: NSError?) -> Void in
                if error != nil {
                    self?.showAlertResult("Exit Transport:\(error?.localizedDescription)")
                }
            })
        }
        else {
            self.showAlertResult("Component Not Exist.")
        }
    }
    
    func flightController(fc: DJIFlightController, didUpdateSystemState state: DJIFlightControllerCurrentState) {
        let landingGear: DJILandingGear? = fc.landingGear
        
        if (landingGear != nil) {
            if landingGear!.mode != landingGearMode {
                self.landingGearMode = landingGear!.mode
                self.modeLabel.text = self.stringWithLandingGearMode(landingGearMode)
            }
            if landingGear!.status != landingGearStatus {
                self.landingGearStatus = landingGear!.status
                self.statusLabel.text = self.stringWithLandingGearStatus(landingGearStatus)
            }
        }
    }
    
    func stringWithLandingGearMode(mode: DJILandingGearMode) -> String {
        if mode == DJILandingGearMode.Auto {
            return "Auto"
        }
        else if mode == DJILandingGearMode.Normal {
            return "Normal"
        }
        else if mode == DJILandingGearMode.Transport {
            return "Transport"
        }
        else {
            return "N/A"
        }
        
    }
    
    func stringWithLandingGearStatus(status: DJILandingGearStatus) -> String {
        if status == DJILandingGearStatus.Deployed {
            return "Deployed"
        }
        else if status == DJILandingGearStatus.Deploying {
            return "Deploying"
        }
        else if status == DJILandingGearStatus.Retracted {
            return "Retracted"
        }
        else if status == DJILandingGearStatus.Retracting {
            return "Retracting"
        }
        else if status == DJILandingGearStatus.Stopped {
            return "Stoped"
        }
        else {
            return "N/A"
        }
        
    }

}