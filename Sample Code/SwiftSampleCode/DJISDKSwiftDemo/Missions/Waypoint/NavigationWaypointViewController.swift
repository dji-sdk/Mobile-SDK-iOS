//
//  NavigationWaypointViewController.swift
//  DJISDKSwiftDemo
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
    var progressAlertView: UIAlertController? = nil
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
    
    func showProgressAlert(_ msg: String?) {
        // create the alert
        let alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    

    @IBAction func onUploadMissionButtonClicked(_ sender: AnyObject) {
        if CLLocationCoordinate2DIsValid(self.aircraftLocation) {
            self.updateMission()
            
            self.missionManager.prepare(self.waypointMission, withProgress:
                {[weak self] (progress: Float) -> Void in
            
                let message: String = "Mission Uploading:\(Int(100 * progress))%"
                if self?.progressAlertView == nil {
                    self?.progressAlertView = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
                    self?.present((self?.progressAlertView)!, animated: true, completion: nil)
                }
                else {
                    self?.progressAlertView!.message = message
                }
                if progress == 1.0 {
                    self?.progressAlertView?.dismiss(animated: true, completion: nil)
                    self?.progressAlertView = nil
                }
            }, withCompletion:{[weak self] (error: Error?) -> Void in
                
                if self?.progressAlertView != nil  {
                    self?.progressAlertView?.dismiss(animated: true, completion: nil)
                    self?.progressAlertView = nil
                }
                if (error != nil) {
                    self?.showAlertResult("Upload Mission Result:\(error!)")
                }
            })
        }
        else {
            self.showAlertResult("Current Drone Location Invalid")
        }
    }

    @IBAction func onDownloadMissionButtonClicked(_ sender: AnyObject) {
        
        self.missionManager.downloadMission(progress: {[weak self](progress: Float) -> Void in
            
            let message: String = "Mission Downloading:\(Int(progress * 100))%%"
            if self?.progressAlertView == nil {
                self?.progressAlertView = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
                self?.present((self?.progressAlertView)!, animated: true, completion: nil)
            }
            else {
                self?.progressAlertView!.message = message
            }
            if progress == 1.0 {
                self?.progressAlertView?.dismiss(animated: true, completion: nil)
                self?.progressAlertView = nil
            }
        }, withCompletion: {[weak self](mission: DJIMission?, error: Error?) -> Void in
            
            
            if self?.progressAlertView != nil  {
                self?.progressAlertView?.dismiss(animated: true, completion: nil)
                self?.progressAlertView = nil
            }
            if mission != nil && (mission is DJIWaypointMission) {
                let wpMission: DJIWaypointMission = mission as! DJIWaypointMission
                self?.showAlertResult("Download Mission Result:\(error) Waypoint(\(wpMission.waypointCount))")
            }
            else if error != nil  {
                self?.showAlertResult("Download Mission:\(error!)")
            }

        })
    }

    @IBAction func onStartMissionButtonClicked(_ sender: AnyObject) {
        self.missionManager.startMissionExecution(completion: {[weak self] (error: Error?) -> Void in
            if (error != nil ) {
                self?.showAlertResult("Start Mission:\(error!)")
            }
        })
    }

    @IBAction func onStopMissionButtonClicked(_ sender: AnyObject) {
        self.missionManager.stopMissionExecution(completion: {[weak self] (error: Error?) -> Void in
            if (error != nil ) {
                self?.showAlertResult("Stop Mission:\(error!)")
            }
        })
    }

    @IBAction func onPauseMissionButtonClicked(_ sender: AnyObject) {
        self.missionManager.pauseMissionExecution(completion: {[weak self] (error: Error?) -> Void in
            if (error != nil ) {
                self?.showAlertResult("Pause Mission:\(error!)")
            }
        })
    }

    @IBAction func onResumeMissionButtonClicked(_ sender: AnyObject) {
        self.missionManager.resumeMissionExecution(completion: {[weak self] (error: Error?) -> Void in
            if (error != nil ) {
                self?.showAlertResult("Resume Mission:\(error!)")
            }
        })
    }

    @IBAction func onBackButtonClicked(_ sender: AnyObject) {
        self.navigationController!.popViewController(animated: true)
    }

    @IBAction func onMissionConfigButtonClicked(_ sender: AnyObject) {
        var frame = self.waypointMissionConfigView?.frame
        frame?.size.width = self.view.frame.width
        self.waypointMissionConfigView?.frame = frame!
        frame = self.waypointMissionConfigView?.finishActionScroll.frame
        frame?.size.width = self.view.frame.width - frame!.origin.x * 2
        self.waypointMissionConfigView?.finishActionScroll.frame = frame!
        self.waypointMissionConfigView?.finishActionScroll.contentSize = (self.waypointMissionConfigView?.finishActionSeg.frame.size)!
        self.waypointMissionConfigView!.center = self.view.center
        
        
        UIView.animate(withDuration: 0.25, animations: {() -> Void in
            self.waypointMissionConfigView!.alpha = 1
        })
    }

    @IBAction func onWaypointConfigButtonClicked(_ sender: AnyObject) {
        self.waypointConfigView.center = self.view.center
        self.waypointConfigView.waypointList = self.waypointList
        UIView.animate(withDuration: 0.25, animations: {() -> Void in
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
        self.waypointConfigView.okButton.addTarget(self, action: #selector(NavigationWaypointViewController.onWaypointConfigOKButtonClicked(_:)), for: .touchUpInside)
        self.view!.addSubview(self.waypointConfigView)
        self.waypointMissionConfigView = NavigationWaypointMissionConfigView()
        self.waypointMissionConfigView!.alpha = 0
        self.waypointMissionConfigView!.okButton.addTarget(self, action: #selector(NavigationWaypointViewController.onMissionConfigOKButtonClicked(_:)), for: .touchUpInside)
        self.view!.addSubview(self.waypointMissionConfigView!)
        self.tipsLabel.layer.cornerRadius = 5.0
        self.tipsLabel.layer.backgroundColor = UIColor.black.cgColor
        self.djiMapView = DJIMapView(mapView: mapView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let aircraft: DJIAircraft? = self.fetchAircraft()
        if aircraft != nil {
            aircraft!.flightController?.delegate = self
        }
        
        self.missionManager.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController!.title = ""
        self.navigationController!.isNavigationBarHidden = false
        let aircraft: DJIAircraft? = self.fetchAircraft()
        if aircraft != nil {
            if aircraft!.flightController?.delegate === self {
                aircraft!.flightController!.delegate = nil
            }
        }
        

        self.missionManager.delegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getCornerRadius(_ pointA: DJIWaypoint?, middleWaypoint pointB: DJIWaypoint?, nextWaypoint pointC: DJIWaypoint?) -> CGFloat {
        if pointA == nil || pointB == nil || pointC == nil {
            return 2.0
        }
        let loc1: CLLocation = CLLocation(latitude: pointA!.coordinate.latitude, longitude: pointA!.coordinate.longitude)
        let loc2: CLLocation = CLLocation(latitude: pointB!.coordinate.latitude, longitude: pointB!.coordinate.longitude)
        let loc3: CLLocation = CLLocation(latitude: pointC!.coordinate.latitude, longitude: pointC!.coordinate.longitude)
        let d1: CLLocationDistance = loc2.distance(from: loc1)
        let d2: CLLocationDistance = loc2.distance(from: loc3)
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
        for i :Int32 in 0 ..< Int32(self.waypointMission.waypointCount) {
            let wp: DJIWaypoint = self.waypointMission.getWaypointAt(i)!
            var prevWaypoint: DJIWaypoint? = nil
            var nextWaypoint: DJIWaypoint? = nil
            let prev: Int32 = i - 1
            let next: Int32 = i + 1
            if prev >= 0 {
                prevWaypoint = self.waypointMission.getWaypointAt(prev)
            }
            if next < self.waypointMission.waypointCount {
                nextWaypoint = self.waypointMission.getWaypointAt(next)
            }
            wp.cornerRadiusInMeters = Float(self.getCornerRadius(prevWaypoint!, middleWaypoint: wp, nextWaypoint: nextWaypoint!))
        }
    }

    func createWaypointMission() {
        let height: Float = 30.0
        self.waypointMission.removeAllWaypoints()
        self.waypointMission.maxFlightSpeed = 6.0
        self.waypointMission.autoFlightSpeed = 4.0
        self.waypointMission.finishedAction = DJIWaypointMissionFinishedAction.goHome
        self.waypointMission.headingMode = DJIWaypointMissionHeadingMode.auto
        self.waypointMission.flightPathMode = DJIWaypointMissionFlightPathMode.normal
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
        let action1: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.shootPhoto, param: 0)
        let action2: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.rotateAircraft, param: -180)
        let action3: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.shootPhoto, param: 0)
        let action4: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.rotateAircraft, param: -90)
        let action5: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.shootPhoto, param: 0)
        let action6: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.rotateAircraft, param: 0)
        let action7: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.shootPhoto, param: 0)
        let action8: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.rotateAircraft, param: 90)
        let action9: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.shootPhoto, param: 0)
        let action10: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.rotateAircraft, param: 180)
        let action11: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.rotateGimbalPitch, param: -45)
        wp1.add(action1)
        wp1.add(action2)
        wp1.add(action3)
        wp1.add(action4)
        wp1.add(action5)
        wp1.add(action6)
        wp1.add(action7)
        wp1.add(action8)
        wp1.add(action9)
        wp1.add(action10)
        wp1.add(action11)
        let wp2: DJIWaypoint = DJIWaypoint(coordinate: point2)
        wp2.altitude = height
        let action12: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.rotateGimbalPitch, param: 29)
        wp2.add(action12)
        let wp3: DJIWaypoint = DJIWaypoint(coordinate: point3)
        wp3.altitude = height
        let action14: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.startRecord, param: 0)
        wp3.add(action14)
        let wp4: DJIWaypoint = DJIWaypoint(coordinate: point4)
        wp4.altitude = height
        let action15: DJIWaypointAction = DJIWaypointAction(actionType: DJIWaypointActionType.stopRecord, param: 0)
        wp4.add(action15)
        self.waypointMission.add(wp1)
        self.waypointMission.add(wp2)
        self.waypointMission.add(wp3)
        self.waypointMission.add(wp4)
        self.waypointMission.add(wp1)
        self.waypointMission.add(wp2)
        self.waypointMission.add(wp3)
        self.waypointMission.add(wp4)
        if self.waypointMission.flightPathMode == DJIWaypointMissionFlightPathMode.curved {
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
        
        let point = self.waypointList.first;
        if (point != nil){
            self.waypointList.append(point!)
        }
        self.waypointMission.addWaypoints(self.waypointList)
        if self.waypointMission.flightPathMode == DJIWaypointMissionFlightPathMode.curved {
            self.calcCornerRadius()
        }
    }

    @IBAction func onEditButtonClicked(_ sender: UIButton) {
        self.isEditEnable = !self.isEditEnable
        if self.isEditEnable {
            self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(NavigationWaypointViewController.onMapViewTap(_:)))
            self.view!.addGestureRecognizer(self.tapGesture!)
            sender.setTitle("Finished", for: UIControlState())
        }
        else {
            sender.setTitle("Add Waypoint", for: UIControlState())
            if (self.tapGesture != nil) {
                self.view!.removeGestureRecognizer(self.tapGesture!)
                self.tapGesture = nil
            }
        }
    }

    @IBAction func onSpeedSliderTouchDown(_ sender: UISlider) {
        self.tipsLabel.text = String(format: "%0.1fm/s", sender.value)
    }

    @IBAction func onSpeedSliderTouchUp(_ sender: UISlider) {
        DJIWaypointMission.setAutoFlightSpeed(sender.value, withCompletion: {[weak self] (error: Error?) -> Void in
            self?.showAlertResult("Set auto flight speed(\(sender.value)m/s):\(error)")
        })
    }

    @IBAction func onSpeedSliderValueChanged(_ sender: UISlider) {
        self.tipsLabel.text = String(format: "%0.1fm/s", sender.value)
    }

    func onWaypointConfigOKButtonClicked(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.25, animations: {() -> Void in
            self.waypointConfigView.alpha = 0
        })
    }

    func onMissionConfigOKButtonClicked(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.25, animations: {() -> Void in
            self.waypointMissionConfigView!.alpha = 0
        })
    }

    func configViewDidDeleteWaypointAtIndex(_ index: Int) {
        if index >= 0 && index < self.waypointAnnotations.count {
            let wpAnno: DJIWaypointAnnotation = self.waypointAnnotations[index] as! DJIWaypointAnnotation
            self.waypointAnnotations.remove(at: index)
            self.mapView.removeAnnotation(wpAnno)
            for i in 0 ..< self.waypointAnnotations.count {
                let wpAnno: DJIWaypointAnnotation = self.waypointAnnotations[i] as! DJIWaypointAnnotation
                wpAnno.text = "\(i + 1)"
                let annoView: DJIWaypointAnnotationView = self.mapView.view(for: wpAnno) as! DJIWaypointAnnotationView
                annoView.titleLabel!.text = wpAnno.text!
            }
        }
    }

    func configViewDidDeleteAllWaypoints() {
        for i in 0 ..< self.waypointAnnotations.count {
            let wpAnno: DJIWaypointAnnotation = self.waypointAnnotations[i] as! DJIWaypointAnnotation
            self.mapView.removeAnnotation(wpAnno)
        }
        self.waypointAnnotations.removeAll()
        self.waypointList.removeAll()
    }

    func onMapViewTap(_ tapGestureRecognizer: UIGestureRecognizer) {
        if self.isEditEnable {
            let point: CGPoint = tapGestureRecognizer.location(in: self.mapView)
            let touchedCoordinate: CLLocationCoordinate2D = mapView.convert(point, toCoordinateFrom: mapView)
            let waypoint: DJIWaypoint = DJIWaypoint(coordinate: touchedCoordinate)
            self.waypointList.append(waypoint)
            let wpAnnotation: DJIWaypointAnnotation = DJIWaypointAnnotation()
            wpAnnotation.coordinate = touchedCoordinate
            wpAnnotation.text = "\(Int(self.waypointList.count))"
            self.mapView.addAnnotation(wpAnnotation)
            self.waypointAnnotations.append(wpAnnotation)
        }
    }

    func missionManager(_ manager: DJIMissionManager, missionProgressStatus missionProgress: DJIMissionProgressStatus) {
        if (missionProgress is DJIWaypointMissionStatus) {
//            var wpmissionStatus: DJIWaypointMissionStatus = missionProgress as! DJIWaypointMissionStatus
        }
    }

    func flightController(_ fc: DJIFlightController, didUpdateSystemState state: DJIFlightControllerCurrentState) {
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
