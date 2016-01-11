//
//  InspireHotPointTestViewController.h
//  DJISdkDemo
//
//  Created by DJI on 15/4/27.
//  Copyright (c) 2015 DJI. All rights reserved.
//
import UIKit
import MapKit
import DJISDK
class NavigationHotPointViewController: DJIBaseViewController, MKMapViewDelegate, DJIFlightControllerDelegate, DJICameraDelegate, DJIMissionManagerDelegate, HotPointConfigViewDelegate {
    var mCurrentHotpointCoordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    var mIsMissionStarted: Bool=false
    var mIsMissionPaused: Bool=false
    var isNeedMissionSync: Bool=false
    var isRecording: Bool = false
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var topContentView: UIView!
    @IBOutlet var startStopButton: UIButton!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var previewView: UIView!
    var djiMapView:DJIMapView?=nil
    var systemState: DJIFlightControllerCurrentState?=nil

    var configView: HotPointConfigView = HotPointConfigView()
    weak var missionManager: DJIMissionManager? = nil
    var hotpointMission: DJIHotPointMission? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.title = "H:{-180.000000, -180.000000}, D:{-180.000000, -180.000000}, GPS:0, H.S:0.0 m/s V.S:0.0 m/s"
        mIsMissionStarted = false
        mIsMissionPaused = false
        self.isNeedMissionSync = true
        let button1: UIView = self.view!.viewWithTag(100)!
        self.decorateView(button1)
        let button2: UIView = self.view!.viewWithTag(200)!
        self.decorateView(button2)
        let button3: UIView = self.view!.viewWithTag(300)!
        self.decorateView(button3)
        self.decorateView(self.recordButton)
      
