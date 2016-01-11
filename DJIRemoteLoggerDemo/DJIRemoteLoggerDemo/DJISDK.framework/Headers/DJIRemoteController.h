/*
 *  DJI iOS Mobile SDK Framework
 *  DJIRemoteController.h
 *
 *  Copyright (c) 2015, DJI.
 *  All rights reserved.
 *
 */

#import <CoreLocation/CoreLocation.h>
#import <DJISDK/DJIBaseComponent.h>

#define DJI_RC_NAME_BUFFER_SIZE         (6)

#define DJI_RC_CONTROL_CHANNEL_SIZE     (4)

NS_ASSUME_NONNULL_BEGIN

/*********************************************************************************/
#pragma mark - Data Structs and Enums
/*********************************************************************************/

#pragma pack(1)

//-----------------------------------------------------------------
#pragma mark DJIRemoteControllerMode
//-----------------------------------------------------------------
/**
 *  Remote Controller mode of operation can be normal (single RC connected to aircraft), master,
 *  slave,  or unknown
 */
typedef NS_ENUM(uint8_t, DJIRemoteControllerMode){
    /**
     *  Remote Controller is a master (will route a connected slave Remote Controller's commands to the aircraft).
     */
    DJIRemoteControllerModeMaster,
    /**
     *  Remote Controller is currently a slave Remote Controller (sends commands to aircraft through a master Remote Controller).
     */
    DJIRemoteControllerModeSlave,
    /**
     *  Remote Controller is unconnected to another Remote Controller.
     */
    DJIRemoteControllerModeNormal,
    /**
     *  The Remote Controller's mode is unknown.
     */
    DJIRemoteControllerModeUnknown,
};

//-----------------------------------------------------------------
#pragma mark DJIRCName
//-----------------------------------------------------------------
/**
 *  Remote Controller's name.
 */
typedef struct
{
    char buffer[DJI_RC_NAME_BUFFER_SIZE];
} DJIRCName;

//-----------------------------------------------------------------
#pragma mark DJIRCPassword
//-----------------------------------------------------------------
/**
 *  Remote Controller's password.
 */
typedef UInt16 DJIRCPassword;

//-----------------------------------------------------------------
#pragma mark DJIRCID
//-----------------------------------------------------------------
/**
 *  Remote Controller's unique identification number. This is given to each Remote
 *  Controller during manufacture and cannot be changed.
 */
typedef uint32_t DJIRCID;

//-----------------------------------------------------------------
#pragma mark DJIRCSignalQualityOfConnectedRC
//-----------------------------------------------------------------
/**
 *  Signal quality of a connected master or slave Remote Controller in percent [0, 100].
 */
typedef uint8_t DJIRCSignalQualityOfConnectedRC;

//-----------------------------------------------------------------
#pragma mark DJIRCControlStyle
//-----------------------------------------------------------------
/**
 *  Remote Controller's control style.
 *
 */
typedef NS_OPTIONS(uint8_t, DJIRCControlStyle){
    /**
     *  Remote Controller uses Japanese controls.
     */
    RCControlStyleJapanese,
    /**
     *  Remote Controller uses American controls.
     */
    RCControlStyleAmerican,
    /**
     *  Remote Controller uses Chinese controls.
     */
    RCControlStyleChinese,
    /**
     *  Remote Controller uses custom controls.
     */
    RCControlStyleCustom,
    /**
     *  Default Remote Controller controls and settings for slave
     *  Remote Controller.
     */
    RCSlaveControlStyleDefault,
    /**
     *  Custom controls and settings for slave Remote Controller.
     */
    RCSlaveControlStyleCustom,
    /**
     *  The Remote Controller's control style is
     *  unknown.
     */
    RCControlStyleUnknown,
};

//-----------------------------------------------------------------
#pragma mark DJIRCControlChannelName
//-----------------------------------------------------------------
/**
 *  Remote Controller control channels.
 */
typedef NS_ENUM(uint8_t, DJIRCControlChannelName){
    /**
     *  Throttle control channel.
     */
    DJIRCControlChannelNameThrottle,
    /**
     *  Pitch control channel for slave Remote Controller.
     *
     */
    DJIRCControlChannelNamePitch,
    /**
     *  Roll control channel for slave Remote Controller.
     */
    DJIRCControlChannelNameRoll,
    /**
     *  Yaw control channel for slave Remote Controller.
     */
    DJIRCControlChannelNameYaw,
};

