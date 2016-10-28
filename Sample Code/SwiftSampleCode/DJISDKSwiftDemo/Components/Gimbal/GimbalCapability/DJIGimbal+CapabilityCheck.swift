//
//  DJIGimbal+CapabilityCheck.swift
//  DJISDKSwiftDemo
//
//  Copyright © 2016 DJI. All rights reserved.
//

import DJISDK
extension DJIGimbal {
    func getCapabilityWithKey(_ key: String) -> DJIParamCapability? {
        if (self.gimbalCapability[key] != nil) {
            let capability: DJIParamCapability = (self.gimbalCapability[key] as! DJIParamCapability)
            return capability
        }
        return nil
    }
    
    func isFeatureSupported(_ key: String) -> Bool {
        let capability: DJIParamCapability = self.getCapabilityWithKey(key)!
        return capability.isSupported
    }
    
    func getParamMin(_ key: String) -> Int? {
        if self.isFeatureSupported(key) {
            let capability: DJIParamCapability = self.getCapabilityWithKey(key)!
            if (capability is DJIParamCapabilityMinMax) {
                let capabilityMinMax: DJIParamCapabilityMinMax = (capability as! DJIParamCapabilityMinMax)
                return capabilityMinMax.min.intValue
            }
        }
        return nil
    }
    
    func getParamMax(_ key: String) -> Int? {
        if self.isFeatureSupported(key) {
            let capability: DJIParamCapability = self.getCapabilityWithKey(key)!
            if (capability is DJIParamCapabilityMinMax) {
                let capabilityMinMax: DJIParamCapabilityMinMax = (capability as! DJIParamCapabilityMinMax)
                return capabilityMinMax.max.intValue
            }
        }
        return nil
    }
}