        self.configView.alpha = 0
        self.configView.delegate = self
        self.configView.layer.cornerRadius = 4.0
        self.configView.layer.masksToBounds = true
        self.view!.addSubview(self.configView)
        self.djiMapView = DJIMapView(mapView: self.mapView)
    }

    func decorateView(theView: UIView) {
        theView.layer.cornerRadius = theView.frame.size.width * 0.5
        theView.layer.borderWidth = 1.2
        theView.layer.borderColor = UIColor.blueColor().CGColor
        theView.layer.masksToBounds = true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // flight controller should be ready
        var aircraft: DJIAircraft? = nil
        aircraft = self.fetchAircraft()
        if aircraft != nil {
            aircraft!.flightController!.delegate = self
        }
        // set mission manager delegate
        self.missionManager = DJIMissionManager.sharedInstance()
        self.missionManager!.delegate = self
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let aircraft:DJIAircraft? = self.fetchAircraft()
        if aircraft != nil {
            if aircraft!.flightController!.delegate === self {
                aircraft!.flightController!.delegate = nil
            }
        }
        // clean the delegate
        if self.missionManager!.delegate === self {
            self.missionManager!.delegate = nil
        }
    
        if djiMapView != nil {
            self.djiMapView = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showConfigView() {
        if self.systemState != nil {
            self.configView.altitude = CGFloat(self.systemState!.altitude)
        }
        self.configView.center = self.view.center
        UIView.animateWithDuration(0.25, animations: {() -> Void in
            self.configView.alpha = 1.0
        })
    }

    func downloadHotPointMission() {
        
        self.missionManager!.downloadMissionWithProgress(nil, withCompletion: {[weak self](mission: DJIMission?, error: NSError?) -> Void in
            if error == nil {
                self?.resumeMissionScene(mission!)
            }
            else {
                self?.showAlertResult("Download Mission Falied: \(error!.description)")
            }
        })
    }

    func resumeMissionScene(mission: DJIMission) {
        if mission is DJIHotPointMission {
            self.hotpointMission = mission as? DJIHotPointMission
            mCurrentHotpointCoordinate = self.hotpointMission!.hotPoint
            if CLLocationCoordinate2DIsValid(mCurrentHotpointCoordinate) {
                djiMapView!.addPOICoordinate(mCurrentHotpointCoordinate, radius:CGFloat(self.hotpointMission!.radius))
                var region: MKCoordinateRegion = MKCoordinateRegion()
                region.center = mCurrentHotpointCoordinate
                region.span.latitudeDelta = 0.001
                region.span.longitudeDelta = 0.001
                self.mapView.setRegion(region, animated: true)
                mIsMissionStarted = true
                self.startStopButton.setTitle("Stop", forState: .Normal)
            }
        }
    }

    func missionManager(manager: DJIMissionManager, missionProgressStatus missionProgress: DJIMissionProgressStatus) {
        if (missionProgress is DJIHotPointMissionStatus) {
            let hotPointMissionStatus: DJIHotPointMissionStatus = missionProgress as! DJIHotPointMissionStatus
            
            if isNeedMissionSync {
                self.isNeedMissionSync = false
                self.downloadHotPointMission()
            }
            if (hotPointMissionStatus.error != nil) {
                self.showAlertResult("Mission Error: \(hotPointMissionStatus.error!.description)")
            }
        }
    }

    func flightController(fc: DJIFlightController, didUpdateSystemState state: DJIFlightControllerCurrentState) {
       // var speed: Float = sqrtf(state.velocityX * state.velocityX + state.velocityY * state.velocityY)
        let titleMessage: String = "H:{%0.6f, %0.6f}, D:{%0.6f, %0.6f}, GPS:\(state.homeLocation.latitude), H.S:%0.1f m/s V.S:%0.1f m/s"
        self.navigationController!.title = titleMessage
        self.systemState = state
        if CLLocationCoordinate2DIsValid(state.aircraftLocation) {
            let heading:Double = state.attitude.yaw*M_PI/180.0
            djiMapView!.updateAircraftLocation(state.aircraftLocation, withHeading: heading)
        }
    }

   
    func configViewWillDisappear() {
        if self.hotpointMission == nil {
            self.hotpointMission = DJIHotPointMission()
        }
        let mission: DJIHotPointMission = self.hotpointMission!
        mission.hotPoint = mCurrentHotpointCoordinate
        mission.altitude = Float(self.configView.altitude)
        mission.radius = Float(self.configView.radius)
        mission.angularVelocity = Float(self.configView.speed)
        mission.startPoint = self.configView.startPoint
        mission.heading = self.configView.heading
        mission.isClockwise = self.configView.clockwise
        //Hot point mission's altitude should between low limit and hight limit. default low limit is 5M, hight limit is 120M
        if mission.altitude < 5 || mission.altitude > 120 {
            self.showAlertResult("Mission altitude should be in [5M, 120M]")
            return
        }
        //    if (mission.radius > DJIHotPointMaxRadius) {
        //        self?.showAlertResult(@"Mission surround radius too large");
        //        return;
        //    }
        let maxSpeed:Float = DJIHotPointMission.maxAngularVelocityForRadius(mission.radius)
        if mission.angularVelocity > maxSpeed {
            self.showAlertResult("Speed should not larger then:\(maxSpeed)")
            return
        }
        
        self.missionManager!.prepareMission(self.hotpointMission!, withProgress: nil, withCompletion: {[weak self] (error: NSError?) -> Void in
            self?.missionManager!.startMissionExecutionWithCompletion({[weak self] (error: NSError?) -> Void in
                if (error != nil ){
                    self?.showAlertResult("Start Hotpoint Mission:\(error!.description)")
                }
                else {
                    self?.djiMapView!.addPOICoordinate(self!.hotpointMission!.hotPoint, radius: CGFloat(self!.hotpointMission!.radius))
                    self?.mIsMissionStarted = true
                    self?.startStopButton.setTitle("Stop", forState: .Normal)
                }
            })
        })
    }

    @IBAction func onSetHotPointButtonClikced(sender: AnyObject) {
        if mIsMissionStarted {
            self.showAlertResult("There is a mission in executing...")
            return
        }
        if self.systemState == nil {
            return
        }
        self.isNeedMissionSync = false
        mCurrentHotpointCoordinate = self.systemState!.aircraftLocation
        if CLLocationCoordinate2DIsValid(mCurrentHotpointCoordinate) {
            djiMapView!.addPOICoordinate(mCurrentHotpointCoordinate,radius: 0)
            var region: MKCoordinateRegion = MKCoordinateRegion()
            region.center = mCurrentHotpointCoordinate
            region.span.latitudeDelta = 0.001
            region.span.longitudeDelta = 0.001
            self.mapView.setRegion(region, animated: true)
        }
    }

    @IBAction func onStartStopButtonClicked(sender: UIButton) {
        if mIsMissionStarted {
            self.missionManager!.stopMissionExecutionWithCompletion({[weak self] (error: NSError?) -> Void in
                self?.showAlertResult("Stop Hotpoint Mission:\(error?.description)")
                if error == nil {
                    self?.mIsMissionStarted = false
                    self?.startStopButton.setTitle("Start", forState: .Normal)
                }
            })
        }
        else {
            if CLLocationCoordinate2DIsValid(mCurrentHotpointCoordinate) {
                self.showConfigView()
            }
            else {
                self.showAlertResult("Current location is invalid.")
            }
        }
    }

    @IBAction func onPauseResumeButtonClicked(sender: UIButton) {
        if mIsMissionStarted {
            if mIsMissionPaused {
                self.missionManager!.resumeMissionExecutionWithCompletion({[weak self] (error: NSError?) -> Void in
                    self?.showAlertResult("Resume Hotpoint Mission:\(error?.description)")
                    if error == nil {
                        self?.mIsMissionPaused = false
                        sender.setTitle("Pause", forState: .Normal)
                    }
                })
            }
            else {
                self.missionManager!.pauseMissionExecutionWithCompletion({[weak self] (error: NSError?) -> Void in
                    self?.showAlertResult("Pause Hotpoint Mission:\(error?.description)")
                    if error == nil {
                        self?.mIsMissionPaused = true
                        sender.setTitle("Resume", forState: .Normal)
                    }
                })
            }
        }
    }

    @IBAction func onRecordButtonClicked(sender: AnyObject) {
        let aircraft:DJIAircraft? = self.fetchAircraft()
        if aircraft == nil {
            return
        }
        if isRecording {
            aircraft!.camera!.stopRecordVideoWithCompletion({[weak self] (error: NSError?) -> Void in
                self?.showAlertResult("Stop Rec:\(error?.description)")
            })
        }
        else {
            aircraft!.camera!.startRecordVideoWithCompletion({[weak self] (error: NSError?) -> Void in
                self?.showAlertResult("Stard Rec: \(error?.description)")
            })
        }
    }

}
