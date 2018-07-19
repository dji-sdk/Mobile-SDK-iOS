//
//  DemoXT2Helper.m
//  DJISdkDemo
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import "DemoXT2Helper.h"

@implementation DemoXT2Helper

// Returns the XT2 vision camera instance. Returns nil if XT2 is not attached.
+ (nullable DJICamera *)connectedXT2VisionCamera {
    if ([DJISDKManager product] && [[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        DJIAircraft *aircraft = (DJIAircraft *)[DJISDKManager product];
        for (DJICamera *camera in [aircraft cameras]) {
            if ([camera.displayName isEqualToString:DJICameraDisplayNameXT2Visual]) {
                return camera;
            }
        }
    }
    return nil;
}

// Returns the thermal camera instance.
+ (nullable DJICamera *)connectedThermalCamera {
    if ([DJISDKManager product] && [[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        DJIAircraft *aircraft = (DJIAircraft *)[DJISDKManager product];
        for (DJICamera *camera in [aircraft cameras]) {
            if ([camera isThermalCamera]) {
                return camera;
            }
        }
    }
    return nil;
}

+ (BOOL)isXT2Camera {
    if (![self connectedThermalCamera]) {
        return NO;
    }
    return [self connectedThermalCamera].displayName == DJICameraDisplayNameXT2Thermal;
}

// These keys will act on the thermal (IR) camera.
+ (nullable DJICameraKey *)thermalCameraKeyWithParam:(nonnull NSString *)param {
    if (![self connectedThermalCamera]) {
        return nil;
    }
    return [DJICameraKey keyWithIndex:[self connectedThermalCamera].index andParam:param];
}

+ (DJICameraDisplayMode)videoModeForThermalCamera {
    return [[DJISDKManager keyManager] getValueForKey:[self thermalCameraKeyWithParam:DJICameraParamDisplayMode]].unsignedIntegerValue;
}

+ (nullable DJICamera *)cameraAtComponentIndex:(NSInteger)componentIndex {
    if ([DJISDKManager product] && [[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        DJIAircraft *aircraft = (DJIAircraft *)[DJISDKManager product];
        for (DJICamera *camera in [aircraft cameras]) {
            if (camera.index == componentIndex) {
                return camera;
            }
        }
    }

    return nil;
}
@end
