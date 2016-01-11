//
//  DJIAirLink.h
//  DJISDK
//
//  Created by DJI on 15/11/13.
//  Copyright © 2015年 DJI. All rights reserved.
//

#import <DJISDK/DJISDK.h>

NS_ASSUME_NONNULL_BEGIN

@class DJIAirLink;

/**
 *  Define the air link max supported channel count
 */
#define DJI_AIRLINK_SUPPORTED_CHANNEL_COUNT (8)

/*********************************************************************************/
#pragma mark - DJISignalInformation
/*********************************************************************************/
@interface DJISignalInformation : NSObject

/**
 *  Signal quality in percent [0, 100].
 */
@property(nonatomic, readonly) int percent;

/**
 *  Signal strength in dBm.
 *
 */
@property(nonatomic, readonly) int power;

@end

/*********************************************************************************/
#pragma mark - Data Struct
/*********************************************************************************/

/**
 *  Downlink channel selection mode (manual or automatic) for wireless link.
 */
typedef NS_ENUM(uint8_t, DJIALChannelSelectionMode) {
    /**
     *  Air link will automatically select the best physical channel based on the signal environment.
     */
    DJIALChannelSelectionModeAuto,
    /**
     *  Manually select the physical channel.
     */
    DJIALChannelSelectionModeManual,
    /**
     *  Unknown physical channel selection mode.
     */
    DJIALChannelSelectionModeUnknown,
};

/**
 *  OSD data units.
 */
typedef NS_ENUM(uint8_t, DJIALOSDUnits) {
    /**
     *  Imperial
     */
    DJIALOSDUnitsImperial,
    /**
     *  Metric
     */
    DJIALOSDUnitsMetric,
    /**
     *  Unknown
     */
    DJIALOSDUnitsUnknown,
};

/**
 *  Remote Controller port to output secondary video to (in addition to USB video sent to the Mobile Device).
 */
typedef NS_ENUM(uint8_t, DJIALSecondaryVideoOutputPort) {
    /**
     *  HDMI port
     */
    DJIALSecondaryVideoOutputPortHDMI,
    /**
     *  SDI port
     */
    DJIALSecondaryVideoOutputPortSDI,
    /**
     *  Unknown
     */
    DJIALSecondaryVideoOutputPortUnknown,
};

/**
 *  Define the combination of video sources to form the secondary output video.
 */
typedef NS_ENUM(uint8_t, DJIALPIPDisplayMode) {
    /**
     *  Displays the FPV Camera (HDMI or AV input to the air link Module).
     */
    DJIALPIPDisplayModeLB,
    /**
     *  Displays the video from the HD Gimbal (Gimbal input to the air link Module).
     */
    DJIALPIPDisplayModeExt,
    /**
     *  Displays the video from HD Gimbal camera as the main subject, and the HDMI or AV video from FPV camera in a mini window (Picture in Picture, or PIP).
     */
    DJIALPIPDisplayModePIPLB,
    /**
     *  Displays the HDMI or AV output of the FPV camera as the main subject, and the video from the HD Gimbal in a mini window (Picture in Picture, or PIP).
     */
    DJIALPIPDisplayModePIPExt,
    /**
     *  Unknown output mode.
     */
    DJIALPIPDisplayModeUnknown,
};

/**
 *  Secondary output video resolution and frame rate.
 */
typedef NS_ENUM(uint8_t, DJIALSecondaryVideoFormat) {
    /**
     *  1080I
     */
    DJIALSecondaryVideoFormat1080I60FPS,
    DJIALSecondaryVideoFormat1080I50FPS,
    /**
     *  1080P
     */
    DJIALSecondaryVideoFormat1080P60FPS,
    DJIALSecondaryVideoFormat1080P50FPS,
    DJIALSecondaryVideoFormat1080P30FPS,
    DJIALSecondaryVideoFormat1080P25FPS,
    DJIALSecondaryVideoFormat1080P24FPS,
    /**
     *  720P
     */
    DJIALSecondaryVideoFormat720P60FPS,
    DJIALSecondaryVideoFormat720P50FPS,
    DJIALSecondaryVideoFormat720P30FPS,
    DJIALSecondaryVideoFormat720P25FPS,
    /**
     *  Unknown
     */
    DJIALSecondaryVideoFormatUnknown,
};

/**
 *  PIP (Picture In Picture) position on the screen reltaive to the main subject video.
 *
 */
typedef NS_ENUM(uint8_t, DJIALPIPPosition) {
    /**
     *  PIP is in the screen's top left.
     */
    DJIALPIPPositionTopLeft,
    /**
     *  PIP is in the screen's top right.
     */
    DJIALPIPPositionTopRight,
    /**
     *  PIP is in the screen's bottom left.
     */
    DJIALPIPPositionBottomLeft,
    /**
     *  PIP is in the screen's bottom right.
     */
    DJIALPIPPositionBottomRight,
    /**
     *  Unknown PIP position.
     */
    DJIALPIPPositionUnknown,
};

