//
//  FCFlightLimitationViewController.swift
//  DJISDKSwiftDemo
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
        // Do any additional setup after loading the view from its nib.
      }
    
    func getParameters() {

        let fc: DJIFlightController? = self.fetchFlightController()
        if fc != nil {
            fc?.delegate = self
            
            fc?.flightLimitation?.getMaxFlightHeightWithCompletion({[weak self](height: Float, error: NSError?) -> Void in
                if error != nil {
                    self?.showAlertResult("Get Max Flight Height:\(error?.localizedDescription)")
                }
                else {
                    self?.heightLimitTextField.text = String(format: "%0.1f", height)
                }
            })
            
            fc?.flightLimitation?.getMaxFlightRadiusLimitationEnabledWithCompletion({[weak self](enabled: Bool, error: NSError?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("Get RadiusLimitationEnable:\(error?.localizedDescription)")
                }
                else {
                    self?.radiusLimitSwitch.on = enabled
                    if enabled != false {
                        self?.radiusLimitTextField.enabled = true
                        fc?.flightLimitation?.getMaxFlightRadiusWithCompletion({[weak self](radius: Float, error: NSError?) -> Void in
                            
                            if error != nil {
                                self?.showAlertResult("Get MaxFlightRadius:\(error?.localizedDescription)")
                            }
                            else {
                                self?.radiusLimitTextField.text = String(format: "%0.1f", radius)
                            }
                            
                            })
                    }
                    else {
                        self?.radiusLimitTextField.enabled = false
                        self?.radiusLimitTextField.text = "0"
                    }
                }
                })
        }

    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLimitSwitchValueChanged(sender: UISwitch) {
        let fc: DJIFlightController? = self.fetchFlightController()
        if fc != nil {
            fc?.flightLimitation?.setMaxFlightRadiusLimitationEnabled(sender.on, withCompletion: {[weak self](error: NSError?) -> Void in
                if error != nil {
                    self?.showAlertResult("setMaxFlightRadiusLimitationEnabled:\(error?.localizedDescription)")
                    sender.setOn(!sender.on, animated: true)
                }
                else {
                        if sender.on {
                            self?.radiusLimitTextField.enabled = true
                            fc?.flightLimitation?.getMaxFlightRadiusWithCompletion({[weak self](radius: Float, error: NSError?) -> Void in
                                if error != nil {
                                    self?.showAlertResult("\(error?.localizedDescription)")
                                }
                                else {
                                        self?.radiusLimitTextField.text = String(format: "%0.1f", radius)
                                }
                                
                                fc?.flightLimitation?.getMaxFlightHeightWithCompletion({[weak self](height: Float, error: NSError?) -> Void in
                                    if error != nil {
                                        self?.showAlertResult("Get Max Flight Height:\(error?.localizedDescription)")
                                    }
                                    else {
                                        self?.heightLimitTextField.text = String(format: "%0.1f", height)
                                    }
                                    })
                            })
                            
                        }
                        else {
                            self?.radiusLimitTextField.enabled = false
                            self?.radiusLimitTextField.text = "0"
                        }
                }
            })
        }
    }
    
    func setMaxFlightHeight(height: Float) {
        let fc: DJIFlightController? = self.fetchFlightController()
        if fc != nil {
            fc?.flightLimitation?.setMaxFlightHeight(height, withCompletion: {[weak self](error: NSError?) -> Void in
                //if error != nil {
                    self?.showAlertResult("setMaxFlightHeight:\(error?.localizedDescription)")
                //}
            })
        }
    }
    
    func setMaxFlightRadius(radius: Float) {
        let fc: DJIFlightController? = self.fetchFlightController()
        if fc != nil {
            fc?.flightLimitation?.setMaxFlightRadius(radius, withCompletion: {[weak self](error: NSError?) -> Void in
                //if error != nil {
                    self?.showAlertResult("setMaxFlightRadius:\(error?.localizedDescription)")
                //}
            })
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.isEqual(self.heightLimitTextField) {
            let value: Float = CFloat(textField.text!)!
            self.setMaxFlightHeight(value)
        }
        else {
            let value: Float = CFloat(textField.text!)!
            self.setMaxFlightRadius(value)
        }
        if textField.isFirstResponder() as Bool == true {
            textField.resignFirstResponder()
        }
        return true
    }
    
 
}