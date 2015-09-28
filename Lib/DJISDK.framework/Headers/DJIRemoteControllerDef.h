//
//  DJIRemoteControllerDef.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DJI_RC_NAME_BUFFER_SIZE         (6)

#define DJI_RC_CONTROL_CHANNEL_SIZE     (4)

#pragma pack(1)

/**
 *  RC work mode
 */
typedef NS_ENUM(uint8_t, DJIRCWorkMode){
    /**
     *  Master mode
     */
    RCWorkModeMaster,
    /**
     *  Slave mode
     */
    RCWorkModeSlave,
    /**
     *  Work mode close
     */
    RCWorkModeClosed,
    /**
     *  Work mode unknown
     */
    RCWorkModeUnknown,
};

/**
 *  RC Name
 */
typedef struct
{
    char mBuffer[DJI_RC_NAME_BUFFER_SIZE];
} DJIRCName;

/**
 *  RC Password
 */
typedef struct
{
    UInt16 mPassword;
} DJIRCPassword;

/**
 *  RC Identifier
 */
typedef struct
{
    uint32_t mID;
} DJIRCID;

/**
 *  RC Signal quality
 */
typedef struct
{
    uint8_t mQuality;
} DJIRCSignalQuality;

/**
 *  Control style for RC
 */
typedef NS_OPTIONS(uint8_t, DJIRCControlStyle){
    /**
     *  Japanese control style
     */
    RCControlStyleJapanese,
    /**
     *  American control style
     */
    RCControlStyleAmerican,
    /**
     *  Chinese control style
     */
    RCControlStyleChinese,
    /**
     *  Custom control style
     */
    RCControlStyleCustom,
    /**
     *  Default control style, for slave RC settings
     */
    RCSlaveControlStyleDefault = 0x00,
    /**
     *  Custom control style, for slave RC settings
     */
    RCSlaveControlStyleCustom = 0x01,
    /**
     *  Unknown control style
     */
    RCControlStyleUnknown = 0xFF,
};

/**
 *  RC control channel name
 */
typedef NS_ENUM(uint8_t, DJIRCControlChannelName){
    /**
     *  Control channel alieron
     */
    RCControlChannelAileron = 0x01,
    /**
     *  Control channel elevator
     */
    RCControlChannelElevator,
    /**
     *  Control channel throttle
     */
    RCControlChannelThrottle,
    /**
     *  Control channel rudder
     */
    RCControlChannelRudder,
    /**
     *  Control channel pitch, for slave RC settings
     */
    RCControlChannelPitch = 0x01,
    /**
     *  Control channel roll, for slave RC settings
     */
    RCControlChannelRoll,
    /**
     *  Control channel yaw, for slave RC settings
     */
    RCControlChannelYaw,
};

typedef struct
{
    /**
     *  Control channel. see DJI_RC_CONTROL_CHANNEL_xxx
     */
    DJIRCControlChannelName mChannel;
    /**
     *  Is this channel's control need to resverse
     */
    BOOL mReverse;
} DJIRCControlChannel;

typedef struct
{
    /**
     *  Control style. If set the slave, use RCSlaveControlStyleXXX
     */
    DJIRCControlStyle mControlStyle;
    
    /**
     *  Control channels for custom if the mControlStyle is RCCustomControlStyle
     */
    DJIRCControlChannel mControlChannel[DJI_RC_CONTROL_CHANNEL_SIZE];
} DJIRCControlMode;

/**
 *  Result of slave who request for gimbal control permission
 */
typedef NS_OPTIONS(uint8_t, DJIRCRequestGimbalControlResult){
    /**
     *  Request was agreed
     */
    RCRequestGimbalControlResultAgree,
    /**
     *  Request was denied
     */
    RCRequestGimbalControlResultDeny,
    /**
     *  Request was timeout
     */
    RCRequestGimbalControlResultTimeout,
    /**
     *  Request was Authorized
     */
    RCRequestGimbalControlResultAuthorized,
    /**
     *  Request was unknown
     */
    RCRequestGimbalControlResultUnknown,
};

