//
//  DJIAirLinkBaseTypes.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#ifndef DJIAirLinkBaseTypes_h
#define DJIAirLinkBaseTypes_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Define the air link maximum supported channel count.
 */
#define DJI_LBAIRLINK_SUPPORTED_CHANNEL_COUNT (8)

/*********************************************************************************/
#pragma mark - WiFiLink
/*********************************************************************************/

/**
 *  WiFi frequency band.
 */
typedef NS_ENUM (uint8_t, DJIWiFiFrequencyBand){
    /**
     *  The WiFi Frequency band is 2.4 GHz.
     */
    DJIWiFiFrequencyBand2Dot4G,
    /**
     *  The WiFi Frequency band is 5 GHz.
     */
    DJIWiFiFrequencyBand5G,
    /**
     *  Dual frequency band mode. The WiFi frequency band can be either 2.4 GHz
     *  or 5 GHz.
     */
    DJIWiFiFrequencyBandDual,
    /**
     *  The WiFi Frequency is unknown.
     */
    DJIWiFiFrequencyBandUnknown = 0xFF,
    
};

/**
 *  WiFi Signal Quality - as measuremed by Osmo, Phantom 3 4K and Phantom 3
 *  Standard.
 */
typedef NS_ENUM (uint8_t, DJIWiFiSignalQuality) {
    /**
     *  WiFi Signal Quality is good.
     */
    DJIWiFiSignalQualityGood,
    /**
     *  WiFi Signal Quality is medium. At this level, the video quality will be
     *  degraded compared to when the signal quality is good.
     */
    DJIWiFiSignalQualityMedium,
    /**
     *  WiFi Signal Quality is bad. At this level, the video quality will be
     *  degraded compared to when the signal quality is medium.
     */
    DJIWiFiSignalQualityBad,
    /**
     *  WiFi Signal Quality is Unknown.
     */
    DJIWiFiSignalQualityUnknown = 0xFF,
};

/**
 *  WiFi data rate. Lower rates are used for longer ranges, but will have lower
 *  video quality.
 */
typedef NS_ENUM (uint8_t, DJIWiFiDataRate) {
    /**
     *  1 Mbps.
     */
    DJIWiFiDataRate1Mbps,
    /**
     *  2 Mbps.
     */
    DJIWiFiDataRate2Mbps,
    /**
     *  4 Mbps.
     */
    DJIWiFiDataRate4Mbps,
    /**
     *  Unknown.
     */
    DJIWiFiDataRateUnknown = 0xFF,
};

/**
 *  The interference power of a WiFi channel.
 */
@interface DJIWiFiChannelInterference : NSObject

/**
 *  The interference power with range from [-60, -100] dBm. A smaller, more
 *  negative value represents less interference and better communication quality.
 */
@property (nonatomic, readonly) NSInteger power;

/**
 *  The channel index.
 */
@property (nonatomic, readonly) NSUInteger channel;

/**
 *  The frequency band that the channel belongs to.
 */
@property (nonatomic, readonly) DJIWiFiFrequencyBand band;

@end

/*********************************************************************************/
#pragma mark - LBAirLink
/*********************************************************************************/

/**
 *  Define the air link maximum supported channel count.
 */
#define DJI_LBAIRLINK_SUPPORTED_CHANNEL_COUNT (8)

/*********************************************************************************/
#pragma mark - Data Struct
/*********************************************************************************/

/**
 *  Downlink channel selection mode (manual or automatic) for the wireless link.
 */
typedef NS_ENUM (uint8_t, DJILBAirLinkChannelSelectionMode) {
    /**
     *  Air link will automatically select the best physical channel based on
     *  the signal environment.
     */
    DJILBAirLinkChannelSelectionModeAuto,
    /**
     *  Manually select the physical channel.
     */
    DJILBAirLinkChannelSelectionModeManual,
    /**
     *  Unknown physical channel selection mode.
     */
    DJILBAirLinkChannelSelectionModeUnknown,
};

/**
 *  OSD data units.
 */
typedef NS_ENUM (uint8_t, DJILBAirLinkOSDUnits) {
    /**
     *  Imperial
     */
    DJILBAirLinkOSDUnitsImperial,
    /**
     *  Metric
     */
    DJILBAirLinkOSDUnitsMetric,
    /**
     *  Unknown
     */
    DJILBAirLinkOSDUnitsUnknown,
};

/**
 *  Remote Controller port to which to send secondary video (in addition to USB
 *  video sent to the Mobile Device).
 */
