//
//  MissionManagerViewController.h
//  DJISdkDemo
//
//  Created by DJI on 15/7/2.
//  Copyright (c) 2015 DJI. All rights reserved.
//
import UIKit
import DJISDK
class MissionManagerViewController: DJIBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.connectedProduct is DJIAircraft) {
            self.followMe.enabled = true
            self.customMission.enabled = true
            self.iOC.enabled = true
            self.waypoint.enabled = true
            self.hotpoint.enabled = true
            self.virtualStick.enabled = true
        }
        else {
            self.followMe.enabled = false
            self.customMission.enabled = false
            self.iOC.enabled = false
            self.waypoint.enabled = false
            self.hotpoint.enabled = false
            self.virtualStick.enabled = false
        }
        if (self.connectedProduct is DJIHandheld) {
            self.panoramaMission.enabled = true
        }
        else {
            var aircraft: DJIAircraft = self.connectedProduct as! DJIAircraft
            if aircraft.model.containsString("Inspire") {
                self.panoramaMission.enabled = true
            }
            else {
                self.panoramaMission.enabled = false
            }
        }
        // Do any additional setup after loading the view from its nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onJoystickButtonClicked(sender: AnyObject) {
        var joystickVC: NavigationJoystickViewController? = nil
        joystickVC = NavigationJoystickViewController(product: self.connectedProduct)
        self.navigationController!.pushViewController(joystickVC!, animated: true)
    }

    @IBAction func onWaypointButtonClicked(sender: AnyObject) {
        var wpVC: NavigationWaypointViewController? = nil
        wpVC = NavigationWaypointViewController(product: self.connectedProduct)
        self.navigationController!.pushViewController(wpVC!, animated: true)
    }

    @IBAction func onHotPointButtonClicked(sender: AnyObject) {
        var hpVC: NavigationHotPointViewController? = nil
        hpVC = NavigationHotPointViewController(product: self.connectedProduct)
        self.navigationController!.pushViewController(hpVC!, animated: true)
    }

    @IBAction func onFollowMeButtonClicked(sender: AnyObject) {
        var fmVC: NavigationFollowMeViewController? = nil
        fmVC = NavigationFollowMeViewController(product: self.connectedProduct)
        self.navigationController!.pushViewController(fmVC!, animated: true)
    }

    @IBAction func onCustomMissionButtonClicked(sender: AnyObject) {
        var cmVC: CustomMissionViewController? = nil
        cmVC = CustomMissionViewController(product: self.connectedProduct)
        self.navigationController!.pushViewController(cmVC!, animated: true)
    }

    @IBAction func onIOCButtonClicked(sender: AnyObject) {
        var iocVC: NavigationIOCViewController? = nil
        iocVC = NavigationIOCViewController(product: self.connectedProduct)
        self.navigationController!.pushViewController(iocVC!, animated: true)
    }

    @IBAction func onPanoramaMissionClicked(sender: AnyObject) {
        var panoVC: PanoramaViewController? = nil
        panoVC = PanoramaViewController(product: self.connectedProduct)
        self.navigationController!.pushViewController(panoVC!, animated: true)
    }

    @IBOutlet weak var panoramaMission: UIButton!
    @IBOutlet weak var customMission: UIButton!
    @IBOutlet weak var hotpoint: UIButton!
    @IBOutlet weak var followMe: UIButton!
    @IBOutlet weak var waypoint: UIButton!
    @IBOutlet weak var iOC: UIButton!
    @IBOutlet weak var virtualStick: UIButton!

    @IBAction func onJoystickButtonClicked(sender: AnyObject) {
    }

    @IBAction func onWaypointButtonClicked(sender: AnyObject) {
    }

    @IBAction func onHotPointButtonClicked(sender: AnyObject) {
    }

    @IBAction func onFollowMeButtonClicked(sender: AnyObject) {
    }

    @IBAction func onCustomMissionButtonClicked(sender: AnyObject) {
    }

    @IBAction func onIOCButtonClicked(sender: AnyObject) {
    }

    @IBAction func onPanoramaMissionClicked(sender: AnyObject) {
    }
}
//
//  MissionManagerViewController.m
//  DJISdkDemo
//
//  Created by Ares on 15/7/2.
//  Copyright (c) 2015 DJI. All rights reserved.
//

import DJISDK