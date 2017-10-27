//
//  DemoComponentHelper.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  It is recommended that user should not cache any instances of DJIBaseProduct (including DJIAircraft and DJIHandheld) and any instances
 *  of DJIBaseComponent (e.g. DJICamera). Therefore, a set of helper methods is provided to access the product and components.
 */
#import <DJISDK/DJISDK.h>
#import "DemoComponentHelper.h"

@implementation DemoComponentHelper

+(DJIBaseProduct*) fetchProduct {
    return [DJISDKManager product]; 
}

+(nullable DJIAircraft*) fetchAircraft {
    if (![DJISDKManager product]) {
        return nil;
    }
    
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft*)[DJISDKManager product]);
    }
    
    return nil;
}

+(nullable DJIHandheld *)fetchHandheld {
    if (![DJISDKManager product]) {
        return nil;
    }
    
    if ([[DJISDKManager product] isKindOfClass:[DJIHandheld class]]) {
        return ((DJIHandheld*)[DJISDKManager product]);
    }
    
    return nil;
}

+(nullable DJICamera*) fetchCamera {
    if (![DJISDKManager product]) {
        return nil;
    }
    
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft*)[DJISDKManager product]).camera;
    }
    else if ([[DJISDKManager product] isKindOfClass:[DJIHandheld class]]) {
        return ((DJIHandheld*)[DJISDKManager product]).camera;
    }
    return nil;
}

+(nullable DJIGimbal*) fetchGimbal {
    if (![DJISDKManager product]) {
        return nil;
    }
    
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft*)[DJISDKManager product]).gimbal;
    }
    else if ([[DJISDKManager product] isKindOfClass:[DJIHandheld class]]) {
        return ((DJIHandheld*)[DJISDKManager product]).gimbal;
    }
    
    return nil;
}

+(nullable DJIFlightController*) fetchFlightController {
    if (![DJISDKManager product]) {
        return nil;
    }
    
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft*)[DJISDKManager product]).flightController;
    }
    
    return nil;
}

+(nullable DJIRemoteController*) fetchRemoteController {
    if (![DJISDKManager product]) {
        return nil;
    }
    
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft*)[DJISDKManager product]).remoteController;
    }
    
    return nil;
}

+(nullable DJIBattery*) fetchBattery {
    if (![DJISDKManager product]) {
        return nil;
    }
    
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft*)[DJISDKManager product]).battery;
    }
    else if ([[DJISDKManager product] isKindOfClass:[DJIHandheld class]]) {
        return ((DJIHandheld*)[DJISDKManager product]).battery;
    }
    
    return nil;
}
+(nullable DJIAirLink*) fetchAirLink {
    if (![DJISDKManager product]) {
        return nil;
    }
    
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft*)[DJISDKManager product]).airLink;
    }
    else if ([[DJISDKManager product] isKindOfClass:[DJIHandheld class]]) {
        return ((DJIHandheld*)[DJISDKManager product]).airLink;
    }
    
    return nil;
}

+(nullable DJIHandheldController*) fetchHandheldController
{
    if (![DJISDKManager product]) {
        return nil;
    }
    
    if ([[DJISDKManager product] isKindOfClass:[DJIHandheld class]]) {
        return ((DJIHandheld*)[DJISDKManager product]).handheldController;
    }
    
    return nil;
}

+(nullable DJIMobileRemoteController *)fetchMobileRemoteController {
    if (![DJISDKManager product]) {
        return nil;
    }

    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft*)[DJISDKManager product]).mobileRemoteController;
    }

    return nil;
}

+(nullable DJIKeyedValue *)startListeningAndGetValueForChangesOnKey:(DJIKey *)key
                                              withListener:(id)listener
                                            andUpdateBlock:(DJIKeyedListenerUpdateBlock)updateBlock {
    [[DJISDKManager keyManager] startListeningForChangesOnKey:key withListener:listener andUpdateBlock:updateBlock];
    return [[DJISDKManager keyManager] getValueForKey:key];
}

@end
