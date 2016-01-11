//
//  DJIAirLink.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIBaseComponent.h>

@class DJIWiFiLink;
@class DJILBAirLink;

/**
 *  This class contains DJI WiFi and DJI Lightbridge components, you can check if the current device supports WiFi and
 *  Lightbridge features by accessing the following two BOOL variables.
 */
@interface DJIAirLink : DJIBaseComponent

/**
 *  YES if WiFi Link is supported
 *
 */
@property (nonatomic, readonly) BOOL isWifiLinkSupported;

/**
 *  YES if LB Air Link is supported
 *
 */
@property (nonatomic, readonly) BOOL isLBAirLinkSupported;

/**
 *  Returns WiFiLink if it's available
 *
 */
@property (nonatomic, strong) DJIWiFiLink *wifiLink;

/**
 *  Returns Lightbridge Link if it's available
 *
 */
@property (nonatomic, strong) DJILBAirLink *lbAirLink;

@end