//-----------------------------------------------------------------
#pragma mark DJIRCControlChannel
//-----------------------------------------------------------------
typedef struct
{
    /**
     *  Name of the control channel. The format of this
     *  is DJI_RC_CONTROL_CHANNEL_xxx. The default is American.
     */
    DJIRCControlChannelName channel;
    /**
     *  The control channel's settings will be reversed.
     *  For example, for throttle the joystick is moved up or
     *  down. If the control channel was reversed, the same motion
     *  that was once used for up would now move the aircraft
     *  down and the same motion that was once used for down would
     *  now move the aircraft up.
     */
    BOOL reverse;
} DJIRCControlChannel;

//-----------------------------------------------------------------
#pragma mark DJIRCControlMode
//-----------------------------------------------------------------
typedef struct
{
    /**
     *  The control style the Remote Controller is set to.
     */
    DJIRCControlStyle controlStyle;
    /**
     *  Setting controls for each of the channels.
     */
    DJIRCControlChannel controlChannel[DJI_RC_CONTROL_CHANNEL_SIZE];
} DJIRCControlMode;

//-----------------------------------------------------------------
#pragma mark DJIRCRequestGimbalControlResult
//-----------------------------------------------------------------
/**
 *  Result when a slave Remote Controller requests permission to control the gimbal.
 */
typedef NS_OPTIONS(uint8_t, DJIRCRequestGimbalControlResult){
    /**
     *  The master Remote Controller agrees to the slave's request.
     */
    RCRequestGimbalControlResultAgree,
    /**
     *  The master Remote Controller denies the slave's request. If the slave Remote Controller wants to control the gimbal, it must send a request to master Remote Controller first. Then the master Remote Controller can decide to approve or deny the request.
     */
    RCRequestGimbalControlResultDeny,
    /**
     *  The slave Remote Controller's request timed out.
     */
    RCRequestGimbalControlResultTimeout,
    /**
     *  The master Remote Controller authorizes the slave request to control the gimbal.
     */
    RCRequestGimbalControlResultAuthorized,
    /**
     *  The slave Remote Controller's request is unknown.
     */
    RCRequestGimbalControlResultUnknown,
};

//-----------------------------------------------------------------
#pragma mark DJIRCControlPermission
//-----------------------------------------------------------------
typedef struct
{
    /**
     *  TRUE if the Remote Controller has permission
     *  to control the gimbal yaw.
     */
    bool hasGimbalYawControlPermission;
    /**
     *  TRUE if the Remote Controller has permission
     *  to control the gimbal roll.
     */
    bool hasGimbalRollControlPermission;
    /**
     *  TRUE if the Remote Controller has permission
     *  to control the gimbal pitch.
     */
    bool hasGimbalPitchControlPermission;
    /**
     *  TRUE if the Remote Controller has permission
     *  to control camera playback.
     */
    bool hasPlaybackControlPermission;
    /**
     *  TRUE if the Remote Controller has permission
     *  to record video with the camera.
     */
    bool hasRecordControlPermission;
    /**
     *  TRUE if the Remote Controller has permission
     *  to take pictures with the camera.
     */
    bool hasCaptureControlPermission;
} DJIRCControlPermission;

//-----------------------------------------------------------------
#pragma mark DJIRCGimbalControlSpeed
//-----------------------------------------------------------------
typedef struct
{
    /**
     *  Gimbal's pitch speed.
     *
     */
    uint8_t pitchSpeed;
    /**
     *  Gimbal's roll speed.
     *
     */
    uint8_t rollSpeed;
    /**
     *  Gimbal's yaw speed.
     *
     */
    uint8_t yawSpeed;
} DJIRCGimbalControlSpeed;

//-----------------------------------------------------------------
#pragma mark DJIRCToAircraftPairingState
//-----------------------------------------------------------------
/**
 *  Remote Controller pairing state.
 */
typedef NS_ENUM(uint8_t, DJIRCToAircraftPairingState){
    /**
     *  The Remote Controller is not pairing.
     */
    DJIRCToAircraftPairingStateNotParing,
    /**
     *  The Remote Controller is currently pairing.
     */
    DJIRCToAircraftPairingStateParing,
    /**
     *  The Remote Controller's pairing was completed.
     */
    DJIRCToAircraftPairingStateCompleted,
    /**
     *  The Remote Controller's pairing state is unknown.
     */
    DJIRCToAircraftPairingStateUnknown,
};

//-----------------------------------------------------------------
#pragma mark DJIRCJoinMasterResult
//-----------------------------------------------------------------
/**
 *  Result when a slave Remote Controller tries to join
 *  a master Remote Controller.
 */