typedef struct
{
    /**
     *  Has gimbal yaw control permission
     */
    bool mHasGimbalYawControlPermission;
    /**
     *  Has gimbal roll control permission
     */
    bool mHasGimbalRollControlPermission;
    /**
     *  Has gimbal pitch control permission
     */
    bool mHasGimbalPitchControlPermission;
    /**
     *  Has camera playback control permission
     */
    bool mHasPlaybackControlPermission;
    /**
     *  Has camera record control permission
     */
    bool mHasRecordControlPermission;
    /**
     *  Has camera capture control permission
     */
    bool mHasCaptureControlPermission;
} DJIRCControlPermission;

typedef struct
{
    /**
     *  Pitch speed
     */
    uint8_t mPitchSpeed;
    /**
     *  Roll speed
     */
    uint8_t mRollSpeed;
    /**
     *  Yaw speed
     */
    uint8_t mYawSpeed;
} DJIRCGimbalControlSpeed;

/**
 *  RC paring state
 */
typedef NS_ENUM(uint8_t, DJIRCParingState){
    /**
     *  RC not in paring state
     */
    RCParingStateNormal,
    /**
     *  RC is in paring
     */
    RCParingStateParing,
    /**
     *  RC paring completed
     */
    RCParingStateCompleted,
    /**
     *  RC Paring state unknown
     */
    RCParingStateUnknown,
};

/**
 *  Join master result
 */
typedef NS_ENUM(uint8_t, DJIRCJoinMasterResult){
    /**
     *  Join master Succeeded
     */
    RCJoinMasterSucceeded,
    /**
     *  Join master failed for the password error
     */
    RCJoinMasterPasswordError,
    /**
     *  Join request was rejected by master
     */
    RCJoinMasterRejected,
    /**
     *  Join master failed for the master's salve count has reach maximum
     */
    RCJoinMasterReachMaximum,
    /**
     *  Join master request timeout
     */
    RCJoinMasterResponseTimeout,
    /**
     *  Join master unknown
     */
    RCJoinMasterUnknown
};


typedef struct
{
    /**
     *  The remaining power of RC battery. mAh
     */
    uint32_t mRemainPower;
    /**
     *  The remaining power percent of RC battery. [0, 100]
     */
    uint8_t  mRemainPowerPercent;
} DJIRCBatteryInfo;

/**
 *  RC GPS Time
 */
typedef struct
{
    uint8_t  mHour;
    uint8_t  mMinute;
    uint8_t  mSecond;
    uint16_t mYear;
    uint8_t  mMonth;
    uint8_t  mDay;
} DJIRCGpsTime;

/**
 *  RC GPS Data
 */
typedef struct
{
    /**
     *  Gps time
     */
    DJIRCGpsTime mTime;
    /**
     *  Latitude (degree)
     */
    double mLatitude;
    /**
     *  Longitude (degree)
     */
    double mLongitude;
    /**
     *  Speed on X (m/s)
     */
    float mSpeedX;
    /**
     *  Speed on Y (m/s)
     */
    float mSpeedY;
    /**
     *  Current available satellite count
     */
    int mSatelliteCount;
    /**
     *  Accuracy (m)
     */
    float mAccuracy;
    /**
     *  Is Gps data valid
     */
    BOOL mIsValid;
} DJIRCGPSData;

/**
 *  Define RC's wheel how to control the gimbal.
 */
typedef NS_ENUM(uint8_t, DJIRCGimbalControlDirection){
    /**
     *  Control the gimbal's pitch
     */
    RCGimbalControlDirectionPitch,
    /**
     *  Control the gimbal's roll
     */
    RCGimbalControlDirectionRoll,
    /**
     *  Controll the gimbal's yaw
     */
    RCGimbalControlDirectionYaw,
};

/**
 *  Wheel on the top right of RC
 */
typedef struct
{
    /**
     *  Wheel value changed
     */
    BOOL mWheelChanged;
    /**
     *  Wheel pressed
     */
    BOOL mWheelButtonDown;
    /**
     *  Wheel offset sign(+/-), YES = +, NO = -
     */
    BOOL mWheelOffsetSign;
    /**
     *  Wheel offset value
     */
    uint8_t mWheelOffset;
} DJIRCHardwareRightWheel;

/**
 *  Wheel on the top left of RC
 */
