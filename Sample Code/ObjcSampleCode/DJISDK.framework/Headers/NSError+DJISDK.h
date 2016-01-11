//
//  NSError+DJISDK.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*********************************************************************************/
#pragma mark - Error Domains
/*********************************************************************************/
/**
 *  SDK common error domain
 */
FOUNDATION_EXPORT NSString * _Nonnull const DJISDKErrorDomain;
/**
 *  SDK camera error domain
 */
FOUNDATION_EXPORT NSString *_Nonnull const DJISDKCameraErrorDomain;
/**
 *  SDK mission error domain
 */
FOUNDATION_EXPORT NSString *_Nonnull const DJISDKMissionErrorDomain;
/**
 *  SDK battery error domain
 */
FOUNDATION_EXPORT NSString *_Nonnull const DJISDKBatteryErrorDomain;
/**
 *  SDK gimbal error domain
 */
FOUNDATION_EXPORT NSString *_Nonnull const DJISDKGimbalErrorDomain;
/**
 *  SDK flight controller domain
 */
FOUNDATION_EXPORT NSString *_Nonnull const DJISDKFlightControllerErrorDomain;
/**
 *  SDK remote controller domain
 */
FOUNDATION_EXPORT NSString *_Nonnull const DJISDKRemoteControllerErrorDomain;
/**
 *  SDK registration error domain
 */
FOUNDATION_EXPORT NSString *_Nonnull const DJISDKRegistrationErrorDomain;

//-----------------------------------------------------------------
#pragma mark DJISDKRegistrationError
//-----------------------------------------------------------------
typedef NS_ENUM (NSInteger, DJISDKRegistrationError){
    /**
     *  The application is not able to connect to the internet the first time it registers.
     */
    DJISDKRegistrationErrorCouldNotConnectToInternet = -1L,

    /**
     *  The application key you provided is incorrect.
     */
    DJISDKRegistrationErrorInvalidAppKey = -2L,

    /**
     *  The network you are trying to reach is busy, or the server is unreachable.
     */
    DJISDKRegistrationErrorHTTPTimeout = -3L,

    /**
     *  The attempt to copy meta data from another registered device to the device that is
     *  currently connected is not allowed. For example, if a developer has two devices and
     *  the application is activated with the application key onto one of the devices, if the
     *  other device is plugged in and tries to register the application, this error will occur.
     */
    DJISDKRegistrationErrorDeviceDoesNotMatch = -4L,

    /**
     *  The bundle identifier of your application does not match the bundle identifier you
     *  registered on the website when you applied to obtain an application key.
     */
    DJISDKRegistrationErrorBundleIdDoesNotMatch = -5L,

    /**
     *  The application key is prohibited. This occurs when an application key that has already
     *  been released by DJI is revoked. Please contact DJI for assistance.
     */
    DJISDKRegistrationErrorAppKeyProhibited = -6L,

    /**
     *  There is a maximum number of devices one application key can be used to activate. The
     *  maximum number of devices is given when an application is registered on the DJI developer
     *  website. This error will occur if the maximum number of activations has been reached.
     */
    DJISDKRegistrationErrorMaxActivationCountReached = -7L,

    /**
     *  This error occurrs when an application key was given for a specific platform and is trying
     *  to be used to activate an application for another platform. For instance, if an application
     *  key was given for an iOS applicationa and is used to activate an Android application, this
     *  error will occur.
     */
    DJISDKRegistrationErrorAppKeyInvalidPlatformError = -8L,

    /**
     *  The application key does not exist. Please make sure the application key you are entering
     *  is correct.
     */
    DJISDKRegistrationErrorAppKeyDoesNotExist = -9L,

    /**
     *  There are two levels for the SDK framework, level 1 and level 2. If an application key was
     *  given under one level and is trying to be used to active an application using another level
     *  SDK framework, this error will occur.
     */
    DJISDKRegistrationErrorAppKeyLevelNotPermitted = -10L,

    /**
     *  There is a server error. Please contact DJI for assistance.
     */
    DJISDKRegistrationErrorServerParseFailure = -11L,

    /**
     *  There is a server error. Please contact DJI for assistance.
     */
    DJISDKRegistrationErrorServerWriteError = -12L,

    /**
     *  There is a server error. Please contact DJI for assistance.
     */
    DJISDKRegistrationErrorServerDataAbnormal = -13L,

    /**
     *  The activation data received from server
     *  valid. Please reconnect to the internet and try again.
     */
    DJISDKRegistrationErrorInvalidMetaData = -14L,

    /**
     *  No application key was inputted.
     */
    DJISDKRegistrationErrorEmptyAppKey = -15L,

    /**
     *  An unknown error occurred when the application was trying to register. Please contact DJI
     *  for assistance.
     */
    DJISDKRegistrationErrorUnknown = -999L
};

