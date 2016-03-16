//
//  JoystickTestViewController.h
//  DJISdkDemo
//
//  Created by DJI on 14-10-27.
//  Copyright (c) 2014 DJI. All rights reserved.
//
import UIKit
import CoreLocation
import DJISDK

class NavigationJoystickViewController: DJIBaseViewController, DJICameraDelegate, DJIFlightControllerDelegate {
    
    var mThrottle: CGFloat = 0.0
    var mPitch: CGFloat = 0.0
    var mRoll: CGFloat = 0.0
    var mYaw: CGFloat = 0.0
    
    // TODO: Why need strong here?
    @IBOutlet weak var joystickLeft: JoyStickView!
    @IBOutlet weak var joystickRight: JoyStickView!
    @IBOutlet weak var coordinateSys: UIButton!
    @IBOutlet weak var enableVirtualStickButton: UIButton!
    weak var aircraft: DJIAircraft? = nil
    

    @IBAction func onEnterVirtualStickControlButtonClicked(sender: AnyObject) {
        if (self.aircraft != nil) {
            self.aircraft!.flightController?.enableVirtualStickControlModeWithCompletion({[weak self] (error: NSError?) in
                if error != nil {
                    self?.showAlertResult("Enter Virtual Stick Mode:\(error!.description)")
                } else {
                    self?.showAlertResult("Enter Virtual Stick Mode: Success.")
                }
                })
            self.aircraft!.flightController?.yawControlMode = DJIVirtualStickYawControlMode.AngularVelocity
            self.aircraft!.flightController?.rollPitchControlMode = DJIVirtualStickRollPitchControlMode.Velocity
        }
    }

    @IBAction func onExitVirtualStickControlButtonClicked(sender: AnyObject) {
        if (self.aircraft == nil) {
            return
        }
        
        self.aircraft!.flightController?.disableVirtualStickControlModeWithCompletion({ [weak self] (error: NSError?) -> Void in
            if error != nil {
                self?.showAlertResult("Exit Virtual Stick Mode: \(error!.debugDescription)")
            }
            else {
                self?.showAlertResult("Exit Virtual Stick Mode: Success.")
            }
        })
    }

    @IBAction func onTakeoffButtonClicked(sender: AnyObject) {
        if (self.aircraft == nil) {
            return
        }
        
        self.aircraft!.flightController?.takeoffWithCompletion({[weak self] (error: NSError?) -> Void in
            if error != nil {
                self?.showAlertResult("Takeoff: \(error!.description)")
            }
            else {
                self?.showAlertResult("Takeoff: Success.")
            }
        })
    }

    @IBAction func onCoordinateSysButtonClicked(sender: AnyObject) {
        if (self.aircraft == nil) {
            return
        }
        
        if self.aircraft!.flightController?.rollPitchCoordinateSystem == DJIVirtualStickFlightCoordinateSystem.Ground {
            self.aircraft!.flightController?.rollPitchCoordinateSystem = DJIVirtualStickFlightCoordinateSystem.Body
            coordinateSys.setTitle("CoordinateSys:Body", forState: .Normal)
        }
        else {
            self.aircraft!.flightController?.rollPitchCoordinateSystem = DJIVirtualStickFlightCoordinateSystem.Ground
            coordinateSys.setTitle("CoordinateSys:Ground", forState: .Normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //    playerOrigin = player.frame.origin;
        let notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "onStickChanged:", name: "StickChanged", object: nil)
      
        if (ConnectedProductManager.sharedInstance.fetchAircraft() != nil) {
            self.aircraft = ConnectedProductManager.sharedInstance.fetchAircraft()
        
            if (self.aircraft == nil) {
                return
            }
            
            // To be consistent with UI part, set the coordinate to Ground
            if self.aircraft!.flightController != nil {
                self.aircraft!.flightController!.rollPitchControlMode = DJIVirtualStickRollPitchControlMode.Angle
            }
        
        }
        
    }


    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // flight controller should be ready
        if (self.aircraft != nil) {
            self.aircraft?.flightController?.delegate = self
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.aircraft != nil) {
            if self.aircraft?.flightController?.delegate === self {
                self.aircraft?.flightController?.delegate = nil
            }
        }
    }

    func onStickChanged(notification: NSNotification) {
        var dict: [NSObject : AnyObject] = notification.userInfo!
        let vdir: NSValue = dict["dir"] as! NSValue
        let dir: CGPoint = vdir.CGPointValue()
        let joystick: JoyStickView? = notification.object as? JoyStickView
        if joystick != nil {
            if joystick == self.joystickLeft {
                self.setThrottle(dir.y, andYaw: dir.x)
            }
            else {
                self.setPitch(dir.y, andRoll: dir.x)
            }
        }
    }

    func setThrottle(y: CGFloat, andYaw x: CGFloat) {
        mThrottle = y * -2
        mYaw = x * 30
        self.updateJoystick()
    }

    func setPitch(y: CGFloat, andRoll x: CGFloat) {
        mPitch = y * 15.0
        mRoll = x * 15.0
        self.updateJoystick()
    }

    func updateJoystick() {
        var ctrlData: DJIVirtualStickFlightControlData = DJIVirtualStickFlightControlData()
        ctrlData.pitch = Float(mPitch)
        ctrlData.roll = Float(mRoll)
        ctrlData.yaw = Float(mYaw)
        ctrlData.verticalThrottle = Float(mThrottle)
        if ((self.aircraft != nil && self.aircraft!.flightController != nil) && (self.aircraft!.flightController!.isVirtualStickControlModeAvailable())) {
            NSLog("mThrottle: %f, mYaw: %f", mThrottle, mYaw)
            self.aircraft!.flightController!.sendVirtualStickFlightControlData(ctrlData, withCompletion: nil)
        }
    }

    func flightController(fc: DJIFlightController, didUpdateSystemState state: DJIFlightControllerCurrentState) {
    }


}