typedef NS_ENUM(uint8_t, DJIRCJoinMasterResult){
    /**
     *  The slave Remote Controller's attempt to join
     *  the master Remote Controller was successful.
     */
    DJIRCJoinMasterResultSuccessful,
    /**
     *  The slave Remote Controller's attempt to join
     *  the master Remote Controller was unsuccessful
     *  due to a password error.
     */
    DJIRCJoinMasterResultPasswordError,
    /**
     *  The slave Remote Controller's attempt to join
     *  the master Remote Controller was rejected.
     */
    DJIRCJoinMasterResultRejected,
    /**
     *  The slave Remote Controller's attempt to join
     *  the master Remote Controller was unsuccesful
     *  because the master Remote Controller is at the
     *  maximum number of slaves it can have.
     */
    DJIRCJoinMasterResultReachMaximum,
    /**
     *  The slave Remote Controller's attempt to join
     *  the master Remote Controller was unsuccessful
     *  because the request timed out.
     */
    DJIRCJoinMasterResultResponseTimeout,
    /**
     *  The result of the slave Remote Controller's
     *  attempt to join the master Remote Controller
     *  is unknown.
     */
    DJIRCJoinMasterResultUnknown
};

//-----------------------------------------------------------------
#pragma mark DJIRCBatteryInfo
//-----------------------------------------------------------------
typedef struct
{
    /**
     *  The remaining power in the Remote Controller's
     *  battery in milliamp hours (mAh).
     */
    uint32_t remainingEnergyInMAh;
    /**
     *  The remaining power in the Remote Controller's
     *  battery as a percentage in the range of [0, 100].
     */
    uint8_t  remainingEnergyInPercent;
} DJIRCBatteryInfo;

//-----------------------------------------------------------------
#pragma mark DJIRCGpsTime
//-----------------------------------------------------------------
/**
 *  Remote Controller's GPS time.
 */
typedef struct
{
    uint8_t  hour;
    uint8_t  minute;
    uint8_t  second;
    uint16_t year;
    uint8_t  month;
    uint8_t  day;
} DJIRCGpsTime;

//-----------------------------------------------------------------
#pragma mark DJIRCGPSData
//-----------------------------------------------------------------
/**
 *  Remote Controller's GPS data.
 */
typedef struct
{
    /**
     *  The Remote Controller's GPS time.
     */
    DJIRCGpsTime time;
    /**
     *  The Remote Controller's GPS latitude
     *  in degrees.
     */
    double latitude;
    /**
     *  The Remote Controller's GPS longitude
     *  in degrees.
     */
    double longitude;
    /**
     *  The Remote Controller's speed in the x
     *  direction in meters/second. The positive x direction is to the right of the aircraft.
     *
     */
    float speedX;
    /**
     *  The Remote Controller's speed in the y
     *  direction in meters/second. The positive y direction is to the front of the aircraft.
     *
     */
    float speedY;
    /**
     *  The number of GPS sattelites the Remote Controller sees.
     */
    int satelliteCount;
    /**
     *  The the margin of error, in meters, for the
     *  GPS location.
     */
    float accuracy;
    /**
     *  Whether or not the GPS data is valid. The data is not valid if there are too few satellites or the signal strength is too low.
     */
    BOOL isValid;
} DJIRCGPSData;

//-----------------------------------------------------------------
#pragma mark DJIRCGimbalControlDirection
//-----------------------------------------------------------------
/**
 *  Defines what the Gimbal Dial (upper left wheel on the Remote Controller) will control.
 */
typedef NS_ENUM(uint8_t, DJIRCGimbalControlDirection){
    /**
     *  The upper left wheel will control the gimbal's pitch.
     */
    DJIRCGimbalControlDirectionPitch,
    /**
     *  The upper left wheel will control the gimbal's roll.
     */
    DJIRCGimbalControlDirectionRoll,
    /**
     *  The upper left wheel will control the gimbal's yaw.
     */
    DJIRCGimbalControlDirectionYaw,
};

//-----------------------------------------------------------------
#pragma mark DJIRCHardwareRightWheel
//-----------------------------------------------------------------
/**
 *  Current state of the Camera Settings Dial (upper right wheel on the Remote Controller).
 */
typedef struct
{
    /**
     *  YES if wheel value has changed.
     */
    BOOL wheelChanged;
    /**
     *  YES if wheel is being pressed.
     */
    BOOL wheelButtonDown;
    /**
     *  YES if wheel is being turned in a clockwise direction.
     */
    BOOL wheelDirection;
    /**
     *  Wheel value in the range of [X,Y].
     *
     */
    uint8_t value;
} DJIRCHardwareRightWheel;

