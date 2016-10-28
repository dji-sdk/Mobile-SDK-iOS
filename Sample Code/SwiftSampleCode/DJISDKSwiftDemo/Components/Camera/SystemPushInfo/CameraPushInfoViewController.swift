//
//  CameraPushInfoViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 12/18/15.
//  Copyright © 2015 DJI. All rights reserved.
//

import DJISDK

class CameraPushInfoViewController: DemoPushInfoViewController, DJICameraDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Push Info"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set the delegate to receive the push data from camera
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            camera!.delegate = self
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Clean camera's delegate before exiting the view
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil && camera!.delegate === self {
            camera!.delegate = nil
        }
    }

    func camera(_ camera: DJICamera, didUpdate systemState: DJICameraSystemState) {
        let cameraInfoString: NSMutableString = NSMutableString()
        cameraInfoString.append("Shooting single photo: ")
        cameraInfoString.append(systemState.isShootingSinglePhoto ? "YES\n" : "NO\n")
        cameraInfoString.append("Shooting single photo in RAW format: ")
        cameraInfoString.append(systemState.isShootingSinglePhotoInRAWFormat ? "YES\n" : "NO\n")
        cameraInfoString.append("Shooting burst photos: ")
        cameraInfoString.append(systemState.isShootingBurstPhoto ? "YES\n" : "NO\n")
        cameraInfoString.append("Recording: ")
        cameraInfoString.append(systemState.isRecording ? "YES\n" : "NO\n")
        cameraInfoString.append("Camera over-heated: ")
        cameraInfoString.append(systemState.isCameraOverHeated ? "YES\n" : "NO\n")
        cameraInfoString.append("Camera has error: ")
        cameraInfoString.append(systemState.isCameraError ? "YES\n" : "NO\n")
        cameraInfoString.append("In USB mode: ")
        cameraInfoString.append(systemState.isUSBMode ? "YES\n" : "NO\n")
        cameraInfoString.append("Camera Mode: ")
        switch systemState.mode {
            case DJICameraMode.shootPhoto:
                cameraInfoString.append("Shoot Photo Mode\n")
            case DJICameraMode.recordVideo:
                cameraInfoString.append("Record Video Mode\n")
            case DJICameraMode.playback:
                cameraInfoString.append("Playback Mode\n")
            case DJICameraMode.mediaDownload:
                cameraInfoString.append("Media Download Mode\n")
            default:
                break
        }

        cameraInfoString.appendFormat("Current video recording time: %d\n", systemState.currentVideoRecordingTimeInSeconds)
        self.pushInfoLabel.text = cameraInfoString as String
    }
}