typedef NS_ENUM (uint8_t, DJILBAirLinkSecondaryVideoOutputPort) {
    /**
     *  HDMI port
     */
    DJILBAirLinkSecondaryVideoOutputPortHDMI,
    /**
     *  SDI port
     */
    DJILBAirLinkSecondaryVideoOutputPortSDI,
    /**
     *  Unknown
     */
    DJILBAirLinkSecondaryVideoOutputPortUnknown,
};


/**
 *  Defines the combination of video sources to form the secondary output video.
 *  The secondary output can display video streams from one or two input sources. 
 *  When the encode mode is single:
        * Source 1 represents video from one of the LB input ports (HDMI or AV).
        * Source 2 represents video from EXT input port (HD Gimbal Camera). 
 *  When the encode mode is dual: 
        * Source 1 represents video from HDMI input port. 
        * Source 2 represents video from AV input port.
 */
typedef NS_ENUM (uint8_t, DJILBAirLinkPIPDisplayMode) {
    /**
     *  Displays video from Source 1 only.
     *  When the current encode mode is single, the secondary output will 
     *  display video from HDMI or AV input.
     *  When the current encode mode is dual, the secondary output will display
     *  video from HDMI input.
     */
    DJILBAirLinkPIPDisplayModeSource1Only,
    /**
     *  Displays video from Source 2 only.
     *  When the current encode mode is single, the secondary output will
     *  display video from HD Gimbal camera.
     *  When the current encode mode is dual, the secondary output will display
     *  video from HDMI input.
     */
    DJILBAirLinkPIPDisplayModeSource2Only,
    /**
     *  Displays the video from Source 1 as the main subject, and the video from
     *  Source 2 in a mini window (Picture in Picture, or PIP).
     */
    DJILBAirLinkPIPDisplayModePIPSource1Main,
    /**
     *  Displays the video from Source 2 as the main subject, and the video from
     *  Source 1 in a mini window (Picture in Picture, or PIP).
     */
    DJILBAirLinkPIPDisplayModePIPSource2Main,
    /**
     *  Unknown output mode.
     */
    DJILBAirLinkPIPDisplayModeUnknown,
};

/**
 *  Secondary output video resolution and frame rate.
 */
typedef NS_ENUM (uint8_t, DJILBAirLinkSecondaryVideoFormat) {
    /**
     *  1080I
     */
    DJILBAirLinkSecondaryVideoFormat1080I60FPS,
    DJILBAirLinkSecondaryVideoFormat1080I50FPS,
    /**
     *  1080P
     */
    DJILBAirLinkSecondaryVideoFormat1080P60FPS,
    DJILBAirLinkSecondaryVideoFormat1080P50FPS,
    DJILBAirLinkSecondaryVideoFormat1080P30FPS,
    DJILBAirLinkSecondaryVideoFormat1080P25FPS,
    DJILBAirLinkSecondaryVideoFormat1080P24FPS,
    /**
     *  720P
     */
    DJILBAirLinkSecondaryVideoFormat720P60FPS,
    DJILBAirLinkSecondaryVideoFormat720P50FPS,
    DJILBAirLinkSecondaryVideoFormat720P30FPS,
    DJILBAirLinkSecondaryVideoFormat720P25FPS,
    /**
     *  Unknown
     */
    DJILBAirLinkSecondaryVideoFormatUnknown,
};

/**
 *  PIP (Picture In Picture) position on the screen reltaive to the main subject
 *  video.
 */
typedef NS_ENUM (uint8_t, DJILBAirLinkPIPPosition) {
    /**
     *  PIP is on the screen's top left.
     */
    DJILBAirLinkPIPPositionTopLeft,
    /**
     *  PIP is on the screen's top right.
     */
    DJILBAirLinkPIPPositionTopRight,
    /**
     *  PIP is on the screen's bottom left.
     */
    DJILBAirLinkPIPPositionBottomLeft,
    /**
     *  PIP is on the screen's bottom right.
     */
    DJILBAirLinkPIPPositionBottomRight,
    /**
     *  Unknown PIP position.
     */
    DJILBAirLinkPIPPositionUnknown,
};

/**
 *  FPV(First-person view) Video can prioritize either quality or latency.
 */
typedef NS_ENUM (uint8_t, DJILBAirLinkFPVVideoQualityLatency) {
    /**
     *  High quality priority.
     */
    DJILBAirLinkFPVVideoQualityLatencyHighQuality,
    /**
     *  Low latency priority.
     */
    DJILBAirLinkFPVVideoQualityLatencyLowLatency,
    /**
     *  Unknown transmission mode.
     */
    DJILBAirLinkFPVVideoQualityLatencyUnknown,
};

