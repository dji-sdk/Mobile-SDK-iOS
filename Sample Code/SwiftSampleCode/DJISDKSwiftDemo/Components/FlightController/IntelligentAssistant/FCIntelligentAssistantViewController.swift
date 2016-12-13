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
    
    func updateSwitchState(_ fa:DJIIntelligentFlightAssistant?){
        if (fa != nil) {
            fa?.getCollisionAvoidanceEnabled(completion: { (state:Bool, error: Error?) -> Void in
                if (error != nil) {
                    self.showAlertResult("Error to get collision avoidance:\(error?.localizedDescription)")
                }else {
                    self.collisionAvoidanceEnable.setOn(state, animated:false)
                }
                
                fa?.getVisionPositioningEnabled(completion: { (state:Bool, error:Error?) -> Void in
                    if (error != nil) {
                        self.showAlertResult("Error to get vision positioning:\(error?.localizedDescription)")
                    }else {
                        self.visionPositioningEnable.setOn(state, animated:false)
                    }
                })
            })
        }
    }
    
    func intelligentFlightAssistant(_ assistant: DJIIntelligentFlightAssistant, didUpdate state: DJIVisionDetectionState) {
        
        self.isSensorWorking.text = state.isSensorWorking.description
        self.systemWarning.text = stringWithSystemWarnings(state.systemWarning)
        
        let firstSector : DJIVisionDetectionSector? = state.detectionSectors?[0]
        self.l2Distance.text = firstSector?.obstacleDistanceInMeters.description
        self.l2WarningLevel.text = firstSector?.warningLevel.rawValue.description
        
        self.l1Distance.text = (state.detectionSectors?[1])?.obstacleDistanceInMeters.description
        self.l1WarningLevel.text = (state.detectionSectors?[1])?.warningLevel.rawValue.description

        self.r1Distance.text = (state.detectionSectors?[2])?.obstacleDistanceInMeters.description
        self.r1WarningLevel.text = (state.detectionSectors?[2])?.warningLevel.rawValue.description
        
        self.r2Distance.text = (state.detectionSectors?[3])?.obstacleDistanceInMeters.description
        self.r2WarningLevel.text = (state.detectionSectors?[3])?.warningLevel.rawValue.description
    }
    
    func stringWithSystemWarnings(_ status: DJIVisionSystemWarning) -> String {
        if status == DJIVisionSystemWarning.unknown {
            return "Unknown"
        }
        else if status == DJIVisionSystemWarning.invalid {
            return "Invalid"
        }
        else if status == DJIVisionSystemWarning.safe {
            return "Safe"
        }
        else if status == DJIVisionSystemWarning.dangerous {
            return "Dangerous"
        }
        
        return "SDK Wrong"
        
    }
    
    @IBAction func onCollisionAvoidanceSwitchValueChanged(_ sender: UISwitch){
        let fc: DJIFlightController? = self.fetchFlightController()
        let fa = fc?.intelligentFlightAssistant
        if (fa != nil) {
          fa?.setCollisionAvoidanceEnabled(sender.isOn, withCompletion: { (error:Error?) -> Void in
            if (error != nil) {
                self.showAlertResult("Error to enable/disable CollisionAvoidance:\(error)")
                sender.setOn(!sender.isOn, animated:false)
            }
          })
        }
    }
    
    @IBAction func onVisionPositioningSwitchValueChanged(_ sender: UISwitch){
        let fc: DJIFlightController? = self.fetchFlightController()
        let fa = fc?.intelligentFlightAssistant
        if (fa != nil) {
            fa?.setVisionPositioningEnabled(sender.isOn, withCompletion: { (error:Error?) -> Void in
                if (error != nil) {
                    self.showAlertResult("Error to enable/disable VisionPositioning:\(error)")
                    sender.setOn(!sender.isOn, animated:false)
                }
            })
        }
    }
    
}
