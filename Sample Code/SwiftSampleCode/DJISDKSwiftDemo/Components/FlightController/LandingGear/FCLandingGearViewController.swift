//
//  FCLandingGearViewController.swift
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
        self.landingGearMode = DJILandingGearMode.Unknown
        self.landingGearStatus = DJILandingGearStatus.Unknown
        if let fc = self.fetchFlightController() {
            fc.delegate = self
        }
    }
    
    @IBAction func onTurnOnButtonClicked(sender: AnyObject) {
        if let fc = self.fetchFlightController() {
            guard let landingGear = fc.landingGear else {
                self.showAlertResult("Component Not Exist.")
                return
            }
            landingGear.turnOnAutoLandingGearWithCompletion { [weak self] (error: NSError?) -> Void in
                guard let error = error else { return }
                self?.showAlertResult("Turn on:\(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func onTurnOffButtonClicked(sender: AnyObject) {
        if let fc = self.fetchFlightController() {
            guard let landingGear = fc.landingGear else {
                self.showAlertResult("Component Not Exist.")
                return
            }
            landingGear.turnOffAutoLandingGearWithCompletion { [weak self] (error: NSError?) -> Void in
                guard let error = error else { return }
                self?.showAlertResult("Turn Off:\(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func onEnterTransportButtonClicked(sender: AnyObject) {
        guard let fc = self.fetchFlightController() else { return }
        
        guard let landingGear = fc.landingGear else {
            self.showAlertResult("Component Not Exist.")
            return
        }
        
        landingGear.enterTransportModeWithCompletion { [weak self] (error: NSError?) -> Void in
            guard let error = error else { return }
            self?.showAlertResult("Enter Transport: \(error.localizedDescription)")
        }
    }
    
    @IBAction func onExitTransportButtonClicked(sender: AnyObject) {
        guard let fc = self.fetchFlightController() else { return }
        
        guard let landingGear = fc.landingGear else {
            self.showAlertResult("Component Not Exist.")
            return
        }
        landingGear.exitTransportModeWithCompletion { [weak self] (error: NSError?) -> Void in
            guard let error = error else { return }
            self?.showAlertResult("Exit Transport:\(error.localizedDescription)")
        }
    }
    
    func flightController(fc: DJIFlightController, didUpdateSystemState state: DJIFlightControllerCurrentState) {
        guard let landingGear = fc.landingGear else { return }
        
        if landingGear.mode != landingGearMode {
            self.landingGearMode = landingGear.mode
            self.modeLabel.text = self.stringWithLandingGearMode(landingGearMode)
        }
        if landingGear.status != landingGearStatus {
            self.landingGearStatus = landingGear.status
            self.statusLabel.text = self.stringWithLandingGearStatus(landingGearStatus)
        }
    }
    
    func stringWithLandingGearMode(mode: DJILandingGearMode) -> String {
        switch mode {
            case .Auto:         return "Auto"
            case .Normal:       return "Normal"
            case .Transport:    return "Transport"
            default:            return "N/A"
        }
    }
    
    func stringWithLandingGearStatus(status: DJILandingGearStatus) -> String {
        switch status {
            case .Deployed:     return "Deployed"
            case .Deploying:    return "Deploying"
            case .Retracted:    return "Retracted"
            case .Retracting:   return "Retracting"
            case .Stopped:      return "Stopped"
            default:            return "N/A"
        }
    }

}