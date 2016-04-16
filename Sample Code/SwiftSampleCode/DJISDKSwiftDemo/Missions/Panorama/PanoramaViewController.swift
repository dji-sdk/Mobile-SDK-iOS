//
//  InspireFollowMeViewController.h
//  DJISdkDemo
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.getThumbnailButton.enabled = false
        DJIMissionManager.sharedInstance()!.delegate = self
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isRunning && self.panoMission != nil {
            DJIMissionManager.sharedInstance()!.stopMissionExecutionWithCompletion({[weak self] (error: NSError?) -> Void in
                if error != nil {
                    NSLog("Stop mission failed: \(error!.description)")
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

    @IBAction func onStartFullCircleClick(sender: AnyObject) {
        self.resetButton.enabled = false
        self.startSelfieButton.enabled = false
        self.startFullButton.enabled = false
        self.startPanoMissionWithPanoMode(DJIPanoramaMode.FullCircle)
    }

    @IBAction func onStartSelfieClick(sender: AnyObject) {
        self.resetButton.enabled = false
        self.startSelfieButton.enabled = false
        self.startFullButton.enabled = false
        self.startPanoMissionWithPanoMode(DJIPanoramaMode.HalfCircle)
    }

    @IBAction func onResetClick(sender: AnyObject) {
        self.panoMission = nil
        for imageView: UIImageView in self.imageViews {
            imageView.image = nil
        }
        self.startFullButton.enabled = true
        self.startSelfieButton.enabled = true
        self.getThumbnailButton.enabled = false
    }

    @IBAction func onGetThumbnailClick(sender: AnyObject) {
        self.fetchThumbnailForPanorama()
    }

    func startPanoMissionWithPanoMode(mode: DJIPanoramaMode) {
        self.isRunning = true
        self.panoMission = DJIPanoramaMission(panoramaMode: mode)

        if (self.panoMission != nil) {
        DJIMissionManager.sharedInstance()!.prepareMission(self.panoMission!, withProgress: {(progress: Float) -> Void in
        }, withCompletion: {[weak self] (error: NSError?) -> Void in
        
            if error != nil {
                self?.showAlertResult("Upload PanoMission failed: \(error!.description)")
                self?.isRunning = false
                self?.resetButton.enabled = true
            }
            else {
                DJIMissionManager.sharedInstance()!.startMissionExecutionWithCompletion({[weak self] (error: NSError?) -> Void in
                    if error != nil{
                        self?.showAlertResult("Start Panorama Mission failed: \(error!.description)")
                    }
                    else {
                        self?.showAlertResult("Start Panorama succeeded. ")
                    }
                    self?.isRunning = false
                    self?.resetButton.enabled = true
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
        self.getThumbnailButton.enabled = false
        self.resetButton.enabled = false
      
        NSLog("Start to fectch media file. ")
        self.panoMission!.getPanoramaMediaFileWithCompletion({[weak self](panoMedia: DJIMedia?, error: NSError?) -> Void in
            
            if error != nil {
                self?.showAlertResult("Fail to get the panorama media: \(error!.description)")
                self?.resetButton.enabled = true
                self?.getThumbnailButton.enabled = true
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
        self.panoMedia!.fetchSubMediaFileListWithCompletion({[weak self](mediaList:[DJIMedia]?, error: NSError?) -> Void in
            
            if error != nil {
                self?.showAlertResult("Fail to fetch the sub-media list: \(error!.description)")
                self?.resetButton.enabled = true
                self?.getThumbnailButton.enabled = true
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
            self.resetButton.enabled = true
            self.getThumbnailButton.enabled = true
            return
        }
        let media: DJIMedia = self.mediaList![self.currentIndex]
     
        media.fetchThumbnailWithCompletion({[weak self] (error: NSError?) -> Void in
       
            if error != nil  {
                self?.showAlertResult("fetch thumbnail failed: \(error!.description)")
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

    func missionManager(manager: DJIMissionManager, didFinishMissionExecution error: NSError?) {
        if error != nil {
            self.showAlertResult("Panorama mission failed: \(error!.description)")
        }
        else {
            self.showAlertResult("Panorama mission succeeded. ")
            self.getThumbnailButton.enabled = true
        }
    }

    func missionManager(manager: DJIMissionManager, missionProgressStatus missionProgress: DJIMissionProgressStatus) {
        if (missionProgress is DJIPanoramaMissionStatus) {
            let panoStatus: DJIPanoramaMissionStatus = missionProgress as! DJIPanoramaMissionStatus
            NSLog("Stored photos number: %u", UInt(panoStatus.currentSavedNumber))
        }
    }

}