//-----------------------------------------------------------------
#pragma mark DJISDKError
//-----------------------------------------------------------------
typedef NS_ENUM (NSInteger, DJISDKError){
    /**
     *  Feature not supported error.
     */
    DJISDKErrorSDKFeatureNotSupported = -1000L,
    /**
     *  Application not activated error.
     */
    DJISDKErrorApplicationNotActivated = -1001L,
    /**
     *  SDKLevel not permitted error
     */
    DJISDKErrorSDKLevelNotPermitted = -1002L,
    /**
     *  Timeout error.
     */
    DJISDKErrorTimeout = -1003L,
    /**
     *  System busy error
     */
    DJISDKErrorSystemBusy = -1004L,
    /**
     *  Parameters invalid error
     */
    DJISDKErrorInvalidParameters = -1005L,
    /**
     *  Get parameter failed error.
     */
    DJISDKErrorParameterGetFailed = -1006L,
    /**
     *  Set parameter failed error.
     */
    DJISDKErrorParameterSetFailed = -1007L,
    /**
     *  Command execute failed error.
     */
    DJISDKErrorCommandExecutionFailed = -1008L,
    /**
     *  Send data failed error.
     */
    DJISDKErrorSendDataFailed = -1009L,
    /**
     *  Connection to SDK failed error.
     */
    DJISDKErrorConnectionToSDKFailed = -1010L,
    /**
     *  Server data not ready.
     */
    DJISDKErrorServerDataNotReady = -1011L,
    /**
     *  Product unknown.
     */
    DJISDKErrorProductUnknown = -1012L,
    /**
     *  Product not support.
     */
    DJISDKErrorProductNotSupport = -1013L,
    /**
     *  Device not found.
     */
    DJISDKErrorDeviceNotFound = -1014L,
    /**
     *  The command is not supported by the current firmware version.
     */
    DJISDKErrorNotSupportedByFirmware = -1015L,
    /**
     *  Not defined error.
     */
    DJISDKErrorNotDefined = -1999L,
};

//-----------------------------------------------------------------
#pragma mark DJISDKCameraError
//-----------------------------------------------------------------
typedef NS_ENUM (NSInteger, DJISDKCameraError){
    /**
     *  Not supported command or command not support in this firmware.
     */
    DJISDKCameraErrorFirmwareDoesNotSupportCommand = -3000L,
    /**
     *  Camera memory allocation failed error.
     */
    DJISDKCameraErrorMemoryAllocationFailed = -3001L,
    /**
     *  Camera busy or command could not execute in current state.
     */
    DJISDKCameraErrorCommandCurrentlyNotEnabled = -3002L,
    /**
     *  Camera time not synced.
     */
    DJISDKCameraErrorTimeNotSynced = -3003L,
    /**
     *  No SD card.
     */
    DJISDKCameraErrorSDCardNotInserted = -3004L,
    /**
     *  SD card full.
     */
    DJISDKCameraErrorSDCardFull = -3005L,
    /**
     *  SD card error.
     */
    DJISDKCameraErrorSDCardError = -3006L,
    /**
     *  Camera sensor error.
     */
    DJISDKCameraErrorSensorError = -3007L,
    /**
     *  Camera system error.
     */
    DJISDKCameraErrorSystemError = -3008L,
    /**
     *  Media type error.
     */
    DJISDKCameraErrorMediaTypeError = -3009L,
};

