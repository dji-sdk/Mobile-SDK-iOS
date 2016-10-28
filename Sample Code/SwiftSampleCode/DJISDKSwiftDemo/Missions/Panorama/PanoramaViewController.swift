//
//  PanoramaViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 15/3/5.
//  Copyright (c) 2015 DJI. All rights reserved.
//
import UIKit
import CoreLocation
import DJISDK

class PanoramaViewController: DJIBaseViewController, DJIMissionManagerDelegate{
    var panoMission: DJIPanoramaMission? = nil
    var mediaList: [DJIMedia]? = nil
    var panoMedia: DJIMedia?=nil
    var currentIndex: Int = 0
    @IBOutlet weak var startFullButton: UIButton!
    @IBOutlet weak var startSelfieButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var getThumbnailButton: UIButton!
    @IBOutlet var imageViews: [UIImageView]!
    var isRunning: Bool = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getThumbnailButton.isEnabled = false
        DJIMissionManager.sharedInstance()!.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isRunning && self.panoMission != nil {
            DJIMissionManager.sharedInstance()!.stopMissionExecution(completion: {[weak self] (error: Error?) -> Void in
                if error != nil {
                    NSLog("Stop mission failed: \(error!)")
                }
                else {
                    NSLog("Succeed to stop the mission. ")
                    self?.isRunning = false
                }
            })
        }
        if DJIMissionManager.sharedInstance()!.delegate === self {
            DJIMissionManager.sharedInstance()!.delegate = nil
        }
    }

    @IBAction func onStartFullCircleClick(_ sender: AnyObject) {
        self.resetButton.isEnabled = false
        self.startSelfieButton.isEnabled = false
        self.startFullButton.isEnabled = false
        self.startPanoMissionWithPanoMode(DJIPanoramaMode.fullCircle)
    }

    @IBAction func onStartSelfieClick(_ sender: AnyObject) {
        self.resetButton.isEnabled = false
        self.startSelfieButton.isEnabled = false
        self.startFullButton.isEnabled = false
        self.startPanoMissionWithPanoMode(DJIPanoramaMode.halfCircle)
    }

    @IBAction func onResetClick(_ sender: AnyObject) {
        self.panoMission = nil
        for imageView: UIImageView in self.imageViews {
            imageView.image = nil
        }
        self.startFullButton.isEnabled = true
        self.startSelfieButton.isEnabled = true
        self.getThumbnailButton.isEnabled = false
    }

    @IBAction func onGetThumbnailClick(_ sender: AnyObject) {
        self.fetchThumbnailForPanorama()
    }

    func startPanoMissionWithPanoMode(_ mode: DJIPanoramaMode) {
        self.isRunning = true
        self.panoMission = DJIPanoramaMission(panoramaMode: mode)

        if (self.panoMission != nil) {
        DJIMissionManager.sharedInstance()!.prepare(self.panoMission!, withProgress: {(progress: Float) -> Void in
        }, withCompletion: {[weak self] (error: Error?) -> Void in
        
            if error != nil {
                self?.showAlertResult("Upload PanoMission failed: \(error!)")
                self?.isRunning = false
                self?.resetButton.isEnabled = true
            }
            else {
                DJIMissionManager.sharedInstance()!.startMissionExecution(completion: {[weak self] (error: Error?) -> Void in
                    if error != nil{
                        self?.showAlertResult("Start Panorama Mission failed: \(error!)")
                    }
                    else {
                        self?.showAlertResult("Start Panorama succeeded. ")
                    }
                    self?.isRunning = false
                    self?.resetButton.isEnabled = true
                })
            }
        })
        }
    }

    func fetchThumbnailForPanorama() {
        if self.panoMission == nil {
            self.showAlertResult("No panorama mission is available. ")
            return
        }
        self.getThumbnailButton.isEnabled = false
        self.resetButton.isEnabled = false
      
        NSLog("Start to fectch media file. ")
        self.panoMission!.getPanoramaMediaFile(completion: {[weak self](panoMedia: DJIMedia?, error: Error?) -> Void in
            
            if error != nil {
                self?.showAlertResult("Fail to get the panorama media: \(error!)")
                self?.resetButton.isEnabled = true
                self?.getThumbnailButton.isEnabled = true
            }
            else {
                self?.panoMedia = panoMedia
                self?.fetchSubMediaFileListWithMedia()
            }
        })
    }

    func fetchSubMediaFileListWithMedia() {
        NSLog("Start to fetch sub Media file list. ")
        if (self.panoMedia != nil) {
        self.panoMedia!.fetchSubMediaFileList(completion: {[weak self](mediaList:[DJIMedia]?, error: Error?) -> Void in
            
            if error != nil {
                self?.showAlertResult("Fail to fetch the sub-media list: \(error!)")
                self?.resetButton.isEnabled = true
                self?.getThumbnailButton.isEnabled = true
            }
            else {
                NSLog("fetch sub media file list success. ")
                self?.mediaList = mediaList
                self?.fetchThumbnailsOneByOne()
            }
            
            })
        }
    }

    func fetchThumbnailsOneByOne() {
        self.currentIndex = 0
        self.fetchSingleThumbnail()
    }

    func fetchSingleThumbnail() {
        if (self.mediaList == nil) {
            return
        }
        
        if self.currentIndex >= self.mediaList!.count {
            self.resetButton.isEnabled = true
            self.getThumbnailButton.isEnabled = true
            return
        }
        let media: DJIMedia = self.mediaList![self.currentIndex]
     
        media.fetchThumbnail(completion: {[weak self] (error: Error?) -> Void in
       
            if error != nil  {
                self?.showAlertResult("fetch thumbnail failed: \(error!)")
            }
            else {
                let currentIndex: Int = self?.currentIndex ?? 0
                let view: UIImageView? = self?.imageViews[currentIndex]
                view?.image = self?.mediaList![currentIndex].thumbnail
            }
            self?.currentIndex += 1
            self?.fetchSingleThumbnail()
        })
    }

    func missionManager(_ manager: DJIMissionManager, didFinishMissionExecution error: Error?) {
        if error != nil {
            self.showAlertResult("Panorama mission failed: \(error!)")
        }
        else {
            self.showAlertResult("Panorama mission succeeded. ")
            self.getThumbnailButton.isEnabled = true
        }
    }

    func missionManager(_ manager: DJIMissionManager, missionProgressStatus missionProgress: DJIMissionProgressStatus) {
        if (missionProgress is DJIPanoramaMissionStatus) {
            let panoStatus: DJIPanoramaMissionStatus = missionProgress as! DJIPanoramaMissionStatus
            NSLog("Stored photos number: %u", UInt(panoStatus.currentSavedNumber))
        }
    }

}