//-----------------------------------------------------------------
#pragma mark DJIRCHardwareLeftWheel
//-----------------------------------------------------------------
typedef struct
{
    /**
     *  Gimabl Dial's (upper left wheel) value in the range of [364, 1684].
     *
     */
    uint16_t value;
} DJIRCHardwareLeftWheel;

//-----------------------------------------------------------------
#pragma mark DJIRCHardwareTransformationSwitchState
//-----------------------------------------------------------------
/**
 *  Transformation Switch position states.
 */
typedef NS_ENUM(uint8_t, DJIRCHardwareTransformationSwitchState){
    /**
     *  Retract landing gear switch state
     */
    DJIRCHardwareTransformationSwitchStateRetract,
    /**
     *  Deploy landing gear switch state.
     */
    DJIRCHardwareTransformationSwitchStateDeploy
};

//-----------------------------------------------------------------
#pragma mark DJIRCHardwareTransformSwitch
//-----------------------------------------------------------------
/**
 *  Transformation Switch position. The Transformation Switch is around the Return To Home Button on Inspire, Inspire 1 and M100 Remote Controllers, and controls the state of the aircraft's landing gear.
 */
typedef struct
{
    DJIRCHardwareTransformationSwitchState transformationSwitchState;
} DJIRCHardwareTransformationSwitch;

//-----------------------------------------------------------------
#pragma mark DJIRCHardwareFlightModeSwitchState
//-----------------------------------------------------------------
typedef NS_ENUM(uint8_t, DJIRCHardwareFlightModeSwitchState)
{
    /**
     *  The Remote Controller's flight mode switch is set to the F (Function) mode on the left. Remote Controller must be in Function mode to enable communicaiton with the Mobile Device.
     *
     */
    DJIRCHardwareFlightModeSwitchStateF,
    /**
     *  The Remote Controller's flight mode switch is set to the A (Attitude) mode in the middle. Attitude mode does not use GPS and the vision system for hovering or flying, but uses the barometer to maintain alititude. If the GPS signal is strong enough, the aircraft can still return to home in this mode.
     */
    DJIRCHardwareFlightModeSwitchStateA,
    /**
     *  The Remote Controller's flight mode switch is set to the P (Positioning) mode on the right. Positioning mode can use both GPS and the vision system (when available) to fly and hover.
     */
    DJIRCHardwareFlightModeSwitchStateP,
} ;

//-----------------------------------------------------------------
#pragma mark DJIRCHardwareFlightModeSwitch
//-----------------------------------------------------------------
/**
 *  The value of the Remote Controller's flight mode switch.
 */
typedef struct
{
    DJIRCHardwareFlightModeSwitchState mode;
} DJIRCHardwareFlightModeSwitch;

//-----------------------------------------------------------------
#pragma mark DJIRCHardwareButton
//-----------------------------------------------------------------
/**
 *  Remote Controller has numerous momentary push buttons, which will use this state.
 */
typedef struct
{
    /**
     *  YES if button is pressed down.
     */
    BOOL buttonDown;
} DJIRCHardwareButton;

//-----------------------------------------------------------------
#pragma mark DJIRCHardwareJoystick
//-----------------------------------------------------------------
typedef struct
{
    /**
     *  Joystick's channel value in the range of [364, 1684]. This
     *  value may be different for the aileron, elevator, throttle, and rudder.
     *
     */
    uint16_t value;
} DJIRCHardwareJoystick;

//-----------------------------------------------------------------
#pragma mark DJIRCHardwareState
//-----------------------------------------------------------------
/**
 *  Remote Controller's current state.
 */
typedef struct
{
    /**
     *  Current state of the joystick.
     *
     */
    DJIRCHardwareJoystick leftHorizontal;
    DJIRCHardwareJoystick leftVertical;
    DJIRCHardwareJoystick rightVertical;
    DJIRCHardwareJoystick rigthHorizontal;

    /**
     *  Current state of the upper left wheel on the Remote Controller (Gimbal Dial).
     */
    DJIRCHardwareLeftWheel leftWheel;

    /**
     *  Current state of the upper right wheel on the Remote Controller (Camera Settings Dial).
     *
     */
    DJIRCHardwareRightWheel rightWheel;

    /**
     *  Current state of the Transformation Switch on the Remote Controller.
     *
     */
    DJIRCHardwareTransformationSwitch transformationSwitch;

    /**
     *  Current state of the Flight Mode Switch on the Remote Controller.
     *
     */
    DJIRCHardwareFlightModeSwitch flightModeSwitch;

    /**
     *  Current state of the Return To Home Button.
     *
     */
    DJIRCHardwareButton goHomeButton;

    /**
     *  Current state of the Video Recording Button.
     *
     */
    DJIRCHardwareButton recordButton;

    /**
     *  Current state of the Shutter Button.
     *
     */
    DJIRCHardwareButton shutterButton;

    /**
     *  Current state of the Playback Button.
     *
     */
    DJIRCHardwareButton playbackButton;

    /**
     *  Current state of custom button 1 (left Back Button).
     *
     */
    DJIRCHardwareButton customButton1;

    /**
     *  Current state of custom button 2 (right Back Button).
     *
     */
    DJIRCHardwareButton customButton2;
} DJIRCHardwareState;

