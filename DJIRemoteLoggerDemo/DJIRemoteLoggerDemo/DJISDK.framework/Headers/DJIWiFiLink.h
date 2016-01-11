//
//  DJIWiFiLink.h
//  DJISDK
//
//  Created by DJI on 30/11/15.
//  Copyright © 2015 DJI. All rights reserved.
//

#import <DJISDK/DJISDK.h>
#import <DJISDK/DJIBaseComponent.h>

NS_ASSUME_NONNULL_BEGIN


/**
 *  WiFi frequency band
 */
typedef NS_ENUM(uint8_t, DJIWiFiFrequencyBand){
    /**
     *  The WiFi Frequency band is 2.4G
     */
    DJIWiFiFrequencyBand2Dot4G,
    /**
     *  The WiFi Frequency band is 5.8G
     */
    DJIWiFiFrequencyBand5Dot8G,
    /**
     *  The WiFi Frequency is unknown
     */
    DJIWiFiFrequencyBandUnknown = 0xFF,

};

/**
 *  WiFi Signal Quality
 *
 */
typedef NS_ENUM(uint8_t, DJIWiFiSignalQuality) {
    /**
     *  WiFi Signal Quality is good
     */
    DJIWiFiSignalQualityGood = 0,
    /**
     *  WiFi Signal Quality is medium
     *
     */
    DJIWiFiSignalQualityMedium = 1,
    /**
     *  WiFi Signal Quality is bad
     *
     */
    DJIWiFiSignalQualityBad = 2,
    /**
     *  WiFi Signal Quality is Unknown
     */
    DJIWiFiSignalQualityUnknown = 0xFF,
};


@class DJIWiFiLink;
@protocol DJIWiFiLinkDelegate <NSObject>

@optional

/**
 *  Updates WiFi Signal Quality.
 *
 *  @param link DJIWiFiLink object
 *  @param quality WiFi signal quality
 *
 */
- (void)wifiLink:(DJIWiFiLink* _Nonnull)link didUpdatesWiFiSignalQuality:(DJIWiFiSignalQuality)quality;
@end

//-----------------------------------------------------------------
#pragma mark WiFi Component
//-----------------------------------------------------------------
@interface DJIWiFiLink : NSObject

/**
 *  Returns the DJIWiFiLink delegate.
 */
@property (nonatomic, weak) id <DJIWiFiLinkDelegate> delegate;

/**
 *  Returns the WiFi signal quality.
 *
 */
@property (nonatomic, readonly) DJIWiFiSignalQuality wifiSignalQuality;

/**
 *  Reboot WiFi.
 *
 *  @param block Remote execution result error block.
 */
-(void) rebootWiFiWithCompletion:(DJICompletionBlock)block;

//-----------------------------------------------------------------
#pragma mark SSID and Password
//-----------------------------------------------------------------
/**
 *  Gets WiFi SSID.
 *
 *  @param block Remote execution result error block.
 */
-(void) getWiFiSSIDWithCompletion:(void(^)(NSString* ssid, NSError* _Nullable error))block;

/**
 *  Sets WiFi SSID.
 *
 *  @param ssid the WiFi ssid want to change.
 *  @param block Remote execution result error block.
 *
 */
-(void) setWiFiSSID:(NSString *)ssid withCompletion:(DJICompletionBlock)block;

/**
 *  Gets WiFi Password.
 *
 *  @param block Remote execution result error block.
 */
-(void) getWiFiPasswordWithCompletion:(void(^)(NSString* password, NSError* _Nullable error))block;

/**
 *  Sets WiFi Password.
 *
 *  @param password The new WiFi password.
 *  @param block Remote execution result error block.
 */
-(void) setWiFiPassword:(NSString *)password withCompletion:(DJICompletionBlock)block;


//-----------------------------------------------------------------
#pragma mark Frequency Band Selection
//-----------------------------------------------------------------
/**
 *  YES if product allows user to change WiFi frequency bands.
 *  Currently, only OSMO supports this feature.
 */
-(BOOL) isWiFiFrequencyBandSetable;

/**
 *  Sets WiFi frequency band.
 *  It can be called only if isWiFiFrequencyBandSetable returns YES.
 *
 *  @param frequencyBand WiFi frequency band to change to.
 *  @param block Remote execution result error block.
 */
-(void)setWiFiFrequencyBand:(DJIWiFiFrequencyBand)frequencyBand withCompletion:(DJICompletionBlock)block;

/**
 *  Gets current WiFi frequency band.
 *  It can be called only if isWiFiFrequencyBandSetable returns YES.
 *
 */
-(void)getWiFiFrequencyBandWithCompletion:(void (^)(DJIWiFiFrequencyBand frequencyBand, NSError* _Nullable error))block;


@end

NS_ASSUME_NONNULL_END
