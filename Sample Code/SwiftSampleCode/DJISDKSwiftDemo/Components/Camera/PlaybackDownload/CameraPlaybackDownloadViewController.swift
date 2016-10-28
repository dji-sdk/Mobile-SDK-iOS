//
//  CameraPlaybackDownloadViewController.swift
//  DJISDKSwiftDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
*  This file demonstrates how to download files in playback manager. It includes:
*  1. How to show the video feed on the view. Commands in playback manager highly depend on the user interaction,
*     so it is important to show the video feed to the user why using playback manager.
*  2. How to set delegate to the playback manager. It is important to check current playback state before executing
*     the commands.
*  3. How to select the files to download.
*  4. How to download the selected files in the playback manager.
*  The basic workflow is as follow:
*  1. Check if the current camera mode is DJICameraMode.Playback. If it is not, change it to DJICameraMode.Playback.
*  2. If current playback mode is already in multiple edit, we can start to select files and jump to step 3.
*     a. In order to switch to multiple edit, the playback manager need to switch to multiple preview first. Therefore,
*        we check if the mode is already in multiple preview. If that is the case, we enter multiple edit mode. Otherwise,
*        we enter multiple preview first and then enter multiple edit.
*  3. Select the files with index 1 and index 2. （CAUTION: please ensure that there are at least two files in SD Card.
*  4. Start downloading the selected files.
*/
import DJISDK
import UIKit
import VideoPreviewer

class CameraPlaybackDownloadViewController: DJIBaseViewController, DJIPlaybackDelegate, DJICameraDelegate {

    var isFinished: Bool = false {
        didSet {
            self.updateButtons()
        }
    }

    var isInMultipleEditMode: Bool = false {
        didSet {
            self.updateButtons()
        }
    }
    
    
    var isSelectedFilesEnough: Bool = false {
     
        didSet {
            self.updateButtons()
        }
    }
    
    @IBOutlet weak var selectFirstButton: UIButton!
    @IBOutlet weak var selectSecondButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isFinished = false
        self.isInMultipleEditMode = false
        self.isSelectedFilesEnough = false
        self.statusLabel.text = ""
        self.setVideoPreview()
        let camera: DJICamera? = self.fetchCamera()
        if (camera == nil) {
            self.showAlertResult("Cannot detect the camera. ")
            return
        }
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
        if camera != nil  && camera!.playbackManager?.delegate === self {
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
                    self?.showAlertResult("ERROR: getCameraModeWithCompletion::\(error!)")
                }
                else if mode != DJICameraMode.playback {
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
            
            camera?.setCameraMode(DJICameraMode.playback, withCompletion: {[weak self](error: Error?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("ERROR: setCameraMode:withCompletion::\(error!)")
                }
            })
        }
    }

    @IBAction func onSelectFirstClicked(_ sender: AnyObject) {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            camera?.playbackManager?.toggleFileSelection(at: 0)
        }
    }

    @IBAction func onSelectSecondClicked(_ sender: AnyObject) {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            camera?.playbackManager?.toggleFileSelection(at: 1)
        }
    }

    @IBAction func onDownloadClicked(_ sender: AnyObject) {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            self.isFinished = true
            var currentFileTotalSize: UInt = 0
            var currentFileRecievedSize: UInt = 0
            var currentFileName: String? = nil
            
            camera?.playbackManager?.downloadSelectedFiles(preparation: {[weak self](fileName: String?, fileType: DJIDownloadFileType, fileSize: UInt, skip: UnsafeMutablePointer<ObjCBool>) -> Void in
                
                currentFileName = fileName
                self?.statusLabel.text = "Start to download file: \(fileName)"
                currentFileTotalSize = fileSize
                currentFileRecievedSize = 0
            }, process: {[weak self](data: Data?, error: Error?) -> Void in
                
                DispatchQueue.main.async(execute: {() -> Void in
                    
                    if error != nil {
                        self?.showAlertResult("ERROR occurs while downloading file: \(currentFileName)")
                    }
                    else {
                        currentFileRecievedSize += UInt(data!.count)
                        self?.statusLabel.text = "Downloaded: \(Int(CGFloat(currentFileRecievedSize) * 100.0 / CGFloat(currentFileTotalSize)))%"
                    }
                })
            }, fileCompletion: {() -> Void in
                
                self.statusLabel.text = "A file is downloaded"
            }, overallCompletion: {[weak self](error: Error?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("ERROR: downloadSelectedFiles:\(error!)")
                }
                else {
                    self?.showAlertResult("All files are downloaded. ")
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


    func updateButtons() {
        if self.isFinished || !self.isInMultipleEditMode {
            self.selectFirstButton.isEnabled = false
            self.selectSecondButton.isEnabled = false
            self.downloadButton.isEnabled = false
            return
        }
        self.selectFirstButton.isEnabled = true
        self.selectSecondButton.isEnabled = true
        self.downloadButton.isEnabled = self.isSelectedFilesEnough
    }

    func camera(_ camera: DJICamera, didReceiveVideoData videoBuffer: UnsafeMutablePointer<UInt8>, length size: Int) {
        VideoPreviewer.instance().push(videoBuffer, length: Int32(size))
    }

    func playbackManager(_ playbackManager: DJIPlaybackManager, didUpdate playbackState: DJICameraPlaybackState) {
        if self.isFinished {
            return
        }
        self.isSelectedFilesEnough = playbackState.numberOfSelectedFiles  > 0
        switch playbackState.playbackMode {
            case DJICameraPlaybackMode.multipleFilesEdit:
            // already in multiple edit. Then select files.
                self.isInMultipleEditMode = true
            case DJICameraPlaybackMode.multipleFilesPreview:
                playbackManager.enterMultipleEditMode()
            case DJICameraPlaybackMode.download:
                break
            default:
                playbackManager.enterMultiplePreviewMode()
        }

    }

}
