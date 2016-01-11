//
//  CameraPushInfoViewController.h
//  DJISdkDemo
//
//  Created by DJI on 12/18/15.
//  Copyright © 2015 DJI. All rights reserved.
//

import DJISDK

class CameraPushInfoViewController: DemoPushInfoViewController, DJICameraDelegate {

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Set the delegate to receive the push data from camera
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            camera!.delegate = self
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // Clean camera's delegate before exiting the view
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil && camera!.delegate === self {
            camera!.delegate = nil
        }
    }

    func camera(camera: DJICamera, didUpdateSystemState systemState: DJICameraSystemState) {
        let cameraInfoString: NSMutableString = NSMutableString()
        cameraInfoString.appendString("Shooting single photo: ")
        cameraInfoString.appendString(systemState.isShootingSinglePhoto ? "YES\n" : "NO\n")
        cameraInfoString.appendString("Shooting single photo in RAW format: ")
        cameraInfoString.appendString(systemState.isShootingSinglePhotoInRAWFormat ? "YES\n" : "NO\n")
        cameraInfoString.appendString("Shooting burst photos: ")
        cameraInfoString.appendString(systemState.isShootingBurstPhoto ? "YES\n" : "NO\n")
        cameraInfoString.appendString("Recording: ")
        cameraInfoString.appendString(systemState.isRecording ? "YES\n" : "NO\n")
        cameraInfoString.appendString("Camera over-heated: ")
        cameraInfoString.appendString(systemState.isCameraOverHeated ? "YES\n" : "NO\n")
        cameraInfoString.appendString("Camera has error: ")
        cameraInfoString.appendString(systemState.isCameraError ? "YES\n" : "NO\n")
        cameraInfoString.appendString("In USB mode: ")
        cameraInfoString.appendString(systemState.isUSBMode ? "YES\n" : "NO\n")
        cameraInfoString.appendString("Camera Mode: ")
        switch systemState.mode {
            case DJICameraMode.ShootPhoto:
                cameraInfoString.appendString("Shoot Photo Mode\n")
            case DJICameraMode.RecordVideo:
                cameraInfoString.appendString("Record Video Mode\n")
            case DJICameraMode.Playback:
                cameraInfoString.appendString("Playback Mode\n")
            case DJICameraMode.MediaDownload:
                cameraInfoString.appendString("Media Download Mode\n")
            default:
                break
        }

        cameraInfoString.appendFormat("Current video recording time: %d\n", systemState.currentVideoRecordingTimeInSeconds)
        self.pushInfoLabel.text = cameraInfoString as String
    }
}
