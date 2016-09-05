//
//  WiFiLinkSSIDViewController.m
//  DJISdkDemo
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let airLink:DJIAirLink? = self.fetchAirLink()
        if airLink != nil && airLink!.isWifiLinkSupported {
            self.getValueButton.enabled = true
            self.setValueButton.enabled = true
        }
        else {
            self.getValueButton.enabled = false
            self.setValueButton.enabled = false
            self.showAlertResult("The product doesn't support WiFi. ")
        }
    }
    
    @IBAction override func onGetButtonClicked(sender: AnyObject) {
        
        let airLink: DJIAirLink? = self.fetchAirLink()
        if (airLink != nil) {
            let wifiLink: DJIWiFiLink? = airLink!.wifiLink
            if wifiLink != nil {
              
                wifiLink!.getWiFiSSIDWithCompletion({[weak self](ssid: String?, error: NSError?) -> Void in
                    if error != nil {
                        self?.showAlertResult("ERROR: getWiFiSSID \(error!.description)")
                    }
                    else {
                        self?.getValueTextField.text = ssid
                    }
                })
            }
        }
    }
    
    @IBAction override func onSetButtonClicked(sender: AnyObject) {
        let airLink: DJIAirLink? = self.fetchAirLink()
        if (airLink != nil) {
        let wifiLink: DJIWiFiLink? = airLink!.wifiLink
        if wifiLink != nil {
            wifiLink!.setWiFiSSID(self.setValueTextField.text!, withCompletion: {[weak self](error: NSError?) -> Void in
                if error != nil {
                    self?.showAlertResult("ERROR: setWiFiSSID \(error!.description)")
                }
                else {
                    self?.showAlertResult("Success. ")
                }
            })
        }
        }
    }
}