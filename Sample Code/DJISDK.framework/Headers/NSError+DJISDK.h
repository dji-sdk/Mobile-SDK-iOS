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
/**
 *  SDK GEO error domain
 */
FOUNDATION_EXPORT NSString *_Nonnull const DJISDKGEOErrorDomain;

/*********************************************************************************/
#pragma mark DJISDKRegistrationError
/*********************************************************************************/

/**
 *  The Error of SDK Registration
 */
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
     *  The activation data received from server is invalid. Please reconnect to
     *  the internet and try again.
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

/*********************************************************************************/
#pragma mark DJISDKError
/*********************************************************************************/

/**
 *  DJI SDK Error
 */
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
     *  The received data is invalid.
     */
    DJISDKErrorReceivedDataInvalid = -1016L,
    /**
     *  No data is received.
     */
    DJISDKErrorNoReceivedData = -1017L,
    /**
     *  The Bluetooth is off. Turn it on in iOS settings menu.
     */
    DJISDKErrorBluetoothOff = -1018L,
    /**
     *  Not defined error.
     */
    DJISDKErrorNotDefined = -1999L,
};

/*********************************************************************************/
#pragma mark DJISDKCameraError
/*********************************************************************************/

/**
 *  DJI SDK Camera Error
 */
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
     *  The command is not supported by the media file type.
     */
    DJISDKCameraErrorMediaTypeError = -3009L,
    /**
     *  The media file is not found in SD card.
     */
    DJISDKCameraErrorNoSuchMediaFile = -3010L,
    /**
     *  The command is aborted unexpectedly.
     */
    DJISDKCameraErrorMediaCommandAborted = -3011L,
    /**
     *  Data is corrupted during the file transmission.
     */
    DJISDKCameraErrorMediaFileDataCorrupted = -3012L,
    /**
     *  The media command is invalid.
     */
    DJISDKCameraErrorInvalidMediaCommand = -3013L,
    /**
     *  There is no permission to access the media file.
     */
    DJISDKCameraErrorNoPermission = -3014L,
    /**
     *  The download process of DJIPlaybackManager is interrupted.
     */
    DJISDKCameraErrorPlaybackDownloadInterruption = -3015L,
    /**
     *  There is no downloading files to stop.
     */
    DJISDKCameraErrorPlaybackNoDownloadingFiles = -3016L,
};

/*********************************************************************************/
#pragma mark DJISDKFlightControllerError
/*********************************************************************************/

/**
 *  DJI SDK Flight Controller Error
 */
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
     *  Aircraft home point not recorded.
     */
    DJISDKFlightControllerErrorHomePointNotRecorded = -4008L,
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
    DJISDKFlightControllerErrorInNoFlyZone = -4013L,
    /**
     *  Command can not be executed because the motors started.
     */
    DJISDKFlightControllerErrorMotorsStarted = -4013L,
    /**
     *  Aircraft could not enter transport mode, since the gimbal is still connected.
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
    /**
     *  The aircraft is not at auto landing state.
     */
    DJISDKFlightControllerErrorAircraftNotAutoLanding = -4021L,
    /**
     *  The aircraft is not at go home state.
     */
    DJISDKFlightControllerErrorAircraftNotGoingHome = -4022L,
    /**
     *  RTK cannot start properly. Please reboot.
     */
    DJISDKFlightControllerErrorRTKStartError = -4023L,
    /**
     *  Connection between base station and mobile station is broken.
     */
    DJISDKFlightControllerErrorRTKConnectionBroken = -4024L,
    /**
     *  RTK base station antenna error. Check if the antenna is connected to the correct port.
     */
    DJISDKFlightControllerErrorRTKBSAntennaError = -4025L,
    /**
     *  RTK base station's coordinate resets.
     */
    DJISDKFlightControllerErrorRTKBSCoordinatesReset = -4026L,
    /**
     *  Illegal battery.
     */
    DJISDKFlightControllerErrorIllegalBattery = -4027L,
};

/*********************************************************************************/
#pragma mark DJISDKMissionError
/*********************************************************************************/

/**
 *  DJI SDK Mission Error
 */
