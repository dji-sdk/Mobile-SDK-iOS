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
 *  The class contains different wireless links between the aircraft, the remote controller and the mobile device. A product may only supports some of the wireless links within DJIAirLink. Please check the query method (e.g. isWiFiLinkSupported) before accessing a wireless link.
 */
@interface DJIAirLink : DJIBaseComponent

/**
 *  YES if WiFi Link is supported
 *
 */
@property (nonatomic, readonly) BOOL isWifiLinkSupported;

/**
 *  YES if Lightbridge Link is supported
 *
 */
@property (nonatomic, readonly) BOOL isLBAirLinkSupported;

/**
 *  YES if the auxiliary control link is supported. The auxiliary control link is the wireless link between remote controller and aircraft on products that have a WiFi Video link. Phantom 3 Standard, and Phantom 3 4K have auxiliary control link.
 *
 */
@property (nonatomic, readonly) BOOL isAuxLinkSupported;

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

/**
 *  Returns the auxiliary control link if it's available
 */
@property (nonatomic, strong) DJIAuxLink *auxLink;

@end
