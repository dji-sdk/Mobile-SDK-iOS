//
//  DJIHandheldControllerBaseTypes.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*********************************************************************************/
#pragma mark DJIHandheldWiFiFrequency Type
/*********************************************************************************/

/**
 *  Handheld WiFi Frequency Type.
 */
typedef NS_ENUM (uint8_t, DJIHandheldWiFiFrequencyType){
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
typedef NS_ENUM (uint8_t, DJIHandheldPowerMode){
    /**
     *  The Handheld Power Mode is awake.
     *  For Osmo, when it is in this mode, all the components in `DJIHandheld`
     *  are accessible.
     */
    DJIHandheldPowerModeAwake,
    /**
     *  The Handheld Power Mode is sleeping. The handheld controller keeps the
     *  WiFi connection to the Mobile device alive but most other components
     *  are off. The power consumption is low in this mode.
     *  For Osmo, when it is in this mode, only the `DJIHandheldController`,
     *  `DJIAirLink`, and `DJIBattery` are accessible.
     */
    DJIHandheldPowerModeSleeping,
    /**
     *  The Handheld Power Mode is powered off. Once this mode is set the
     *  delegate will receive this mode until the handheld device is shut down
     *  completely.
     *  It is not supported by Osmo Mobile. 
     */
    DJIHandheldPowerModePowerOff,
    /**
     *  The Handheld Power Mode in unknown.
     */
    DJIHandheldPowerModeUnknown = 0xFF
};

/**
 *  The status of the shutter button and record button on the handheld 
 *  controller.
 *  Used by Osmo Mobile only.
 */
typedef NS_ENUM (uint8_t, DJIHandheldButtonStatus) {
    /**
     *  The button status is idle.
     */
    DJIHandheldButtonStatusIdle,
    /**
     *  Only the shutter button was pressed and released.
     */
    DJIHandheldButtonStatusShutterButtonPressed,
    /**
     *  Only the record button was pressed and released.
     */
    DJIHandheldButtonStatusRecordButtonPressed,
    /**
     *  The shutter button is pressed without release.
     */
    DJIHandheldButtonStatusShutterButtonLongPress,
    /**
     *  The button status is unknown.
     */
    DJIHandheldButtonStatusModeUnknown = 0xFF,
};

/**
 *  The status of the trigger button on the handheld controller.
 *  Used by Osmo Mobile only.
 */
typedef NS_ENUM (uint8_t, DJIHandheldTriggerStatus) {
    /**
     *  Trigger button status is idle.
     */
    DJIHandheldTriggerStatusIdle,
    /**
     *  Trigger button is pressed and released.
     */
    DJIHandheldTriggerStatusSingleClick,
    /**
     *  Trigger button is pressed twice quicky.
     */
    DJIHandheldTriggerStatusDoubleClick,
    /**
     *  Trigger button is pressed three times quickly.
     */
    DJIHandheldTriggerStatusTripleClick,
    /**
     *  Trigger button status is unknown.
     */
    DJIHandheldTriggerStatusUnknown = 0xFF,
};

/**
 *  Status of the handheld joystick in vertical direction.
 *  Used by Osmo Mobile only.
 */
typedef NS_ENUM (uint8_t, DJIHandheldJoystickVerticalDirection) {
    /**
     *  Joystick has no movement in the vertical direction.
     */
    DJIHandheldJoystickVerticalDirectionMiddle,
    /**
     *  Joystick is moved up in the vertical direction.
     */
    DJIHandheldJoystickVerticalDirectionUp,
    /**
     *  Joystick is moved down in the vertical direction.
     */
    DJIHandheldJoystickVerticalDirectionDown,
    /**
     *  Joystick status in the vertical direction is unknown.
     */
    DJIHandheldJoystickVerticalDirectionUnknown = 0xFF,
};

/**
 *  Status of the handheld joystick in horizontal direction.
 *  Used by Osmo Mobile only.
 */
typedef NS_ENUM (uint8_t, DJIHandheldJoystickHorizontalDirection) {
    /**
     *  Joystick has no movement in the horizontal direction.
     */
    DJIHandheldJoystickHorizontalDirectionMiddle,
    /**
     *  Joystick is moved left in the horizontal direction.
     */
    DJIHandheldJoystickHorizontalDirectionLeft,
    /**
     *  Joystick is moved right in the horizontal direction.
     */
    DJIHandheldJoystickHorizontalDirectionRight,
    /**
     *  Joystick status in the horizontal direction is unknown.
     */
    DJIHandheldJoystickHorizontalDirectionUnknown = 0xFF,
};

/**
 *  Handheld controller's current hardware state.
 *  Used by Osmo Mobile only.
 */
@interface DJIHandheldControllerHardwareState : NSObject

/**
 *  Status of the shutter button and record button.
 */
@property(nonatomic, readonly) DJIHandheldButtonStatus handheldButtonStatus;

/**
 *  Status of the trigger button.
 */
@property(nonatomic, readonly) DJIHandheldTriggerStatus triggerState;

/**
 *  Status of the joystick in vertical direction.
 */
@property(nonatomic, readonly) DJIHandheldJoystickVerticalDirection joystickVerticalDirection;

/**
 *  Status of the joystick in horizontal direction.
 */
@property(nonatomic, readonly) DJIHandheldJoystickHorizontalDirection joystickHorizontalDirection;

@end

NS_ASSUME_NONNULL_END
