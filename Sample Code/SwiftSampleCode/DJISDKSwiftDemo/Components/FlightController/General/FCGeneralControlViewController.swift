//
//  FCGeneralControlViewController.m
//  DJISdkDemo
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
    
    @IBAction func onTakeoffButtonClicked(sender: AnyObject) {
        let fc: DJIFlightController? = self.fetchFlightController()
        if fc != nil {
            fc!.takeoffWithCompletion({[weak self](error: NSError?) -> Void in
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
    
    @IBAction func onGoHomeButtonClicked(sender: AnyObject) {
        let fc: DJIFlightController? = self.fetchFlightController()
        if fc != nil {
            fc!.goHomeWithCompletion({[weak self](error: NSError?) -> Void in
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
    
    @IBAction func onLandButtonClicked(sender: AnyObject) {
        let fc: DJIFlightController? = self.fetchFlightController()
        if fc != nil {
            fc!.autoLandingWithCompletion({[weak self](error: NSError?) -> Void in
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