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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // disable the set/get button first.
        self.getValueButton.enabled = false
        self.setValueButton.enabled = false
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let airLink: DJIAirLink? = self.fetchAirLink()
        if airLink != nil && airLink!.isLBAirLinkSupported {
            airLink!.lbAirLink?.setChannelSelectionMode(DJILBAirLinkChannelSelectionMode.Auto, withCompletion: nil)
        }
    }
    /**
     *  Check if the LB Air Link is in mode DJILBAirLinkChannelSelectionModeManual.
     *  We need to set it to DJILBAirLinkChannelSelectionModeManual if it is not.
     */
    
    func getLBChannelMode() {
        let airLink: DJIAirLink? = self.fetchAirLink()
        if airLink != nil {
            
            airLink!.lbAirLink?.getChannelSelectionModeWithCompletion({[weak self](mode: DJILBAirLinkChannelSelectionMode, error: NSError?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("ERROR: getChannelSelectionMode: \(error!.description)")
                }
                else if mode == DJILBAirLinkChannelSelectionMode.Manual {
                    self?.getValueButton.enabled = true
                    self?.setValueButton.enabled = true
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
            
            airLink!.lbAirLink?.setChannelSelectionMode(DJILBAirLinkChannelSelectionMode.Manual, withCompletion: {[weak self](error: NSError?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("ERROR: setChannelSelectionMode: \(error!.description)")
                }
                else {
                    self?.getValueButton.enabled = true
                    self?.setValueButton.enabled = true
                }
            })
        }
    }
    
    @IBAction override func onGetButtonClicked(sender: AnyObject) {
        let airLink: DJIAirLink? = self.fetchAirLink()
        if airLink != nil {
            
            airLink!.lbAirLink?.getChannelWithCompletion({[weak self](channel: Int32, error: NSError?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("ERROR: getChannel: \(error!.description)")
                }
                else {
                    let getTextString: String = "\(UInt(channel))"
                    self?.getValueTextField.text = getTextString
                }
            })
        }
    }
    
    @IBAction override func onSetButtonClicked(sender: AnyObject) {
        let airLink: DJIAirLink? = self.fetchAirLink()
        if airLink != nil && self.setValueTextField.text != ""{
            let channelIndex: Int32 = Int32(self.setValueTextField.text!)!
            airLink!.lbAirLink?.setChannel(channelIndex, withCompletion: {[weak self](error: NSError?) -> Void in
                if error != nil {
                    self?.showAlertResult("ERROR: setChannel: \(error!.description)")
                }
                else {
                    self?.showAlertResult("SUCCESS. ")
                }
            })
        }
    }
}