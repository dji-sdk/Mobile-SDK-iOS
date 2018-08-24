//
//  DJIGimbal+CapabilityCheck.m
//  DJISdkDemo
//
//  Copyright © 2016 DJI. All rights reserved.
//

#import "DJIGimbal+CapabilityCheck.h"
#import <DJISDK/DJISDK.h>

@implementation DJIGimbal (CapabilityCheck)

-(DJIParamCapability *) getCapabilityWithKey:(NSString *)key {
    if (self.capabilities && self.capabilities[key]) {
        DJIParamCapability *capability = (DJIParamCapability *)self.capabilities[key];
        return capability;
    }
    return nil;
}

-(BOOL) isFeatureSupported:(NSString *)key {
    DJIParamCapability *capability = [self getCapabilityWithKey:key];
    if (capability) {
        return capability.isSupported;
    }
    return NO;
}

-(NSNumber *) getParamMin:(NSString *)key {
    if ([self isFeatureSupported:key]) {
        DJIParamCapability *capability = [self getCapabilityWithKey:key];
        if ([capability isKindOfClass:[DJIParamCapabilityMinMax class]]) {
            DJIParamCapabilityMinMax *capabilityMinMax = (DJIParamCapabilityMinMax *)capability;
            return capabilityMinMax.min;
        }
    }
    return nil;
}

-(NSNumber *) getParamMax:(NSString *)key {
    if ([self isFeatureSupported:key]) {
        DJIParamCapability *capability = [self getCapabilityWithKey:key];
        if ([capability isKindOfClass:[DJIParamCapabilityMinMax class]]) {
            DJIParamCapabilityMinMax *capabilityMinMax = (DJIParamCapabilityMinMax *)capability;
            return capabilityMinMax.max;
        }
    }
    return nil;
}

@end