//-----------------------------------------------------------------
#pragma mark DJIRCCalibrationState
//-----------------------------------------------------------------
/**
 *  Remote Controller's calibration state.
 */
typedef NS_ENUM(uint8_t, DJIRCCalibrationState){
    /**
     *  There is currently no Remote Controller calibration happening.
     */
    DJIRCCalibrationStateNotCalibrating,
    /**
     *  Currently recording the joystick in its center position (joystick is untouched).
     */
    DJIRCCalibrationStateRecordingCenterPosition,
    /**
     *  Currently recording the extreme joystick positions, when joysticks
     *  are all the way to their max in any direction (left, right, up, or down).
     */
    DJIRCCalibrationStateRecordingExtremePositions,
    /**
     *  The Remote Controller is exiting calibration.
     */
    DJIRCCalibrationStateExit,
};

#pragma pack()

/*********************************************************************************/
#pragma mark - DJIRCInfo
/*********************************************************************************/

@interface DJIRCInfo : NSObject
/**
 *  Remote Controller's unique identifier.
 */
@property(nonatomic, assign) DJIRCID identifier;

/**
 *  Remote Controller's name.
 */
@property(nonatomic, assign) DJIRCName name;

/**
 *  Remote Controller's password.
 */
@property(nonatomic, assign) DJIRCPassword password;

/**
 *  Signal quality of a conneected master or slave Remote Controller.
 */
@property(nonatomic, assign) DJIRCSignalQualityOfConnectedRC signalQuality;

/**
 *  Remote Controller's control permissions.
 */
@property(nonatomic, assign) DJIRCControlPermission controlPermission;

/**
 *  Converts the Remote Controller's name from the property 'name' to a string.
 *
 *  @return Remote Controller's name as a string.
 */
-(NSString*) RCName;

/**
 *  Converts the Remote Controller's password from the property 'password' to a string.
 *
 *  @return Remote Controller's password as a string.
 */
-(NSString*) RCPassword;

/**
 *  Converts the Remote Controller's unique identifier from the property 'identifier' to a string.
 *
 *  @return Remote Controller's identifier as a string.
 */
-(NSString*) RCIdentifier;

@end

/*********************************************************************************/
#pragma mark - DJIRemoteControllerDelegate
/*********************************************************************************/

@class DJIRemoteController;


@protocol DJIRemoteControllerDelegate <NSObject>

@optional

/**
 *  Callback function that updates the Remote Controller's current hardware state.
 *
 *  @param rc    Instance of the Remote Controller for which the hardware state will be updated.
 *  @param state Current state of the Remote Controller's hardware state.
 */
-(void) remoteController:(DJIRemoteController*)rc didUpdateHardwareState:(DJIRCHardwareState)state;

/**
 *  Callback function that updates the Remote Controller's current GPS data.
 *
 *  @param rc    Instance of the Remote Controller for which the GPS data will be updated.
 *  @param state Current state of the Remote Controller's GPS data.
 */
-(void) remoteController:(DJIRemoteController*)rc didUpdateGpsData:(DJIRCGPSData)gpsData;

/**
 *  Callback function that updates the Remote Controller's current battery state.
 *
 *  @param rc    Instance of the Remote Controller for which the battery state will be updated.
 *  @param state Current state of the Remote Controller's battery state.
 */
-(void) remoteController:(DJIRemoteController *)rc didUpdateBatteryState:(DJIRCBatteryInfo)batteryInfo;

/**
 *  Callback function that gets called when a slave Remote Controller makes a request to a master
 *  Remote Controller to control the gimbal using the method requestGimbalControlRightWithCallbackBlock.
 *
 *  @param rc    Instance of the Remote Controller.
 *  @param state Information of the slave making the request to the master Remote Controller.
 */
-(void) remoteController:(DJIRemoteController *)rc didReceiveGimbalControlRequestFromSlave:(DJIRCInfo*)slave;

@end