/**
 *  FPV Video can prioritize either quality or latency.
 */
typedef NS_ENUM(uint8_t, DJIALFPVVideoQualityLatency) {
    /**
     *  High quality priority.
     */
    DJIALFPVVideoQualityLatencyHighQuality,
    /**
     *  Low latency priority.
     */
    DJIALFPVVideoQualityLatencyLowLatency,
    /**
     *  Unknown transmission mode.
     */
    DJIALFPVVideoQualityLatencyUnknown,
};

/**
 *  Wireless downlink data rate. Lower rates are used for longer ranges, but will have lower video quality.
 *
 */
typedef NS_ENUM(uint8_t, DJIALDataRate) {
    /**
     *  4 Mbps
     */
    DJIALDataRate4Mbps,
    /**
     *  6 Mbps
     */
    DJIALDataRate6Mbps,
    /**
     *  8 Mbps
     */
    DJIALDataRate8Mbps,
    /**
     *  10 Mbps
     */
    DJIALDataRate10Mbps,
    /**
     *  Unknown
     */
    DJIALDataRateUnknown
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
    int8_t rssi[DJI_AIRLINK_SUPPORTED_CHANNEL_COUNT];
} DJIALAllChannelSignalStrengths;

/*********************************************************************************/
#pragma mark - DJIAirLinkDelegate
/*********************************************************************************/
@protocol DJIAirLinkDelegate <NSObject>

@optional

/**
 *  Signal quality and strength information for current downlink channel on each Remote Controller antenna.
 *
 *  @param airlink     AirLink Instance.
 *  @param antennas    DJISignalInformation object.
 */
-(void) airlink:(DJIAirLink* _Nonnull)airlink didUpdateRemoteControllerSignalInformation:(NSArray* _Nonnull)antennas;

/**
 *  Signal quality and strength information for current uplink channel on each air link module antenna.
 *
 *  @param airlink     AirLink Instance.
 *  @param antennas    DJISignalInformation object.
 */
-(void) airlink:(DJIAirLink* _Nonnull)airlink didUpdateLightbridgeModuleSignalInformation:(NSArray* _Nonnull)antennas;

/**
 *  Signal strength for all available downlink channels.
 *
 *  @param airlink     AirLink Instance.
 *  @param freqPower   Frequency power.
 */
-(void) airlink:(DJIAirLink *_Nonnull)airlink didUpdateAllChannelSignalStrengths:(DJIALAllChannelSignalStrengths)signalStrength;

/**
 *  Callback for when the FPV video bandwidth percentage has changed. Each Remote Controller can create a secondary video from the FPV and HD Gimbal video downlink information. For the slave Remote Controllers it's important to know if the percentage bandwidth has changed so the right PIP display mode (DJIPIPDisplayMode) can be selected. For example, if the FPV video bandwidth goes to 100%, then DJIALPIPModeLB should be used.
 *
 *  @param airlink          AirLink instance.
 *  @param bandwidthPercent Output bandwidth percentage.
 */
-(void) airlink:(DJIAirLink* _Nonnull)airlink didFPVBandwidthPercentChanged:(float)bandwidthPercent;

/**
 *  Tells the delegate that a updated Video data is received.
 *
 *  @param airlink     AirLink Instance.
 *  @param data        The received video data.
 */
-(void) airlink:(DJIAirLink* _Nonnull)airlink didRececivedVideoData:(NSData*)data;

@end


/*********************************************************************************/
#pragma mark - DJIAirLink
/*********************************************************************************/
@interface DJIAirLink : DJIBaseComponent

@property(nonatomic, weak) id<DJIAirLinkDelegate> delegate;

/**
 *  Sets downlink channel selection mode (automatic or manual).
 *
 *  @param mode       Channel selection mode for AirLink.
 *  @param completion Completion block.
 */
-(void) setChannelSelectionMode:(DJIALChannelSelectionMode)mode withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets downlink channel selection mode.
 *
 *  @param completion Completion block.
 */
-(void) getChannelSelectionModeWithCompletion:(void(^_Nullable)(DJIALChannelSelectionMode mode, NSError* _Nullable error))completion;

/**
 *  Sets fixed downlink channel. Channel selection mode should be set to DJIALChannelSelectionModeManual.
 *  Channel can be between 1 and DJIAirLinkSupportedChannelMax.
 *
 *  @param channel    Specific channel for the air link.
 *  @param completion Completion block.

 */
-(void) setChannel:(int)channel withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets current downlink channel of air link.
 *
 *  @param completion Completion block.
 */
