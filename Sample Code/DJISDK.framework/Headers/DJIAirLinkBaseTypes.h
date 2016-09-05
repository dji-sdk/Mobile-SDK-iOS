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
    DJILBAirLinkDataRateUnknown
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

NS_ASSUME_NONNULL_END

#endif /* DJIAirLinkBaseTypes_h */
