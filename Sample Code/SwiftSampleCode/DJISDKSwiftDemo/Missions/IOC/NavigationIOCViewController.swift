//
//  NavigationIOCViewController.swift
//  DJISDKSwiftDemo
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
        let aircraft: DJIAircraft? = self.fetchAircraft()
        if aircraft != nil {
            // Do any additional setup after loading the view from its nib.
            aircraft!.flightController?.delegate = self

        }
        for i in 100 ..< 105 {
            let btn: UIButton? = self.view!.viewWithTag(i) as? UIButton
            if btn != nil {
                btn!.layer.cornerRadius = btn!.frame.size.width * 0.5
                btn!.layer.borderWidth = 1.2
                btn!.layer.borderColor = UIColor.red.cgColor
                btn!.layer.masksToBounds = true
            }
        }
        self.djiMapView = DJIMapView(mapView: self.mapView)
     
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let aircraft: DJIAircraft? = self.fetchAircraft()
        if aircraft != nil {
            aircraft!.flightController?.delegate = self
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let aircraft: DJIAircraft? = self.fetchAircraft()
        if aircraft != nil {
            if aircraft!.flightController?.delegate === self {
                aircraft!.flightController!.delegate = nil
            }
        }
        
        if djiMapView != nil  {
            self.djiMapView = nil
        }
    }

    @IBAction func onStartIOCButtonClicked(_ sender: AnyObject) {
        let aircraft: DJIAircraft? = self.fetchAircraft()
        if aircraft != nil {
            
        let type: DJIFlightOrientationMode = DJIFlightOrientationMode(rawValue: UInt8(self.iocTypeSegmentCtrl.selectedSegmentIndex))!
        aircraft!.flightController?.setFlightOrientationMode(type, withCompletion: {[weak self] (error: Error?) -> Void in
            if (error != nil){
                self?.showAlertResult("Start IOC: \(error!)")
            }
        })
        }
    }

    @IBAction func onStopIOCButtonClicked(_ sender: AnyObject) {
        let aircraft: DJIAircraft? = self.fetchAircraft()
        if aircraft != nil {
        
        
        aircraft!.flightController?.setFlightOrientationMode(DJIFlightOrientationMode.defaultAircraftHeading, withCompletion: {[weak self] (error: Error?) -> Void in
            if (error != nil) {
                self?.showAlertResult("Stop IOC: \(error!)")
            }
        })
        }
    }

    @IBAction func onRecordButtonClicked(_ sender: AnyObject) {
        let aircraft: DJIAircraft? = self.fetchAircraft()
        if aircraft == nil {
            return
        }
        if self.isRecording {
            aircraft!.camera!.stopRecordVideo(completion: {[weak self] (error: Error?) -> Void in
                if (error != nil ) {
                    self?.showAlertResult("Stop Record: \(error!)")
                } else {
                    self?.showAlertResult("Stop Record:Success")
                }
            })
        }
        else {
            aircraft!.camera!.startRecordVideo(completion: {[weak self] (error: Error?) -> Void in
                if (error != nil ) {
                    self?.showAlertResult("Start Record: \(error!)")
                } else {
                    self?.showAlertResult("Start Record:Success")
                }            })
        }
    }

    @IBAction func onLockCourseButtonClicked(_ sender: AnyObject) {
        let aircraft: DJIAircraft? = self.fetchAircraft()
        if aircraft == nil {
            return
        }
        aircraft!.flightController?.lockCourseUsingCurrentDirection(completion: {[weak self] (error: Error?) -> Void in
            
            if (error != nil ) {
                self?.showAlertResult("Lock Course: \(error!)")
            } else {
                self?.showAlertResult("Lock Course: Success")
            }
        })
    }

  
    func camera(_ camera: DJICamera, didUpdate systemState: DJICameraSystemState) {
        let aircraft: DJIAircraft? = self.fetchAircraft()
        if aircraft == nil {
            return
        }
        if systemState.mode != DJICameraMode.recordVideo {
            aircraft!.camera!.setCameraMode(DJICameraMode.recordVideo, withCompletion: nil)
        }
        if self.isRecording != systemState.isRecording {
            let recBtn: UIButton? = self.view!.viewWithTag(103) as? UIButton
            if recBtn != nil {
                recBtn!.setTitleColor((systemState.isRecording ? UIColor.red : UIColor.black), for: UIControlState())
            }
            self.isRecording = systemState.isRecording
        }
    }

    func flightController(_ fc: DJIFlightController, didUpdateSystemState state: DJIFlightControllerCurrentState) {
        if CLLocationCoordinate2DIsValid(state.aircraftLocation) {
            let heading: Double = state.attitude.yaw*M_PI/180.0
            djiMapView!.updateAircraftLocation(state.aircraftLocation, withHeading: heading)
         
        }
        if CLLocationCoordinate2DIsValid(state.homeLocation) {
            djiMapView!.updateHomeLocation(state.homeLocation)
        }
    }
 
}
