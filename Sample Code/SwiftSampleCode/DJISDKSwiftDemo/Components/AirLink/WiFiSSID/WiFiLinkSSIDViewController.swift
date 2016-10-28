//
//  WiFiLinkSSIDViewController.swift
//  DJISDKSwiftDemo
//
//  Copyright © 2016 DJI. All rights reserved.
//

import DJISDK
class WiFiLinkSSIDViewController: DemoGetSetViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "WiFi SSID"
        self.rangeLabel.text = "The input should just include alphabet, number, space, '-'\nandshould not be more than 30 characters. "
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let airLink:DJIAirLink? = self.fetchAirLink()
        if airLink != nil && airLink!.isWifiLinkSupported {
            self.getValueButton.isEnabled = true
            self.setValueButton.isEnabled = true
        }
        else {
            self.getValueButton.isEnabled = false
            self.setValueButton.isEnabled = false
            self.showAlertResult("The product doesn't support WiFi. ")
        }
    }
    
    @IBAction override func onGetButtonClicked(_ sender: AnyObject) {
        
        let airLink: DJIAirLink? = self.fetchAirLink()
        if (airLink != nil) {
            let wifiLink: DJIWiFiLink? = airLink!.wifiLink
            if wifiLink != nil {
              
                wifiLink!.getWiFiSSID(completion: {[weak self](ssid: String?, error: Error?) -> Void in
                    if error != nil {
                        self?.showAlertResult("ERROR: getWiFiSSID \(error!)")
                    }
                    else {
                        self?.getValueTextField.text = ssid
                    }
                })
            }
        }
    }
    
    @IBAction override func onSetButtonClicked(_ sender: AnyObject) {
        let airLink: DJIAirLink? = self.fetchAirLink()
        if (airLink != nil) {
        let wifiLink: DJIWiFiLink? = airLink!.wifiLink
        if wifiLink != nil {
            wifiLink!.setWiFiSSID(self.setValueTextField.text!, withCompletion: {[weak self](error: Error?) -> Void in
                if error != nil {
                    self?.showAlertResult("ERROR: setWiFiSSID \(error!)")
                }
                else {
                    self?.showAlertResult("Success. ")
                }
            })
        }
        }
    }
}