typedef NS_ENUM (NSInteger, DJISDKMissionError){
    /**
     *  Mode error. For products except Phantom 4, please make sure the remote controller's mode switch is in 'F' mode. For Phantom 4, please make sure the remote controller's mode switch is in 'P' mode.
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
     *  The aircraft is not in the air.
     */
    DJISDKMissionErrorAircraftNotInTheAir = -5003L,
    /**
     *  The aircraft's altitude is too high.
     */
    DJISDKMissionErrorAircraftAltitudeTooHigh = -5004L,
    /**
     *  The aircraft's altitude is too low.
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
     *  Aircraft's home point is not recordeded.
     */
    DJISDKMissionErrorAircraftHomePointNotRecorded = -5010L,
    /**
     *  Aircraft lost the follow target.
     */
    DJISDKMissionErrorAircraftLostFollowMeTarget = -5011L,
    /**
     *  Aircraft is in novice mode.
     */
    DJISDKMissionErrorAircraftInNoviceMode = -5012L,
    /**
     *  Aircraft is in a no fly zone.
     */
    DJISDKMissionErrorAircraftInNoFlyZone = -5013L,
    /**
     *  The aircraft has reached the flight limitation.
     */
    DJISDKMissionErrorReachFlightLimitation = -5014L,
    /**
     *  Aircraft is running a mission.
     */
    DJISDKMissionErrorAircraftRunningMission = -5015L,
    /**
     *  Aircraft is not running a mission.
     */
    DJISDKMissionErrorAircraftNoRunningMission = -5016L,
    /**
     *  No aircraft mission.
     */
    DJISDKMissionErrorAircraftNoMission = -5017L,
    /**
     *  Aircraft is near the home point.
     */
    DJISDKMissionErrorAircraftNearHomePoint = -5018L,
    /**
     *  Aircraft is too far away from the mission.
     */
    DJISDKMissionErrorAircraftFarAwayMission = -5019L,
    /**
     *  Mission's parameters are invalid.
     */
    DJISDKMissionErrorMissionParametersInvalid = -5020L,
    /**
     *  Mission's total distance is too large.
     */
    DJISDKMissionErrorMissionTotalDistanceTooLarge = -5021L,
    /**
     *  Mission needs too much time to execute.
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
     *  Aircraft already in command state. Repeating the same command results in this error.
     */
    DJISDKMissionErrorAircraftAlreadyInCommandState = -5025L,
    /**
     *  Mission not prepared.
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
    /**
     *  The tracking target is lost.
     */
    DJISDKMissionErrorTrackingTargetLost = -5030L,
    /**
     *  No live video feed is captured for the ActiveTrack Mission.
     */
    DJISDKMissionErrorNoVideoFeed = -5031L,
    /**
     *  The frame rate of the live video feed is too low.
     */
    DJISDKMissionErrorVideoFrameRateTooLow = -5032L,
    /**
     *  The vision system cannot get the authorization to control the aircraft.
     */
    DJISDKMissionErrorVisionSystemNotAuthorized = -5033L,
    /**
     *  The vision system encounters system error.
     */
    DJISDKMissionErrorVisionSystemError = -5034L,
    /**
     *  The aircraft cannot bypass the obstacle.
     */
    DJISDKMissionErrorCannotBypassObstacle = -5035L,
    /**
     *  Mission is stopped by the user.
     */
    DJISDKMissionErrorStoppedByUser = -5036L,
    /**
     *  The vision system requires calibration.
     */
    DJISDKMissionErrorVisionSystemNeedCalibration = -5037L,
    /**
     *  The vision sensors are overexposed.
     */
    DJISDKMissionErrorVisionSensorOverexposed = -5038L,
    /**
     *  The vision sensors are underexposed.
     */
    DJISDKMissionErrorVisionSensorUnderexposed = -5039L,
    /**
     *  The data from the vision system is abnormal.
     */
    DJISDKMissionErrorVisionDataAbnormal = -5040L,
    /**
     *  The feature points found by both vision sensors cannot match.
     */
    DJISDKMissionErrorFeaturePointCannotMatch = -5041L,
    /**
     *  The tracking rectangle is too small.
     */
    DJISDKMissionErrorTrackingRectTooSmall = -5042L,
    /**
     *  The tracking rectangle is too large.
     */
    DJISDKMissionErrorTrackingRectTooLarge = -5043L,
    /**
     *  The tracking target doesn't have enough features to lock onto.
     */
    DJISDKMissionErrorTrackingTargetNotEnoughFeature = -5044L,
    /**
     *  The Tracking target is too close to the aircraft.
     */
    DJISDKMissionErrorTrackingTargetTooClose = -5045L,
    /**
     *  The tracking target is too far away from the aircraft.
     */
    DJISDKMissionErrorTrackingTargetTooFar = -5046L,
    /**
     *  The tracking target is too high.
     */
    DJISDKMissionErrorTrackingTargetTooHigh = -5047L,
    /**
     *  The tracking target is shaking too much.
     */
    DJISDKMissionErrorTrackingTargetShaking = -5048L,
    /**
     *  The ActiveTrack mission is too unsure the tracking object and confirmation is required.
     */
    DJISDKMissionErrorTrackingTargetLowConfidence = -5049L,
    /**
     *  Mission is paused by user.
     */
    DJISDKMissionErrorMissionPausedByUser = -5050L,
    /**
     *  Gimbal pitch is too low.
     */
    DJISDKMissionErrorGimbalPitchTooLow = -5051L,
    /**
     *  Gimbal pitch is too large.
     */
    DJISDKMissionErrorGimbalPitchTooLarge = -5052L,
    /**
     *  Encounter an obstacle.
     */
    DJISDKMissionErrorObstacleDetected = -5053L,
    /**
     *  TapFly direction invalid.
     */
    DJISDKMissionErrorTapFlyDirectionInvalid = -5054L,
    /**
     *  The front vision system is not available.
     */
    DJISDKMissionErrorVisionSystemNotAvailable = -5055L,
    /**
     *  The initialization of the mission failed.
     */
    DJISDKMissionErrorInitializationFailed = -5056L,
    /**
     *  Mission can not pause or resume.
     */
    DJISDKMissionErrorCannotPauseOrResume = -5057L,
    /**
     *  The aircraft reaches the altitude lower bound of the TapFly Mission.
     */
    DJISDKMissionErrorReachAltitudeLowerBound = -5058L,

};
/*********************************************************************************/
#pragma mark GEO Error
/*********************************************************************************/

