//
//  CameraFPVViewController.swift
//  DJISDKSwiftDemo
//
//  Copyright © 2016 DJI. All rights reserved.
//

import DJISDK
import VideoPreviewer

class CameraFPVViewController: DJIBaseViewController, DJICameraDelegate {
    
    @IBOutlet weak var fpvView : UIView!
    @IBOutlet weak var fpvTemView : UIView!
    @IBOutlet weak var fpvTemEnableSwitch : UISwitch!
    @IBOutlet weak var fpvTemperatureData : UILabel!
    
    var isSettingMode:Bool = false
    
    var adapter : VideoPreviewerSDKAdapter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            camera!.delegate = self
            updateThermalCameraUI()
        }
        self.isSettingMode = false
        
        VideoPreviewer.instance().start()
        adapter = VideoPreviewerSDKAdapter(videoPreviewer: VideoPreviewer.instance())
        adapter.start()
    }
    
    func updateThermalCameraUI() {
        let camera: DJICamera? = self.fetchCamera()
        if (camera == nil) {
            return
        }
        let state:Bool = camera!.isThermalImagingCamera()
        fpvTemView.isHidden = !state
        if (state) {
            camera?.getThermalMeasurementMode(completion: { (
                mode:DJICameraThermalMeasurementMode, error:Error?) -> Void in
                if (error == nil) {
                    self.fpvTemEnableSwitch.setOn(mode != DJICameraThermalMeasurementMode.disabled, animated: true)
                } else {
                    self.showAlertResult("Failed to get the Thermal measurement mode status:\(error)")
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        VideoPreviewer.instance().setView(self.fpvView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        VideoPreviewer.instance().unSetView()
        adapter.stop()
    }
    
    @IBAction func onSegmentControlValueChanged(_ sender: UISegmentedControl) {
        let product: DJIBaseProduct? = ConnectedProductManager.sharedInstance.connectedProduct
        if product != nil {
            VideoPreviewer.instance().enableHardwareDecode = (sender.selectedSegmentIndex == 1)
        }
    }
    
    
    func camera(_ camera: DJICamera, didReceiveVideoData videoBuffer: UnsafeMutablePointer<UInt8>, length size: Int){
        VideoPreviewer.instance().push(videoBuffer, length: Int32(size))
    }
    
    func camera(_ camera: DJICamera, didUpdate systemState: DJICameraSystemState) {
        if systemState.mode == DJICameraMode.playback || systemState.mode == DJICameraMode.mediaDownload {
            if !self.isSettingMode {
                self.isSettingMode = true
                camera.setCameraMode(DJICameraMode.shootPhoto, withCompletion: {[weak self](error: Error?) -> Void in
                    if error == nil {
                        self?.isSettingMode = false
                    }
                })
            }
        }
    }
    
    func camera(_ camera: DJICamera, didUpdateTemperatureData temperature: Float) {
        self.fpvTemperatureData.text = temperature.description
    }
    
    @IBAction func onThermalTemperatureDataSwitchValueChanged(_ sender: UISwitch){
        let camera: DJICamera? = self.fetchCamera()
        camera?.setThermalMeasurementMode(
            sender.isOn ? DJICameraThermalMeasurementMode.spotMetering : DJICameraThermalMeasurementMode.disabled,
            withCompletion: { (error:Error?) -> Void in
            if (error != nil) {
                self.showAlertResult("Error to change ThermalMeasurementMode:\(error)")
                sender.setOn(!sender.isOn, animated:false)
            }
        })
    }
}
