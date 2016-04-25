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
@class DJIAuxLink;

/**
 *
 *  The class contains different wireless links between the aircraft, the remote controller and the mobile device. To determine whether the current device supports WiFi and Lightbridge features, call `isWifiLinkSupported` or `isLBAirLinkSupported`.
 *
 *   With the Osmo the mobile device communicates directly via wifi.
 */

@interface DJIAirLink : DJIBaseComponent

/**
 *  YES if WiFi Air Link is supported.
 *
 */
@property (nonatomic, readonly) BOOL isWifiLinkSupported;

/**
 *  YES if Lightbridge Air Link is supported.
 *
 */
@property (nonatomic, readonly) BOOL isLBAirLinkSupported;

/**
 *  YES if the Auxiliary Control Air Link is supported. The Auxiliary Control link is the wireless link between the remote controller and aircraft on products that have a WiFi Video link. Phantom 3 Standard, and Phantom 3 4K have an auxiliary control link.
 *
 */
@property (nonatomic, readonly) BOOL isAuxLinkSupported;

/**
 *  Returns the WiFi Air Link if it is available.
 *
 */
@property (nonatomic, strong) DJIWiFiLink *_Nullable wifiLink;

/**
 *  Returns the Lightbridge Air Link if it is available.
 *
 */
@property (nonatomic, strong) DJILBAirLink *_Nullable lbAirLink;

/**
 *  Returns the Auxiliary Control Air Link if it is available.
 */
@property (nonatomic, strong) DJIAuxLink *_Nullable auxLink;

@end