/**
 *  Wireless downlink data rate. Lower rates are used for longer ranges, but
 *  will have lower video quality.
 */
typedef NS_ENUM (uint8_t, DJILBAirLinkDataRate) {
    /**
     *  4 Mbps (Potential range up to 3 km)
     */
    DJILBAirLinkDataRate4Mbps,
    /**
     *  6 Mbps (Potential range up to 2 km)
     */
    DJILBAirLinkDataRate6Mbps,
    /**
     *  8 Mbps (Potential range up to 1.5 km)
     */
    DJILBAirLinkDataRate8Mbps,
    /**
     *  10 Mbps (Potential range up to 0.7 km)
     */
    DJILBAirLinkDataRate10Mbps,
    /**
     *  Unknown
     */
    DJILBAirLinkDataRateUnknown = 0xFF
};

/**
 *  RSSI (Received Signal Strength Indicator) in dBm
 *
 */
typedef struct
{
    /**
     *  RSSI with range [-100, -60] dBm
     *
     */
    int8_t rssi[DJI_LBAIRLINK_SUPPORTED_CHANNEL_COUNT];
} DJILBAirLinkAllChannelSignalStrengths;

/**
 *  The video source for the delegate method
 *  `- (void)lbAirLink:(DJILBAirLink *_Nonnull)lbAirLink didReceiveVideoData:(NSData *)data`
 *  in `DJILBAirLinkDelegate` and `DJICameraDelegate`.
 */
typedef NS_ENUM (uint8_t, DJIVideoDataChannel) {
    /**
     *  Video from AV or HDMI is received by the delegate method.
     *  It can only be set when the encode mode is `DJILBAirLinkEncodeModeSingle`
     *  and the FPV video bandwidth percent is non-zero.
     *  When the encode mode is `DJILBAirLinkEncodeModeSingle` and the FPV video
     *  bandwidth percent is 100%, the video data channel will be set to
     *  `DJIVideoDataChannelFPVCamera` automatically.
     */
    DJIVideoDataChannelFPVCamera,
    /**
     *  Video from HD Gimbal is received by the delegate method.
     *  It can only be set when the encode mode is `DJILBAirLinkEncodeModeSingle`
     *  and the FPV video bandwidth percent is not 100%.
     *  When the encode mode is `DJILBAirLinkEncodeModeSingle` and the FPV video
     *  bandwidth percent is 0%, the video data channel will be set to 
     *  `DJIVideoDataChannelHDGimbal` automatically.
     */
    DJIVideoDataChannelHDGimbal,
    /**
     *  Video from HDMI is received by the delegate method.
     *  It can only be set when the encode mode is `DJILBAirLinkEncodeModeDual`
     *  and the dual encode mode percent is not 0%.
     *  When the encode mode is `DJILBAirLinkEncodeModeDual` and the dual encode
     *  mode percent is 100%, the video data channel will be set to
     *  `DJIVideoDataChannelHDMI` automatically.
     */
    DJIVideoDataChannelHDMI,
    /**
     *  Video from AV is received by the delegate method.
     *  It can only be set when the encode mode is `DJILBAirLinkEncodeModeDual`
     *  and the dual encode mode percent is not 100%.
     *  When the encode mode is `DJILBAirLinkEncodeModeDual` and the dual encode
     *  mode percent is 0%, the video data channel will be set to
     *  `DJIVideoDataChannelAV` automatically.
     */
    DJIVideoDataChannelAV,
    /**
     *  Unknown
     */
    DJIVideoDataChannelUnknown = 0xFF
};

/**
 *  Lightbridge 2 encode mode.
 */
