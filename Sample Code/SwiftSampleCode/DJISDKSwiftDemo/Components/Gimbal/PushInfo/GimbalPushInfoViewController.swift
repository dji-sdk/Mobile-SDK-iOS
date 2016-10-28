//
//  GimbalPushInfoViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 12/17/15.
//  Copyright © 2015 DJI. All rights reserved.
//

import DJISDK
class GimbalPushInfoViewController: DemoPushInfoViewController, DJIGimbalDelegate {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set the delegate to receive the push data from gimbal
        let gimbal: DJIGimbal? = self.fetchGimbal()
        if gimbal != nil {
            gimbal!.delegate = self
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Clean gimbal's delegate before exiting the view
        let gimbal: DJIGimbal? = self.fetchGimbal()
        if gimbal != nil && gimbal!.delegate === self {
            gimbal!.delegate = nil
        }
    }
    // Override method in DJIGimbalDelegate to receive the pushed data
    func gimbal(_ gimbal: DJIGimbal, didUpdate gimbalState: DJIGimbalState) {
        let gimbalInfoString: NSMutableString = NSMutableString()
        gimbalInfoString.appendFormat("Gimbal attitude in degree: (%f, %f, %f)\n", gimbalState.attitudeInDegrees.pitch, gimbalState.attitudeInDegrees.roll, gimbalState.attitudeInDegrees.yaw)
        gimbalInfoString.appendFormat("Roll fine tune in degree: %d\n", Int(gimbalState.rollFineTuneInDegrees))
        gimbalInfoString.append("Gimbal work mode: ")
        switch gimbalState.workMode {
            case DJIGimbalWorkMode.fpvMode:
                gimbalInfoString.append("FPV\n")
            case DJIGimbalWorkMode.freeMode:
                gimbalInfoString.append("Free\n")
            case DJIGimbalWorkMode.yawFollowMode:
                gimbalInfoString.append("Yaw-follow\n")
            default:
                break
        }

        gimbalInfoString.append("Is attitude reset: ")
        gimbalInfoString.append(gimbalState.isAttitudeReset ? "YES\n" : "NO\n")
        gimbalInfoString.append("Is calibrating: ")
        gimbalInfoString.append(gimbalState.isCalibrating ? "YES\n" : "NO\n")
        gimbalInfoString.append("Is pitch at stop: ")
        gimbalInfoString.append(gimbalState.isPitchAtStop ? "YES\n" : "NO\n")
        gimbalInfoString.append("Is roll at stop: ")
        gimbalInfoString.append(gimbalState.isRollAtStop ? "YES\n" : "NO\n")
        gimbalInfoString.append("Is yaw at stop: ")
        gimbalInfoString.append(gimbalState.isYawAtStop ? "YES\n" : "NO\n")
        self.pushInfoLabel.text = gimbalInfoString as String
    }
}
