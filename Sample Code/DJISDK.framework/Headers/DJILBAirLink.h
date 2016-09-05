//
//  DJILBAirLink.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <DJISDK/DJIAirLinkBaseTypes.h>
#import <DJISDK/DJIBaseProduct.h>

NS_ASSUME_NONNULL_BEGIN

@class DJILBAirLink;
@class DJISignalInformation;

/*********************************************************************************/
#pragma mark - DJILBAirLinkDelegate
/*********************************************************************************/

/**
 *  This protocol provides delegate methods to receive updated signal information
 *  for channels and updated video data from Lightbridge 2.
 */
@protocol DJILBAirLinkDelegate <NSObject>

@optional

/**
 *  Signal quality and strength information for current uplink channel on each
 *  Remote Controller antenna.
 *
 *  @param lbAirLink   DJILBAirLink Instance.
 *  @param antennas    DJISignalInformation object. The power property is valid
 *  only when the connecting product is Lightbridge 2.
 *                     For other products, the value of power is always 0.
 */
- (void)lbAirLink:(DJILBAirLink *_Nonnull)lbAirLink didUpdateRemoteControllerSignalInformation:(NSArray *_Nonnull)antennas;

/**
 *  Signal quality and strength information for current downlink channel on each
 *  air link module antenna.
 *
 *  @param lbAirLink    DJILBAirLink Instance.
 *  @param antennas     DJISignalInformation object.
 */
- (void)lbAirLink:(DJILBAirLink *_Nonnull)lbAirLink didUpdateLBAirLinkModuleSignalInformation:(NSArray *_Nonnull)antennas;

/**
 *  Signal strength for all available downlink channels.
 *
 *  @param lbAirLink        DJILBAirLink Instance.
 *  @param signalStrength   The strength of the signal.
 */
- (void)lbAirLink:(DJILBAirLink *_Nonnull)lbAirLink didUpdateAllChannelSignalStrengths:(DJILBAirLinkAllChannelSignalStrengths)signalStrength;

/**
 *  Callback for when the FPV video bandwidth percentage has changed. Each
 *  Remote Controller can create a secondary video from the FPV and HD Gimbal
 *  video downlink information. For the slave Remote Controllers, it is 
 *  important to know if the percentage bandwidth has changed so the right PIP
 *  display mode (`DJIPIPDisplayMode`) can be selected. For example, if the FPV
 *  video bandwidth goes to 100%, `DJIALPIPModeLB` should be used.
 *
 *  @param lbAirLink        `DJILBAirLink` instance.
 *  @param bandwidthPercent Output bandwidth percentage.
 */
- (void)lbAirLink:(DJILBAirLink *_Nonnull)lbAirLink didFPVBandwidthPercentChanged:(float)bandwidthPercent;

/**
 *  Tells the delegate that an updated Video data is received.
 *
 *  @param lbAirLink    `DJILBAirLink` Instance.
 *  @param data         The received video data.
 */
- (void)lbAirLink:(DJILBAirLink *_Nonnull)lbAirLink didReceiveVideoData:(NSData *)data;

@end


/*********************************************************************************/
#pragma mark - DJILBAirLink
/*********************************************************************************/

/**
 *  This class contains methods to change settings of the Lightbridge Air Link.
 */
@interface DJILBAirLink : NSObject

/**
 *  Returns the DJILBAirLink delegate.
 */
@property(nonatomic, weak) id<DJILBAirLinkDelegate> delegate;

/**
 *  Selects the video data which will be received by the video data
 *  `- (void)lbAirLink:(DJILBAirLink *_Nonnull)lbAirLink didReceiveVideoData:(NSData *)data`
 *  in `DJILBAirLinkDelegate` and `DJICameraDelegate`.
 *
 *  @param videoDataChannel The video source that streams data to the delegate
 *                          method.
 *  @param completion       Completion block that receives the execution result.
 */
-(void)setVideoDataChannel:(DJIVideoDataChannel)videoDataChannel
            withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the selected video data which will be received by the video data
 *  `- (void)lbAirLink:(DJILBAirLink *_Nonnull)lbAirLink didReceiveVideoData:(NSData *)data`
 *  in `DJILBAirLinkDelegate` and `DJICameraDelegate`.
 *
 *  @param completion   Completion block that receives the execution result.
 */
-(void)getVideoDataChannelWithCompletion:(void(^_Nonnull)(DJIVideoDataChannel videoChannel,
                                                          NSError *_Nullable error))completion;

/**
 *  Sets the downlink channel selection mode (automatic or manual).
 *
 *  @param mode       Channel selection mode for `LBAirLink`.
 *  @param completion Completion block.
 */
