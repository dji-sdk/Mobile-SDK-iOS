//
//  FCGeneralControlViewController.swift
//  DJISdkDemo
//
//  Created by DJI on 16/1/6.
//  Copyright © 2016 DJI. All rights reserved.
//

import DJISDK
class FCGeneralControlViewController: DJIBaseViewController {
    
    @IBAction func onTakeoffButtonClicked(sender: AnyObject) {
        guard let fc = self.fetchFlightController() else {
            self.showAlertResult("Component Not Exist")
            return
        }
        fc.takeoffWithCompletion { [weak self] (error: NSError?) -> Void in
            guard let error = error else {
                self?.showAlertResult("Takeoff Succeeded.")
                return
            }
            self?.showAlertResult("Takeoff Error: \(error.localizedDescription)")
        }
    }
    
    @IBAction func onGoHomeButtonClicked(sender: AnyObject) {
        guard let fc = self.fetchFlightController() else {
            self.showAlertResult("Component Not Exist")
            return
        }
        fc.goHomeWithCompletion { [weak self] (error: NSError?) -> Void in
            guard let error = error else {
                self?.showAlertResult("GoHome Succeeded.")
                return
            }
            self?.showAlertResult("GoHome Error: \(error.localizedDescription)")
        }
    }
    
    @IBAction func onLandButtonClicked(sender: AnyObject) {
        guard let fc = self.fetchFlightController() else {
            self.showAlertResult("Component Not Exist")
            return
        }
        fc.autoLandingWithCompletion { [weak self] (error: NSError?) -> Void in
            guard let error = error else {
                self?.showAlertResult("Land Succeeded.")
                return
            }
            self?.showAlertResult("Land Error:\(error.localizedDescription)")
        }
    }
}