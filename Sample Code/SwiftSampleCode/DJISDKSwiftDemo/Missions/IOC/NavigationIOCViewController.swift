//
//  DJIIOCViewController.h
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
        let aircraft: DJIAircraft? = self.fetchAircraft()
        if aircraft != nil {
            // Do any additional setup after loading the view from its nib.
            aircraft!.flightController!.delegate = self

        }
        for var i = 100; i < 105; i++ {
            let btn: UIButton? = self.view!.viewWithTag(i) as? UIButton
            if btn != nil {
                btn!.layer.cornerRadius = btn!.frame.size.width * 0.5
                btn!.layer.borderWidth = 1.2
                btn!.layer.borderColor = UIColor.redColor().CGColor
                btn!.layer.masksToBounds = true
            }
        }
        self.djiMapView = DJIMapView(mapView: self.mapView)
     
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let aircraft: DJIAircraft? = self.fetchAircraft()
        if aircraft != nil {
            aircraft!.flightController!.delegate = self
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let aircraft: DJIAircraft? = self.fetchAircraft()
        if aircraft != nil {
            if aircraft!.flightController!.delegate === self {
                aircraft!.flightController!.delegate = nil
            }
        }
        
        if djiMapView != nil  {
            self.djiMapView = nil
        }
    }

    @IBAction func onStartIOCButtonClicked(sender: AnyObject) {
        let aircraft: DJIAircraft? = self.fetchAircraft()
        if aircraft != nil {
            
        let type: DJIFlightOrientationMode = DJIFlightOrientationMode(rawValue: UInt8(self.iocTypeSegmentCtrl.selectedSegmentIndex))!
        aircraft!.flightController!.setFlightOrientationMode(type, withCompletion: {[weak self] (error: NSError?) -> Void in
            if (error != nil){
                self?.showAlertResult("Start IOC: \(error!.description)")
            }
        })
        }
    }

    @IBAction func onStopIOCButtonClicked(sender: AnyObject) {
        let aircraft: DJIAircraft? = self.fetchAircraft()
        if aircraft != nil {
        
        
        aircraft!.flightController!.setFlightOrientationMode(DJIFlightOrientationMode.DefaultAircraftHeading, withCompletion: {[weak self] (error: NSError?) -> Void in
            if (error != nil) {
                self?.showAlertResult("Stop IOC: \(error!.description)")
            }
        })
        }
    }

    @IBAction func onRecordButtonClicked(sender: AnyObject) {
        let aircraft: DJIAircraft? = self.fetchAircraft()
        if aircraft == nil {
            return
        }
        if self.isRecording {
            aircraft!.camera!.stopRecordVideoWithCompletion({[weak self] (error: NSError?) -> Void in
                if (error != nil ) {
                    self?.showAlertResult("Stop Record: \(error!.description)")
                } else {
                    self?.showAlertResult("Stop Record:Success")
                }
            })
        }
        else {
            aircraft!.camera!.startRecordVideoWithCompletion({[weak self] (error: NSError?) -> Void in
                if (error != nil ) {
                    self?.showAlertResult("Start Record: \(error!.description)")
                } else {
                    self?.showAlertResult("Start Record:Success")
                }            })
        }
    }

    @IBAction func onLockCourseButtonClicked(sender: AnyObject) {
        let aircraft: DJIAircraft? = self.fetchAircraft()
        if aircraft == nil {
            return
        }
        aircraft!.flightController!.lockCourseUsingCurrentDirectionWithCompletion({[weak self] (error: NSError?) -> Void in
            
            if (error != nil ) {
                self?.showAlertResult("Lock Course: \(error!.description)")
            } else {
                self?.showAlertResult("Lock Course: Success")
            }
        })
    }

  
    func camera(camera: DJICamera, didUpdateSystemState systemState: DJICameraSystemState) {
        let aircraft: DJIAircraft? = self.fetchAircraft()
        if aircraft == nil {
            return
        }
        if systemState.mode != DJICameraMode.RecordVideo {
            aircraft!.camera!.setCameraMode(DJICameraMode.RecordVideo, withCompletion: nil)
        }
        if self.isRecording != systemState.isRecording {
            let recBtn: UIButton? = self.view!.viewWithTag(103) as? UIButton
            if recBtn != nil {
                recBtn!.setTitleColor((systemState.isRecording ? UIColor.redColor() : UIColor.blackColor()), forState: .Normal)
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
