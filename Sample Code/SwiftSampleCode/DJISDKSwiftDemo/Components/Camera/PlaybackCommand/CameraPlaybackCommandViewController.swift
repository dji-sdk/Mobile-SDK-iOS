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
            self.multipleButton.isEnabled = !isInMultipleMode
            self.singleButton.isEnabled = isInMultipleMode
        }
    }
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var multipleButton: UIButton!
    @IBOutlet weak var singleButton: UIButton!

    
    override func viewWillAppear(_ animated: Bool) {
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

    override func viewWillDisappear(_ animated: Bool) {
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
            
            camera!.getModeWithCompletion({[weak self](mode: DJICameraMode, error: Error?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("ERROR: getCameraModeWithCompletion:\(error!)")
                }
                else if mode == DJICameraMode.playback {
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
            
            camera!.setCameraMode(DJICameraMode.playback, withCompletion: {[weak self](error: Error?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("ERROR: setCameraMode:withCompletion::\(error!)")
                }
                else {
                    // Normally, once an operation is finished, the camera still needs some time to finish up
                    // all the work. It is safe to delay the next operation after an operation is finished.
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {() -> Void in
                        
                        self?.isInPlaybackMode = true
                    })
                }
            })
        }
    }

    @IBAction func onPreviousButtonClicked(_ sender: AnyObject) {
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

    @IBAction func onNextButtonClicked(_ sender: AnyObject) {
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

    @IBAction func onMultipleButtonClicked(_ sender: AnyObject) {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            camera!.playbackManager?.enterMultiplePreviewMode()
        }
    }

    @IBAction func onSingleButtonClicked(_ sender: AnyObject) {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            camera!.playbackManager?.enterSinglePreviewMode(with: 0)
        }
    }

    func setVideoPreview() {
        VideoPreviewer.instance().start()
        VideoPreviewer.instance().setView(self.view)
    }

    func cleanVideoPreview() {
        VideoPreviewer.instance().unSetView()
    }



    func camera(_ camera: DJICamera, didReceiveVideoData videoBuffer: UnsafeMutablePointer<UInt8>, length size: Int){
        VideoPreviewer.instance().push(videoBuffer, length: Int32(size))
    }


    func playbackManager(_ playbackManager: DJIPlaybackManager, didUpdate playbackState: DJICameraPlaybackState) {
        self.isInMultipleMode = playbackState.playbackMode == DJICameraPlaybackMode.multipleFilesPreview || playbackState.playbackMode == DJICameraPlaybackMode.multipleFilesEdit
    }

  }
