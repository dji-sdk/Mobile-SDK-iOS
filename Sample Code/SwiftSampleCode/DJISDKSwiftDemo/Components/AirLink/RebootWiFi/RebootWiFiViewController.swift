//
//  RebootWiFiViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 1/7/16.
//  Copyright © 2016 DJI. All rights reserved.
//

import DJISDK
class RebootWiFiViewController: DJIBaseViewController {
    @IBOutlet weak var rebootWiFiButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Reboot WiFi"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let airLink: DJIAirLink? = self.fetchAirLink()
        if airLink != nil && airLink!.isWifiLinkSupported {
            self.rebootWiFiButton.isEnabled = true
        }
        else {
            self.rebootWiFiButton.isEnabled = false
            self.showAlertResult("The product doesn't support WiFi. ")
        }
    }
    
    @IBAction func onRebootWiFiClicked(_ sender: AnyObject) {
        let airLink: DJIAirLink? = self.fetchAirLink()
        if airLink != nil && airLink!.wifiLink != nil {
            airLink!.wifiLink!.rebootWiFi(completion: {[weak self](error: Error?) -> Void in
                if error != nil {
                    self?.showAlertResult("ERROR: rebootWiFi: \(error!)")
                }
                else {
                    self?.showAlertResult("SUCCESS: rebootWiFi. ")
                }
            })
        }
    }
    
    
}