//-----------------------------------------------------------------
#pragma mark DJISDKFlightControllerError
//-----------------------------------------------------------------
typedef NS_ENUM (NSInteger, DJISDKFlightControllerError) {
    /**
     *  Mode error
     */
    DJISDKFlightControllerErrorModeError = -4000L,
    /**
     *  Aircraft too close to the home point.
     */
    DJISDKFlightControllerErrorNearHomePoint = -4001L,
    /**
     *  Aircraft currently running a mission
     */
    DJISDKFlightControllerErrorRunningMission = -4002L,
    /**
     *  Aircraft currently running virtual stick
     */
    DJISDKFlightControllerErrorRunningVirtualStick = -4003L,
    /**
     *  Aircraft not in the air.
     */
    DJISDKFlightControllerErrorAircraftNotInTheAir = -4004L,
    /**
     *  Aircraft flight limited.
     */
    DJISDKFlightControllerErrorFlightLimited = -4005L,
    /**
     *  Aircraft GPS weak
     */
    DJISDKFlightControllerErrorBadGPS = -4006L,
    /**
     *  Aircraft low battery
     */
    DJISDKFlightControllerErrorLowBattery = -4007L,
    /**
     *  Aircraft not record home point.
     */
    DJISDKFlightControllerErrorHomePointNotRecord = -4008L,
    /**
     *  Aircraft taking off
     */
    DJISDKFlightControllerErrorTakingOff = -4009L,
    /**
     *  Aircraft landing
     */
    DJISDKFlightControllerErrorLanding = -4010L,
    /**
     *  Aircraft going home
     */
    DJISDKFlightControllerErrorGoingHome = -4011L,
    /**
     *  Aircraft starting engine
     */
    DJISDKFlightControllerErrorStartingEngine = -4012L,
    /**
     *  Aircraft in a no fly zone.
     */
    DJISDKFlightControllerErrorInNoFlyZone = -4013,
    /**
     *  Compass calibration
     */
    DJISDKFlightControllerErrorCompassCalibration = -4013L,
    /**
     *  Gimbal not removed.
     */
    DJISDKFlightControllerErrorGimbalNotRemoved = -4014L,
    /**
     *  Try to turn off motors during flight.
     */
    DJISDKFlightControllerErrorAircraftFlying = -4015L,
    /**
     *  The new home point is too far.
     */
    DJISDKFlightControllerErrorHomePointTooFar = -4016L,
    /**
     *  The new home altitude is too low.
     */
    DJISDKFlightControllerErrorGoHomeAltitudeTooLow = -4017L,
    /**
     *  The new home altitude is too high.
     */
    DJISDKFlightControllerErrorGoHomeAltitudeTooHigh = -4018L,
    /**
     *  The remote controller's mode switch is not in correct mode.
     */
    DJISDKFlightControllerErrorRemoteControllerModeError = -4019L,
    /**
     *  The virtual stick control mode is not available.
     */
    DJISDKFlightControllerErrorVirtualStickControlModeError = -4020L,
};

