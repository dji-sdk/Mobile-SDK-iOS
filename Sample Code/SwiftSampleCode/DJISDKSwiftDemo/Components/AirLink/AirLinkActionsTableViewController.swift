//
//  AirLinkActionsTableViewController.m
//  DJISdkDemo
//
//  Copyright © 2016 DJI. All rights reserved.
import DJISDK

class AirLinkActionsTableViewController: DemoTableViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.connectedComponent = ConnectedProductManager.sharedInstance.fetchAirLink()
        self.sectionNames = ["WiFiLink","Lightbridge"]
        let wifiSetting:[DemoSettingItem] = [DemoSettingItem(name: "Set/Get WiFi SSID", andClass: WiFiLinkSSIDViewController.self), DemoSettingItem(name: "Reboot WiFi", andClass: RebootWiFiViewController.self)]
        self.items.append(wifiSetting)
        
        let lbSetting:[DemoSettingItem] = [DemoSettingItem(name: "Set/Get Channel", andClass:SetGetChannelViewController.self)]

        self.items.append(lbSetting)
        // The AirLink doesn't support firmware version checking and serial number checking.
    }
    
}
