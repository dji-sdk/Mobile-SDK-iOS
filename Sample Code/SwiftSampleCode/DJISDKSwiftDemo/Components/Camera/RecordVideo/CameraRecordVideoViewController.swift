//
//  CameraRecordVideoViewController.h
//  DJISdkDemo
//
//  Created by DJI on 12/28/15.
//  Copyright © 2015 DJI. All rights reserved.
//
import UIKit
import DJISDK
import VideoPreviewer

class CameraRecordVideoViewController: DJIBaseViewController, DJICameraDelegate {

    var recordingTime: Int32 = 0
    var videoFeedView: UIView? = nil
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
    
    override func viewWillAppear(animated: Bool) {
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
        self.startRecordButton.enabled = false
        self.stopRecordButton.enabled = false
        // start to check the pre-condition
        self.getCameraMode()
    }

    override func viewWillDisappear(animated: Bool) {
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
            
            camera?.getCameraModeWithCompletion({[weak self](mode: DJICameraMode, error: NSError?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("ERROR: getCameraModeWithCompletion::\(error!.description)")
                }
                else if mode == DJICameraMode.RecordVideo {
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
            
            camera?.setCameraMode(DJICameraMode.RecordVideo, withCompletion: {[weak self](error: NSError?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("ERROR: setCameraMode:withCompletion::\(error!.description)")
                }
                else {
                    // Normally, once an operation is finished, the camera still needs some time to finish up
                    // all the work. It is safe to delay the next operation after an operation is finished.
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {() -> Void in
                        
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

    @IBAction func onStartRecordButtonClicked(sender: AnyObject) {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            self.startRecordButton.enabled = false
            camera?.startRecordVideoWithCompletion({[weak self](error: NSError?) -> Void in
                if error != nil {
                    self?.showAlertResult("ERROR: startRecordVideoWithCompletion::\(error!.description)")
                }
            })
        }
    }
    /**
     *  When the camera is recording, the stop record button should be enabled. Then the user can stop recording
     *  the video.
     */

    @IBAction func onStopRecordButtonClicked(sender: AnyObject) {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            self.stopRecordButton.enabled = false
            camera?.stopRecordVideoWithCompletion({[weak self](error: NSError?) -> Void in
                if error != nil {
                    self?.showAlertResult("ERROR: stopRecordVideoWithCompletion::\(error!.description)")
                }
            })
        }
    }

    func setVideoPreview() {
        self.videoFeedView = UIView(frame: CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT))
        self.view!.addSubview(self.videoFeedView!)
        self.view!.sendSubviewToBack(self.videoFeedView!)
        //    self.videoFeedView.backgroundColor = [UIColor grayColor];
        VideoPreviewer.instance().start()
        VideoPreviewer.instance().setView(self.videoFeedView)
    }

    func cleanVideoPreview() {
        VideoPreviewer.instance().unSetView()
        VideoPreviewer.removePreview()
        if self.videoFeedView != nil {
            self.videoFeedView!.removeFromSuperview()
            self.videoFeedView = nil
        }
    }

    func toggleRecordUI() {
        self.startRecordButton.enabled = (self.isInRecordVideoMode && !self.isRecordingVideo)
        self.stopRecordButton.enabled = (self.isInRecordVideoMode && self.isRecordingVideo)
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

    func camera(camera: DJICamera, didReceiveVideoData videoBuffer: UnsafeMutablePointer<UInt8>, length size: Int) {
        let pBuffer = UnsafeMutablePointer<UInt8>.alloc(size)
        memcpy(pBuffer, videoBuffer, size)
        VideoPreviewer.instance().dataQueue.push(pBuffer, length: Int32(size))
    }

    func camera(camera: DJICamera, didUpdateSystemState systemState: DJICameraSystemState) {
        self.isRecordingVideo = systemState.isRecording
        self.recordingTime = systemState.currentVideoRecordingTimeInSeconds
    }


  
}