- (void)setChannelSelectionMode:(DJILBAirLinkChannelSelectionMode)mode
                 withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets downlink channel selection mode.
 *
 *  @param completion Completion block.
 */
- (void)getChannelSelectionModeWithCompletion:(void (^_Nonnull)(DJILBAirLinkChannelSelectionMode mode,
                                                                NSError *_Nullable error))completion;

/**
 *  Sets fixed downlink channel. Channel selection mode should be set to
 *  `DJILBAirLinkChannelSelectionModeManual`.
 *  Channel can be between 1 and `DJILBAirLinkSupportedChannelMax`.
 *
 *  @param channel    Specific channel for the air link.
 *  @param completion Completion block.
 
 */
- (void)setChannel:(int)channel withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets current downlink channel of air link.
 *
 *  @param completion Completion block.
 */
- (void)getChannelWithCompletion:(void (^_Nonnull)(int channel,
                                                   NSError *_Nullable error))completion;

/**
 *  Sets the downlink data rate (throughput). Higher data rates increase the
 *  quality of video transmission, but can only be used at shorter ranges.
 *
 *  @param rate  Fixed rate (throughput).
 *  @param completion Completion block.
 */
- (void)setDataRate:(DJILBAirLinkDataRate)rate
     withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the current downlink data rate (throughput).
 *
 *  @param completion Completion block.
 */
- (void)getDataRateWithCompletion:(void (^_Nonnull)(DJILBAirLinkDataRate rate,
                                                    NSError *_Nullable error))completion;

/**
 *  Sets FPV video quality vs latency preference. This mode only effects the FPV
 *  camera and not the camera on the HD Gimbal.
 *
 *  @param qualityLatency Quality vs Latency tradeoff for the FPV video
 *  @param completion     Completion block.
 */
- (void)setFPVQualityLatency:(DJILBAirLinkFPVVideoQualityLatency)qualityLatency
              withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets FPV video quality vs latency preference. This mode only effects the FPV
 *  camera and not the camera on the HD Gimbal.
 *
 *  @param completion Completion block.
 */
- (void)getFPVQualityLatencyWithCompletion:(void (^_Nonnull)(DJILBAirLinkFPVVideoQualityLatency qualityLatency,
                                                             NSError *_Nullable error))completion;

/**
 *  Sets the percentage downlink video bandwidth dedicated to the FPV camera.
 *  The remaining percentage is dedicated to the camera on the HD Gimbal.
 *  Setting 100% dedicates all the video bandwidth to FPV.
 *
 *  @param percent    Percentage downlink bandwidth for FPV camera.
 *  @param completion Completion block.
 */
- (void)setFPVVideoBandwidthPercent:(float)percent
                     withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the percentage downlink video bandwidth dedicated to the FPV camera.
 *  The remaining percentage is dedicated to the camera on the HD Gimbal.
 *  Setting 100% dedicates all the video bandwidth to FPV.
 *
 */
- (void)getFPVVideoBandwidthPercentWithCompletion:(void (^_Nonnull)(float percent,
                                                                    NSError *_Nullable error))completion;


/*********************************************************************************/
#pragma mark - Secondary Video Output
/*********************************************************************************/

/**
 *  Return whether secondary video output supported.
 *
 *  @return Secondary video output support result
 */
- (BOOL)isSecondaryVideoOutputSupported;

/**
 *  Enable secondary video output on Remote Controller. The remote controller
 *  outputs video to the Mobile Device by default. This will enable a secondary
 *  video stream to one of the Remote Controller's physical HDMI and SDI ports
 *  (set by setSecondaryVideoPort).
 *
 *  @param enabled    Enables secondary video output.
 *  @param completion Completion block.
 */
- (void)setSecondaryVideoOutputEnabled:(BOOL)enabled
                        withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets whether secondary video output on Remote Controller is enabled. The
 *  Remote Controller outputs video to the Mobile Device by default, but a
 *  secondary video can be routed to its HDMI or SDI port. Use
 *  `setSecondaryVideoOuputEnable` to enable or disable, and
 *  `setSecondaryVideoOutputPort` to choose the port.
 *
 *  @param completion Completion block.
 */
- (void)getSecondaryVideoOutputEnabledWithCompletion:(void (^_Nonnull)(BOOL enabled,
                                                                       NSError *_Nullable error))completion;

/**
 *  Sets secondary video output port on Remote Controller. HDMI or SDI are
 *  possible. Only one port can be active at once.
 *
 *  @param port       Secondary video output port.
 *  @param completion Completion block.
 */
- (void)setSecondaryVideoOutputPort:(DJILBAirLinkSecondaryVideoOutputPort)port
                     withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets secondary video output port on Remote Controller. HDMI or SDI are
 *  possible. Only one port can be active at once.
 *
 *  @param completion Completion block.
 */
