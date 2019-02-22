//
//  CameraFPVViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 2019/1/15.
//  Copyright © 2019 DJI. All rights reserved.
//

import UIKit
import DJISDK

class CameraFPVViewController: UIViewController {

    @IBOutlet weak var decodeModeSeg: UISegmentedControl!
    @IBOutlet weak var tempSwitch: UISwitch!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var fpvView: UIView!
    
    var adapter: VideoPreviewerAdapter?
    var needToSetMode = false
        
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let camera = fetchCamera()
        camera?.delegate = self
        
        needToSetMode = true
        
        DJIVideoPreviewer.instance()?.start()
        
        adapter = VideoPreviewerAdapter.init()
        adapter?.start()
        
        if camera?.displayName == DJICameraDisplayNameMavic2ZoomCamera ||
            camera?.displayName == DJICameraDisplayNameMavic2ProCamera {
            adapter?.setupFrameControlHandler()
        }
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DJIVideoPreviewer.instance()?.setView(fpvView)
        updateThermalCameraUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Call unSetView during exiting to release the memory.
        DJIVideoPreviewer.instance()?.unSetView()
        
        if adapter != nil {
            adapter?.stop()
            adapter = nil
        }
    }
    
    @IBAction func onSwitchValueChanged(_ sender: UISwitch) {
        guard let camera = fetchCamera() else { return }
        
        let mode: DJICameraThermalMeasurementMode = sender.isOn ? .spotMetering : .disabled
        camera.setThermalMeasurementMode(mode) { [weak self] (error) in
            if error != nil {
                self?.tempSwitch.setOn(false, animated: true)

                let alert = UIAlertController(title: nil, message: String(format: "Failed to set the measurement mode: %@", error?.localizedDescription ?? "unknown"), preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                
                self?.present(alert, animated: true)
            }
        }
        
    }
    
    /**
     *  DJIVideoPreviewer is used to decode the video data and display the decoded frame on the view. DJIVideoPreviewer provides both software
     *  decoding and hardware decoding. When using hardware decoding, for different products, the decoding protocols are different and the hardware decoding is only supported by some products.
     */
    @IBAction func onSegmentControlValueChanged(_ sender: UISegmentedControl) {
        DJIVideoPreviewer.instance()?.enableHardwareDecode = sender.selectedSegmentIndex == 1
    }
    
    fileprivate func updateThermalCameraUI() {
        guard let camera = fetchCamera(),
        camera.isThermalCamera()
        else {
            tempSwitch.setOn(false, animated: false)
            return
        }
        
        camera.getThermalMeasurementMode { [weak self] (mode, error) in
            if error != nil {
                let alert = UIAlertController(title: nil, message: String(format: "Failed to set the measurement mode: %@", error?.localizedDescription ?? "unknown"), preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                
                self?.present(alert, animated: true)
                
            } else {
                let enabled = mode != .disabled
                self?.tempSwitch.setOn(enabled, animated: true)
                
            }
        }
    }
}

/**
 *  DJICamera will send the live stream only when the mode is in DJICameraModeShootPhoto or DJICameraModeRecordVideo. Therefore, in order
 *  to demonstrate the FPV (first person view), we need to switch to mode to one of them.
 */
extension CameraFPVViewController: DJICameraDelegate {
    func camera(_ camera: DJICamera, didUpdate systemState: DJICameraSystemState) {
        if systemState.mode != .recordVideo && systemState.mode != .shootPhoto {
            return
        }
        if needToSetMode == false {
            return
        }
        needToSetMode = false
        camera.setMode(.shootPhoto) { [weak self] (error) in
            if error != nil {
                self?.needToSetMode = true
            }
        }
        
    }
    
    func camera(_ camera: DJICamera, didUpdateTemperatureData temperature: Float) {
        tempLabel.text = String(format: "%f", temperature)
    }
    
}

extension CameraFPVViewController {
    fileprivate func fetchCamera() -> DJICamera? {
        guard let product = DJISDKManager.product() else {
            return nil
        }
        
        if product is DJIAircraft || product is DJIHandheld {
            return product.camera
        }
        return nil
    }
}
