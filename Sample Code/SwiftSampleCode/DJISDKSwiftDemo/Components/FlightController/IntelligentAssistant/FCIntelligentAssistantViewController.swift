//
//  FCIntelligentAssistantViewController.swift
//  DJISdkDemo
//
//  Created by DJI on 16/1/5.
//  Copyright © 2016 DJI. All rights reserved.
//

import DJISDK
class FCIntelligentAssistantViewController: DJIBaseViewController, DJIIntelligentFlightAssistantDelegate {
    
    @IBOutlet weak var isSensorWorking: UILabel!
    @IBOutlet weak var isBraking: UILabel!
    @IBOutlet weak var systemWarning: UILabel!
    @IBOutlet weak var collisionAvoidanceEnable: UISwitch!
    @IBOutlet weak var visionPositioningEnable: UISwitch!
    // Sectors:
    @IBOutlet weak var l2Distance: UILabel!
    @IBOutlet weak var l2WarningLevel: UILabel!
    @IBOutlet weak var l1Distance: UILabel!
    @IBOutlet weak var l1WarningLevel: UILabel!
    @IBOutlet weak var r1Distance: UILabel!
    @IBOutlet weak var r1WarningLevel: UILabel!
    @IBOutlet weak var r2Distance: UILabel!
    @IBOutlet weak var r2WarningLevel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        if let fc = self.fetchFlightController(), fa = fc.intelligentFlightAssistant {
            fa.delegate = self
            updateSwitchState(fa);
        }
    }
    
    func updateSwitchState(fa:DJIIntelligentFlightAssistant?){
        fa?.getCollisionAvoidanceEnabledWithCompletion{ (state:Bool, error: NSError?) -> Void in
            if let error = error {
                self.showAlertResult("Error to get collision avoidance:\(error.description)")
            } else {
                self.collisionAvoidanceEnable.setOn(state, animated:false)
            }
            
            fa?.getVisionPositioningEnabledWithCompletion{ (state:Bool, error:NSError?) -> Void in
                if let error = error {
                    self.showAlertResult("Error to get vision positioning:\(error.description)")
                } else {
                    self.visionPositioningEnable.setOn(state, animated:false)
                }
            }
        }
    }
    
    func intelligentFlightAssistant(assistant: DJIIntelligentFlightAssistant, didUpdateVisionDetectionState state: DJIVisionDetectionState) {
        
        self.isSensorWorking.text = state.isSensorWorking.description ?? "None"
        self.isBraking.text = state.isBraking.description ?? "None"
        self.systemWarning.text = stringWithSystemWarnings(state.systemWarning)
        
        let firstSector : DJIVisionDetectionSector? = state.detectionSectors[0] as? DJIVisionDetectionSector
            self.l2Distance.text = firstSector?.obstacleDistanceInMeters.description
        self.l2WarningLevel.text = firstSector?.warningLevel.rawValue.description
        
        self.l1Distance.text = (state.detectionSectors[1] as?DJIVisionDetectionSector)?.obstacleDistanceInMeters.description
        self.l1WarningLevel.text = (state.detectionSectors[1] as? DJIVisionDetectionSector)?.warningLevel.rawValue.description
        
        self.r1Distance.text = (state.detectionSectors[2] as?DJIVisionDetectionSector)?.obstacleDistanceInMeters.description
        self.r1WarningLevel.text = (state.detectionSectors[2] as? DJIVisionDetectionSector)?.warningLevel.rawValue.description
        
        self.r2Distance.text = (state.detectionSectors[3] as?DJIVisionDetectionSector)?.obstacleDistanceInMeters.description
        self.r2WarningLevel.text = (state.detectionSectors[3] as? DJIVisionDetectionSector)?.warningLevel.rawValue.description
    }
    
    func stringWithSystemWarnings(status: DJIVisionSystemWarning) -> String {
        switch status {
            case .Unknown:
                return "Unknown"
            case .Invalid:
                return "Invalid"
            case .Safe:
                return "Safe"
            case .Dangerous:
                return "Dangerous"
        }
    }
    
    @IBAction func onCollisionAvoidanceSwitchValueChanged(sender: UISwitch){
      self.fetchFlightController()?.intelligentFlightAssistant?.setCollisionAvoidanceEnabled(sender.on) { (error:NSError?) -> Void in
        if let error = error {
            self.showAlertResult("Error to enable/disable CollisionAvoidance:\(error.description)")
            sender.setOn(!sender.on, animated:false)
        }
      }
    }
    
    @IBAction func onVisionPositioningSwitchValueChanged(sender: UISwitch){
        self.fetchFlightController()?.intelligentFlightAssistant?.setVisionPositioningEnabled(sender.on) { (error:NSError?) -> Void in
            if let error = error {
                self.showAlertResult("Error to enable/disable VisionPositioning:\(error.description)")
                sender.setOn(!sender.on, animated:false)
            }
        }
    }
    
}