/**
 *  DJI SDK GEO Error
 */
typedef NS_ENUM(NSInteger, DJISDKGEOError){
    /**
     *  User is not logged in.
     */
    DJISDKGEOErrorNotLoggedIn = -6001L,
    /**
     *  The operation is cancelled.
     */
    DJISDKGEOErrorOperationCancelled = -6002L,
    /**
     *  Aircraft's location is not available.
     */
    DJISDKGEOErrorAircraftLocationNotAvailable = -6003L,
    /**
     *  Aircraft's serial number is not available.
     */
    DJISDKGEOErrorAircraftSerialNumberNotAvailable = -6004L,
    /**
     *  The token is invalid.
     */
    DJISDKGEOErrorInvalidToken = -6005L,
    /**
     *  User is not authorized.
     */
    DJISDKGEOErrorNotAuthorized = -6006L,
    /**
     *  Data returned by server is invalid. 
     */
    DJISDKGEOErrorInvalidServerData = -6007L,
    /**
     *  The system is still initializing.
     */
    DJISDKGEOErrorInitializationNotFinished = -6008L,
    /**
     *  Aircraft's location does not support GEO.
     */
    DJISDKGEOErrorNotSupportGEO = -6009L,
    /**
     *  This area is not eligible for unlocking.
     */
    DJISDKGEOErrorAreaNotEligibleUnlock = -6010L,
    /**
     *  The simulated aircraft location is not valid.
     *  During the simulation, a location is valid if it is within 50km of (37.460484, -122.115312).
     */
    DJISDKGEOErrorInvalidSimulatedLocation = -6011L,
};

/**
 *  NSError's DJISDK category. It contains methods to create custom NSErrors.
 *
 */
@interface NSError (DJISDK)

/**
 *  Get DJISDKError
 *
 *  @param errorCode errorCode for `DJISDKError`.
 */
+ (_Nullable instancetype)DJISDKErrorForCode:(NSInteger)errorCode;

/**
 *  Get DJISDKCameraError
 *
 *  @param errorCode errorCode for `DJISDKCameraError`.
 */
+ (_Nullable instancetype)DJISDKCameraErrorForCode:(NSInteger)errorCode;

/**
 *  Get DJISDKFlightControllerError
 *
 *  @param errorCode errorCode for `DJISDKFlightControllerError`.
 */
+ (_Nullable instancetype)DJISDKFlightControllerErrorForCode:(NSInteger)errorCode;

/**
 *  Get DJISDKMissionError
 *
 *  @param errorCode errorCode for `DJISDKMissionError`.
 */
+ (_Nullable instancetype)DJISDKMissionErrorForCode:(NSInteger)errorCode;

/**
 *  Get DJISDKRegistrationError
 *
 *  @param errorCode errorCode for `DJISDKRegistrationError`.
 */
+ (_Nullable instancetype)DJISDKRegistrationErrorForCode:(DJISDKRegistrationError)errorCode;

/**
 *  Get DJISDKGEOError
 *
 *  @param errorCode errorCode for `DJISDKGEOError`
 */
+ (_Nullable instancetype)DJISDKGEOErrorForCode:(DJISDKGEOError)errorCode;

/**
 *  Get DJISDKError
 *
 *  @param errorCode Error code for `DJISDKError`.
 *  @param errorDomain Domain for `DJISDKError`.
 *  @param desc Description for `DJISDKError`.
 */
+ (_Nullable instancetype)DJISDKErrorForCode:(NSInteger)errorCode domain:(NSString *_Nonnull)errorDomain desc:(const NSString *_Nonnull)desc;

@end

NS_ASSUME_NONNULL_END
