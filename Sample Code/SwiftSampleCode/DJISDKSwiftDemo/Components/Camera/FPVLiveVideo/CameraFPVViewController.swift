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
    var isSettingMode:Bool = false 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            camera!.delegate = self
        }
        self.isSettingMode = false
        VideoPreviewer.instance().start()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        let pBuffer = UnsafeMutablePointer<UInt8>.alloc(size)
        memcpy(pBuffer, videoBuffer, size)
        VideoPreviewer.instance().dataQueue.push(pBuffer, length: Int32(size))
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
}