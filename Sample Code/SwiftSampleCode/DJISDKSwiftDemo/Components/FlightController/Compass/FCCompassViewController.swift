//
//  FCCompassViewController.swift
//  DJISdkDemo
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
        if let fc = self.fetchFlightController() {
            fc.delegate = self
        }
    }
    
    @IBAction func onCompassCalibrationButtonClicked(sender: UIButton) {
        let STOP_TAG: Int = 100
        let START_TAG: Int = 101
        guard let fc = self.fetchFlightController() else {
            self.showAlertResult("Component Not Exist.")
            return
        }
        if sender.tag == STOP_TAG {
            fc.compass?.stopCalibrationWithCompletion { [weak self] (error: NSError?) -> Void in
                if let error = error {
                    self?.showAlertResult("Stop Calibration:\(error.localizedDescription)")
                }
                else {
                    sender.setTitle("Start Calibration", forState: .Normal)
                    sender.tag = START_TAG
                }
            }
        }
        else {
            fc.compass?.startCalibrationWithCompletion { [weak self] (error: NSError?) -> Void in
                if let error = error {
                    self?.showAlertResult("Start Calibration:\(error.localizedDescription)")
                }
                else {
                    sender.setTitle("Stop Calibration", forState: .Normal)
                    sender.tag = STOP_TAG
                }
            }
        }
    }
    
    func flightController(fc: DJIFlightController, didUpdateSystemState state: DJIFlightControllerCurrentState)
    {
        guard let compass = fc.compass else { return }
        self.headingLabel.text = String(format: "%0.1f", compass.heading)
        self.calibratingLabel.text = compass.isCalibrating ? "YES" : "NO"
        self.statusLabel.text = self.stringWithCalibrationStatus(compass.calibrationStatus)
    }
    
    func stringWithCalibrationStatus(status: DJICompassCalibrationStatus) -> String {
        switch status {
            case .None:         return "None"
            case .Horizontal:   return "Horizontal"
            case .Vertical:     return "Vertical"
            case .Succeeded:    return "Succeeded"
            case .Failed:       return "Failed"
            default:            return "Unknown"
        }
        
    }
    
}