-(void) getChannelWithCompletion:(void(^_Nullable)(int channel, NSError* _Nullable error))completion;

/**
 *  Sets the downlink data rate (throughput). Higher data rates increase the quality of video transmission, but can only be used at shorter ranges.
 *
 *  @param rate  Fixed rate (throughput).
 *  @param completion Completion block.
 */
-(void) setDataRate:(DJIALDataRate)rate withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the current downlink data rate (throughput).
 *
 *  @param completion Completion block.
 */
-(void) getDataRateWithCompletion:(void(^_Nullable)(DJIALDataRate rate, NSError* _Nullable error))completion;

/**
 *  Sets FPV video quality vs latency preference. This mode only effects the FPV camera and not the camera on the HD Gimbal.
 *
 *  @param qualityLatency Quality vs Latency tradeoff for the FPV video
 *  @param completion     Completion block.
 */
-(void) setFPVQualityLatency:(DJIALFPVVideoQualityLatency)qualityLatency withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets FPV video quality vs latency preference. This mode only effects the FPV camera and not the camera on the HD Gimbal.
 *
 *  @param completion Completion block.
 */
-(void) getFPVQualityLatencyWithCompletion:(void(^_Nullable)(DJIALFPVVideoQualityLatency qualityLatency, NSError* _Nullable error))completion;

/**
 *  Sets the percentage downlink video bandwidth dedicated to the FPV camera. The remaining percentage is dedicated to the camera on the HD Gimbal. Setting 100% dedicates all the video bandwidth to FPV.
 *
 *  @param percent    Percentage downlink bandwidth for FPV camera.
 *  @param completion Completion block.
 */
-(void) setFPVVideoBandwidthPercent:(float)percent withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the percentage downlink video bandwidth dedicated to the FPV camera. The remaining percentage is dedicated to the camera on the HD Gimbal. Setting 100% dedicates all the video bandwidth to FPV.
 *
 */
-(void) getFPVVideoBandwidthPercentWithCompletion:(void(^_Nullable)(float percent, NSError* _Nullable error))completion;


/*********************************************************************************/
#pragma mark - Secondary Video Output
/*********************************************************************************/

/**
 *  Return whether secondary video output supported.
 *
 *  @return Secondary video output support result
 */
-(BOOL) isSecondaryVideoOutputSupported;

/**
 *  Enable secondary video output on Remote Controller. The remote controller outputs video to the Mobile Device by default. This will enable a secondary video stream to one of the Remote Controller's physical HDMI and SDI ports (set by setSecondaryVideoPort).
 *
 *  @param enabled    Enables secondary video output.
 *  @param completion Completion block.
 */
-(void) setSecondaryVideoOutputEnabled:(BOOL)enabled withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets whether secondary video output on Remote Controller is enabled. The Remote Controller outputs video to the Mobile Device by default, but a secondary video can be routed to its HDMI or SDI port. Use setSecondaryVideoOuputEnable to enable/disable and setSecondaryVideoOutputPort to choose the port.
 *
 *  @param completion Completion block.
 */
-(void) getSecondaryVideoOutputEnabledWithCompletion:(void(^_Nullable)(BOOL enabled, NSError* _Nullable error))completion;

/**
 *  Sets secondary video output port on Remote Controller. HDMI or SDI are possible. Only one port can be active at once.
 *
 *  @param port       Secondary video output port.
 *  @param completion Completion block.
 */
-(void) setSecondaryVideoOutputPort:(DJIALSecondaryVideoOutputPort)port withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets secondary video output port on Remote Controller. HDMI or SDI are possible. Only one port can be active at once.
 *
 *  @param completion Completion block.
 */
-(void) getSecondaryVideoOutputPortWithCompletion:(void(^_Nullable)(DJIALSecondaryVideoOutputPort port, NSError* _Nullable error))completion;

/**
 *  Sets the secondary video output Picture in Picture (PIP) display mode. The air link module can connect to both an FPV camera (through the HDMI and AV ports) and a camera mounted on the HD Gimbal (through the Gimbal port). The output video can then be a combination of the two video sources. Either a single video source can be displayed, or one can be displayed within the other (as a Picture in Picture, or PIP). If the mode is set incorrectly, then no output video will be displayed. For example, if only a FPV camera is connected, or the bandwidth for the 'LB' data (FPV) is set to 100 percent, then the only mode that will display data is the DJIALPIPModeLB.
 *
 *  @param pipDisplay Picture in Picture display mode.
 *  @param completion Completion block.
 *
 */
-(void) setPIPDisplay:(DJIALPIPDisplayMode)pipDisplay withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the secondary video output Picture in Picture (PIP) display mode. The air link module can connect to both an FPV camera (through the HDMI and AV ports) and a camera mounted on the HD Gimbal (through the Gimbal port). The output video can then be a combination of the two video sources. Either a single video source can be displayed, or one can be displayed within the other (as a Picture in Picture, or PIP).
 *
 *  @param completion Completion block.
 *
 */
