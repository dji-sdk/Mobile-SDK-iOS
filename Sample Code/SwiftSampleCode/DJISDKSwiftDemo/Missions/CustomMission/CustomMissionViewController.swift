//
//  CustomMissionViewController.h
//  DJISdkDemo
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
    
    func stepsCollectionView(view: DJIStepsCollectionView, didSelectType type: DJICollectionViewCellType){
            let step: DJIMissionStep = self.missionStepFromType(type)!
            self.allSteps.append(step)
            let cell: DJICollectionViewCell = DJICollectionViewCell.collectionViewCell()!
            cell.cellType = type
            cell.setBorderColor(UIColor.blackColor())
            cell.attachedObject = step
            self.allCells.append(cell)
            self.updateScrollView()
    }

    

    @IBAction func onStartMissionButtonClicked(sender: AnyObject) {
        self.startCustomMission()
    }

    @IBAction func onStopMissionButtonClicked(sender: AnyObject) {
        self.missionManager!.stopMissionExecutionWithCompletion({[weak self] (error: NSError?) in
            if (error != nil) {
                self?.showAlertResult(error!.description)
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
            aircraft!.flightController!.delegate = self
        }
        
        self.waypointList = [AnyObject]()
        self.waypointAnnotations = [AnyObject]()
        self.djiMapView = DJIMapView(mapView: mapView)
        self.stepIndex = -1
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController!.title = ""
        let aircraft: DJIAircraft? = self.fetchAircraft()
        if aircraft != nil {
            if aircraft!.flightController!.delegate === self {
                aircraft!.flightController!.delegate = nil
            }
        }
        self.missionManager!.delegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onPauseMissionButtonClicked(sender: AnyObject) {
        self.missionManager!.pauseMissionExecutionWithCompletion({[weak self] (error: NSError?) in
            if (error != nil) {
                self?.showAlertResult("Pause Mission:\(error!.localizedDescription)")
            }
        })
    }

    @IBAction func onResumeMissionButtonClicked(sender: AnyObject) {
        self.missionManager!.resumeMissionExecutionWithCompletion({[weak self] (error: NSError?)->Void in
            if (error != nil) {
                self?.showAlertResult("Resume Mission\(error!.localizedDescription)")
            }
        })
    }

    @IBAction func onAddMissionButtonClicked(sender: AnyObject) {
        if self.stepsCollectionView == nil {
            self.stepsCollectionView = DJIStepsCollectionView()
            self.stepsCollectionView!.center = self.view.center
            self.stepsCollectionView!.delegate = self
            self.stepsCollectionView!.alpha = 0.0
            self.view!.addSubview(self.stepsCollectionView!)
        }
        UIView.animateWithDuration(0.2, animations: {() -> Void in
            self.stepsCollectionView!.alpha = 1.0
        })
    }

    func waypointOnMapView(touchedCoordinate: CLLocationCoordinate2D) {
        let waypoint: DJIWaypoint = DJIWaypoint(coordinate: touchedCoordinate)
        self.waypointList.append(waypoint)
        let wpAnnotation: DJIWaypointAnnotation = DJIWaypointAnnotation()
        wpAnnotation.coordinate = touchedCoordinate
        wpAnnotation.text = "\(Int(self.waypointList.count))"
        self.mapView.addAnnotation(wpAnnotation)
        self.waypointAnnotations.append(wpAnnotation)
    }

// DJIMissionManagerDelegate
    
    func missionManager(manager: DJIMissionManager, didFinishMissionExecution error: NSError?) {
        if (error != nil) {
            self.showAlertResult("Mission Finished with error:\(error!.localizedDescription)")
        } else {
            self.stepIndex = Int(self.allCells.count)
            self.updateCells()
            self.showAlertResult("Mission Finished!")
        }
    }

    func missionManager(manager: DJIMissionManager, missionProgressStatus missionProgress: DJIMissionProgressStatus) {
        if (missionProgress is DJICustomMissionStatus) {
            let customMissionStatus: DJICustomMissionStatus = missionProgress as! DJICustomMissionStatus
            let currentExecStep: DJIMissionStep = customMissionStatus.currentExecutingStep!
            let index: Int = self.allSteps.indexOf(currentExecStep)!
            if index != NSNotFound {
                if self.stepIndex != index {
                    self.stepIndex = Int(index)
                    self.updateCells()
                }
            }
        }
    }

// DJIFlightControllerDelegate
    func flightController(fc: DJIFlightController, didUpdateSystemState state: DJIFlightControllerCurrentState) {
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
        self.missionManager!.stopMissionExecutionWithCompletion({[weak self] (error: NSError?) -> Void in
            if (error != nil ) {
                self?.showAlertResult("Custom mission stop error: \(error!.description)")
            } else {
                self?.showAlertResult("Custom mission is stopped!")
            }
        })
    }

    func updateWaypointMissionOnUIView(waypointMission: DJIWaypointMission) {
        let count:Int32 = waypointMission.waypointCount
        var i:Int32
        for (i = 0; i < count; i++) {
            self.waypointOnMapView(waypointMission.getWaypointAtIndex(i)!.coordinate)
        }
    }

    func updateHotpointMissionOnUIView(hotpointMission: DJIHotPointMission) {
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
        self.missionManager!.prepareMission(customMission!, withProgress: nil, withCompletion: {[weak self] (error: NSError?) -> Void in
            if error == nil {
                self?.missionManager!.startMissionExecutionWithCompletion({ [weak self] (error: NSError?) -> Void in
                    if error != nil {
                        self?.showAlertResult("Custom Mission Start Failed:\(error!.localizedDescription)")
                    }
                })
            }
            else {
                self?.showAlertResult("Custom Mission Failed:\(error!.localizedDescription)")
            }
        })
    }

    func createWaypointMission() -> DJIWaypointMission {
        let mission: DJIWaypointMission = DJIWaypointMission()
        mission.maxFlightSpeed = 15
        mission.autoFlightSpeed = 10
        mission.finishedAction = DJIWaypointMissionFinishedAction.NoAction
        mission.headingMode = DJIWaypointMissionHeadingMode.Auto
        mission.flightPathMode = DJIWaypointMissionFlightPathMode.Normal
        
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
        waypoint1.turnMode = DJIWaypointTurnMode.Clockwise
        let loc2: CLLocationCoordinate2D = CLLocationCoordinate2DMake(droneLocation.latitude + POINT_OFFSET * 2, droneLocation.longitude - POINT_OFFSET * 2)
        let waypoint2: DJIWaypoint = DJIWaypoint(coordinate: loc2)
        waypoint2.altitude = 20
        waypoint2.heading = 0
        waypoint2.actionRepeatTimes = 1
        waypoint2.actionTimeoutInSeconds = 60
        waypoint2.cornerRadiusInMeters = 5
        waypoint2.turnMode = DJIWaypointTurnMode.Clockwise
        let loc3: CLLocationCoordinate2D = CLLocationCoordinate2DMake(droneLocation.latitude + POINT_OFFSET * 2, droneLocation.longitude + POINT_OFFSET * 2)
        let waypoint3: DJIWaypoint = DJIWaypoint(coordinate: loc3)
        waypoint3.altitude = 25
        waypoint3.heading = 0
        waypoint3.actionRepeatTimes = 1
        waypoint3.actionTimeoutInSeconds = 60
        waypoint3.turnMode = DJIWaypointTurnMode.Clockwise
        mission.addWaypoint(waypoint1)
        mission.addWaypoint(waypoint2)
        mission.addWaypoint(waypoint3)
        return mission
    }

    func createHotpointMissionWith(location: CLLocationCoordinate2D) -> DJIHotPointMission {
        let mission: DJIHotPointMission = DJIHotPointMission()
        var droneLocation: CLLocationCoordinate2D = location
        if ((self.currentState != nil) && CLLocationCoordinate2DIsValid(self.currentState!.aircraftLocation)) {
            droneLocation = self.currentState!.aircraftLocation
        }
        mission.hotPoint = CLLocationCoordinate2DMake(droneLocation.latitude - POINT_OFFSET, droneLocation.longitude - POINT_OFFSET)
        mission.altitude = 15
        mission.radius = 15
        mission.isClockwise = false
        mission.angularVelocity = DJIHotPointMission.maxAngularVelocityForRadius(30)
        mission.startPoint = DJIHotPointStartPoint.Nearest
        mission.heading = DJIHotPointHeading.AlongCircleLookingForward
        return mission
    }

    func stepsCollectionViewDidDeleteLast(view: DJIStepsCollectionView) {
        if self.allCells.count > 0 {
            let cell = self.allCells.last
            if (cell != nil) {
                cell!.removeFromSuperview()
                self.allCells.removeLast()
                self.allSteps.removeLast()
                if self.allCells.count > 0 {
                    let count = self.allCells.count
                    self.scrollView.contentSize = CGSizeMake(CGFloat(count * 50), 50)
                }
            }
        }
    }

    func updateScrollView() {
        let count: Int = Int(self.allCells.count)
        self.scrollView.contentSize = CGSizeMake(CGFloat(count * 50), 50)
        let cell = self.allCells.last
        if (cell != nil){
            var frame: CGRect = cell!.frame
            frame.origin.x = CGFloat((count - 1) * 50)
            cell!.frame = frame
            self.scrollView.addSubview(cell!)
        }
    }

    func updateCells() {
        for var i = 0; i < stepIndex; i++ {
            let cell: DJICollectionViewCell = self.allCells[i]
            cell.showProgress(false)
            cell.setBorderColor(UIColor.greenColor())
        }
        if stepIndex < self.allCells.count {
            let cell: DJICollectionViewCell = self.allCells[stepIndex]
            cell.showProgress(true)
            cell.setBorderColor(UIColor.redColor())
        }
    }

    func missionStepFromType(type: DJICollectionViewCellType) -> DJIMissionStep?{
        switch type {
            case .Takeoff:
                                return DJITakeoffStep()

            case .Gohome:
                                return DJIGoHomeStep()

            case .Goto:
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

            case .GimbalAttitude:
                var atti: DJIGimbalAttitude = DJIGimbalAttitude()
                atti.pitch = -45
                atti.roll = 0
                atti.yaw = 0
                
                let step: DJIGimbalAttitudeStep = DJIGimbalAttitudeStep(attitude: atti)!
                step.completionTime = 3.0
                return step

            case .SingleShootPhoto:
                                return DJIShootPhotoStep(singleShootPhoto:())!

            case .ContinousShootPhoto:
                                return DJIShootPhotoStep(photoCount: 3, timeInterval: 3)!

            case .RecordVideoDruation:
                                return DJIRecordVideoStep(duration: 10)!

            case .RecordVideoStart:
                                return DJIRecordVideoStep(startRecordVideo:())!

            case .RecordVideoStop:
                                return DJIRecordVideoStep(stopRecordVideo:())!

            case .WaypointMission:
                                let wpMission: DJIWaypointMission = self.createWaypointMission()
                                updateWaypointMissionOnUIView(wpMission)
                                return DJIWaypointStep(waypointMission: wpMission)!

            case .HotpointMission:
                                var location = CLLocationCoordinate2DMake(0, 0)
                                if (aircraftLocation != nil) {
                                    location = aircraftLocation!
                                }
                                let hpMission: DJIHotPointMission = self.createHotpointMissionWith(location)
                                updateHotpointMissionOnUIView(hpMission)
                                return DJIHotpointStep(hotpointMission: hpMission)!

            case .FollowmeMission:
                                let fmMission: DJIFollowMeMission = DJIFollowMeMission()
                return DJIFollowMeStep(followMeMission: fmMission, duration: 10)!

        }

    }


}