typedef NS_ENUM (uint8_t, DJILBAirLinkEncodeMode) {
    /**
     *  Single encode mode. Lightbridge 2 will only encode the video input from
     *  either the AV port or the HDMI port.
     */
    DJILBAirLinkEncodeModeSingle,
    /**
     *  Dual encode mode. Lightbridge 2 will encode the video input from both
     *  the AV port and the HDMI port.
     */
    DJILBAirLinkEncodeModeDual,
    /**
     *  Unknown
     */
    DJILBAirLinkEncodeModeUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark - OcuSyncLink
/*********************************************************************************/
/**
 *  Downlink channel selection mode (manual or automatic) for the wireless
 *  OcuSync Link.
 */
typedef NS_ENUM (uint8_t, DJIOcuSyncChannelSelectionMode) {
    /**
     *  OcuSync will automatically select the best channel number and bandwidth
     *  adapting to the signal environment.
     */
    DJIOcuSyncChannelSelectionModeAuto,
    /**
     *  Both channel number and bandwidth can be selected manually.
     */
    DJIOcuSyncChannelSelectionModeManual,
    /**
     *  Unknown physical channel selection mode.
     */
    DJIOcuSyncChannelSelectionModeUnknown = 0xFF
};

/**
 *  The channel bandwidth for the OcuSync downlink (from the aircraft to the
 *  remote controller). Setting a smaller bandwidth will reduce the data rate,
 *  but make the connection more robust.
 *  Only supported by Mavic Pro.
 */
typedef NS_ENUM (uint8_t, DJIOcuSyncBandwidth) {
    /**
     *  The frequency band of the OcuSync link is 20 MHz (up to 46 Mbps).
     */
    DJIOcuSyncBandwidth20MHz,
    /**
     *  The frequency band of the OcuSync link is 10 MHz (up to 23 Mbps).
     */
    DJIOcuSyncBandwidth10MHz,
    /**
     *  Unknown frequency band.
     */
    DJIOcuSyncBandwidthUnknown = 0xFF
};

/**
 *  This class represents the power spectral density of a frequency slice.
 *  Only supported by Mavic Pro.
 */
@interface DJIOcuSyncFrequencyInterference : NSObject
/**
 *  The average interference spectral density of the frequency range. The valid
 *  range is from [-60, -110] dBm/MHz. A smaller (more negative) value
 *  represents less interference and better communication quality.
 */
@property(nonatomic, readonly) NSInteger powerPerMHz;
/**
 *  The start point of the frequency range in MHz.
 */
@property(nonatomic, readonly) float frequencyStart;
/**
 *  The width of the frequency range in MHz.
 */
@property(nonatomic, readonly) float frequencyWidth;

@end

/**
 *  OcuSync link warning messages.
 *  Only supported by Mavic Pro.
 */
typedef NS_ENUM (uint8_t, DJIOcuSyncWarningMessage) {
    /**
     *  Warning that interference is high for take-off. When the signal gets
     *  weaker as separation between remote controller and aircraft get larger,
     *  there is a change the link will fail. 
     */
    DJIOcuSyncWarningMessageStrongTakeoffInterference,
    /**
     *  There is strong interference on the downlink signal incident on the
     *  remote controller. If the channel selection mode 
     *  `DJIOcuSyncChannelSelectionModeManual` is being used, consider changing
     *  to `DJIOcuSyncChannelSelectionModeAuto` as the OcuSync link can
     *  automatically select Channel Numbers and bandwidth to mitigate 
     *  interference on the fly.
     */
    DJIOcuSyncWarningMessageStrongDownlinkInterference,
    /**
     *  There is strong interference on the uplink signal incident on the
     *  aircraft.
     */
    DJIOcuSyncWarningMessageStrongUplinkInterference,
    /**
     *  Weak OcuSync signal strength. Be aware of anything blocking the signal
     *  between the remote controller and aircraft, adjust the orientation of
     *  the antennas on the remote controller, or reduce the distance between
     *  remote controller and aircraft to increase signal strength.
     */
    DJIOcuSyncWarningMessageWeakSignal,
    /**
     *  The OcuSync link on the aircraft is rebooting.
     */
    DJIOcuSyncWarningMessageAircraftLinkReboot,
    /**
     *  The uplink from the remote controller to the aircraft is broken. Usually
     *  if only the uplink disconnects, it is due to interference on the
     *  aircraft's OcuSync antennas. Try changing the channel number if the
     *  interference source cannot be removed.
     */
    DJIOcuSyncWarningMessageUplinkBroken,
    /**
     *  The downlink from the aircraft to the remote controller is broken.
     *  Usually if only the downlink disconnects, it is due to interference
     *  on the remote controller's OcuSync antennas. Try changing channel 
     *  number, or reducing the bandwidth of the channel to make it more
     *  robust.
     */
    DJIOcuSyncWarningMessageDownlinkBroken,
    /**
     *  The link between the remote controller and the aircraft is unusable. It
     *  is determined to be unusable if signal is too weak. Check to see if the 
     *  antennas are setup correctly and the path from remote controller to 
     *  aircraft is unobstructed.
     */
    DJIOcuSyncWarningMessageLinkUnusable,
};


NS_ASSUME_NONNULL_END

#endif /* DJIAirLinkBaseTypes_h */
