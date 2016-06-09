//
//  FCFlightLimitationViewController.swift
//  DJISdkDemo
//
//  Created by DJI on 16/1/5.
//  Copyright © 2016 DJI. All rights reserved.
//

import DJISDK

class FCFlightLimitationViewController: DJIBaseViewController, DJIFlightControllerDelegate {
    @IBOutlet weak var heightLimitTextField: UITextField!
    @IBOutlet weak var radiusLimitTextField: UITextField!
    @IBOutlet weak var radiusLimitSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getParameters()
      }
    
    func getParameters() {

        if let fc = self.fetchFlightController() {
            fc.delegate = self
            
            fc.flightLimitation?.getMaxFlightHeightWithCompletion { [weak self] (height: Float, error: NSError?) -> Void in
                guard let error = error else {
                    self?.heightLimitTextField.text = String(format: "%0.1f", height)
                    return
                }
                self?.showAlertResult("Get Max Flight Height:\(error.localizedDescription)")
            }
            
            fc.flightLimitation?.getMaxFlightRadiusLimitationEnabledWithCompletion { [weak self] (enabled: Bool, error: NSError?) -> Void in
                
                if let error = error {
                    self?.showAlertResult("Get RadiusLimitationEnable:\(error.localizedDescription)")
                }
                else {
                    self?.radiusLimitSwitch.on = enabled
                    if enabled {
                        self?.radiusLimitTextField.enabled = true
                        fc.flightLimitation?.getMaxFlightRadiusWithCompletion { [weak self] (radius: Float, error: NSError?) -> Void in
                            
                            guard let error = error else {
                                self?.radiusLimitTextField.text = String(format: "%0.1f", radius)
                                return
                            }
                            self?.showAlertResult("Get MaxFlightRadius:\(error.localizedDescription)")
                        }
                    }
                    else {
                        self?.radiusLimitTextField.enabled = false
                        self?.radiusLimitTextField.text = "0"
                    }
                }
            }
        }

    }
    
    @IBAction func onLimitSwitchValueChanged(sender: UISwitch) {
        if let fc = self.fetchFlightController() {
            fc.flightLimitation?.setMaxFlightRadiusLimitationEnabled(sender.on) { [weak self] (error: NSError?) -> Void in
                if let error = error {
                    self?.showAlertResult("setMaxFlightRadiusLimitationEnabled:\(error.localizedDescription)")
                    sender.setOn(!sender.on, animated: true)
                }
                else {
                    if sender.on {
                        self?.radiusLimitTextField.enabled = true
                        fc.flightLimitation?.getMaxFlightRadiusWithCompletion { [weak self] (radius: Float, error: NSError?) -> Void in
                            guard let error = error else {
                                self?.radiusLimitTextField.text = String(format: "%0.1f", radius)
                                return
                            }
                            self?.showAlertResult("\(error.localizedDescription)")
                            
                            fc.flightLimitation?.getMaxFlightHeightWithCompletion { [weak self] (height: Float, error: NSError?) -> Void in
                                guard let error = error else {
                                    self?.heightLimitTextField.text = String(format: "%0.1f", height)
                                    return
                                }
                                self?.showAlertResult("Get Max Flight Height:\(error.localizedDescription)")
                            }
                        }
                        
                    }
                    else {
                        self?.radiusLimitTextField.enabled = false
                        self?.radiusLimitTextField.text = "0"
                    }
                }
            }
        }
    }
    
    func setMaxFlightHeight(height: Float) {
        if let fc = self.fetchFlightController() {
            fc.flightLimitation?.setMaxFlightHeight(height) { [weak self] (error: NSError?) -> Void in
                //if error != nil {
                    self?.showAlertResult("setMaxFlightHeight:\(error?.localizedDescription)")
                //}
            }
        }
    }
    
    func setMaxFlightRadius(radius: Float) {
        if let fc = self.fetchFlightController() {
            fc.flightLimitation?.setMaxFlightRadius(radius) { [weak self] (error: NSError?) -> Void in
                //if error != nil {
                    self?.showAlertResult("setMaxFlightRadius:\(error?.localizedDescription)")
                //}
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.heightLimitTextField {
            let value: Float = CFloat(textField.text!)!
            self.setMaxFlightHeight(value)
        }
        else {
            let value = CFloat(textField.text!)!
            self.setMaxFlightRadius(value)
        }
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
        return true
    }
    
 
}