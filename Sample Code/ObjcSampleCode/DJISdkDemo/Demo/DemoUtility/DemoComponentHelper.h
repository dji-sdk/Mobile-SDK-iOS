//
//  DemoComponentHelper.h
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJISDK.h>

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

NS_ASSUME_NONNULL_BEGIN

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
+(nullable DJIKeyedValue *)startListeningAndGetValueForChangesOnKey:(DJIKey *)key
                                                       withListener:(id)listener
                                                     andUpdateBlock:(DJIKeyedListenerUpdateBlock)updateBlock;

NS_ASSUME_NONNULL_END

@end
