//
//  SetGetChannelViewController.swift
//  DJISDKSwiftDemo
//
//  Copyright © 2016 DJI. All rights reserved.
//

import DJISDK
class SetGetChannelViewController: DemoGetSetViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Set/Get LB Channel"
        self.rangeLabel.text = "The input should be an integer. The valid range is [0, 7]. "
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // disable the set/get button first.
        self.getValueButton.isEnabled = false
        self.setValueButton.isEnabled = false
        let airLink: DJIAirLink? = self.fetchAirLink()
        if airLink != nil && airLink!.isLBAirLinkSupported {
            self.getLBChannelMode()
        }
        else {
            self.showAlertResult("The product doesn't support LB Air Link. ")
        }
    }
    /**
     *  It is recommended to keep the selection mode as Auto. Normally, it will have a more stable performance.
     *  Therefore, we set the mode back to Auto while exiting the view.
     */
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let airLink: DJIAirLink? = self.fetchAirLink()
        if airLink != nil && airLink!.isLBAirLinkSupported {
            airLink!.lbAirLink?.setChannelSelectionMode(DJILBAirLinkChannelSelectionMode.auto, withCompletion: nil)
        }
    }
    /**
     *  Check if the LB Air Link is in mode DJILBAirLinkChannelSelectionModeManual.
     *  We need to set it to DJILBAirLinkChannelSelectionModeManual if it is not.
     */
    
    func getLBChannelMode() {
        let airLink: DJIAirLink? = self.fetchAirLink()
        if airLink != nil {
            
            airLink!.lbAirLink?.getChannelSelectionMode(completion: {[weak self](mode: DJILBAirLinkChannelSelectionMode, error: Error?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("ERROR: getChannelSelectionMode: \(error!)")
                }
                else if mode == DJILBAirLinkChannelSelectionMode.manual {
                    self?.getValueButton.isEnabled = true
                    self?.setValueButton.isEnabled = true
                }
                else {
                    self?.setLBChannelMode()
                }
                
            })
        }
    }
    
    func setLBChannelMode() {
        let airLink: DJIAirLink? = self.fetchAirLink()
        if airLink != nil {
            
            airLink!.lbAirLink?.setChannelSelectionMode(DJILBAirLinkChannelSelectionMode.manual, withCompletion: {[weak self](error: Error?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("ERROR: setChannelSelectionMode: \(error!)")
                }
                else {
                    self?.getValueButton.isEnabled = true
                    self?.setValueButton.isEnabled = true
                }
            })
        }
    }
    
    @IBAction override func onGetButtonClicked(_ sender: AnyObject) {
        let airLink: DJIAirLink? = self.fetchAirLink()
        if airLink != nil {
            
            airLink!.lbAirLink?.getChannelWithCompletion({[weak self](channel: Int32, error: Error?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("ERROR: getChannel: \(error!)")
                }
                else {
                    let getTextString: String = "\(UInt(channel))"
                    self?.getValueTextField.text = getTextString
                }
            })
        }
    }
    
    @IBAction override func onSetButtonClicked(_ sender: AnyObject) {
        let airLink: DJIAirLink? = self.fetchAirLink()
        if airLink != nil && self.setValueTextField.text != ""{
            let channelIndex: Int32 = Int32(self.setValueTextField.text!)!
            airLink!.lbAirLink?.setChannel(channelIndex, withCompletion: {[weak self](error: Error?) -> Void in
                if error != nil {
                    self?.showAlertResult("ERROR: setChannel: \(error!)")
                }
                else {
                    self?.showAlertResult("SUCCESS. ")
                }
            })
        }
    }
}