-(void) getPIPDisplayWithCompletion:(void(^_Nullable)(DJIALPIPDisplayMode pipDisplay, NSError* _Nullable error))completion;

/**
 *  Enables and disables OSD overlay on the secondary video. OSD is flight data like altitude, attitude etc. and can be overlayed on the PIP video.
 *
 *  @param enabled Whether dispaly OSD on screen.
 *  @param completion Completion block.
 *
 */
-(void) setDisplayOSDEnabled:(BOOL)enabled withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets whether OSD is overlayed on the video feed.
 *
 *  @param completion Completion block.
 *
 */
-(void) getDisplayOSDEnabledWithCompletion:(void(^_Nullable)(BOOL enabled, NSError* _Nullable error))completion;

/**
 *  Sets OSD top margin.
 *
 */
-(void) setOSDTopMargin:(NSUInteger)margin withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets OSD top margin.
 *
 *  @param completion Completion block.
 *
 */
-(void) getOSDTopMarginWithCompletion:(void(^_Nullable)(NSUInteger margin, NSError* _Nullable error))completion;

/**
 *  Sets OSD left margin.
 *
 *  @param margin     Left margin of OSD, should be in range [0, 50]
 *  @param completion Completion block.
 *
 */
-(void) setOSDLeftMargin:(NSUInteger)margin withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets OSD left margin.
 *
 *  @param completion Completion block.
 *
 */
-(void) getOSDLeftMarginWithCompletion:(void(^_Nullable)(NSUInteger margin, NSError* _Nullable error))completion;

/**
 *  Sets OSD bottom margin.
 *
 *  @param margin     Bottom margin of OSD, should be in range [0, 50]
 *  @param completion Completion block.
 *
 */
-(void) setOSDBottomMargin:(NSUInteger)margin withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets OSD bottom margin.
 *
 *  @param completion Completion block.
 *
 */
-(void) getOSDBottomMarginWithCompletion:(void(^_Nullable)(NSUInteger margin, NSError* _Nullable error))completion;

/**
 *  Sets OSD right margin.
 *
 *  @param margin     Right margin of OSD, should be in range [0, 50]
 *  @param completion Completion block.
 *
 */
-(void) setOSDRightMargin:(NSUInteger)margin withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets OSD right margin.
 *
 *  @param completion Completion block.
 *
 */
-(void) getOSDRightMarginWithCompletion:(void(^_Nullable)(NSUInteger margin, NSError* _Nullable error))completion;

/**
 *  Sets OSD units to be metric or imperial.
 *
 *  @param units       OSD unit.
 *  @param completion Completion block.
 *
 */
-(void) setOSDUnits:(DJIALOSDUnits)units withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets OSD units as either metric or imperial.
 *
 *  @param completion Completion block.
 *
 */
-(void) getOSDUnitsWithCompletion:(void(^_Nullable)(DJIALOSDUnits units, NSError* _Nullable error))completion;

/**
 *  Sets Remote Controller HDMI video port output video format.
 *
 *  @param outputFormat Video output format for HDMI port.
 *  @param completion   Completion block.
 *
 */
-(void) setHDMIOutputFormat:(DJIALSecondaryVideoFormat)format withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets Remote Controller HDMI video port output video format.
 *
 *  @param completion Completion block.
 *
 */
-(void) getHDMIOutputFormatWithCompletion:(void (^_Nullable)(DJIALSecondaryVideoFormat format, NSError * _Nullable))completion;

/**
 *  Sets Remote Controller SDI video port output video format.
 *
 *  @param outputFormat Video output format for SDI port.
 *  @param completion   Completion block.
 *
 */
-(void) setSDIOutputFormat:(DJIALSecondaryVideoFormat)format withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets Remote Controller SDI video port output video format.
 *
 *  @param completion Completion block.
 *
 */
-(void) getSDIOutputFormatWithCompletion:(void (^_Nullable)(DJIALSecondaryVideoFormat format, NSError * _Nullable))completion;

/**
 *  Sets PIP (Picture In Picture) position relative to top left corner of the main subject video feed.
 *
 *  @param position   Position of PIP on the screen.
 *  @param completion Completion block.
 *
 */
-(void) setPIPPosition:(DJIALPIPPosition)position withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets PIP (Picture In Picture) position relative to top left corner of the main subject video feed.
 *
 *  @param completion Completion block.
 *
 */
-(void) getPIPPositionWithCompletion:(void (^_Nullable)(DJIALPIPPosition position, NSError * _Nullable))completion;

@end

NS_ASSUME_NONNULL_END