- (void)getSecondaryVideoOutputPortWithCompletion:(void (^_Nonnull)(DJILBAirLinkSecondaryVideoOutputPort port,
                                                                    NSError *_Nullable error))completion;

/**
 *  Sets the secondary video output Picture in Picture (PIP) display mode. The
 *  air link module can connect to both an FPV camera (through the HDMI and AV
 *  ports) and a camera mounted on the HD Gimbal (through the Gimbal port). The
 *  output video can then be a combination of the two video sources. Either a
 *  single video source can be displayed, or one can be displayed within the
 *  other (as a Picture in Picture, or PIP). If the mode is set incorrectly, 
 *  then no output video will be displayed. For example, if only a FPV camera is
 *  connected, or the bandwidth for the 'LB' data (FPV) is set to 100 percent,
 *  the only mode that will display data is the `DJILBAirLinkPIPModeLB`.
 *
 *  @param pipDisplay Picture in Picture (PIP) display mode.
 *  @param completion Completion block.
 *
 */
- (void)setPIPDisplay:(DJILBAirLinkPIPDisplayMode)pipDisplay
       withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the secondary video output Picture in Picture (PIP) display mode. The
 *  air link module can connect to both an FPV camera (through the HDMI and AV
 *  ports) and a camera mounted on the HD Gimbal (through the Gimbal port). The
 *  output video can then be a combination of the two video sources. Either a
 *  single video source can be displayed, or one can be displayed within the
 *  other (as a Picture in Picture, or PIP).
 *
 *  @param completion Completion block.
 *
 */
- (void)getPIPDisplayWithCompletion:(void (^_Nonnull)(DJILBAirLinkPIPDisplayMode pipDisplay,
                                                      NSError *_Nullable error))completion;

/**
 *  Enables and disables On Screen Display (OSD) overlay on the secondary video.
 *  OSD is flight data like altitude, attitude etc. and can be overlayed on the
 *  PIP video.
 *
 *  @param enabled Determines whether to display OSD on screen.
 *  @param completion Completion block.
 *
 */
- (void)setDisplayOSDEnabled:(BOOL)enabled
              withCompletion:(DJICompletionBlock)completion;

/**
 *  Determines whether On Screen Display (OSD) is overlayed on the video feed.
 *
 *  @param completion Completion block.
 *
 */
- (void)getDisplayOSDEnabledWithCompletion:(void (^_Nonnull)(BOOL enabled,
                                                             NSError *_Nullable error))completion;

/**
 *  Sets the OSD top margin in video pixels.
 *
 *  @param margin     Top margin of OSD. The range is [0, 50].
 *  @param completion Completion block.
 *
 */
- (void)setOSDTopMargin:(NSUInteger)margin
         withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the OSD top margin in video pixels.
 *
 *  @param completion Completion block.
 *
 */
- (void)getOSDTopMarginWithCompletion:(void (^_Nonnull)(NSUInteger margin,
                                                        NSError *_Nullable error))completion;

/**
 *  Sets the OSD left margin in video pixels.
 *
 *  @param margin     Left margin of OSD. The range is [0, 50].
 *  @param completion Completion block.
 *
 */
- (void)setOSDLeftMargin:(NSUInteger)margin
          withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the OSD left margin in video pixels.
 *
 *  @param completion Completion block.
 *
 */
- (void)getOSDLeftMarginWithCompletion:(void (^_Nonnull)(NSUInteger margin,
                                                         NSError *_Nullable error))completion;

/**
 *  Sets the OSD bottom margin in video pixels.
 *
 *  @param margin     Bottom margin of OSD. The range is [0, 50].
 *  @param completion Completion block.
 *
 */
- (void)setOSDBottomMargin:(NSUInteger)margin
            withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the OSD bottom margin in video pixels.
 *
 *  @param completion Completion block.
 *
 */
- (void)getOSDBottomMarginWithCompletion:(void (^_Nonnull)(NSUInteger margin,
                                                           NSError *_Nullable error))completion;

/**
 *  Sets the OSD right margin in video pixels.
 *
 *  @param margin     Right margin of OSD. The range is [0, 50].
 *  @param completion Completion block.
 *
 */
- (void)setOSDRightMargin:(NSUInteger)margin
           withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the OSD right margin in video pixels.
 *
 *  @param completion Completion block.
 *
 */
- (void)getOSDRightMarginWithCompletion:(void (^_Nonnull)(NSUInteger margin,
                                                          NSError *_Nullable error))completion;

/**
 *  Sets the OSD units to either metric or imperial.
 *
 *  @param units       OSD units.
 *  @param completion Completion block.
 *
 */