/*********************************************************************************/
#pragma mark - DJIRemoteController
/*********************************************************************************/

@class DJIWiFiLink;

@interface DJIRemoteController : DJIBaseComponent

@property(nonatomic, weak) id<DJIRemoteControllerDelegate> delegate;

@property(nonatomic, strong) DJIWiFiLink *wifiLink;

/**
 *  Query method to check if the Remote Controller supports WiFi (between Mobile Device and Remote Controller).
 *
 */
-(BOOL) isRCWiFiSettingSupported;

/**
 *  Sets the Remote Controller's name.
 *
 *  @param name  Remote Controller name to be set.
 *  @param completion Completion block.
 */
-(void) setRCName:(DJIRCName)name withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the Remote Controller's name.
 *
 */
-(void) getRCNameWithCompletion:(void(^)(DJIRCName name, NSError* _Nullable error))completion;

/**
 *  Sets the Remote Controller's password.
 *
 *  @param password Remote Controller password to be set.
 *  @param block    Completion block.
 */
-(void) setRCPassword:(DJIRCPassword)password withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the Remote Controller's password.
 *
 */
-(void) getRCPasswordWithCompletion:(void(^)(DJIRCPassword password, NSError* _Nullable error))completion;

/**
 *  Sets the Remote Controller's control mode.
 *
 *  @param mode  Remote Controller control mode to be set.
 *  @param completion Completion block.
 */
-(void) setRCControlMode:(DJIRCControlMode)mode withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the master Remote Controller's control mode.
 *
 */
-(void) getRCControlModeWithCompletion:(void(^)(DJIRCControlMode mode, NSError* _Nullable error))completion;

//-----------------------------------------------------------------
#pragma mark RC pairing
//-----------------------------------------------------------------
/**
 *  Enters pairing mode, where the Remote Controller starts pairing with the aircraft.
 *  This method is used when the Remote Controller no longer recognizes which aircraft
 *  it is paired with.
 */
-(void) enterRCToAircraftPairingModeWithCompletion:(DJICompletionBlock)completion;

/**
 *  Exits pairing mode.
 *
 */
-(void) exitRCToAircraftPairingModeWithCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the pairing status as the Remote Controller is pairing with the aircraft.
 *
 */
-(void) getRCToAircraftPairingStateWithCompletion:(void(^)(DJIRCToAircraftPairingState state, NSError* _Nullable error))completion;
//-----------------------------------------------------------------
#pragma mark RC calibration
//-----------------------------------------------------------------
/**
 *  Gets the Remote Controller's calibration state.
 *
 */
-(void) getRCCalibrationStateWithCompletion:(void(^)(DJIRCCalibrationState state, NSError* _Nullable error))completion;

/**
 *  Record the Remote Controller's joystick's center position (when the joysticks are untouched). The center position must be recorded for at least 10ms for successful calibration.

    To calibrate the joysticks completely, call @b recordRCCalibrationCenterPositionWithCompletion (and record for 10ms), then call @b recordRCCalibrationCenterPositionWithCompletion (and record for two full circles of the joysticks), then call @b exitRCCalibrationWithCompletion.

 */
-(void) recordRCCalibrationCenterPositionWithCompletion:(void(^ _Nullable)(DJIRCCalibrationState state, NSError* _Nullable error))completion;

/**
 *  Record the Remote Controller's joystick's extreme positions (when the joystickare at their max in any direction). The joysticks should go through at least two complete extreme circles for successful calibration.

    To calibrate the joysticks completely, call @b recordRCCalibrationCenterPositionWithCompletion (and record for 10ms), then call @b recordRCCalibrationCenterPositionWithCompletion (and record for two full circles of the joysticks), then call @b exitRCCalibrationWithCompletion.

 */
-(void) recordRCCalibrationExtremePositionsWithCompletion:(void(^ _Nullable)(DJIRCCalibrationState state, NSError* _Nullable error))completion;

/**
 *  Exits Remote Controller calibration.

    To calibrate the joysticks completely, call @b recordRCCalibrationCenterPositionWithCompletion (and record for 10ms), then call @b recordRCCalibrationCenterPositionWithCompletion (and record for two full circles of the joysticks), then call @b exitRCCalibrationWithCompletion.

 */
-(void) exitRCCalibrationWithCompletion:(void(^ _Nullable)(DJIRCCalibrationState state, NSError* _Nullable error))completion;


//-----------------------------------------------------------------
#pragma mark RC gimbal control
//-----------------------------------------------------------------
/**
 *  Sets the gimbal's pitch speed for the Remote Controller's upper left wheel (Gimbal Dial).
 *
 *  @param speed Speed to be set for the gimbal's pitch, which should in the range of [0, 100],
 *  where 0 represents very slow and 100 represents very fast.
 *  @param completion Completion block.
 */