//-----------------------------------------------------------------
#pragma mark DJISDKMissionError
//-----------------------------------------------------------------
typedef NS_ENUM (NSInteger, DJISDKMissionError){
    /**
     *  Mode error. Remote controller's mode switch should be in 'F' mode.
     */
    DJISDKMissionErrorModeError = -5000L,
    /**
     *  Aircraft's GPS too weak.
     */
    DJISDKMissionErrorAircraftBadGPS = -5001L,
    /**
     *  Aircraft's battery too low.
     */
    DJISDKMissionErrorAircraftLowBattery = -5002L,
    /**
     *  Aircraft's not in the air.
     */
    DJISDKMissionErrorAircraftNotInTheAir = -5003L,
    /**
     *  Aircraft's altitude too high.
     */
    DJISDKMissionErrorAircraftAltitudeTooHigh = -5004L,
    /**
     *  Aircraft's altitude too low.
     */
    DJISDKMissionErrorAircraftAltitudeTooLow = -5005L,
    /**
     *  Aircraft is taking off.
     */
    DJISDKMissionErrorAircraftTakingoff = -5006L,
    /**
     *  Aircraft is landing
     */
    DJISDKMissionErrorAircraftLanding = -5007L,
    /**
     *  Aircraft is going home
     */
    DJISDKMissionErrorAircraftGoingHome = -5008L,
    /**
     *  Aircraft is starting engine.
     */
    DJISDKMissionErrorAircraftStartingEngine = -5009L,
    /**
     *  Aircraft's home point not record.
     */
    DJISDKMissionErrorAircraftHomePointNotRecord = -5010L,
    /**
     *  Aircraft lost the follow target.
     */
    DJISDKMissionErrorAircraftLostFollowTarget = -5011L,
    /**
     *  Aircraft is in novince mode.
     */
    DJISDKMissionErrorAircraftInNoviceMode = -5012L,
    /**
     *  Aircraft is in no fly zone.
     */
    DJISDKMissionErrorAircraftInNoFlyZone = -5013L,
    /**
     *  Aircraft flight limited.
     */
    DJISDKMissionErrorAircraftFlightLimited = -5014L,
    /**
     *  Aircraft is running a mission.
     */
    DJISDKMissionErrorAircraftRunningMission = -5015L,
    /**
     *  Aircraft no running mission.
     */
    DJISDKMissionErrorAircraftNoRunningMission = -5016L,
    /**
     *  Aircraft no mission.
     */
    DJISDKMissionErrorAircraftNoMission = -5017L,
    /**
     *  Aircraft is near to the home point.
     */
    DJISDKMissionErrorAircraftNearHomePoint = -5018L,
    /**
     *  Aircraft is too far away to the mission.
     */
    DJISDKMissionErrorAircraftFarAwayMission = -5019L,
    /**
     *  Mission's parameters is invalid.
     */
    DJISDKMissionErrorMissionParametersInvalid = -5020L,
    /**
     *  Mission's total distance is too large.
     */
    DJISDKMissionErrorMissionTotalDistanceTooLarge = -5021L,
    /**
     *  Mission need too much time to execute.
     */
    DJISDKMissionErrorMissionNeedTooMuchTime = -5022L,
    /**
     *  Mission resume failed.
     */
    DJISDKMissionErrorMissionResumeFailed = -5023L,
    /**
     *  Command can not be executed.
     */
    DJISDKMissionErrorCommandCanNotExecute = -5024L,
    /**
     *  Aircraft already in command state. duplicate execute a same command will has this error.
     */
    DJISDKMissionErrorAircraftAlreadyInCommandState = -5025L,
    /**
     *  Mission not prepare
     */
    DJISDKMissionErrorMissionNotReady = -5026L,
    /**
     *  Custom mission step can not be paused.
     */
    DJISDKMissionErrorCustomMissionStepCannotPause = -5027L,
    /**
     * Custom mission is not initialized with the mission steps.  The Steps array is empty.
     */
    DJISDKMissionErrorCustomMissionStepsNotInitialized = -5028L,
    /**
     *  Current mission step is initializing.
     */
    DJISDKMissionErrorCustomMissionStepInitializing = -5029L,
};

/**
 *  NSError's DJISDK category. It contains methods to create custom NSErrors.
 *
 */
@interface NSError (DJISDK)

/**
 *  Get DJISDKError
 *
 *  @param errorCode errorCode for DJISDKError
 */
+ (_Nullable instancetype)DJISDKErrorForCode:(NSInteger)errorCode;

/**
 *  Get DJISDKCameraError
 *
 *  @param errorCode errorCode for DJISDKCameraError
 */
+ (_Nullable instancetype)DJISDKCameraErrorForCode:(NSInteger)errorCode;

/**
 *  Get DJISDKFlightControllerError
 *
 *  @param errorCode errorCode for DJISDKFlightControllerError
 */
+ (_Nullable instancetype)DJISDKFlightControllerErrorForCode:(NSInteger)errorCode;

/**
 *  Get DJISDKMissionError
 *
 *  @param errorCode errorCode for DJISDKMissionError
 */
+ (_Nullable instancetype)DJISDKMissionErrorForCode:(NSInteger)errorCode;

/**
 *  Get DJISDKRegistrationError
 *
 *  @param errorCode errorCode for DJISDKRegistrationError
 */
+ (_Nullable instancetype)DJISDKRegistrationErrorForCode:(DJISDKRegistrationError)errorCode;

/**
 *  Get DJISDKError
 *
 *  @param errorCode errorCode for DJISDKError
 *  @param errorDomain domain for DJISDKError
 *  @param desc desc for DJISDKError
 */
+ (_Nullable instancetype)DJISDKErrorForCode:(NSInteger)errorCode domain:(NSString *_Nonnull)errorDomain desc:(const NSString *_Nonnull)desc;

@end

NS_ASSUME_NONNULL_END