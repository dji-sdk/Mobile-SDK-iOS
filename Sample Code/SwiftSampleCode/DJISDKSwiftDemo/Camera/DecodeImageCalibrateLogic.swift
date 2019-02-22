//
//  DecodeImageCalibrateLogic.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 2019/1/15.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation
import DJISDK

class DecodeImageCalibrateLogic: NSObject {
    var cameraName: String? {
        get {
            return _cameraName
        }
        set {
            guard newValue != _cameraName else {
                return
            }
            _cameraName = newValue
            let supported = _cameraName == DJICameraDisplayNameMavic2ZoomCamera || _cameraName == DJICameraDisplayNameMavic2ProCamera
            calibrateNeeded = supported
            calibrateStandAlone = false
        }
    }
    var cameraIndex = 0
    fileprivate var _cameraName: String?
    
    fileprivate var calibrateNeeded = false
    fileprivate var calibrateStandAlone = false
    //data source info
    fileprivate let dataSourceInfo: [String: DJIImageCalibrateFilterDataSource.Type] = [
        DJICameraDisplayNameMavic2ZoomCamera: DJIMavic2ZoomCameraImageCalibrateFilterDataSource.self,
        DJICameraDisplayNameMavic2ProCamera: DJIMavic2ProCameraImageCalibrateFilterDataSource.self,
    ]
    //helper for calibration
    fileprivate var helper: DJIImageCalibrateHelper?
    //calibrate datasource
    fileprivate var dataSource: DJIImageCalibrateFilterDataSource?
    //camera work mode
    fileprivate var workMode: DJICameraMode = .unknown
    
    deinit {
        releaseHelper()
    }
    
    func releaseHelper() {
        dataSource = nil
        helper = nil
    }
    
}

extension DecodeImageCalibrateLogic: DJIImageCalibrateDelegate {
    func shouldCreateHelper() -> Bool {
        return calibrateNeeded
    }
    
    func helperCreated() -> DJIImageCalibrateHelper? {
        if calibrateStandAlone {
            helper = DJIDecodeImageCalibrateHelper.init(shouldCreateCalibrateThread: false, andRenderThread: false)
        } else {
            helper = DJIImageCalibrateHelper.init(shouldCreateCalibrateThread: false, andRenderThread: false)
        }
        if !calibrateNeeded {
            return nil
        }
        return helper
    }
    
    func destroyHelper() {
        releaseHelper()
    }
    
    func calibrateDataSource() -> DJIImageCalibrateFilterDataSource? {
        guard _cameraName != nil else {
            return nil
        }
        
        if let targetClass = dataSourceInfo[_cameraName!],
            dataSource != nil,
            dataSource!.isKind(of: targetClass),
            dataSource!.workMode == workMode.rawValue {
            return dataSource
        } else {
            dataSource = (dataSourceInfo[_cameraName!] ?? DJIImageCalibrateFilterDataSource.self).instance(withWorkMode: workMode.rawValue)
            return dataSource
        }
    }
    
    
}
