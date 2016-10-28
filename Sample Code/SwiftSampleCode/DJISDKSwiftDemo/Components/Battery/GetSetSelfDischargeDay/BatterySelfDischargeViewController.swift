//
//  BatterySelfDischargeViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 12/17/15.
//  Copyright © 2015 DJI. All rights reserved.
//
import DJISDK

class BatterySelfDischargeViewController: DemoGetSetViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Self Discharge Days"
        self.rangeLabel.text = "The input should be an integer. The range is [1, 10]. "
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction override func onGetButtonClicked(_ sender: AnyObject) {
        self.updateSelfDischargeDay()
    }

    func updateSelfDischargeDay() {
        let battery: DJIBattery? = self.fetchBattery()
        if battery != nil {
            
            battery!.getSelfDischargeDay(completion: {[weak self](day: UInt8, error: Error?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("ERROR: getBatterySelfDischargeDay \(error!)")
                }
                else {
                    let getTextString: String = "\(day)"
                    self?.getValueTextField.text = getTextString
                }
            })
        }
    }

    @IBAction override func onSetButtonClicked(_ sender: AnyObject) {
        let battery: DJIBattery? = self.fetchBattery()
        if (battery != nil && self.setValueTextField.text != "") {
            let selDischargeDay: UInt8 = UInt8(self.setValueTextField.text!)!
            battery!.setSelfDischargeDay(selDischargeDay, withCompletion: {[weak self](error: Error?) -> Void in
                if error != nil {
                    self?.showAlertResult("ERROR: setBatterySelfDischargeDay:\(error!)")
                }
                else {
                    self?.showAlertResult("Success. ")
                }
            })
        }
    }
}

