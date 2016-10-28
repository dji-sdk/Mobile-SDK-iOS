//
//  GimbalRotationInSpeedViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 12/17/15.
//  Copyright © 2015 DJI. All rights reserved.
//
import UIKit
import DJISDK

class GimbalRotationInSpeedViewController: DJIBaseViewController {
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!

    var gimbalSpeedTimer: Timer? = nil
    
    var rotationAngleVelocity: Float = 0
    var rotationDirection:DJIGimbalRotateDirection = DJIGimbalRotateDirection.clockwise
    
    @IBAction func onUpButtonClicked(_ sender: AnyObject) {
        self.rotationAngleVelocity = 5.0
        self.rotationDirection = DJIGimbalRotateDirection.clockwise
    }

    @IBAction func onDownButtonClicked(_ sender: AnyObject) {
        self.rotationAngleVelocity = 5.0
        self.rotationDirection = DJIGimbalRotateDirection.counterClockwise
    }

    @IBAction func onStopButtonClicked(_ sender: AnyObject) {
        self.rotationAngleVelocity = 0.0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.resetRotation()
        /*
             *  The proper way to use rotateGimbalInSpeedWithPitch:Roll:Yaw:withCompletion: is to keep sending the command in a 
             *  frequency. The suggested time interval is 40ms.
             */
        if self.gimbalSpeedTimer == nil {
            self.gimbalSpeedTimer = Timer.scheduledTimer(timeInterval: 0.04, target: self, selector: #selector(GimbalRotationInSpeedViewController.onUpdateGimbalSpeedTick(_:)), userInfo: nil, repeats: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.gimbalSpeedTimer != nil {
            self.gimbalSpeedTimer!.invalidate()
            self.gimbalSpeedTimer = nil
        }
    }

    func onUpdateGimbalSpeedTick(_ timer: AnyObject) {
        let gimbal: DJIGimbal? = self.fetchGimbal()
        if gimbal != nil {
            var pitchRotation = DJIGimbalSpeedRotation()
            pitchRotation.angleVelocity = self.rotationAngleVelocity
            pitchRotation.direction = self.rotationDirection
            var stopRotation = DJIGimbalSpeedRotation()
            stopRotation.angleVelocity = 0.0
            stopRotation.direction = DJIGimbalRotateDirection.clockwise
            gimbal?.rotateGimbalBySpeed(withPitch: pitchRotation, roll: stopRotation, yaw: stopRotation, withCompletion: {[weak self](error: Error?) -> Void in
                if error != nil {
                    self?.showAlertResult("ERROR: rotateGimbalInSpeed:\(error!)")
                }
            })
        }
    }

    func resetRotation() {
        self.rotationAngleVelocity = 0.0
        self.rotationDirection = DJIGimbalRotateDirection.clockwise
    }


}