-(void) setRCWheelGimbalSpeed:(uint8_t)speed withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the gimbal's pitch speed for the Remote Controller's upper left wheel (Gimabl Dial).
 *
 */
-(void) getRCWheelGimbalSpeedWithCompletion:(void(^)(uint8_t speed, NSError* _Nullable error))completion;

/**
 *  Sets which of the gimbal directions the top left wheel (Gimabl Dial) on the Remote Controller will control. The
 *  three options (pitch, roll, and yaw) are outlined in the enum named DJIRCGimbalControlDirection
 *  in DJIRemoteControllerDef.h.
 *
 *  @param direction Gimbal direction to be set that the top left wheel on the Remote Controller
 *  will control.
 *  @param completion Completion block.
 */
-(void) setRCControlGimbalDirection:(DJIRCGimbalControlDirection)direction withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets which of the gimbal directions the top left wheel (Gimabl Dial) on the Remote Controller will control.
 *
 */
-(void) getRCControlGimbalDirectionWithCompletion:(void(^)(DJIRCGimbalControlDirection direction, NSError* _Nullable error))completion;

//-----------------------------------------------------------------
#pragma mark RC custom buttons
//-----------------------------------------------------------------
/**
 *  Sets custom button's (Back Button's) tags, which can be used by the user to record user settings for a particular Remote Controller. Unlike all other buttons, switches and sticks on the Remote Controller, the custom buttons only send state to the Mobile Device and not the aircraft.
 *
 *  @param tag1   Button 1's custom tag.
 *  @param tag2   Button 2's custom tag.
 *  @param completion Completion block.
 */
-(void) setRCCustomButton1Tag:(uint8_t)tag1 customButton2Tag:(uint8_t)tag2 withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the custom button's (Back Button's) tags.
 *
 */
-(void) getRCCustomButtonTagWithCompletion:(void(^)(uint8_t tag1, uint8_t tag2, NSError* _Nullable error))completion;

//-----------------------------------------------------------------
#pragma mark RC master and slave mode
//-----------------------------------------------------------------

/**
 *  Query method to check if the Remote Controller supports master/slave mode.
 */
-(BOOL) isMasterSlaveModeSupported;

/**
 *  Sets the Remote Controller's mode. See DJIRemoteControllerMode enum for all possible Remote Controller modes.
 *  The master and slave modes are only supported for the Inspire 1, Inspire 1 Pro and M100.
 *
 *  @param mode  Mode of type DJIRemoteControllerMode to be set for the Remote Controller.
 *  @param completion Completion block.
 */
-(void) setRemoteControllerMode:(DJIRemoteControllerMode)mode withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the Remote Controller's mode.
 *
 */
-(void) getRemoteControllerModeWithCompletion:(void(^)(DJIRemoteControllerMode mode, BOOL isConnected, NSError* _Nullable error))completion;

//-----------------------------------------------------------------
#pragma mark RC master and slave mode - Slave RC methods
//-----------------------------------------------------------------

/**
 *  Used by a slave Remote Controller to join a master Remote Controller. If the master Remote Controller accepts the request, the master Remote Controller will control the aircraft and the slave Remote Controller will control the gimbal and/or be able to view the downlink video.
 *
 *  @param hostId   Master's unique identifier
 *  @param name     Master's name
 *  @param password Master's password
 *  @param block    Remote execution result callback block.
 */
-(void) joinMasterWithID:(DJIRCID)masterId masterName:(DJIRCName)masterName masterPassword:(DJIRCPassword)masterPassword withCompletion:(void(^)(DJIRCJoinMasterResult result, NSError* _Nullable error))completion;

/**
 *  Returns the master Remote Controller's information, which includes the unique identifier, name, and password.
 *
 */
-(void) getJoinedMasterNameAndPassword:(void(^)(DJIRCID masterId, DJIRCName masterName, DJIRCPassword masterPassword, NSError* _Nullable error))completion;

/**
 *  Starts search by slave Remote Controller for nearby master Remote Controllers. To get the list of master Remote Controllers use getAvailableMastersWithCallbackBlock then call stopMasterRCSearchWithCompletion to end th search.
 *
 */
-(void) startMasterRCSearchWithCompletion:(DJICompletionBlock)completion;

/**
 *  Returns all available master Remote Controllers nearby. Before this method can be used, the method startMasterRCSearchWithCompletion needs to be called to start the search for master Remote Controllers. Once the list of masters is received, call stopMasterRCSearchWithCompletion to end the search.
 *
 */
