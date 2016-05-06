//
//  RCParingViewController.swift
//  DJISdkDemo
//
//  Created by DJI on 16/1/6.
//  Copyright © 2016 DJI. All rights reserved.
//


import DJISDK
class RCParingViewController: DJIBaseViewController {
    
    @IBAction func onStartParingButtonClicked(sender: AnyObject) {
        if let rc = self.fetchRemoteController() {
            rc.enterRCToAircraftPairingModeWithCompletion{[weak self](error: NSError?) -> Void in
                if let error = error {
                    self?.showAlertResult("Start Failed: \(error.localizedDescription)")
                }
                else {
                    self?.showAlertResult("Start Succeeded.")
                }
            }
        }
        else {
            self.showAlertResult("Component Not Exist")
        }
    }
    
    @IBAction func onStopParingButtonClicked(sender: AnyObject) {
        if let rc = self.fetchRemoteController() {
            rc.exitRCToAircraftPairingModeWithCompletion{[weak self](error: NSError?) -> Void in
                if let error = error {
                    self?.showAlertResult("Stop Failed: \(error.localizedDescription)")
                }
                else {
                    self?.showAlertResult("Stop Succeeded.")
                }
            }
        }
        else {
            self.showAlertResult("Component Not Exist")
        }
    }
    
}
