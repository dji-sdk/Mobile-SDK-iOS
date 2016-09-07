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

    @IBAction override func onGetButtonClicked(sender: AnyObject) {
        self.updateSelfDischargeDay()
    }

    func updateSelfDischargeDay() {
        let battery: DJIBattery? = self.fetchBattery()
        if battery != nil {
            
            battery!.getSelfDischargeDayWithCompletion({[weak self](day: UInt8, error: NSError?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("ERROR: getBatterySelfDischargeDay \(error!.description)")
                }
                else {
                    let getTextString: String = "\(day)"
                    self?.getValueTextField.text = getTextString
                }
            })
        }
    }

    @IBAction override func onSetButtonClicked(sender: AnyObject) {
        let battery: DJIBattery? = self.fetchBattery()
        if (battery != nil && self.setValueTextField.text != "") {
            let selDischargeDay: UInt8 = UInt8(self.setValueTextField.text!)!
            battery!.setSelfDischargeDay(selDischargeDay, withCompletion: {[weak self](error: NSError?) -> Void in
                if error != nil {
                    self?.showAlertResult("ERROR: setBatterySelfDischargeDay:\(error!.description)")
                }
                else {
                    self?.showAlertResult("Success. ")
                }
            })
        }
    }
}

