//
//  CameraPlaybackCommandViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 12/28/15.
//  Copyright © 2015 DJI. All rights reserved.
//
import UIKit
import DJISDK
import VideoPreviewer

class CameraPlaybackCommandViewController: DJIBaseViewController, DJICameraDelegate, DJIPlaybackDelegate {
    var isInPlaybackMode: Bool = false
    var isInMultipleMode: Bool = false {
        didSet{
            self.multipleButton.enabled = !isInMultipleMode
            self.singleButton.enabled = isInMultipleMode
        }
    }
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var multipleButton: UIButton!
    @IBOutlet weak var singleButton: UIButton!

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setVideoPreview()
        let camera: DJICamera? = self.fetchCamera()
        if (camera == nil) {
            self.showAlertResult("Cannot detect the camera. ")
            return
        }
        self.isInPlaybackMode = false
        if camera!.isPlaybackSupported() == false {
            self.showAlertResult("Playback is not supported. ")
            return
        }
        // set delegate to render camera's video feed into the view
        camera!.delegate = self
        // set playback manager delegate to check playback state
        camera!.playbackManager?.delegate = self
        // start to check the pre-condition
        self.getCameraMode()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // clean the delegate
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil && camera!.delegate === self {
            camera!.delegate = nil
        }
        if camera != nil && camera!.playbackManager?.delegate === self {
            camera!.playbackManager?.delegate = nil
        }
        self.cleanVideoPreview()
    }
    /**
     *  Check if the camera's mode is DJICameraMode.Playback.
     *  If the mode is not DJICameraMode.Playback, we need to set it to be DJICameraMode.Playback.
     */

    func getCameraMode() {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            
            camera!.getCameraModeWithCompletion({[weak self](mode: DJICameraMode, error: NSError?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("ERROR: getCameraModeWithCompletion:\(error!.description)")
                }
                else if mode == DJICameraMode.Playback {
                    self?.isInPlaybackMode = true
                }
                else {
                    self?.setCameraMode()
                }

            })
        }
    }
    /**
     *  Set the camera's mode to DJICameraMode.Playback.
     */

    func setCameraMode() {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            
            camera!.setCameraMode(DJICameraMode.Playback, withCompletion: {[weak self](error: NSError?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("ERROR: setCameraMode:withCompletion::\(error!.description)")
                }
                else {
                    // Normally, once an operation is finished, the camera still needs some time to finish up
                    // all the work. It is safe to delay the next operation after an operation is finished.
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {() -> Void in
                        
                        self?.isInPlaybackMode = true
                    })
                }
            })
        }
    }

    @IBAction func onPreviousButtonClicked(sender: AnyObject) {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            if self.isInMultipleMode {
                camera!.playbackManager?.goToPreviousMultiplePreviewPage()
            }
            else {
                camera!.playbackManager?.goToPreviousSinglePreviewPage()
            }
        }
    }

    @IBAction func onNextButtonClicked(sender: AnyObject) {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            if self.isInMultipleMode {
                camera!.playbackManager?.goToNextMultiplePreviewPage()
            }
            else {
                camera!.playbackManager?.goToNextSinglePreviewPage()
            }
        }
    }

    @IBAction func onMultipleButtonClicked(sender: AnyObject) {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            camera!.playbackManager?.enterMultiplePreviewMode()
        }
    }

    @IBAction func onSingleButtonClicked(sender: AnyObject) {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            camera!.playbackManager?.enterSinglePreviewModeWithIndex(0)
        }
    }

    func setVideoPreview() {
        VideoPreviewer.instance().start()
        VideoPreviewer.instance().setView(self.view)
    }

    func cleanVideoPreview() {
        VideoPreviewer.instance().unSetView()
    }



    func camera(camera: DJICamera, didReceiveVideoData videoBuffer: UnsafeMutablePointer<UInt8>, length size: Int){
        VideoPreviewer.instance().push(videoBuffer, length: Int32(size))
    }


    func playbackManager(playbackManager: DJIPlaybackManager, didUpdatePlaybackState playbackState: DJICameraPlaybackState) {
        self.isInMultipleMode = playbackState.playbackMode == DJICameraPlaybackMode.MultipleFilesPreview || playbackState.playbackMode == DJICameraPlaybackMode.MultipleFilesEdit
    }

  }
