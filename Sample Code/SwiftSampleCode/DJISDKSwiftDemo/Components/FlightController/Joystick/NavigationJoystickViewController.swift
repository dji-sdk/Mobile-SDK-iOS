//
//  NavigationJoystickViewController.swift
//  DJISDSwiftDemo
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

    @IBAction func onEnterVirtualStickControlButtonClicked(sender: AnyObject) {
        if let aircraft = aircraft {
            aircraft.flightController?.enableVirtualStickControlModeWithCompletion {[weak self] (error: NSError?) in
                guard let error = error else {
                    self?.showAlertResult("Enter Virtual Stick Mode: Success.")
                    return
                }
                self?.showAlertResult("Enter Virtual Stick Mode:\(error.description)")
            }
            aircraft.flightController?.yawControlMode = DJIVirtualStickYawControlMode.AngularVelocity
            aircraft.flightController?.rollPitchControlMode = DJIVirtualStickRollPitchControlMode.Velocity
        }
    }

    @IBAction func onExitVirtualStickControlButtonClicked(sender: AnyObject) {
        guard let aircraft = aircraft else { return }
        aircraft.flightController?.disableVirtualStickControlModeWithCompletion { [weak self] (error: NSError?) -> Void in
            guard let error = error else {
                self?.showAlertResult("Exit Virtual Stick Mode: Success.")
                return
            }
            self?.showAlertResult("Exit Virtual Stick Mode: \(error.debugDescription)")
        }
    }

    @IBAction func onTakeoffButtonClicked(sender: AnyObject) {
        guard let aircraft = aircraft else { return }
        aircraft.flightController?.takeoffWithCompletion {[weak self] (error: NSError?) -> Void in
            guard let error = error else {
                self?.showAlertResult("Takeoff: Success.")
                return
            }
            self?.showAlertResult("Takeoff: \(error.description)")
        }
    }

    @IBAction func onCoordinateSysButtonClicked(sender: AnyObject) {
        guard let aircraft = aircraft else { return }
        if aircraft.flightController?.rollPitchCoordinateSystem == .Ground {
            aircraft.flightController?.rollPitchCoordinateSystem = .Body
            coordinateSys.setTitle("CoordinateSys:Body", forState: .Normal)
        }
        else {
            aircraft.flightController?.rollPitchCoordinateSystem = .Ground
            coordinateSys.setTitle("CoordinateSys:Ground", forState: .Normal)
        }
    }
    
    @IBAction func onSimulatorButtonClicked(sender:UIButton) {
        if let fc  = self.aircraft?.flightController, let sim = fc.simulator where !sim.isSimulatorStarted {
            // The initial aircraft's position in the simulator.
            let location = CLLocationCoordinate2DMake(22, 113)
            sim.startSimulatorWithLocation(location, updateFrequency: 20, GPSSatellitesNumber: 10) { (error: NSError?) -> Void in
                self.simulatorStateLabel.hidden = true;
                guard let error = error else {
                    self.showAlertResult("Start simulator succeeded.");
                    return
                }
                self.showAlertResult("Start simulator error:\(error.description)")
            }
        }
    }

    @IBAction func onStopSimulatorButtonClicked(sender: AnyObject) {
        if let fc  = self.aircraft?.flightController, sim = fc.simulator where sim.isSimulatorStarted {
            sim.stopSimulatorWithCompletion { (error: NSError?) -> Void in
                self.simulatorStateLabel.hidden = false;
                guard let error = error else {
                    self.showAlertResult("Stop simulator succeeded.");
                    return
                }
                self.showAlertResult("Stop simulator error:\(error.description)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //    playerOrigin = player.frame.origin;
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(NavigationJoystickViewController.onStickChanged(_:)), name: "StickChanged", object: nil)
      
        if let _ = ConnectedProductManager.sharedInstance.fetchAircraft() {
            guard let aircraft = self.fetchAircraft() else { return }
            self.aircraft = aircraft
            // To be consistent with UI part, set the coordinate to Ground
            if let fc = aircraft.flightController {
                fc.rollPitchControlMode = .Angle
            }
        }
    }


    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // flight controller should be ready
        guard let aircraft = self.fetchAircraft() else { return }
        aircraft.flightController?.delegate = self
        aircraft.flightController?.simulator?.delegate = self
        self.aircraft = aircraft
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let fc = self.fetchFlightController() {
            if fc.delegate === self {
                fc.delegate = nil
            }
            if fc.simulator?.delegate === self {
                fc.simulator?.delegate = nil
            }
        }
    }

    func onStickChanged(notification: NSNotification) {
        var dict: [NSObject : AnyObject] = notification.userInfo!
        let vdir: NSValue = dict["dir"] as! NSValue
        let dir: CGPoint = vdir.CGPointValue()
        if let joystick = notification.object as? JoyStickView {
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
        if let aircraft = self.aircraft, let fc = aircraft.flightController where fc.isVirtualStickControlModeAvailable() {
            NSLog("mThrottle: %f, mYaw: %f", mThrottle, mYaw)
            fc.sendVirtualStickFlightControlData(ctrlData, withCompletion: nil)
        }
    }

    func flightController(fc: DJIFlightController, didUpdateSystemState state: DJIFlightControllerCurrentState) {
    }

    func simulator(simulator: DJISimulator, updateSimulatorState state: DJISimulatorState) {
        self.simulatorStateLabel.hidden = false
        self.simulatorStateLabel.text = "Yaw: \(state.yaw)\nX: \(state.positionX) Y: \(state.positionY) Z: \(state.positionZ)"
    }
}
