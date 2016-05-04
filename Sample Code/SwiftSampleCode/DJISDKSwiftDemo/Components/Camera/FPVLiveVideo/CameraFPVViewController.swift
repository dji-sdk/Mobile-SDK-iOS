//
//  CameraFPVViewController.m
//  DJISdkDemo
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            camera!.delegate = self
            updateThermalCameraUI()
        }
        self.isSettingMode = false
    }
    
    func updateThermalCameraUI() {
        let camera: DJICamera? = self.fetchCamera()
        if (camera == nil) {
            return
        }
        let state:Bool = camera!.isThermalImagingCamera()
        fpvTemView.hidden = !state
        if (state) {
            camera?.getThermalTemperatureDataEnabledWithCompletion({ (
                state:Bool, error:NSError?) -> Void in
                if (error == nil) {
                    self.fpvTemEnableSwitch.setOn(state, animated: true)
                } else {
                    self.showAlertResult("Failed to get the Thermal Temperature Data enabled status:\(error?.description)")
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        VideoPreviewer.instance().start()
        VideoPreviewer.instance().setView(self.fpvView)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        VideoPreviewer.instance().unSetView()
    }
    
    @IBAction func onSegmentControlValueChanged(sender: UISegmentedControl) {
        let product: DJIBaseProduct? = ConnectedProductManager.sharedInstance.connectedProduct
        if product != nil {
            if sender.selectedSegmentIndex == 0 {
                VideoPreviewer.instance().setDecoderWithProduct(product, andDecoderType:VideoPreviewerDecoderType.SoftwareDecoder)
            }
            else {
                VideoPreviewer.instance().setDecoderWithProduct(product, andDecoderType:VideoPreviewerDecoderType.HardwareDecoder)
            }
        }
    }
    
    
    func camera(camera: DJICamera, didReceiveVideoData videoBuffer: UnsafeMutablePointer<UInt8>, length size: Int){
        VideoPreviewer.instance().push(videoBuffer, length: Int32(size))
    }
    
    func camera(camera: DJICamera, didUpdateSystemState systemState: DJICameraSystemState) {
        if systemState.mode == DJICameraMode.Playback || systemState.mode == DJICameraMode.MediaDownload {
            if !self.isSettingMode {
                self.isSettingMode = true
                camera.setCameraMode(DJICameraMode.ShootPhoto, withCompletion: {[weak self](error: NSError?) -> Void in
                    if error == nil {
                        self?.isSettingMode = false
                    }
                })
            }
        }
    }
    
    func camera(camera: DJICamera, didUpdateTemperatureData temperature: Float) {
        self.fpvTemperatureData.text = temperature.description
    }
    
    @IBAction func onThermalTemperatureDataSwitchValueChanged(sender: UISwitch){
        let camera: DJICamera? = self.fetchCamera()
        camera?.setThermalTemperatureDataEnabled(sender.on, withCompletion: { (error:NSError?) -> Void in
            if (error != nil) {
                self.showAlertResult("Error to enable/disable ThermalTemperatureData:\(error?.description)")
                sender.setOn(!sender.on, animated:false)
            }
        })
    }
}