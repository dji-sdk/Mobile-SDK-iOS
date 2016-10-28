//
//  CustomMissionViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 14-7-16.
//  Copyright (c) 2014 DJI. All rights reserved.
//
import UIKit
import MapKit
import DJISDK


let POINT_OFFSET:Double = 0.000179864// 1 = 10 m

let STEP_OFFSET:Double = (0.000179864)
let DEGREE_OF_THIRTY_METER:Double = (0.0000899322 * 3)
//#define DEGREE(x) ((x)*180.0/M_PI)


class CustomMissionViewController: DJIBaseViewController, DJIFlightControllerDelegate, MKMapViewDelegate, DJIMissionManagerDelegate, DJIStepsCollectionViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var isEditEnable: Bool = false
    var waypointList: [AnyObject] = []
    var waypointAnnotations: [AnyObject] = []
    var aircraftLocation: CLLocationCoordinate2D?=nil
    var aircraftAnnotation: DJIAircraftAnnotation?=nil
    var hotPointAnnotation: MKPointAnnotation?=nil
    var currentState: DJIFlightControllerCurrentState?=nil
    var waypointMission: DJIWaypointMission?=nil
    var missionManager: DJIMissionManager?=nil
    var stepsCollectionView: DJIStepsCollectionView? = nil
    
    var customMission: DJICustomMission? = nil
    var djiMapView: DJIMapView? = nil
    var missionSetup: Bool = false
    var deltaProgress: CGFloat = 0
    var allSteps:[DJIMissionStep]=[]
    var allCells:[DJICollectionViewCell] = []
    var stepIndex: Int = 0
    
    func stepsCollectionView(_ view: DJIStepsCollectionView, didSelectType type: DJICollectionViewCellType){
            let step: DJIMissionStep = self.missionStepFromType(type)!
            self.allSteps.append(step)
            let cell: DJICollectionViewCell = DJICollectionViewCell.collectionViewCell()!
            cell.cellType = type
            cell.setBorderColor(UIColor.black)
            cell.attachedObject = step
            self.allCells.append(cell)
            self.updateScrollView()
    }

    

    @IBAction func onStartMissionButtonClicked(_ sender: AnyObject) {
        self.startCustomMission()
    }

    @IBAction func onStopMissionButtonClicked(_ sender: AnyObject) {
        self.missionManager!.stopMissionExecution(completion: {[weak self] (error: Error?) in
            if (error != nil) {
                self?.showAlertResult(error! as! String)
            }
        })
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Custom Mission"
        self.missionManager = DJIMissionManager.sharedInstance()
        self.missionManager!.delegate = self
        
        let aircraft: DJIAircraft? = self.fetchAircraft()
        if aircraft != nil {
            aircraft!.delegate = self
            aircraft!.flightController?.delegate = self
        }
        
        self.waypointList = [AnyObject]()
        self.waypointAnnotations = [AnyObject]()
        self.djiMapView = DJIMapView(mapView: mapView)
        self.stepIndex = -1
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController!.title = ""
        let aircraft: DJIAircraft? = self.fetchAircraft()
        if aircraft != nil {
            if aircraft!.flightController?.delegate === self {
                aircraft!.flightController!.delegate = nil
            }
        }
        self.missionManager!.delegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onPauseMissionButtonClicked(_ sender: AnyObject) {
        self.missionManager!.pauseMissionExecution(completion: {[weak self] (error: Error?) in
            if (error != nil) {
                self?.showAlertResult("Pause Mission:\(error!)")
            }
        })
    }

    @IBAction func onResumeMissionButtonClicked(_ sender: AnyObject) {
        self.missionManager!.resumeMissionExecution(completion: {[weak self] (error: Error?)->Void in
            if (error != nil) {
                self?.showAlertResult("Resume Mission\(error!)")
            }
        })
    }

    @IBAction func onAddMissionButtonClicked(_ sender: AnyObject) {
        if self.stepsCollectionView == nil {
            self.stepsCollectionView = DJIStepsCollectionView()
            self.stepsCollectionView!.center = self.view.center
            self.stepsCollectionView!.delegate = self
            self.stepsCollectionView!.alpha = 0.0
            self.view!.addSubview(self.stepsCollectionView!)
        }
        UIView.animate(withDuration: 0.2, animations: {() -> Void in
            self.stepsCollectionView!.alpha = 1.0
        })
    }

    func waypointOnMapView(_ touchedCoordinate: CLLocationCoordinate2D) {
        let waypoint: DJIWaypoint = DJIWaypoint(coordinate: touchedCoordinate)
        self.waypointList.append(waypoint)
        let wpAnnotation: DJIWaypointAnnotation = DJIWaypointAnnotation()
        wpAnnotation.coordinate = touchedCoordinate
        wpAnnotation.text = "\(Int(self.waypointList.count))"
        self.mapView.addAnnotation(wpAnnotation)
        self.waypointAnnotations.append(wpAnnotation)
    }

// DJIMissionManagerDelegate
    
    func missionManager(_ manager: DJIMissionManager, didFinishMissionExecution error: Error?) {
        if (error != nil) {
            self.showAlertResult("Mission Finished with error:\(error!)")
        } else {
            self.stepIndex = Int(self.allCells.count)
            self.updateCells()
            self.showAlertResult("Mission Finished!")
        }
    }

    func missionManager(_ manager: DJIMissionManager, missionProgressStatus missionProgress: DJIMissionProgressStatus) {
        if (missionProgress is DJICustomMissionStatus) {
            let customMissionStatus: DJICustomMissionStatus = missionProgress as! DJICustomMissionStatus
            let currentExecStep: DJIMissionStep = customMissionStatus.currentExecutingStep!
            let index: Int = self.allSteps.index(of: currentExecStep)!
            if index != NSNotFound {
                if self.stepIndex != index {
                    self.stepIndex = Int(index)
                    self.updateCells()
                }
            }
        }
    }

// DJIFlightControllerDelegate
    func flightController(_ fc: DJIFlightController, didUpdateSystemState state: DJIFlightControllerCurrentState) {
        self.currentState = state
        self.aircraftLocation = state.aircraftLocation
        if CLLocationCoordinate2DIsValid(state.aircraftLocation) {
            let heading: Double = (state.attitude.yaw*M_PI/180.0)
            djiMapView!.updateAircraftLocation(state.aircraftLocation, withHeading:heading)
        }
        if CLLocationCoordinate2DIsValid(state.homeLocation) {
            djiMapView!.updateHomeLocation(state.homeLocation)
        }
    }

    func stopTask() {
        self.missionManager!.stopMissionExecution(completion: {[weak self] (error: Error?) -> Void in
            if (error != nil ) {
                self?.showAlertResult("Custom mission stop error: \(error!)")
            } else {
                self?.showAlertResult("Custom mission is stopped!")
            }
        })
    }

    func updateWaypointMissionOnUIView(_ waypointMission: DJIWaypointMission) {
        for i:Int32 in 0 ..< Int32(waypointMission.waypointCount) {
            self.waypointOnMapView(waypointMission.getWaypointAt(i)!.coordinate)
        }
    }

    func updateHotpointMissionOnUIView(_ hotpointMission: DJIHotPointMission) {
        if CLLocationCoordinate2DIsValid(hotpointMission.hotPoint) {
            if self.hotPointAnnotation == nil {
                self.hotPointAnnotation = MKPointAnnotation()
                self.mapView.addAnnotation(self.hotPointAnnotation!)
            }
            self.hotPointAnnotation!.coordinate = hotpointMission.hotPoint
            self.hotPointAnnotation!.title = String(format: "{%0.6f, %0.6f, %0.1fm}", hotpointMission.hotPoint.latitude, hotpointMission.hotPoint.longitude, hotpointMission.altitude)
        }
    }

    func startCustomMission() {
        
        self.customMission = DJICustomMission(steps: allSteps)
        self.missionManager!.prepare(customMission!, withProgress: nil, withCompletion: {[weak self] (error: Error?) -> Void in
            if error == nil {
                self?.missionManager!.startMissionExecution(completion: { [weak self] (error: Error?) -> Void in
                    if error != nil {
                        self?.showAlertResult("Custom Mission Start Failed:\(error!)")
                    }
                })
            }
            else {
                self?.showAlertResult("Custom Mission Failed:\(error!)")
            }
        })
    }

    func createWaypointMission() -> DJIWaypointMission {
        let mission: DJIWaypointMission = DJIWaypointMission()
        mission.maxFlightSpeed = 15
        mission.autoFlightSpeed = 10
        mission.finishedAction = DJIWaypointMissionFinishedAction.noAction
        mission.headingMode = DJIWaypointMissionHeadingMode.auto
        mission.flightPathMode = DJIWaypointMissionFlightPathMode.normal
        
        // If the aircraftLocation is nil, the waypoint location will be an invalid value
        var droneLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
        if ((self.currentState != nil) && CLLocationCoordinate2DIsValid(self.currentState!.aircraftLocation)) {
            droneLocation = self.currentState!.aircraftLocation
        }
        let loc1: CLLocationCoordinate2D = CLLocationCoordinate2DMake(droneLocation.latitude + POINT_OFFSET * 2, droneLocation.longitude)
        let waypoint1: DJIWaypoint = DJIWaypoint(coordinate: loc1)
        waypoint1.altitude = 15
        waypoint1.heading = 0
        waypoint1.actionRepeatTimes = 1
        waypoint1.actionTimeoutInSeconds = 60
        waypoint1.cornerRadiusInMeters = 5
        waypoint1.turnMode = DJIWaypointTurnMode.clockwise
        let loc2: CLLocationCoordinate2D = CLLocationCoordinate2DMake(droneLocation.latitude + POINT_OFFSET * 2, droneLocation.longitude - POINT_OFFSET * 2)
        let waypoint2: DJIWaypoint = DJIWaypoint(coordinate: loc2)
        waypoint2.altitude = 20
        waypoint2.heading = 0
        waypoint2.actionRepeatTimes = 1
        waypoint2.actionTimeoutInSeconds = 60
        waypoint2.cornerRadiusInMeters = 5
        waypoint2.turnMode = DJIWaypointTurnMode.clockwise
        let loc3: CLLocationCoordinate2D = CLLocationCoordinate2DMake(droneLocation.latitude + POINT_OFFSET * 2, droneLocation.longitude + POINT_OFFSET * 2)
        let waypoint3: DJIWaypoint = DJIWaypoint(coordinate: loc3)
        waypoint3.altitude = 25
        waypoint3.heading = 0
        waypoint3.actionRepeatTimes = 1
        waypoint3.actionTimeoutInSeconds = 60
        waypoint3.turnMode = DJIWaypointTurnMode.clockwise
        
        let waypoint4: DJIWaypoint = DJIWaypoint(coordinate: loc1)
        waypoint4.altitude = 15
        waypoint4.heading = 0
        waypoint4.actionRepeatTimes = 1
        waypoint4.actionTimeoutInSeconds = 60
        waypoint4.cornerRadiusInMeters = 5
        waypoint4.turnMode = DJIWaypointTurnMode.clockwise
        
        mission.add(waypoint1)
        mission.add(waypoint2)
        mission.add(waypoint3)
        mission.add(waypoint4)
        return mission
    }

    func createHotpointMissionWith(_ location: CLLocationCoordinate2D) -> DJIHotPointMission {
        let mission: DJIHotPointMission = DJIHotPointMission()
        var droneLocation: CLLocationCoordinate2D = location
        if ((self.currentState != nil) && CLLocationCoordinate2DIsValid(self.currentState!.aircraftLocation)) {
            droneLocation = self.currentState!.aircraftLocation
        }
        mission.hotPoint = CLLocationCoordinate2DMake(droneLocation.latitude - POINT_OFFSET, droneLocation.longitude - POINT_OFFSET)
        mission.altitude = 15
        mission.radius = 15
        mission.isClockwise = false
        mission.angularVelocity = DJIHotPointMission.maxAngularVelocity(forRadius: 30)
        mission.startPoint = DJIHotPointStartPoint.nearest
        mission.heading = DJIHotPointHeading.alongCircleLookingForward
        return mission
    }

    func stepsCollectionViewDidDeleteLast(_ view: DJIStepsCollectionView) {
        if self.allCells.count > 0 {
            let cell = self.allCells.last
            if (cell != nil) {
                cell!.removeFromSuperview()
                self.allCells.removeLast()
                self.allSteps.removeLast()
                if self.allCells.count > 0 {
                    let count = self.allCells.count
                    self.scrollView.contentSize = CGSize(width: CGFloat(count * 50), height: 50)
                }
            }
        }
    }

    func updateScrollView() {
        let count: Int = Int(self.allCells.count)
        self.scrollView.contentSize = CGSize(width: CGFloat(count * 50), height: 50)
        let cell = self.allCells.last
        if (cell != nil){
            var frame: CGRect = cell!.frame
            frame.origin.x = CGFloat((count - 1) * 50)
            cell!.frame = frame
            self.scrollView.addSubview(cell!)
        }
    }

    func updateCells() {
        for i in 0 ..< stepIndex {
            let cell: DJICollectionViewCell = self.allCells[i]
            cell.showProgress(false)
            cell.setBorderColor(UIColor.green)
        }
        if stepIndex < self.allCells.count {
            let cell: DJICollectionViewCell = self.allCells[stepIndex]
            cell.showProgress(true)
            cell.setBorderColor(UIColor.red)
        }
    }

    func missionStepFromType(_ type: DJICollectionViewCellType) -> DJIMissionStep?{
        switch type {
            case .takeoff:
                                return DJITakeoffStep()

            case .gohome:
                                return DJIGoHomeStep()

            case .goto:
                // Pay attention here, if aircraftLocation is nil, 
                // the goto location will be an invalid value
                var latitude:Double = 0.0
                var longitude:Double = 0.0
                if aircraftLocation != nil {
                    latitude = aircraftLocation!.latitude
                    longitude = aircraftLocation!.longitude
                }
                
                let coord: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude + POINT_OFFSET, longitude + POINT_OFFSET)
                
                waypointOnMapView(coord)
                return DJIGoToStep(coordinate: coord)!

            case .gimbalAttitude:
                var atti: DJIGimbalAttitude = DJIGimbalAttitude()
                atti.pitch = -45
                atti.roll = 0
                atti.yaw = 0
                
                let step: DJIGimbalAttitudeStep = DJIGimbalAttitudeStep(attitude: atti)!
                step.completionTime = 3.0
                return step

            case .singleShootPhoto:
                                return DJIShootPhotoStep(singleShootPhoto:())!

            case .continousShootPhoto:
                                return DJIShootPhotoStep(photoCount: 3, timeInterval: 3)!

            case .recordVideoDruation:
                                return DJIRecordVideoStep(duration: 10)!

            case .recordVideoStart:
                                return DJIRecordVideoStep(startRecordVideo:())!

            case .recordVideoStop:
                                return DJIRecordVideoStep(stopRecordVideo:())!

            case .waypointMission:
                                let wpMission: DJIWaypointMission = self.createWaypointMission()
                                updateWaypointMissionOnUIView(wpMission)
                                return DJIWaypointStep(waypointMission: wpMission)!

            case .hotpointMission:
                                var location = CLLocationCoordinate2DMake(0, 0)
                                if (aircraftLocation != nil) {
                                    location = aircraftLocation!
                                }
                                let hpMission: DJIHotPointMission = self.createHotpointMissionWith(location)
                                updateHotpointMissionOnUIView(hpMission)
                                return DJIHotpointStep(hotpointMission: hpMission)!

            case .followmeMission:
                                let fmMission: DJIFollowMeMission = DJIFollowMeMission()
                return DJIFollowMeStep(followMeMission: fmMission, duration: 10)!

        }

    }


}
