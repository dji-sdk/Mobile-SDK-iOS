//
//  FCLandingGearViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 16/1/5.
//  Copyright © 2016 DJI. All rights reserved.
//

import DJISDK
class FCLandingGearViewController: DJIBaseViewController, DJIFlightControllerDelegate {
    
    
    var landingGearMode: DJILandingGearMode = .unknown
    var landingGearStatus: DJILandingGearStatus = .unknown
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var modeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        self.landingGearMode = DJILandingGearMode.unknown
        self.landingGearStatus = DJILandingGearStatus.unknown
        let fc: DJIFlightController? = self.fetchFlightController()
        if fc != nil {
            fc?.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onTurnOnButtonClicked(_ sender: AnyObject) {
        let fc: DJIFlightController? = self.fetchFlightController()
        
        if (fc != nil) {
            let landingGear: DJILandingGear? = fc!.landingGear
            if landingGear != nil {
                landingGear?.turnOnAutoLandingGear(completion: {[weak self](error: Error?) -> Void in
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
    
    @IBAction func onTurnOffButtonClicked(_ sender: AnyObject) {
        let fc: DJIFlightController? = self.fetchFlightController()
        
        if (fc != nil) {
            let landingGear: DJILandingGear? = fc!.landingGear
            if landingGear != nil {
                landingGear!.turnOffAutoLandingGear(completion: {[weak self](error: Error?) -> Void in
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
    
    @IBAction func onEnterTransportButtonClicked(_ sender: AnyObject) {
        let fc: DJIFlightController? = self.fetchFlightController()
        
        if (fc == nil) {
            return
        }
        
        let landingGear: DJILandingGear? = fc!.landingGear
        if landingGear != nil {
            landingGear!.enterTransportMode(completion: {[weak self](error: Error?) -> Void in
                if error != nil {
                    self?.showAlertResult("Enter Transport: \(error?.localizedDescription)")
                }
            })
        }
        else {
            self.showAlertResult("Component Not Exist.")
        }
    }
    
    @IBAction func onExitTransportButtonClicked(_ sender: AnyObject) {
        let fc: DJIFlightController? = self.fetchFlightController()
        if (fc == nil) {
            return
        }
        
        let landingGear: DJILandingGear? = fc?.landingGear
        if landingGear != nil {
            landingGear!.exitTransportMode(completion: {[weak self](error: Error?) -> Void in
                if error != nil {
                    self?.showAlertResult("Exit Transport:\(error?.localizedDescription)")
                }
            })
        }
        else {
            self.showAlertResult("Component Not Exist.")
        }
    }
    
    func flightController(_ fc: DJIFlightController, didUpdateSystemState state: DJIFlightControllerCurrentState) {
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
    
    func stringWithLandingGearMode(_ mode: DJILandingGearMode) -> String {
        if mode == DJILandingGearMode.auto {
            return "Auto"
        }
        else if mode == DJILandingGearMode.normal {
            return "Normal"
        }
        else if mode == DJILandingGearMode.transport {
            return "Transport"
        }
        else {
            return "N/A"
        }
        
    }
    
    func stringWithLandingGearStatus(_ status: DJILandingGearStatus) -> String {
        if status == DJILandingGearStatus.deployed {
            return "Deployed"
        }
        else if status == DJILandingGearStatus.deploying {
            return "Deploying"
        }
        else if status == DJILandingGearStatus.retracted {
            return "Retracted"
        }
        else if status == DJILandingGearStatus.retracting {
            return "Retracting"
        }
        else if status == DJILandingGearStatus.stopped {
            return "Stoped"
        }
        else {
            return "N/A"
        }
        
    }

}
