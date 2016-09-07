//
//  DJIGimbal+CapabilityCheck.swift
//  DJISDKSwiftDemo
//
//  Copyright © 2016 DJI. All rights reserved.
//

import DJISDK
extension DJIGimbal {
    func getCapabilityWithKey(key: String) -> DJIParamCapability? {
        if (self.gimbalCapability[key] != nil) {
            let capability: DJIParamCapability = (self.gimbalCapability[key] as! DJIParamCapability)
            return capability
        }
        return nil
    }
    
    func isFeatureSupported(key: String) -> Bool {
        let capability: DJIParamCapability = self.getCapabilityWithKey(key)!
        return capability.isSupported
    }
    
    func getParamMin(key: String) -> Int? {
        if self.isFeatureSupported(key) {
            let capability: DJIParamCapability = self.getCapabilityWithKey(key)!
            if (capability is DJIParamCapabilityMinMax) {
                let capabilityMinMax: DJIParamCapabilityMinMax = (capability as! DJIParamCapabilityMinMax)
                return capabilityMinMax.min.integerValue
            }
        }
        return nil
    }
    
    func getParamMax(key: String) -> Int? {
        if self.isFeatureSupported(key) {
            let capability: DJIParamCapability = self.getCapabilityWithKey(key)!
            if (capability is DJIParamCapabilityMinMax) {
                let capabilityMinMax: DJIParamCapabilityMinMax = (capability as! DJIParamCapabilityMinMax)
                return capabilityMinMax.max.integerValue
            }
        }
        return nil
    }
}