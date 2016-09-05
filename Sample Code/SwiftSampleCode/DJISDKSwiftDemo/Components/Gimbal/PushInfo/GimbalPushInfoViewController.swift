//
//  GimbalPushInfoViewController.h
//  DJISdkDemo
//
//  Created by DJI on 12/17/15.
//  Copyright © 2015 DJI. All rights reserved.
//

import DJISDK
class GimbalPushInfoViewController: DemoPushInfoViewController, DJIGimbalDelegate {

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Set the delegate to receive the push data from gimbal
        let gimbal: DJIGimbal? = self.fetchGimbal()
        if gimbal != nil {
            gimbal!.delegate = self
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // Clean gimbal's delegate before exiting the view
        let gimbal: DJIGimbal? = self.fetchGimbal()
        if gimbal != nil && gimbal!.delegate === self {
            gimbal!.delegate = nil
        }
    }
    // Override method in DJIGimbalDelegate to receive the pushed data

    func gimbalController(controller: DJIGimbal, didUpdateGimbalState gimbalState: DJIGimbalState) {
        let gimbalInfoString: NSMutableString = NSMutableString()
        gimbalInfoString.appendFormat("Gimbal attitude in degree: (%f, %f, %f)\n", gimbalState.attitudeInDegrees.pitch, gimbalState.attitudeInDegrees.roll, gimbalState.attitudeInDegrees.yaw)
        gimbalInfoString.appendFormat("Roll fine tune in degree: %d\n", Int(gimbalState.rollFineTuneInDegrees))
        gimbalInfoString.appendString("Gimbal work mode: ")
        switch gimbalState.workMode {
            case DJIGimbalWorkMode.FpvMode:
                gimbalInfoString.appendString("FPV\n")
            case DJIGimbalWorkMode.FreeMode:
                gimbalInfoString.appendString("Free\n")
            case DJIGimbalWorkMode.YawFollowMode:
                gimbalInfoString.appendString("Yaw-follow\n")
            default:
                break
        }

        gimbalInfoString.appendString("Is attitude reset: ")
        gimbalInfoString.appendString(gimbalState.isAttitudeReset ? "YES\n" : "NO\n")
        gimbalInfoString.appendString("Is calibrating: ")
        gimbalInfoString.appendString(gimbalState.isCalibrating ? "YES\n" : "NO\n")
        gimbalInfoString.appendString("Is pitch at stop: ")
        gimbalInfoString.appendString(gimbalState.isPitchAtStop ? "YES\n" : "NO\n")
        gimbalInfoString.appendString("Is roll at stop: ")
        gimbalInfoString.appendString(gimbalState.isRollAtStop ? "YES\n" : "NO\n")
        gimbalInfoString.appendString("Is yaw at stop: ")
        gimbalInfoString.appendString(gimbalState.isYawAtStop ? "YES\n" : "NO\n")
        self.pushInfoLabel.text = gimbalInfoString as String
    }
    
    /**
     *  Updates the gimbal's current state.
     */
    func gimbal(gimbal: DJIGimbal, didUpdateGimbalState gimbalState: DJIGimbalState){
        self.gimbalController(gimbal, didUpdateGimbalState: gimbalState);
    }
}
