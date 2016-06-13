//
//  NavigationIOCViewController.swift
//  DJISdkDemo
//
//  Created by DJI on 15/7/1.
//  Copyright (c) 2015 DJI. All rights reserved.
//
import UIKit
import DJISDK
import MapKit

class NavigationIOCViewController: DJIBaseViewController, DJIFlightControllerDelegate, DJICameraDelegate, MKMapViewDelegate {

    @IBOutlet weak var iocTypeSegmentCtrl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var previewView: UIView!
    var djiMapView: DJIMapView? = nil
    var isRecording: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let aircraft = self.fetchAircraft() {
            aircraft.flightController?.delegate = self
        }
        for i in 100 ..< 105 {
            if let btn = self.view!.viewWithTag(i) as? UIButton {
                btn.layer.cornerRadius = btn.frame.size.width * 0.5
                btn.layer.borderWidth = 1.2
                btn.layer.borderColor = UIColor.redColor().CGColor
                btn.layer.masksToBounds = true
            }
        }
        self.djiMapView = DJIMapView(mapView: self.mapView)
     
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let aircraft = self.fetchAircraft() {
            aircraft.flightController?.delegate = self
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let aircraft = self.fetchAircraft() where aircraft.flightController?.delegate === self {
            aircraft.flightController!.delegate = nil
        }
        if let _ = djiMapView {
            self.djiMapView = nil
        }
    }

    @IBAction func onStartIOCButtonClicked(sender: AnyObject) {
        if let aircraft = self.fetchAircraft() {
            let type = DJIFlightOrientationMode(rawValue: UInt8(self.iocTypeSegmentCtrl.selectedSegmentIndex))!
            aircraft.flightController?.setFlightOrientationMode(type) { [weak self] (error: NSError?) -> Void in
                if let error = error {
                    self?.showAlertResult("Start IOC: \(error.description)")
                }
            }
        }
    }

    @IBAction func onStopIOCButtonClicked(sender: AnyObject) {
        if let aircraft = self.fetchAircraft() {
            aircraft.flightController?.setFlightOrientationMode(DJIFlightOrientationMode.DefaultAircraftHeading) { [weak self] (error: NSError?) -> Void in
                if let error = error {
                    self?.showAlertResult("Stop IOC: \(error.description)")
                }
            }
        }
    }

    @IBAction func onRecordButtonClicked(sender: AnyObject) {
        guard let aircraft = self.fetchAircraft() else { return }
        if self.isRecording {
            aircraft.camera!.stopRecordVideoWithCompletion { [weak self] (error: NSError?) -> Void in
                guard let error = error else {
                    self?.showAlertResult("Stop Record:Success")
                    return
                }
                self?.showAlertResult("Stop Record: \(error.description)")
            }
        }
        else {
            aircraft.camera!.startRecordVideoWithCompletion { [weak self] (error: NSError?) -> Void in
                guard let error = error else {
                    self?.showAlertResult("Start Record:Success")
                    return
                }
                self?.showAlertResult("Start Record: \(error.description)")
            }
        }
    }

    @IBAction func onLockCourseButtonClicked(sender: AnyObject) {
        guard let aircraft = self.fetchAircraft() else { return }
        aircraft.flightController?.lockCourseUsingCurrentDirectionWithCompletion { [weak self] (error: NSError?) -> Void in
            guard let error = error else {
                self?.showAlertResult("Lock Course: Success")
                return
            }
            self?.showAlertResult("Lock Course: \(error.description)")
        }
    }

  
    func camera(camera: DJICamera, didUpdateSystemState systemState: DJICameraSystemState) {
        guard let aircraft = self.fetchAircraft() else { return }
        if systemState.mode != DJICameraMode.RecordVideo {
            aircraft.camera!.setCameraMode(DJICameraMode.RecordVideo, withCompletion: nil)
        }
        if self.isRecording != systemState.isRecording {
            if let recBtn  = self.view!.viewWithTag(103) as? UIButton {
                recBtn.setTitleColor((systemState.isRecording ? UIColor.redColor() : UIColor.blackColor()), forState: .Normal)
            }
            self.isRecording = systemState.isRecording
        }
    }

    func flightController(fc: DJIFlightController, didUpdateSystemState state: DJIFlightControllerCurrentState) {
        if CLLocationCoordinate2DIsValid(state.aircraftLocation) {
            let heading: Double = state.attitude.yaw*M_PI/180.0
            djiMapView!.updateAircraftLocation(state.aircraftLocation, withHeading: heading)
        }
        if CLLocationCoordinate2DIsValid(state.homeLocation) {
            djiMapView!.updateHomeLocation(state.homeLocation)
        }
    }
 
}