- (void)setOSDUnits:(DJILBAirLinkOSDUnits)units
     withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the OSD units (metric or imperial).
 *
 *  @param completion Completion block.
 *
 */
- (void)getOSDUnitsWithCompletion:(void (^_Nonnull)(DJILBAirLinkOSDUnits units,
                                                    NSError *_Nullable error))completion;

/**
 *  Sets the Remote Controller HDMI video port output video format.
 *
 *  @param outputFormat Video output format for the HDMI port.
 *  @param completion   Completion block.
 *
 */
- (void)setHDMIOutputFormat:(DJILBAirLinkSecondaryVideoFormat)format
             withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the Remote Controller HDMI video port output video format.
 *
 *  @param completion Completion block.
 *
 */
- (void)getHDMIOutputFormatWithCompletion:(void (^_Nonnull)(DJILBAirLinkSecondaryVideoFormat format,
                                                            NSError *_Nullable error))completion;

/**
 *  Sets the Remote Controller SDI video port output video format.
 *
 *  @param outputFormat Video output format for SDI port.
 *  @param completion   Completion block.
 *
 */
- (void)setSDIOutputFormat:(DJILBAirLinkSecondaryVideoFormat)format
            withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the Remote Controller SDI video port output video format.
 *
 *  @param completion Completion block.
 *
 */
- (void)getSDIOutputFormatWithCompletion:(void (^_Nonnull)(DJILBAirLinkSecondaryVideoFormat format,
                                                           NSError *_Nullable error))completion;

/**
 *  Sets the PIP (Picture In Picture) position relative to the top left corner
 *  of the main subject video feed.
 *
 *
 *  @param position   Position of the PIP on the screen.
 *  @param completion Completion block.
 *
 */
- (void)setPIPPosition:(DJILBAirLinkPIPPosition)position
        withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the PIP (Picture In Picture) position relative to the top left corner
 *  of the main subject video feed.
 *
 *  @param completion Completion block.
 *
 */
- (void)getPIPPositionWithCompletion:(void (^_Nonnull)(DJILBAirLinkPIPPosition position,
                                                       NSError *_Nullable error))completion;

/**
 *  `YES` if Lightbridge 2 device supports dual encode mode. Dual encode mode
 *  allows the Lightbridge module to encode and transmit both it's AV and HDMI
 *  inputs simultaneously.
 */
-(BOOL) isDualEncodeModeSupported;

/**
 *  Sets Lightbridge 2 encode mode. It is only available when 
 *  `isDualEncodeModeSupported` returns `YES`. For Lightbridge 2 modules that
 *  don't support dual encode mode, the encode mode is always single.
 *
 *  @param mode         The encode mode to set.
 *  @param completion   Completion block.
 *  
 *  @see `DJILBAirLinkEncodeMode`
 */
- (void)setEncodeMode:(DJILBAirLinkEncodeMode)mode
       withCompletion:(DJICompletionBlock)completion;
/**
 *  Gets Lightbridge 2 encode mode. It is only available when
 *  `isDualEncodeModeSupported` returns `YES`. For Lightbridge 2 modules that
 *  don't support dual encode mode, the encode mode is always single.
 *
 *  @param completion   Completion block.
 *
 *  @see `DJILBAirLinkEncodeMode`
 */
- (void)getEncodeModeWithCompletion:(void (^_Nonnull)(DJILBAirLinkEncodeMode mode,
                                                      NSError *_Nullable error))completion;
/**
 *  Sets the computational power and bandwidth balance between AV and HMDI
 *  inputs on the Lightbridge 2 module when dual encode mode is enabled. Balance
 *  is in percent [0.0,  1.0]. It is only available when `isDualEncodeModeSupported`
 *  returns `YES`.
 *  When `percent` is 0.0, all resources are allocated for video data from AV port.
 *  When `percent` is 1.0, all resources are allocated for video data from HDMI port.
 *
 *  @param percent      Percentage resources dedicated to HDMI encoding and transmission.
 *  @param completion   Completion block.
 */
- (void)setDualEncodeModePercent:(float)percent
                  withCompletion:(DJICompletionBlock)completion;
/**
 *  Gets the computational power and bandwidth balance between AV and HMDI
 *  inputs on the Lightbridge 2 module when dual encode mode is enabled.
 *  It is only available when `isDualEncodeModeSupported` returns `YES`.
 *  When `percent` is 0.0, all resources are allocated for video data from AV port.
 *  When `percent` is 1.0, all resources are allocated for video data from HDMI port.
 *
 *  @param completion   Completion block.
 */
- (void)getDualEncodeModePercentWithCompletion:(void (^_Nonnull)(float percent,
                                                                 NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
