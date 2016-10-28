//
//  DemoComponentHelper.h
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DJIBaseProduct;
@class DJIAircraft;
@class DJIHandheld;
@class DJICamera;
@class DJIGimbal;
@class DJIFlightController;
@class DJIRemoteController;
@class DJIBattery;
@class DJIAirLink;
@class DJIHandheldController;
@class DJIMobileRemoteController;

@interface DemoComponentHelper : NSObject

+(DJIBaseProduct*) fetchProduct; 
+(DJIAircraft*) fetchAircraft;
+(DJIHandheld*) fetchHandheld; 
+(DJICamera*) fetchCamera;
+(DJIGimbal*) fetchGimbal;
+(DJIFlightController*) fetchFlightController;
+(DJIRemoteController*) fetchRemoteController;
+(DJIBattery*) fetchBattery;
+(DJIAirLink*) fetchAirLink;
+(DJIHandheldController*) fetchHandheldController;
+(DJIMobileRemoteController*) fetchMobileRemoteController;


@end
