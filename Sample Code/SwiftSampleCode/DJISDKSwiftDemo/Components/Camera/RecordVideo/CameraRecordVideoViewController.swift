//
//  CameraRecordVideoViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 12/28/15.
//  Copyright © 2015 DJI. All rights reserved.
//
import UIKit
import DJISDK
import VideoPreviewer

class CameraRecordVideoViewController: DJIBaseViewController, DJICameraDelegate {

    var recordingTime: Int32 = 0
    @IBOutlet weak var recordingTimeLabel: UILabel!
    @IBOutlet weak var startRecordButton: UIButton!
    @IBOutlet weak var stopRecordButton: UIButton!
    
    
    var isInRecordVideoMode: Bool = false {
        didSet {
            self.toggleRecordUI()
        }
    }
    
    var isRecordingVideo: Bool = false {
        didSet {
            self.toggleRecordUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setVideoPreview()
        // set delegate to render camera's video feed into the view
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            camera?.delegate = self
        }
        self.isInRecordVideoMode = false
        self.isRecordingVideo = false
        // disable the shoot photo button by default
        self.startRecordButton.isEnabled = false
        self.stopRecordButton.isEnabled = false
        // start to check the pre-condition
        self.getCameraMode()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // clean the delegate
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil && camera?.delegate === self {
            camera?.delegate = nil
        }
        self.cleanVideoPreview()
    }
    /**
     *  Check if the camera's mode is DJICameraMode.RecordVideo.
     *  If the mode is not DJICameraMode.RecordVideo, we need to set it to be DJICameraMode.RecordVideo.
     *  If the mode is already DJICameraMode.RecordVideo, we check the exposure mode.
     */

    func getCameraMode() {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            
            camera?.getModeWithCompletion({[weak self](mode: DJICameraMode, error: Error?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("ERROR: getCameraModeWithCompletion::\(error!)")
                }
                else if mode == DJICameraMode.recordVideo {
                    self?.isInRecordVideoMode = true
                }
                else {
                    self?.setCameraMode()
                }

            })
        }
    }
    /**
     *  Set the camera's mode to DJICameraMode.RecordVideo.
     *  If it succeeds, we can enable the take photo button.
     */

    func setCameraMode() {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            
            camera?.setCameraMode(DJICameraMode.recordVideo, withCompletion: {[weak self](error: Error?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("ERROR: setCameraMode:withCompletion::\(error!)")
                }
                else {
                    // Normally, once an operation is finished, the camera still needs some time to finish up
                    // all the work. It is safe to delay the next operation after an operation is finished.
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {() -> Void in
                        
                        self?.isInRecordVideoMode = true
                    })
                }
            })
        }
    }
    /**
     *  When the pre-condition meets, the start record button should be enabled. Then the user can can record
     *  a video now.
     */

    @IBAction func onStartRecordButtonClicked(_ sender: AnyObject) {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            self.startRecordButton.isEnabled = false
            camera?.startRecordVideo(completion: {[weak self](error: Error?) -> Void in
                if error != nil {
                    self?.showAlertResult("ERROR: startRecordVideoWithCompletion::\(error!)")
                }
            })
        }
    }
    /**
     *  When the camera is recording, the stop record button should be enabled. Then the user can stop recording
     *  the video.
     */

    @IBAction func onStopRecordButtonClicked(_ sender: AnyObject) {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            self.stopRecordButton.isEnabled = false
            camera?.stopRecordVideo(completion: {[weak self](error: Error?) -> Void in
                if error != nil {
                    self?.showAlertResult("ERROR: stopRecordVideoWithCompletion::\(error!)")
                }
            })
        }
    }

    func setVideoPreview() {
        VideoPreviewer.instance().start()
        VideoPreviewer.instance().setView(self.view)
    }

    func cleanVideoPreview() {
        VideoPreviewer.instance().unSetView()
    }

    func toggleRecordUI() {
        self.startRecordButton.isEnabled = (self.isInRecordVideoMode && !self.isRecordingVideo)
        self.stopRecordButton.isEnabled = (self.isInRecordVideoMode && self.isRecordingVideo)
        if !self.isRecordingVideo {
            self.recordingTimeLabel.text = "00:00"
        }
        else {
            let hour: Int32 = self.recordingTime / 3600
            let minute: Int32 = (self.recordingTime % 3600) / 60
            let second: Int32 = (self.recordingTime % 3600) % 60
            self.recordingTimeLabel.text = String(format: "%02d:%02d:%02d", hour, minute, second)
        }
    }

    func camera(_ camera: DJICamera, didReceiveVideoData videoBuffer: UnsafeMutablePointer<UInt8>, length size: Int) {
        VideoPreviewer.instance().push(videoBuffer, length: Int32(size))
    }

    func camera(_ camera: DJICamera, didUpdate systemState: DJICameraSystemState) {
        self.isRecordingVideo = systemState.isRecording
        self.recordingTime = systemState.currentVideoRecordingTimeInSeconds
    }


  
}
