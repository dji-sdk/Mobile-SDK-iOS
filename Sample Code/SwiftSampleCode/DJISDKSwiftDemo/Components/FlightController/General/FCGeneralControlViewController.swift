//
//  FCGeneralControlViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 16/1/6.
//  Copyright © 2016 DJI. All rights reserved.
//

import DJISDK
class FCGeneralControlViewController: DJIBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTakeoffButtonClicked(_ sender: AnyObject) {
        let fc: DJIFlightController? = self.fetchFlightController()
        if fc != nil {
            fc!.takeoff(completion: {[weak self](error: Error?) -> Void in
                if error != nil {
                    self?.showAlertResult("Takeoff Error: \(error!.localizedDescription)")
                }
                else {
                    self?.showAlertResult("Takeoff Succeeded.")
                }
            })
        }
        else {
            self.showAlertResult("Component Not Exist")
        }
    }
    
    @IBAction func onGoHomeButtonClicked(_ sender: AnyObject) {
        let fc: DJIFlightController? = self.fetchFlightController()
        if fc != nil {
            fc!.goHome(completion: {[weak self](error: Error?) -> Void in
                if error != nil {
                    self?.showAlertResult("GoHome Error: \(error!.localizedDescription)")
                }
                else {
                    self?.showAlertResult("GoHome Succeeded.")
                }
            })
        }
        else {
            self.showAlertResult("Component Not Exist")
        }
    }
    
    @IBAction func onLandButtonClicked(_ sender: AnyObject) {
        let fc: DJIFlightController? = self.fetchFlightController()
        if fc != nil {
            fc!.autoLanding(completion: {[weak self](error: Error?) -> Void in
                if error != nil {
                    self?.showAlertResult("Land Error:\(error!.localizedDescription)")
                }
                else {
                    self?.showAlertResult("Land Succeeded.")
                }
            })
        }
        else {
            self.showAlertResult("Component Not Exist")
        }
    }
}
