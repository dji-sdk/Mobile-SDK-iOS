//
//  NavigationFollowMeViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 15/3/5.
//  Copyright (c) 2015 DJI. All rights reserved.
//
import UIKit
import CoreLocation
import DJISDK

let SIMULATOR_DEBUG = 1

class NavigationFollowMeViewController: DJIBaseViewController, CLLocationManagerDelegate, DJIFlightControllerDelegate, DJICameraDelegate, DJIMissionManagerDelegate {
    var mLocationManager: CLLocationManager? = nil
    var mUpdateTimer: NSTimer? = nil

    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var accuracyLabel: UILabel!
    @IBOutlet var headingControl: UISegmentedControl!
    
    var userLocation: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    var droneLocation: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    var followMeStarted: Bool = false
    
    
    weak var aircraft: DJIAircraft? = nil
    var followMeMission: DJIFollowMeMission? = nil
    var missionManager:DJIMissionManager = DJIMissionManager.sharedInstance()!

    @IBAction func onFollowMeStart(sender: AnyObject) {
        if !CLLocationCoordinate2DIsValid(self.userLocation) {
            self.showAlertResult("Could not locating my location")
            return
        }
        if !CLLocationCoordinate2DIsValid(self.droneLocation) {
            self.showAlertResult("Could not get drone location")
            return
        }
        if self.followMeMission == nil {
            self.followMeMission = DJIFollowMeMission()
        }
        self.followMeMission!.followMeCoordinate = self.userLocation
        self.followMeMission!.heading = DJIFollowMeHeading(rawValue: UInt8(self.headingControl.selectedSegmentIndex))!
        
        self.missionManager.prepareMission(self.followMeMission!, withProgress: nil, withCompletion: {[weak self] (error: NSError?) -> Void in
            if error != nil{
                self?.showAlertResult("Upload mission failed: \(error!.description)")
            }
            else {
                self?.missionManager.startMissionExecutionWithCompletion({[weak self] (error: NSError?) -> Void in
                    self?.showAlertResult("Start FollowMe Mission:\(error?.description)")
                    if error == nil {
                        self?.followMeStarted = true
                        self?.startUpdateTimer()
                    }
                })
            }
        })
    }

    @IBAction func onFollowMeStop(sender: AnyObject) {
        self.missionManager.stopMissionExecutionWithCompletion({[weak self] (error: NSError?) -> Void in
            self?.showAlertResult("Stop FollowMe Mission:\(error?.description)")
            if error == nil {
                self?.followMeStarted = false
                self?.stopUpdateTimer()
            }
        })
    }

    @IBAction func onFollowMePause(sender: AnyObject) {
        self.missionManager.pauseMissionExecutionWithCompletion({[weak self] (error: NSError?) -> Void in
            self?.showAlertResult("Start FollowMe Mission:\(error?.description)")
        })
    }

