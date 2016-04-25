//
//  DJIWiFiLink.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <DJISDK/DJISDK.h>
#import <DJISDK/DJIBaseComponent.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  WiFi frequency band.
 */
typedef NS_ENUM (uint8_t, DJIWiFiFrequencyBand){
    /**
     *  The WiFi Frequency band is 2.4G.
     */
    DJIWiFiFrequencyBand2Dot4G,
    /**
     *  The WiFi Frequency band is 5.8G.
     */
    DJIWiFiFrequencyBand5Dot8G,
    /**
     *  The WiFi Frequency is unknown.
     */
    DJIWiFiFrequencyBandUnknown = 0xFF,
    
};

/**
 *  WiFi Signal Quality - as measuremed by Osmo, Phantom 3 4K and Phantom 3 Standard.
 */
typedef NS_ENUM (uint8_t, DJIWiFiSignalQuality) {
    /**
     *  WiFi Signal Quality is good.
     */
    DJIWiFiSignalQualityGood,
    /**
     *  WiFi Signal Quality is medium. At this level, the video quality will be degraded compared to when the signal quality is good.
     */
    DJIWiFiSignalQualityMedium,
    /**
     *  WiFi Signal Quality is bad. At this level, the video quality will be degraded compared to when the signal quality is medium.
     */
    DJIWiFiSignalQualityBad,
    /**
     *  WiFi Signal Quality is Unknown.
     */
    DJIWiFiSignalQualityUnknown = 0xFF,
};

@class DJIWiFiLink;

/**
 *
 *  This protocol provides a delegate method to receive the updated WiFi signal quality.
 *
 */
@protocol DJIWiFiLinkDelegate <NSObject>

@optional

/**
 *  Updates the WiFi Signal Quality.
 *
 *  @param link `DJIWiFiLink` object.
 *  @param quality WiFi signal quality.
 *
 */
- (void)wifiLink:(DJIWiFiLink *_Nonnull)link didUpdatesWiFiSignalQuality:(DJIWiFiSignalQuality)quality;
@end

/*********************************************************************************/
#pragma mark WiFi Component
/*********************************************************************************/

/**
 *  This class provides methods to change the setting of the product's WiFi. You can also reboot the WiFi adapter inside product in order to make the new setting take effect.
 */
@interface DJIWiFiLink : NSObject

/**
 *  Returns the `DJIWiFiLink` delegate.
 */
@property (nonatomic, weak) id <DJIWiFiLinkDelegate> delegate;

/**
 *  Reboot WiFi.
 *
 *  @param block Remote execution result error block.
 */
- (void)rebootWiFiWithCompletion:(DJICompletionBlock)block;

/*********************************************************************************/
#pragma mark SSID and Password
/*********************************************************************************/

/**
 *  Gets the WiFi SSID.
 *
 *  @param block Remote execution result error block.
 */
- (void)getWiFiSSIDWithCompletion:(void (^_Nonnull)(NSString *_Nullable ssid, NSError *_Nullable error))block;

/**
 *  Sets the `WiFi SSID.
 *
 *  @param ssid the WiFi ssid want to change. It should only include alphabetic characters, numbers, spaces, '-' and should not be more than 30 characters.
 *  @param block Remote execution result error block.
 *
 */
- (void)setWiFiSSID:(NSString *_Nonnull)ssid withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the WiFi Password.
 *
 *  @param block Remote execution result error block.
 */
- (void)getWiFiPasswordWithCompletion:(void (^_Nonnull)(NSString *_Nullable password, NSError *_Nullable error))block;

/**
 *  Sets the WiFi Password.
 *
 *  @param password The new WiFi password. It must be at least 8 characters and can only includes alphabetic characters and numbers.
 *  @param block Remote execution result error block.
 */
- (void)setWiFiPassword:(NSString *_Nullable)password withCompletion:(DJICompletionBlock)block;


/*********************************************************************************/
#pragma mark Frequency Band Selection
/*********************************************************************************/

/**
 *  YES if the product allows the user to change WiFi frequency bands.
 *  Only Osmo supports this feature.
 */
- (BOOL)isWiFiFrequencyBandEditable;

/**
 *  Sets the WiFi frequency band.
 *  It can be called only if `isWiFiFrequencyBandEditable` returns YES.
 *
 *  @param frequencyBand WiFi frequency band to change to.
 *  @param block Remote execution result error block.
 */
- (void)setWiFiFrequencyBand:(DJIWiFiFrequencyBand)frequencyBand withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the current WiFi frequency band.
 *  It can be called only if `isWiFiFrequencyBandEditable` returns YES.
 *
 *  @param block Remote execution result error block.
 */
- (void)getWiFiFrequencyBandWithCompletion:(void (^_Nonnull)(DJIWiFiFrequencyBand frequencyBand, NSError *_Nullable error))block;


@end

NS_ASSUME_NONNULL_END
