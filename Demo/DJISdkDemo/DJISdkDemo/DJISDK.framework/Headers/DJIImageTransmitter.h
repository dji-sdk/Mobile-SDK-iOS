//
//  DJIImageTransmitter.h
//  DJISDK
//
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <DJISDK/DJIObject.h>

@class DJIImageTransmitter;

/**
 *  ImageTransmitter's Radio Signal Quality
 */
typedef struct
{
    /**
     *  percentage of signal quality. in range [0, 100]
     */
    uint8_t mPercent;
    /**
     *  The remote controller's signal is up link signal. The image transmitter's signal is down link signal.
     */
    BOOL mUpLink;
} DJIImageTransmitterRadioSignalQuality;

/**
 *  ImageTransmitter's Bandwidth
 */
typedef NS_ENUM(uint8_t, DJIImageTransmitterBandwidth){
    /**
     *  Bandwidth 4 Mbps
     */
    TransmitterBandwidth4Mbps,
    /**
     *  Bandwidth 6 Mbps
     */
    TransmitterBandwidth6Mbps,
    /**
     *  Bandwidth 8 Mbps
     */
    TransmitterBandwidth8Mbps,
    /**
     *  Bandwidth 10 Mbps
     */
    TransmitterBandwidth10Mbps,
    /**
     *  Bandwidth Unknown
     */
    TransmitterBandwidthUnknown = 0xFF,
};

#define IMAGE_TRANSMITTER_RSSI_MIN      (-100)
#define IMAGE_TRANSMITTER_RSSI_MAX      (-60)

#define IMAGE_TRANSMITTER_CHANNEL_MAX   (32)
/**
 *  ImageTransmitter's RSSI
 */
typedef struct
{
    /**
     *  32 channel's power, the channel power value is in range [IMAGE_TRANSMITTER_RSSI_MIN, IMAGE_TRANSMITTER_RSSI_MAX]
     */
    int8_t mRssi[IMAGE_TRANSMITTER_CHANNEL_MAX];
} DJIImageTransmitterChannelPower;

/**
 *  ImageTransmitter's Delegate
 */
@protocol DJIImageTransmitterDelegate <NSObject>

@optional

/**
 *  Update radio signal quality.
 *
 *  @param quality Quality data
 */
-(void) imageTransmitter:(DJIImageTransmitter*)transmitter didUpdateRadioSignalQuality:(DJIImageTransmitterRadioSignalQuality)quality;

/**
 *  Update channel power.
 *
 *  @param power channel power data
 */
-(void) imageTransmitter:(DJIImageTransmitter*)transmitter didUpdateChannelPower:(DJIImageTransmitterChannelPower)power;

@end

@interface DJIImageTransmitter : DJIObject

/**
 *  ImageTransmitter's delegate
 */
@property(nonatomic, weak) id<DJIImageTransmitterDelegate> delegate;

/**
 *  Get version of ImageTransmitter
 *
 *  @param result Remote execute result callback.
 */
-(void) getVersionWithResult:(void(^)(NSString* version, DJIError* error))result;

/**
 *  Start update channel power data.
 *
 *  @param block Remote execute result.
 */
-(void) startChannelPowerUpdatesWithResult:(DJIExecuteResultBlock)block;

/**
 *  Stop update channel power data.
 *
 *  @param block Remote execute result.
 */
-(void) stopChannelPowerUpdatesWithResult:(DJIExecuteResultBlock)block;

/**
 *  Set ImageTransmitter's channel by manual.
 *
 *  @param channel The specify channel by user. in range [0, 31]
 *  @param block   The Remote execute result.
 */
-(void) setChannel:(uint8_t)channel withResult:(DJIExecuteResultBlock)block;

/**
 *  Set ImageTransmitter's auto select channel mode. Transmitter will auto select the best channel.
 *
 *  @param block Remote execute result.
 */
-(void) setChannelAutoSelectWithResult:(DJIExecuteResultBlock)block;

/**
 *  Get ImageTransmitter's current channel and channel select mode
 *
 *  @param block The Remote execute result.
 */
-(void) getChannelWithResult:(void(^)(uint8_t channel, BOOL isAuto, DJIError* error))block;

/**
 *  Set ImageTransmitter's bandwidth. The bandwidth will affect the image data's transfer quality and distance.
 *
 *  @param bandwidth bandwidth set to Transmitter
 *  @param block     The Remote execute result.
 */
-(void) setBandWidth:(DJIImageTransmitterBandwidth)bandwidth withResult:(DJIExecuteResultBlock)block;

/**
 *  Get ImageTransmitter's bandwidth
 *
 *  @param block The Remote execute result.
 */
-(void) getBandwidthWithResult:(void(^)(DJIImageTransmitterBandwidth bandwidth, DJIError* error))block;

/**
 *  Set ImageTransmitter's double output.
 *
 *  @param isDouble Double output switch. if YES the video could be display on APP and HDMI device
 *  @param block    The Remote execute result.
 */
-(void) setDoubleOutput:(BOOL)isDouble withResult:(DJIExecuteResultBlock)block;

/**
 *  Get ImageTransmitte's is double output
 *
 *  @param block The Remote execute result.
 */
-(void) getDoubleOutputState:(void(^)(BOOL isDouble, DJIError* error))block;

@end
