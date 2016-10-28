//
//  NavigationJoystickViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 14-10-27.
//  Copyright (c) 2014 DJI. All rights reserved.
//
import UIKit
import CoreLocation
import DJISDK

class NavigationJoystickViewController: DJIBaseViewController, DJICameraDelegate, DJIFlightControllerDelegate, DJISimulatorDelegate {
    
    var mThrottle: CGFloat = 0.0
    var mPitch: CGFloat = 0.0
    var mRoll: CGFloat = 0.0
    var mYaw: CGFloat = 0.0
    
    // TODO: Why need strong here?
    @IBOutlet weak var joystickLeft: JoyStickView!
    @IBOutlet weak var joystickRight: JoyStickView!
    @IBOutlet weak var coordinateSys: UIButton!
    @IBOutlet weak var enableVirtualStickButton: UIButton!
    @IBOutlet weak var simulatorStateLabel: UILabel!
    
    weak var aircraft: DJIAircraft? = nil
    

    @IBAction func onEnterVirtualStickControlButtonClicked(_ sender: AnyObject) {
        if (self.aircraft != nil) {
            self.aircraft!.flightController?.enableVirtualStickControlMode(completion: {[weak self] (error: Error?) in
                if error != nil {
                    self?.showAlertResult("Enter Virtual Stick Mode:\(error!)")
                } else {
                    self?.showAlertResult("Enter Virtual Stick Mode: Success.")
                }
                })
            self.aircraft!.flightController?.yawControlMode = DJIVirtualStickYawControlMode.angularVelocity
            self.aircraft!.flightController?.rollPitchControlMode = DJIVirtualStickRollPitchControlMode.velocity
        }
    }

    @IBAction func onExitVirtualStickControlButtonClicked(_ sender: AnyObject) {
        if (self.aircraft == nil) {
            return
        }
        
        self.aircraft!.flightController?.disableVirtualStickControlMode(completion: { [weak self] (error: Error?) -> Void in
            if error != nil {
                self?.showAlertResult("Exit Virtual Stick Mode: \(error!)")
            }
            else {
                self?.showAlertResult("Exit Virtual Stick Mode: Success.")
            }
        })
    }

    @IBAction func onTakeoffButtonClicked(_ sender: AnyObject) {
        if (self.aircraft == nil) {
            return
        }
        
        self.aircraft!.flightController?.takeoff(completion: {[weak self] (error: Error?) -> Void in
            if error != nil {
                self?.showAlertResult("Takeoff: \(error!)")
            }
            else {
                self?.showAlertResult("Takeoff: Success.")
            }
        })
    }

    @IBAction func onCoordinateSysButtonClicked(_ sender: AnyObject) {
        if (self.aircraft == nil) {
            return
        }
        
        if self.aircraft!.flightController?.rollPitchCoordinateSystem == DJIVirtualStickFlightCoordinateSystem.ground {
            self.aircraft!.flightController?.rollPitchCoordinateSystem = DJIVirtualStickFlightCoordinateSystem.body
            coordinateSys.setTitle("CoordinateSys:Body", for: UIControlState())
        }
        else {
            self.aircraft!.flightController?.rollPitchCoordinateSystem = DJIVirtualStickFlightCoordinateSystem.ground
            coordinateSys.setTitle("CoordinateSys:Ground", for: UIControlState())
        }
    }
    
    @IBAction func onSimulatorButtonClicked(_ sender:UIButton) {
        let fc  = self.aircraft?.flightController
        if (fc != nil && fc!.simulator != nil) {
            if (fc!.simulator!.isSimulatorStarted == false ) {
                // The initial aircraft's position in the simulator.
                let location = CLLocationCoordinate2DMake(22, 113)
                fc!.simulator!.start(withLocation: location, updateFrequency: 20, gpsSatellitesNumber: 10, withCompletion: { (error: Error?) -> Void in
                    
                    self.simulatorStateLabel.isHidden = true;

                    if (error != nil) {
                        self.showAlertResult("Start simulator error:\(error!)")
                    } else {
                        self.showAlertResult("Start simulator succeeded.");
                    }

                })
            }
        }
    }

    @IBAction func onStopSimulatorButtonClicked(_ sender: AnyObject) {
        
        let fc  = self.aircraft?.flightController
        if (fc != nil && fc!.simulator != nil) {
            if (fc!.simulator!.isSimulatorStarted == true ) {
                
                fc!.simulator!.stop(completion: { (error: Error?) -> Void in
                  
                    self.simulatorStateLabel.isHidden = false;
                    if (error != nil) {
                        self.showAlertResult("Stop simulator error:\(error!)")
                    } else {
                        self.showAlertResult("Stop simulator succeeded.");
                    }

                })
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //    playerOrigin = player.frame.origin;
        let notificationCenter: NotificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(NavigationJoystickViewController.onStickChanged(_:)), name: NSNotification.Name(rawValue: "StickChanged"), object: nil)
      
        if (ConnectedProductManager.sharedInstance.fetchAircraft() != nil) {
            self.aircraft = self.fetchAircraft()
        
            if (self.aircraft == nil) {
                return
            }
            
            // To be consistent with UI part, set the coordinate to Ground
            if self.aircraft!.flightController != nil {
                self.aircraft!.flightController!.rollPitchControlMode = DJIVirtualStickRollPitchControlMode.angle
            }
        
        }
        
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // flight controller should be ready
        self.aircraft = self.fetchAircraft()
        
        if (self.aircraft != nil) {
            self.aircraft?.flightController?.delegate = self
            self.aircraft?.flightController?.simulator?.delegate = self
        }
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let fc = self.fetchFlightController()
        if ( fc != nil) {
            if fc!.delegate === self {
                fc!.delegate = nil
            }
            if fc!.simulator?.delegate === self {
                fc!.simulator?.delegate = nil
            }
        }
    }

    func onStickChanged(_ notification: Notification) {
        var dict: [AnyHashable: Any] = (notification as NSNotification).userInfo!
        let vdir: NSValue = dict["dir"] as! NSValue
        let dir: CGPoint = vdir.cgPointValue
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

    func setThrottle(_ y: CGFloat, andYaw x: CGFloat) {
        mThrottle = y * -2
        mYaw = x * 30
        self.updateJoystick()
    }

    func setPitch(_ y: CGFloat, andRoll x: CGFloat) {
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
            self.aircraft!.flightController!.send(ctrlData, withCompletion: nil)
        }
    }

    func flightController(_ fc: DJIFlightController, didUpdateSystemState state: DJIFlightControllerCurrentState) {
    }


    func simulator(_ simulator: DJISimulator, update state: DJISimulatorState) {
        self.simulatorStateLabel.isHidden = false
        self.simulatorStateLabel.text = "Yaw: \(state.yaw)\nX: \(state.positionX) Y: \(state.positionY) Z: \(state.positionZ)"
    }
}