typedef struct
{
    /**
     *  Wheel value in range [364, 1684]
     */
    uint16_t mValue;
} DJIRCHardwareLeftWheel;

/**
 *  Landing gear state
 */
typedef NS_ENUM(uint8_t, DJIRCHardwareLandingGearState){
    /**
     *  Landing gear ascent
     */
    RCHardwareLandingGearAscend,
    /**
     *  Landing gear descend
     */
    RCHardwareLandingGearDescend
};

/**
 *  Transform button
 */
typedef struct
{
    DJIRCHardwareLandingGearState mLandingGearState;
} DJIRCHardwareTransformButton;

typedef enum
{
    /**
     *  F mode on the left
     */
    RCHardwareModeSwitchF,
    /**
     *  A mode on the middle
     */
    RCHardwareModeSwitchA,
    /**
     *  P mode on the right
     */
    RCHardwareModeSwitchP,
} DJIRCHardwareModeSwitchState;

/**
 *  Mode switch on the top left of RC
 */
typedef struct
{
    DJIRCHardwareModeSwitchState mMode;
} DJIRCHardwareModeSwitch;

/**
 *  Button
 */
typedef struct
{
    /**
     *  Button state
     */
    BOOL mButtonDown;
} DJIRCHardwareButton;

/**
 *  Joystick
 */
typedef struct
{
    /**
     *  Joystick's channel value in range [364, 1684]
     */
    uint16_t mValue;
} DJIRCHardwareJoystick;

typedef struct
{
    /**
     *  Joystick
     */
    DJIRCHardwareJoystick mAileron;
    DJIRCHardwareJoystick mElevator;
    DJIRCHardwareJoystick mThrottle;
    DJIRCHardwareJoystick mRudder;
    
    /**
     *  Wheel on top left
     */
    DJIRCHardwareLeftWheel mLeftWheel;
    
    /**
     *  Wheel on top right
     */
    DJIRCHardwareRightWheel mRightWheel;
    
    /**
     *  Transform button
     */
    DJIRCHardwareTransformButton mTransformButton;
    
    /**
     *  Mode switch
     */
    DJIRCHardwareModeSwitch mModeSwitch;
    
    /**
     *  Go home button
     */
    DJIRCHardwareButton mGoHomeButton;

    /**
     *  Record button
     */
    DJIRCHardwareButton mRecordButton;
    
    /**
     *  Shutter button
     */
    DJIRCHardwareButton mShutterButton;
    
    /**
     *  Playback button
     */
    DJIRCHardwareButton mPlaybackButton;

    /**
     *  Custom button1 on the bottom left
     */
    DJIRCHardwareButton mCustomButton1;
    
    /**
     *  Custom button2 on the bottom right
     */
    DJIRCHardwareButton mCustomButton2;
} DJIRCHardwareState;

/**
 *  Remote controller's calibration state.
 */
typedef NS_ENUM(uint8_t, DJIRCCalibrationState){
    /**
     *  Normal state
     */
    RCCalibrationNormal,
    /**
     *  Record middle value
     */
    RCCalibrationRecordMiddleValue,
    /**
     *  Record extreme value
     */
    RCCalibrationRecordExtremeValue,
    /**
     *  Exit calibration
     */
    RCCalibrationExit,
};

#pragma pack()

@interface DJIRCInfo : NSObject
/**
 *  Remote Controller's Identifier
 */
@property(nonatomic, assign) DJIRCID identifier;

/**
 *  Remote Controller's Name
 */
@property(nonatomic, assign) DJIRCName name;

/**
 *  Remote Controller's Password
 */
@property(nonatomic, assign) DJIRCPassword password;

/**
 *  Remote Controller's Signal Quality
 */
@property(nonatomic, assign) DJIRCSignalQuality signalQuality;

/**
 *  Remote Controller's Control Permission
 */
@property(nonatomic, assign) DJIRCControlPermission controlPermission;

/**
 *  RC name convert from 'name' property
 *
 *  @return RC Name string
 */
-(NSString*) RCName;

/**
 *  RC password convert from 'password' property
 *
 *  @return RC Password string
 */
-(NSString*) RCPassword;

/**
 *  RC Identifier convert from 'identifier' property
 *
 *  @return RC Identifier string
 */
-(NSString*) RCIdentifier;

@end
