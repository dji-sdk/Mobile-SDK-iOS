/*
 *  DJI iOS Mobile SDK Framework
 *  DJIHandheldController.h
 *
 *  Copyright (c) 2015, DJI.
 *  All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import <DJISDK/DJIBaseComponent.h>

@class DJIWiFiLink;

NS_ASSUME_NONNULL_BEGIN

//-----------------------------------------------------------------
#pragma mark DJIHandheldWiFiFrequency Type
//-----------------------------------------------------------------
/**
 *  Remote controller pairing state.
 */
typedef NS_ENUM(uint8_t, DJIHandheldWiFiFrequencyType){
    /**
     *  The Handheld WiFi frequency is 2.4G
     */
    DJIHandheldWiFiFrequency2Dot4G,
    /**
     *  The Handheld WiFi frequency is 5.8G
     */
    DJIHandheldWiFiFrequency5Dot8G,

};

/**
 *  Handheld Power Mode
 */
typedef NS_ENUM(uint8_t, DJIHandheldPowerMode){
    /**
     *  The Handheld Power Mode is operating
     */
    DJIHandheldPowerModeOperating,
    /**
     *  The Handheld Power Mode is sleep
     */
    DJIHandheldPowerModeSleeping,
    
};

@class DJIHandheldController;

@protocol DJIHandheldControllerDelegate <NSObject>

@optional

/**
 *  Get Handheld device's work status
 *
 *  @param sleep if handheld device sleep
 *  @param controller DJIHandheldController object
 *
 */
- (void)getHandheldWorkStatusWithSleep:(BOOL)sleep withHandheldController:(DJIHandheldController *)controller;

@end

/*********************************************************************************/
#pragma mark - DJIHandheldController
/*********************************************************************************/
@interface DJIHandheldController : DJIBaseComponent

//-----------------------------------------------------------------
#pragma mark Handheld Device WIFI
//-----------------------------------------------------------------

/**
 *  Returns the WiFi link
 */
@property(nonatomic, strong) DJIWiFiLink *wifiLink;

/**
 *  Returns the DJIHandheldController delegate
 */
@property(nonatomic, weak) id <DJIHandheldControllerDelegate> delegate;


/**
 *  Query method to check if the Handheld Device supports wifi settings.
 *
 */
-(BOOL) isWiFiSettingSupported;

/**
 *  Make handheld device enter sleep mode
 *  @param block Completion block.
 *
 */
- (void)enterSleepModeWithCompletion:(DJICompletionBlock)block;

/**
 *  Make handheld device awake from sleep mode
 *  @param block Completion block.
 *
 */
- (void)awakeFromSleepModeWithCompletion:(DJICompletionBlock)block;

/**
 *  Shutdown handheld device
 *  @param block Completion block.
 *
 */
- (void)shutDownHandheldWithCompletion:(DJICompletionBlock)block;

@end
NS_ASSUME_NONNULL_END