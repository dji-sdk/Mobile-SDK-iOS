//
//  RCParingViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 16/1/6.
//  Copyright © 2016 DJI. All rights reserved.
//


import DJISDK
class RCParingViewController: DJIBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onStartParingButtonClicked(_ sender: AnyObject) {
        let rc: DJIRemoteController? = self.fetchRemoteController()
        if rc != nil {
            rc!.enterRCToAircraftPairingMode(completion: {[weak self](error: Error?) -> Void in
                if error != nil {
                    self?.showAlertResult("Start Failed: \(error!.localizedDescription)")
                }
                else {
                    self?.showAlertResult("Start Succeeded.")
                }
            })
        }
        else {
            self.showAlertResult("Component Not Exist")
        }
    }
    
    @IBAction func onStopParingButtonClicked(_ sender: AnyObject) {
        let rc: DJIRemoteController? = self.fetchRemoteController()
        if rc != nil {
            rc!.exitRCToAircraftPairingMode(completion: {[weak self](error: Error?) -> Void in
                if error != nil {
                    self?.showAlertResult("Stop Failed: \(error!.localizedDescription)")
                }
                else {
                    self?.showAlertResult("Stop Succeeded.")
                }
            })
        }
        else {
            self.showAlertResult("Component Not Exist")
        }
    }
    
}
