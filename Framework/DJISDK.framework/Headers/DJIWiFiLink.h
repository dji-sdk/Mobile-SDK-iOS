//
//  DJIWiFiLink.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <DJISDK/DJISDK.h>
#import <DJISDK/DJIBaseComponent.h>
#import <DJISDK/DJIAirLinkBaseTypes.h>

NS_ASSUME_NONNULL_BEGIN

@class DJIWiFiLink;

/**
 *
 *  This protocol provides a delegate method to receive the updated WiFi signal
 *  quality.
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
- (void)wifiLink:(DJIWiFiLink *_Nonnull)link didUpdateWiFiSignalQuality:(DJIWiFiSignalQuality)quality;

/**
 *  Interference power of the available channels.
 *  Supported only by Mavic Pro. 
 *
 *  @param link             `DJIWiFiLink` object.
 *  @param interferences    The interference power of available channels.
 */
- (void)wifiLink:(DJIWiFiLink *_Nonnull)link didUpdateChannelInterferencePowers:(NSArray<DJIWiFiChannelInterference *> *)interferences;

@end

/*********************************************************************************/
#pragma mark WiFi Component
/*********************************************************************************/

/**
 *  This class provides methods to change the setting of the product's WiFi. You
 *  can also reboot the WiFi adapter inside product in order to make the new
 *  setting take effect.
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
- (void)getWiFiSSIDWithCompletion:(void (^_Nonnull)(NSString *_Nullable ssid,
                                                    NSError *_Nullable error))block;

/**
 *  Sets the WiFi SSID. The setting will take effect only after the product
 *  reboots.
 *
 *  @param ssid     The WiFi SSID to change to. Must alphanumeric, space and '-'
 *                  characters and must not be more than 30 characters in length.
 *  @param block    Remote execution result error block.
 */
- (void)setWiFiSSID:(NSString *_Nonnull)ssid
     withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the WiFi Password.
 *
 *  @param block Remote execution result error block.
 */
- (void)getWiFiPasswordWithCompletion:(void (^_Nonnull)(NSString *_Nullable password,
                                                        NSError *_Nullable error))block;

/**
 *  Sets the WiFi Password.
 *
 *  @param password The new WiFi password. It must be at least 8 characters and
 *  can only includes alphabetic characters and numbers.
 *  @param block Remote execution result error block.
 */
- (void)setWiFiPassword:(NSString *_Nullable)password
         withCompletion:(DJICompletionBlock)block;


/*********************************************************************************/
#pragma mark Frequency Band Selection
/*********************************************************************************/

/**
 *  YES if the product allows the user to change WiFi frequency bands.
 *  Osmo and Mavic Pro with WiFi connection support this feature.
 */
- (BOOL)isWiFiFrequencyBandEditable;

/**
 *  Sets the WiFi frequency band.
 *  It can be called only if `isWiFiFrequencyBandEditable` returns YES.
 *
 *  @param frequencyBand WiFi frequency band to change to.
 *  @param block Remote execution result error block.
 */
- (void)setWiFiFrequencyBand:(DJIWiFiFrequencyBand)frequencyBand
              withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the current WiFi frequency band.
 *  It can be called only if `isWiFiFrequencyBandEditable` returns YES.
 *
 *  @param block Remote execution result error block.
 */
- (void)getWiFiFrequencyBandWithCompletion:(void (^_Nonnull)(DJIWiFiFrequencyBand frequencyBand,
                                                             NSError *_Nullable error))block;

/*********************************************************************************/
#pragma mark Channels
/*********************************************************************************/
/**
 *  Sets the WiFi channel. `getAvailableChannels` must be used to determine
 *  which channels are possible to set.
 *  When a new channel is set, the WiFi on the product will reboot.
 *  The channel can only be changed when the product is not flying.
 *  Supported only by Mavic Pro.
 *  
 *  @param channelIndex Index of the channel to select.
 *  @param block        The completion block with the returned execution result.
 */
-(void)setChannel:(NSUInteger)channelIndex withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the WiFi channel. Channels 1-13 are in the 2.4 GHz band. Other channels
 *  are in the 5 GHz band.
 *  Supported only by Mavic Pro.
 *
 *  @param block    The completion block with the returned execution result.
 */
-(void)getChannelWithCompletion:(void (^)(NSUInteger channelIndex,
                                          NSError *_Nullable error))block;

/**
 *  Gets the channels available for the current frequency band. When 
 *  `DJIWiFiFrequencyBandDual` is selected, channels for both 2.4GHz and 5GHz
 *  are available.
 *  Supported only by Mavic Pro.
 *
 *  @param block    The completion block with the returned execution result.
 */
-(void)getAvailableChannelsWithCompletion:(void (^)(NSArray<NSNumber *> *_Nullable channels,
                                                    NSError *_Nullable error))block;

/*********************************************************************************/
#pragma mark Data Rate
/*********************************************************************************/
/**
 *  Sets the WiFi data rate (throughput). Higher data rates increase the quality
 *  of video transmission, but can only be used at shorter ranges.
 *
 *  @param rate     Data rate (throughput).
 *  @param block    The completion block with the returned execution result.
 */
-(void)setDataRate:(DJIWiFiDataRate)rate withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the current data rate (throughput).
 *
 *  @param block    The completion block with the returned execution result.
 */
-(void)getDataRateWithCompletion:(void (^)(DJIWiFiDataRate rate,
                                                   NSError *_Nullable error))block;


@end

NS_ASSUME_NONNULL_END