-(void) getAvailableMastersWithCompletion:(void(^)(NSArray<DJIRCInfo *> * masters, NSError* _Nullable error))completion;

/**
 *  Used by a slave Remote Controller to stop the search for nearby master Remote Controllers.
 *
 */
-(void) stopMasterRCSearchWithCompletion:(DJICompletionBlock)completion;

/**
 *  Returns the state of the master Remote Controller search. The search is initiated by the Mobile Device, but performed by the Remote Controller. Therefore, if the Mobile Device's application crashes while a search is ongoing, this method can be used to let the new instance of the application understand the Remote Controller state.
 *
 */
-(void) getMasterRCSearchStateWithCompletion:(void(^)(BOOL isStarted, NSError* _Nullable error))completion;

/**
 *  Removes a master Remote Controller from the current slave Remote Controller.
 *
 *  @param masterId The connected master's identifier
 *  @param completion Completion block
 */
-(void) removeMaster:(DJIRCID)masterId withCompletion:(DJICompletionBlock)completion;

/**
 *  Called by the slave Remote Controller to request gimbal control from the master Remote Controller.
 *s
 */
-(void) requestGimbalControlRightWithCompletion:(void(^)(DJIRCRequestGimbalControlResult result, NSError* _Nullable error))completion;

/**
 *  Sets the Remote Contoller's slave control mode.
 *
 *  @param mode  Control mode to be set. the mode's style should be RCSlaveControlStyleXXX
 *  @param completion Completion block
 */
-(void) setSlaveControlMode:(DJIRCControlMode)mode withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the Remote Controller's slave control mode.
 *
 */
-(void) getSlaveControlModeWithCompletion:(void(^)(DJIRCControlMode mode, NSError* _Nullable error))completion;

/**
 *  Called by the slave Remote Controller to set the gimbal's pitch, roll, and yaw speed with range [0, 100].
 *
 *  @param speed Gimal's pitch, roll, and yaw speed with range [0, 100].
 *  @param completion Completion block
 */
-(void) setSlaveJoystickControlGimbalSpeed:(DJIRCGimbalControlSpeed)speed withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the current slave's gimbal's pitch, roll, and yaw speed with range [0, 100].
 *
 */
-(void) getSlaveJoystickControlGimbalSpeedWithCompletion:(void(^)(DJIRCGimbalControlSpeed speed, NSError* _Nullable error))completion;


//-----------------------------------------------------------------
#pragma mark RC master and slave mode - Master RC methods
//-----------------------------------------------------------------

/**
 *  Used by the current master Remote Controller to get all the slaves connected to it.
 *
 *  @param block Remote execution result callback block. The arrray of slaves contains objects
 *  of type DJIRCInfo.
 */
-(void) getSlaveListWithCompletion:(void(^)(NSArray<DJIRCInfo *> * slaveList, NSError* _Nullable error))block;

/**
 *  Removes a slave Remote Controller from the current master Remote Controller.
 *
 *  @param slaveId Target slave to be remove.
 *  @param completion Completion block
 */
-(void) removeSlave:(DJIRCID)slaveId withCompletion:(DJICompletionBlock)completion;

/**
 *  Sets the slave's control permissions (called by the master Remote Controller).
 *
 *  @param slaveId    Slave for which control permissions need to be set.
 *  @param permission Control permissions that need to be set for the slave.
 *  @param completion Completion block
 */
-(void) setSlave:(DJIRCID)slaveId controlPermission:(DJIRCControlPermission)permission withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the slave's Remote Controller control permissions. In order to get the control permissions for a specific
 *  slave Remote Controller , check each index of the array of slaves until you have retrieved
 *  the slave Remote Controller for which you want to get the control permissions.
 *
 *  @param completion Completion block. The array of slaves contains objects of type DJIRCInfo.
 */
-(void) getSlaveControlPermission:(void(^)(NSArray<DJIRCInfo *> * slaveList, NSError* _Nullable error))completion;

/**
 *  When a slave Remote Controller requests a master Remote Controller to control the gimbal, this
 *  method is used by a master Remote Controller to respond to the slave Remote Controller's request.
 *
 *  @param requesterId The slave Remote Controller's identifier.
 *  @param isAgree     Whether or not the master Remote Controller agrees or disagrees to give the slave
 *  Remote Controller the right to control the gimbal.
 */
-(void) responseRequester:(DJIRCID)requesterId forGimbalControlRight:(BOOL)isAgree;

@end
NS_ASSUME_NONNULL_END
