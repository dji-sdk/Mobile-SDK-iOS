//
//  CameraShootSinglePhotoViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 12/28/15.
//  Copyright © 2015 DJI. All rights reserved.
//
import UIKit
import DJISDK
import VideoPreviewer

class CameraShootSinglePhotoViewController: DJIBaseViewController, DJICameraDelegate {

    var isInShootPhotoMode: Bool = false {
        didSet {
            self.toggleShootPhotoButton()
        }
    }
    
    var isShootingPhoto: Bool = false {
        didSet {
            self.toggleShootPhotoButton()
        }
    }
    
    var isStoringPhoto: Bool = false {
        didSet {
            self.toggleShootPhotoButton()
        }
    }
    
    @IBOutlet weak var shootPhotoButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setVideoPreview()
        // set delegate to render camera's video feed into the view
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            camera?.delegate = self
        }
        // disable the shoot photo button by default
        self.shootPhotoButton.isEnabled = false
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
     *  Check if the camera's mode is DJICameraMode.ShootPhoto.
     *  If the mode is not DJICameraMode.ShootPhoto, we need to set it to be ShootPhoto.
     *  If the mode is already DJICameraMode.ShootPhoto, we check the exposure mode.
     */

    func getCameraMode() {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            
            camera?.getModeWithCompletion({[weak self](mode: DJICameraMode, error: Error?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("ERROR: getCameraModeWithCompletion::\(error!)")
                }
                else if mode == DJICameraMode.shootPhoto {
                    self?.isInShootPhotoMode = true
                }
                else {
                    self?.setCameraMode()
                }

            })
        }
    }
    /**
     *  Set the camera's mode to DJICameraMode.ShootPhoto.
     *  If it succeeds, we can enable the take photo button.
     */

    func setCameraMode() {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            
            camera?.setCameraMode(DJICameraMode.shootPhoto, withCompletion: {[weak self](error: Error?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("ERROR: setCameraMode:withCompletion:\(error!)")
                }
                else {
                    // Normally, once an operation is finished, the camera still needs some time to finish up
                    // all the work. It is safe to delay the next operation after an operation is finished.
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {() -> Void in
                        
                        self?.isInShootPhotoMode = true
                    })
                }
            })
        }
    }
    /**
     *  When the pre-condition meets, the shoot photo button should be enabled. Then the user can can shoot
     *  a photo now.
     */

    @IBAction func onShootPhotoButtonClicked(_ sender: AnyObject) {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            self.shootPhotoButton.isEnabled = false
            camera?.startShootPhoto(DJICameraShootPhotoMode.single, withCompletion: {[weak self](error: Error?) -> Void in
                if error != nil {
                    self?.showAlertResult("ERROR: startShootPhoto:withCompletion::\(error!)")
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

    func toggleShootPhotoButton() {
        self.shootPhotoButton.isEnabled = (self.isInShootPhotoMode && !self.isShootingPhoto && !self.isStoringPhoto)
    }

    func camera(_ camera: DJICamera, didReceiveVideoData videoBuffer: UnsafeMutablePointer<UInt8>, length size: Int) {
        VideoPreviewer.instance().push(videoBuffer, length: Int32(size))
    }

    func camera(_ camera: DJICamera, didUpdate systemState: DJICameraSystemState) {
        self.isShootingPhoto = systemState.isShootingSinglePhoto || systemState.isShootingIntervalPhoto || systemState.isShootingBurstPhoto
        self.isStoringPhoto = systemState.isStoringPhoto
    }


}
