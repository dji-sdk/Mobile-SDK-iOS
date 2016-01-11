//
//  GroundStationTestViewController.h
//  DJISdkDemo
//
//  Created by DJI on 14-7-16.
//  Copyright (c) 2014 DJI. All rights reserved.
//
import UIKit
import MapKit
import DJISDK

let DEGREEOFTHIRTYMETER = 0.0000899322 * 3
//#define DEGREE(x) ((x)*180.0/M_PI)

class NavigationWaypointViewController: DJIBaseViewController, DJIFlightControllerDelegate, MKMapViewDelegate, DJIMissionManagerDelegate, NavigationWaypointConfigViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tipsView: UIView!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var speedSlider: UISlider!
    var progressAlertView: UIAlertView? = nil
    var isEditEnable: Bool = false
    var waypointList: [AnyObject]=[]
    var waypointAnnotations: [AnyObject]=[]
    var aircraftLocation: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    var aircraftAnnotation: DJIAircraftAnnotation? = nil
    var waypointConfigView: NavigationWaypointConfigView = NavigationWaypointConfigView()
    var waypointMissionConfigView: NavigationWaypointMissionConfigView? = nil
    var tapGesture: UITapGestureRecognizer? = nil
    var currentState: DJIFlightControllerCurrentState? = nil
    var waypointMission: DJIWaypointMission = DJIWaypointMission()
    var djiMapView: DJIMapView? = nil
    var missionManager:DJIMissionManager = DJIMissionManager.sharedInstance()!
    

    @IBAction func onUploadMissionButtonClicked(sender: AnyObject) {
        if CLLocationCoordinate2DIsValid(self.aircraftLocation) {
            self.updateMission()
            
            self.missionManager.prepareMission(self.waypointMission, withProgress:
                {[weak self] (progress: Float) -> Void in
            
                let message: String = "Mission Uploading:\(Int(100 * progress))%"
                if self?.progressAlertView == nil {
                    self?.progressAlertView = UIAlertView(title: nil, message: message, delegate: nil, cancelButtonTitle:nil)
                    self?.progressAlertView!.show()
                }
                else {
                    self?.progressAlertView!.message = message
                }
                if progress == 1.0 {
                    self?.progressAlertView!.dismissWithClickedButtonIndex(0, animated: true)
                    self?.progressAlertView = nil
                }
            }, withCompletion:{[weak self] (error: NSError?) -> Void in
                
                if self?.progressAlertView != nil  {
                    self?.progressAlertView!.dismissWithClickedButtonIndex(0, animated: true)
                    self?.progressAlertView = nil
                }
                if (error != nil) {
                    self?.showAlertResult("Upload Mission Result:\(error!.description)")
                }
            })
        }
        else {
            self.showAlertResult("Current Drone Location Invalid")
        }
    }

    @IBAction func onDownloadMissionButtonClicked(sender: AnyObject) {
        
        self.missionManager.downloadMissionWithProgress({[weak self](progress: Float) -> Void in
            
            let message: String = "Mission Downloading:\(Int(progress * 100))%%"
            if self?.progressAlertView == nil {
                self?.progressAlertView = UIAlertView(title: nil, message: message, delegate: nil, cancelButtonTitle: nil)
                self?.progressAlertView!.show()
            }
            else {
                self?.progressAlertView!.message = message
            }
            if progress == 1.0 {
                self?.progressAlertView!.dismissWithClickedButtonIndex(0, animated: true)
                self?.progressAlertView = nil
            }
        }, withCompletion: {[weak self](mission: DJIMission?, error: NSError?) -> Void in
            
            if self?.progressAlertView != nil {
                self?.progressAlertView!.dismissWithClickedButtonIndex(0, animated: true)
                self?.progressAlertView = nil
            }
            if mission != nil && (mission is DJIWaypointMission) {
                let wpMission: DJIWaypointMission = mission as! DJIWaypointMission
                self?.showAlertResult("Download Mission Result:\(error?.description) Waypoint(\(wpMission.waypointCount))")
            }
            else if error != nil  {
                self?.showAlertResult("Download Mission:\(error!.description)")
            }

        })
    }

    @IBAction func onStartMissionButtonClicked(sender: AnyObject) {
        self.missionManager.startMissionExecutionWithCompletion({[weak self] (error: NSError?) -> Void in
            if (error != nil ) {
                self?.showAlertResult("Start Mission:\(error!.description)")
            }
        })
    }

    @IBAction func onStopMissionButtonClicked(sender: AnyObject) {
        self.missionManager.stopMissionExecutionWithCompletion({[weak self] (error: NSError?) -> Void in
            if (error != nil ) {
                self?.showAlertResult("Stop Mission:\(error!.description)")
            }
        })
    }

    @IBAction func onPauseMissionButtonClicked(sender: AnyObject) {
        self.missionManager.pauseMissionExecutionWithCompletion({[weak self] (error: NSError?) -> Void in
            if (error != nil ) {
                self?.showAlertResult("Pause Mission:\(error!.description)")
            }
        })
    }

    @IBAction func onResumeMissionButtonClicked(sender: AnyObject) {
        self.missionManager.resumeMissionExecutionWithCompletion({[weak self] (error: NSError?) -> Void in
            if (error != nil ) {
                self?.showAlertResult("Resume Mission:\(error!.description)")
            }
        })
    }

    @IBAction func onBackButtonClicked(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }

    @IBAction func onMissionConfigButtonClicked(sender: AnyObject) {
        var frame = self.waypointMissionConfigView?.frame
        frame?.size.width = self.view.frame.width
        self.waypointMissionConfigView?.frame = frame!
        frame = self.waypointMissionConfigView?.finishActionScroll.frame
        frame?.size.width = self.view.frame.width - frame!.origin.x * 2
        self.waypointMissionConfigView?.finishActionScroll.frame = frame!
        self.waypointMissionConfigView?.finishActionScroll.contentSize = (self.waypointMissionConfigView?.finishActionSeg.frame.size)!
        self.waypointMissionConfigView!.center = self.view.center
        
        
        UIView.animateWithDuration(0.25, animations: {() -> Void in
            self.waypointMissionConfigView!.alpha = 1
        })
    }

    @IBAction func onWaypointConfigButtonClicked(sender: AnyObject) {
        self.waypointConfigView.center = self.view.center
        self.waypointConfigView.waypointList = self.waypointList
        UIView.animateWithDuration(0.25, animations: {() -> Void in
            self.waypointConfigView.alpha = 1
        })
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.waypointList = [AnyObject]()
        self.waypointAnnotations = [AnyObject]()
        self.isEditEnable = false
        self.waypointConfigView.alpha = 0
        self.waypointConfigView.delegate = self
        self.waypointConfigView.okButton.addTarget(self, action: "onWaypointConfigOKButtonClicked:", forControlEvents: .TouchUpInside)
        self.view!.addSubview(self.waypointConfigView)
        self.waypointMissionConfigView = NavigationWaypointMissionConfigView()
        self.waypointMissionConfigView!.alpha = 0
        self.waypointMissionConfigView!.okButton.addTarget(self, action: "onMissionConfigOKButtonClicked:", forControlEvents: .TouchUpInside)
        self.view!.addSubview(self.waypointMissionConfigView!)
        self.tipsLabel.layer.cornerRadius = 5.0
        self.tipsLabel.layer.backgroundColor = UIColor.blackColor().CGColor
        self.djiMapView = DJIMapView(mapView: mapView)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let aircraft: DJIAircraft? = self.fetchAircraft()
        if aircraft != nil {
            aircraft!.flightController!.delegate = self
        }
        
        self.missionManager.delegate = self
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController!.title = ""
        self.navigationController!.navigationBarHidden = false
        let aircraft: DJIAircraft? = self.fetchAircraft()
        if aircraft != nil {
            if aircraft!.flightController!.delegate === self {
                aircraft!.flightController!.delegate = nil
            }
        }
        

        self.missionManager.delegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getCornerRadius(pointA: DJIWaypoint?, middleWaypoint pointB: DJIWaypoint?, nextWaypoint pointC: DJIWaypoint?) -> CGFloat {
        if pointA == nil || pointB == nil || pointC == nil {
            return 2.0
        }
        let loc1: CLLocation = CLLocation(latitude: pointA!.coordinate.latitude, longitude: pointA!.coordinate.longitude)
        let loc2: CLLocation = CLLocation(latitude: pointB!.coordinate.latitude, longitude: pointB!.coordinate.longitude)
        let loc3: CLLocation = CLLocation(latitude: pointC!.coordinate.latitude, longitude: pointC!.coordinate.longitude)
        let d1: CLLocationDistance = loc2.distanceFromLocation(loc1)
        let d2: CLLocationDistance = loc2.distanceFromLocation(loc3)
        var dmin: CLLocationDistance = min(d1, d2)
        if dmin < 1.0 {
            dmin = 1.0
        }
        else {
            dmin = 1.0 + (dmin - 1.0) * 0.2
            dmin = min(dmin, 10.0)
        }
        return CGFloat(dmin)
    }

    func calcCornerRadius() {
        for var i :Int32 = 0; i < Int32(self.waypointMission.waypointCount); i++ {
            let wp: DJIWaypoint = self.waypointMission.getWaypointAtIndex(i)!
            var prevWaypoint: DJIWaypoint? = nil
            var nextWaypoint: DJIWaypoint? = nil
            let prev: Int32 = i - 1
            let next: Int32 = i + 1
            if prev >= 0 {
                prevWaypoint = self.waypointMission.getWaypointAtIndex(prev)
            }
            if next < self.waypointMission.waypointCount {
                nextWaypoint = self.waypointMission.getWaypointAtIndex(next)
            }
            wp.cornerRadiusInMeters = Float(self.getCornerRadius(prevWaypoint!, middleWaypoint: wp, nextWaypoint: nextWaypoint!))
        }
    }

    func createWaypointMission() {
        let height: Float = 30.0
        self.waypointMission.removeAllWaypoints()
        self.waypointMission.maxFlightSpeed = 6.0
        self.waypointMission.autoFlightSpeed = 4.0
        self.waypointMission.finishedAction = DJIWaypointMissionFinishedAction.GoHome
        self.waypointMission.headingMode = DJIWaypointMissionHeadingMode.Auto
        self.waypointMission.flightPathMode = DJIWaypointMissionFlightPathMode.Normal
        //DJIWaypointMissionAirLineCurve
        var point1: CLLocationCoordinate2D
        var point2: CLLocationCoordinate2D
        var point3: CLLocationCoordinate2D
        var point4: CLLocationCoordinate2D
        point1 = CLLocationCoordinate2DMake(self.aircraftLocation.latitude + DEGREE_OF_THIRTY_METER, self.aircraftLocation.longitude)
        point2 = CLLocationCoordinate2DMake(self.aircraftLocation.latitude, self.aircraftLocation.longitude + DEGREE_OF_THIRTY_METER)
        point3 = CLLocationCoordinate2DMake(self.aircraftLocation.latitude - DEGREE_OF_THIRTY_METER, self.aircraftLocation.longitude)
        point4 = CLLocationCoordinate2DMake(self.aircraftLocation.latitude, self.aircraftLocation.longitude - DEGREE_OF_THIRTY_METER)
        let wp1: DJIWaypoint = DJIWaypoint(coordinate: point1)
        wp1.altitude = height
        let action1: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.ShootPhoto, param: 0)
        let action2: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.RotateAircraft, param: -180)
        let action3: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.ShootPhoto, param: 0)
        let action4: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.RotateAircraft, param: -90)
        let action5: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.ShootPhoto, param: 0)
        let action6: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.RotateAircraft, param: 0)
        let action7: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.ShootPhoto, param: 0)
        let action8: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.RotateAircraft, param: 90)
        let action9: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.ShootPhoto, param: 0)
        let action10: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.RotateAircraft, param: 180)
        let action11: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.RotateGimbalPitch, param: -45)
        wp1.addAction(action1)
        wp1.addAction(action2)
        wp1.addAction(action3)
        wp1.addAction(action4)
        wp1.addAction(action5)
        wp1.addAction(action6)
        wp1.addAction(action7)
        wp1.addAction(action8)
        wp1.addAction(action9)
        wp1.addAction(action10)
        wp1.addAction(action11)
        let wp2: DJIWaypoint = DJIWaypoint(coordinate: point2)
        wp2.altitude = height
        let action12: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.RotateGimbalPitch, param: 29)
        wp2.addAction(action12)
        let wp3: DJIWaypoint = DJIWaypoint(coordinate: point3)
        wp3.altitude = height
        let action14: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.StartRecord, param: 0)
        wp3.addAction(action14)
        let wp4: DJIWaypoint = DJIWaypoint(coordinate: point4)
        wp4.altitude = height
        let action15: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.StopRecord, param: 0)
        wp4.addAction(action15)
        self.waypointMission.addWaypoint(wp1)
        self.waypointMission.addWaypoint(wp2)
        self.waypointMission.addWaypoint(wp3)
        self.waypointMission.addWaypoint(wp4)
        if self.waypointMission.flightPathMode == DJIWaypointMissionFlightPathMode.Curved {
            self.calcCornerRadius()
        }
    }

    func updateMission() {
        self.waypointMission.maxFlightSpeed = CFloat(self.waypointMissionConfigView!.maxFlightSpeed.text!)!
        self.waypointMission.autoFlightSpeed = CFloat(self.waypointMissionConfigView!.autoFlightSpeed.text!)!
        self.waypointMission.finishedAction = DJIWaypointMissionFinishedAction(rawValue: UInt8(self.waypointMissionConfigView!.finishedAction.selectedSegmentIndex))!
        self.waypointMission.headingMode = DJIWaypointMissionHeadingMode(rawValue: UInt(self.waypointMissionConfigView!.headingMode.selectedSegmentIndex))!
        self.waypointMission.flightPathMode = DJIWaypointMissionFlightPathMode(rawValue: UInt(self.waypointMissionConfigView!.airlineMode.selectedSegmentIndex))!
        self.waypointMission.removeAllWaypoints()
        self.waypointMission.addWaypoints(self.waypointList)
        if self.waypointMission.flightPathMode == DJIWaypointMissionFlightPathMode.Curved {
            self.calcCornerRadius()
        }
    }

    @IBAction func onEditButtonClicked(sender: UIButton) {
        self.isEditEnable = !self.isEditEnable
        if self.isEditEnable {
            self.tapGesture = UITapGestureRecognizer(target: self, action: "onMapViewTap:")
            self.view!.addGestureRecognizer(self.tapGesture!)
            sender.setTitle("Finished", forState: .Normal)
        }
        else {
            sender.setTitle("Add Waypoint", forState: .Normal)
            if (self.tapGesture != nil) {
                self.view!.removeGestureRecognizer(self.tapGesture!)
                self.tapGesture = nil
            }
        }
    }

    @IBAction func onSpeedSliderTouchDown(sender: UISlider) {
        self.tipsLabel.text = String(format: "%0.1fm/s", sender.value)
    }

    @IBAction func onSpeedSliderTouchUp(sender: UISlider) {
        DJIWaypointMission.setAutoFlightSpeed(sender.value, withCompletion: {[weak self] (error: NSError?) -> Void in
            self?.showAlertResult("Set auto flight speed(\(sender.value)m/s):\(error?.description)")
        })
    }

    @IBAction func onSpeedSliderValueChanged(sender: UISlider) {
        self.tipsLabel.text = String(format: "%0.1fm/s", sender.value)
    }

    func onWaypointConfigOKButtonClicked(sender: AnyObject) {
        UIView.animateWithDuration(0.25, animations: {() -> Void in
            self.waypointConfigView.alpha = 0
        })
    }

    func onMissionConfigOKButtonClicked(sender: AnyObject) {
        UIView.animateWithDuration(0.25, animations: {() -> Void in
            self.waypointMissionConfigView!.alpha = 0
        })
    }

    func configViewDidDeleteWaypointAtIndex(index: Int) {
        if index >= 0 && index < self.waypointAnnotations.count {
            let wpAnno: DJIWaypointAnnotation = self.waypointAnnotations[index] as! DJIWaypointAnnotation
            self.waypointAnnotations.removeAtIndex(index)
            self.mapView.removeAnnotation(wpAnno)
            for var i = 0; i < self.waypointAnnotations.count; i++ {
                let wpAnno: DJIWaypointAnnotation = self.waypointAnnotations[i] as! DJIWaypointAnnotation
                wpAnno.text = "\(i + 1)"
                let annoView: DJIWaypointAnnotationView = self.mapView.viewForAnnotation(wpAnno) as! DJIWaypointAnnotationView
                annoView.titleLabel!.text = wpAnno.text!
            }
        }
    }

    func configViewDidDeleteAllWaypoints() {
        for var i = 0; i < self.waypointAnnotations.count; i++ {
            let wpAnno: DJIWaypointAnnotation = self.waypointAnnotations[i] as! DJIWaypointAnnotation
            self.mapView.removeAnnotation(wpAnno)
        }
        self.waypointAnnotations.removeAll()
        self.waypointList.removeAll()
    }

    func onMapViewTap(tapGestureRecognizer: UIGestureRecognizer) {
        if self.isEditEnable {
            let point: CGPoint = tapGestureRecognizer.locationInView(self.mapView)
            let touchedCoordinate: CLLocationCoordinate2D = mapView.convertPoint(point, toCoordinateFromView: mapView)
            let waypoint: DJIWaypoint = DJIWaypoint(coordinate: touchedCoordinate)
            self.waypointList.append(waypoint)
            let wpAnnotation: DJIWaypointAnnotation = DJIWaypointAnnotation()
            wpAnnotation.coordinate = touchedCoordinate
            wpAnnotation.text = "\(Int(self.waypointList.count))"
            self.mapView.addAnnotation(wpAnnotation)
            self.waypointAnnotations.append(wpAnnotation)
        }
    }

    func missionManager(manager: DJIMissionManager, missionProgressStatus missionProgress: DJIMissionProgressStatus) {
        if (missionProgress is DJIWaypointMissionStatus) {
//            var wpmissionStatus: DJIWaypointMissionStatus = missionProgress as! DJIWaypointMissionStatus
        }
    }

    func flightController(fc: DJIFlightController, didUpdateSystemState state: DJIFlightControllerCurrentState) {
        self.currentState = state
        self.aircraftLocation = state.aircraftLocation
        if CLLocationCoordinate2DIsValid(state.aircraftLocation) {
            let heading: Double = state.attitude.yaw*M_PI/180.0
            djiMapView!.updateAircraftLocation(state.aircraftLocation, withHeading: heading)
    
        }
        if CLLocationCoordinate2DIsValid(state.homeLocation) {
            djiMapView!.updateHomeLocation(state.homeLocation)
        }
    }


}
