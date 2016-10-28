//
//  FCCompassViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 16/1/5.
//  Copyright © 2016 DJI. All rights reserved.
//

import DJISDK
class FCCompassViewController: DJIBaseViewController, DJIFlightControllerDelegate {
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var calibratingLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        let fc: DJIFlightController? = self.fetchFlightController()
        if fc != nil {
            fc!.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCompassCalibrationButtonClicked(_ sender: UIButton) {
        let STOP_TAG: Int = 100
        let START_TAG: Int = 101
        let fc: DJIFlightController? = self.fetchFlightController()
        if fc != nil {
            if sender.tag == STOP_TAG {
                fc?.compass?.stopCalibration(completion: {[weak self](error: Error?) -> Void in
                    if error != nil {
                        self?.showAlertResult("Stop Calibration:\(error?.localizedDescription)")
                    }
                    else {
                        sender.setTitle("Start Calibration", for: UIControlState())
                        sender.tag = START_TAG
                    }
                })
            }
            else {
                fc?.compass?.startCalibration(completion: {[weak self](error: Error?) -> Void in
                    if error != nil {
                        self?.showAlertResult("Start Calibration:\(error?.localizedDescription)")
                    }
                    else {
                        sender.setTitle("Stop Calibration", for: UIControlState())
                        sender.tag = STOP_TAG
                    }
                })
            }
        }
        else {
            self.showAlertResult("Component Not Exist.")
        }
    }
    
    func flightController(_ fc: DJIFlightController, didUpdateSystemState state: DJIFlightControllerCurrentState)
    {
        if (fc.compass == nil) {
            return;
        }
        
        self.headingLabel.text = String(format: "%0.1f", fc.compass!.heading)
        self.calibratingLabel.text = fc.compass!.isCalibrating ? "YES" : "NO"
        self.statusLabel.text = self.stringWithCalibrationStatus(fc.compass!.calibrationStatus)
    }
    
    func stringWithCalibrationStatus(_ status: DJICompassCalibrationStatus) -> String {
        if status == DJICompassCalibrationStatus.none {
            return "None"
        }
        else if status == DJICompassCalibrationStatus.horizontal {
            return "Horizontal"
        }
        else if status == DJICompassCalibrationStatus.vertical {
            return "Vertical"
        }
        else if status == DJICompassCalibrationStatus.succeeded {
            return "Succeeded"
        }
        else if status == DJICompassCalibrationStatus.failed {
            return "Failed"
        }
        else {
            return "Unknown"
        }
        
    }
    
}
