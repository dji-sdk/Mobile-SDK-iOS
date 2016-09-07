//
//  FCIntelligentAssistantViewController.swift
//  DJISDKSwiftDemo
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
        let fc: DJIFlightController? = self.fetchFlightController()
        if (fc != nil && fc?.intelligentFlightAssistant != nil) {
            fc?.intelligentFlightAssistant?.delegate = self
            updateSwitchState(fc?.intelligentFlightAssistant);
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSwitchState(fa:DJIIntelligentFlightAssistant?){
        if (fa != nil) {
            fa?.getCollisionAvoidanceEnabledWithCompletion({ (state:Bool, error: NSError?) -> Void in
                if (error != nil) {
                    self.showAlertResult("Error to get collision avoidance:\(error?.description)")
                }else {
                    self.collisionAvoidanceEnable.setOn(state, animated:false)
                }
                
                fa?.getVisionPositioningEnabledWithCompletion({ (state:Bool, error:NSError?) -> Void in
                    if (error != nil) {
                        self.showAlertResult("Error to get vision positioning:\(error?.description)")
                    }else {
                        self.visionPositioningEnable.setOn(state, animated:false)
                    }
                })
            })
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
        if status == DJIVisionSystemWarning.Unknown {
            return "Unknown"
        }
        else if status == DJIVisionSystemWarning.Invalid {
            return "Invalid"
        }
        else if status == DJIVisionSystemWarning.Safe {
            return "Safe"
        }
        else if status == DJIVisionSystemWarning.Dangerous {
            return "Dangerous"
        }
        
        return "SDK Wrong"
        
    }
    
    @IBAction func onCollisionAvoidanceSwitchValueChanged(sender: UISwitch){
        let fc: DJIFlightController? = self.fetchFlightController()
        let fa = fc?.intelligentFlightAssistant
        if (fa != nil) {
          fa?.setCollisionAvoidanceEnabled(sender.on, withCompletion: { (error:NSError?) -> Void in
            if (error != nil) {
                self.showAlertResult("Error to enable/disable CollisionAvoidance:\(error?.description)")
                sender.setOn(!sender.on, animated:false)
            }
          })
        }
    }
    
    @IBAction func onVisionPositioningSwitchValueChanged(sender: UISwitch){
        let fc: DJIFlightController? = self.fetchFlightController()
        let fa = fc?.intelligentFlightAssistant
        if (fa != nil) {
            fa?.setVisionPositioningEnabled(sender.on, withCompletion: { (error:NSError?) -> Void in
                if (error != nil) {
                    self.showAlertResult("Error to enable/disable VisionPositioning:\(error?.description)")
                    sender.setOn(!sender.on, animated:false)
                }
            })
        }
    }
    
}