    @IBAction func onFollowMeResume(sender: AnyObject) {
        self.missionManager.resumeMissionExecutionWithCompletion({[weak self] (error: NSError?) -> Void in
            self?.showAlertResult("Start FollowMe Mission:\(error?.description)")
        })
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationLabel.backgroundColor = UIColor.lightGrayColor()
        self.locationLabel.layer.cornerRadius = 5.0
        self.locationLabel.layer.masksToBounds = true
        self.locationLabel.text = "N/A"
        self.locationLabel.textAlignment = .Center

        self.accuracyLabel.backgroundColor = UIColor.lightGrayColor()
        self.accuracyLabel.layer.cornerRadius = 5.0
        self.accuracyLabel.layer.masksToBounds = true
        self.accuracyLabel.text = "N/A"
        self.accuracyLabel.textAlignment = .Center
        self.followMeStarted = false
        self.droneLocation = kCLLocationCoordinate2DInvalid
        self.userLocation = kCLLocationCoordinate2DInvalid
        self.headingControl.selectedSegmentIndex = 0
        
        if (ConnectedProductManager.sharedInstance.fetchAircraft() != nil) {
            self.aircraft = ConnectedProductManager.sharedInstance.fetchAircraft()
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // flight controller should be ready
        if (self.aircraft != nil) {
            self.aircraft!.flightController?.delegate = self
        }
        // set mission manager delegate
        self.missionManager = DJIMissionManager.sharedInstance()!
        self.missionManager.delegate = self
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // clean the delegate
        if self.missionManager.delegate === self {
            self.missionManager.delegate = nil
        }
     
        if (self.aircraft != nil){
            if self.aircraft!.flightController?.delegate === self {
                self.aircraft!.flightController?.delegate = nil
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func startUpdateLocation() -> Bool {
       // return true
        if CLLocationManager.locationServicesEnabled() {
            if mLocationManager == nil {
                mLocationManager = CLLocationManager()
                mLocationManager!.delegate = self
                mLocationManager!.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                mLocationManager!.distanceFilter = 0.1
                if mLocationManager!.respondsToSelector(#selector(CLLocationManager.requestAlwaysAuthorization)) {
                    mLocationManager!.requestAlwaysAuthorization()
                }
                mLocationManager!.startUpdatingLocation()
            }
            return true
        }
        else {
            self.showAlertResult("Your device not support FollowMe feature")
            return false
        }
    }

    func stopUpdateLocation() {
        if mLocationManager != nil {
            mLocationManager!.stopUpdatingLocation()
            mLocationManager = nil
        }
    }

    func startUpdateTimer() {
        NSThread.detachNewThreadSelector(#selector(NavigationFollowMeViewController.followMeTest), toTarget: self, withObject: nil)
        if mUpdateTimer == nil {
            mUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(NavigationFollowMeViewController.onUpdateTimerTicked(_:)), userInfo: nil, repeats: true)
            mUpdateTimer!.fire()
        }
    }

    func stopUpdateTimer() {
        if mUpdateTimer != nil {
            mUpdateTimer!.invalidate()
            mUpdateTimer = nil
        }
    }

    func onUpdateTimerTicked(sender: AnyObject) {
        if CLLocationCoordinate2DIsValid(self.userLocation) {
            var currentLocation: CLLocation
            currentLocation = CLLocation(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
            var distance: Double = 0
            if CLLocationCoordinate2DIsValid(self.droneLocation) {
                var droneLocation: CLLocation
                droneLocation = CLLocation(latitude: self.droneLocation.latitude, longitude: self.droneLocation.longitude)
                distance = currentLocation.distanceFromLocation(droneLocation)
            }
            self.locationLabel.text = String(format: "Loc:{%0.7f, %0.7f}  \nDrone:{%0.7f, %0.7f} D:%0.2fM", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, self.droneLocation.latitude, self.droneLocation.longitude, distance)
            if self.followMeStarted {
                DJIFollowMeMission.updateFollowMeCoordinate(currentLocation.coordinate, withCompletion: nil)
            }
        }
    }

    func flightController(fc: DJIFlightController, didUpdateSystemState state: DJIFlightControllerCurrentState) {
        if !CLLocationCoordinate2DIsValid(self.userLocation) {
            self.userLocation = CLLocationCoordinate2DMake(state.aircraftLocation.latitude + 0.000004, state.aircraftLocation.longitude + 0.000002)
            //state.droneLocation;
        }
        self.droneLocation = state.aircraftLocation
    }

//    func missionManager(manager: DJIMissionManager, missionProgressStatus missionProgress: DJIMissionProgressStatus) {
//        if (missionProgress is DJIFollowMeMissionStatus) {
//            let fmStatus: DJIFollowMeMissionStatus = missionProgress as! DJIFollowMeMissionStatus
//         //   self.stateLabel.text = "ExecutionState:\(fmStatus.executionState)) HorizontalDistance:%0.01f m"
//        }
//    }

//  #pragma mark - MKLocationManagerDelegate

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let currentLocation:CLLocation? = locations.last
        
        if currentLocation != nil  && currentLocation!.horizontalAccuracy > 0 {
            self.accuracyLabel.text = String(format: "%0.2f M", currentLocation!.horizontalAccuracy)
            self.userLocation = currentLocation!.coordinate
        }
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
            case .NotDetermined:
                 if mLocationManager!.respondsToSelector(#selector(CLLocationManager.requestAlwaysAuthorization)) {
                    mLocationManager!.requestWhenInUseAuthorization()
                }

            default:
                break
        }

    }

    func followMeTest() {
        var tar_pos_lat: Double
        var tar_pos_lon: Double
        var tgt_pos_x: Double
        var tgt_pos_y: Double
        var init_lati: Double
        var init_lont: Double
//        while self.followMeStarted {
//            if CLLocationCoordinate2DIsValid(self.droneLocation) {
//
//            }
//            NSThread.sleepForTimeInterval(0.5)
//        }
        init_lati = self.droneLocation.latitude * M_PI/180.0
        init_lont = self.droneLocation.longitude * M_PI/180.0
        var clock: CGFloat = 0
        let radius: CGFloat = 6378137.0
        while self.followMeStarted {
            
            tgt_pos_x = Double(5.0 * (sin(clock / 10.0 * 0.5)))
            tgt_pos_y = Double(5.0 * cos(clock / 10.0 * 0.5))
            tar_pos_lat = Double(init_lati + (tgt_pos_x/Double(radius)))
            tar_pos_lon = Double(init_lont + (tgt_pos_y/Double(radius)) / cos(init_lati))
            DJIFollowMeMission.updateFollowMeCoordinate(CLLocationCoordinate2DMake((tar_pos_lat)*180.0/M_PI, (tar_pos_lon)*180.0/M_PI), withCompletion: nil)
            clock++
            NSThread.sleepForTimeInterval(0.1)
        }
    }
    
}

