//
//  DJIDiagnostics.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  DJIDiagnosticsError
 */
typedef NS_ENUM (NSInteger, DJIDiagnosticsError){
    /**
     *  Aircraft upgrade error
     */
    DJIDiagnosticsErrorCameraUpgradeError = 1001,
    /**
     *  Camera sensor error
     */
    DJIDiagnosticsErrorCameraSensorError = 1002,
    /**
     *  Camera has overheated
     */
    DJIDiagnosticsErrorCameraOverHeat = 1003,
    /**
     *  Camera encryption error
     */
    DJIDiagnosticsErrorCameraEncryptionError = 1004,
    /**
     *  NO SD card
     */
    DJIDiagnosticsErrorCameraNoSDCard = 1005,
    /**
     *  SD card error
     */
    DJIDiagnosticsErrorCameraSDCardError = 1006,
    /**
     *  Remaining SD card capacity is not enough
     */
    DJIDiagnosticsErrorCameraSDCardNoSpace = 1007,
    /**
     *  SD card is full
     */
    DJIDiagnosticsErrorCameraSDCardFull = 1008,
    /**
     *  SD card readonly
     */
    DJIDiagnosticsErrorCameraSDCardReadOnly = 1009,
    /**
     *  SD card not formatted
     */
    DJIDiagnosticsErrorCameraSDCardNotFormatted = 1010,

    /**
     *  Gimbal gyroscope error
     */
    DJIDiagnosticsErrorGimbalGyroscopeError = 2001,
    /**
     *  Gimbal pitch error
     */
    DJIDiagnosticsErrorGimbalPitchError = 2002,
    /**
     *  Gimbal roll error
     */
    DJIDiagnosticsErrorGimbalRollError = 2003,
    /**
     *  Gimbal yaw error
     */
    DJIDiagnosticsErrorGimbalYawError = 2004,
    /**
     *  Gimbal cannot receive MC data
     */
    DJIDiagnosticsErrorGimbalConnectToFCError = 2005,

    /**
     *  Battery discharge overcurrent
     */
    DJIDiagnosticsErrorBatteryDischargeOverCurrent = 3001,
    /**
     *  Battery discharge overheat
     */
    DJIDiagnosticsErrorBatteryDischargeOverHeat = 3002,
    /**
     *  Low temperature environment: Battery not suitable for flight
     */
    DJIDiagnosticsErrorBatteryLowTemperature = 3003,
    /**
     *  Battery cell is broken
     */
    DJIDiagnosticsErrorBatteryCellBroken = 3004,
    /**
     *  Battery needs a complete process of charging and discharging
     */
    DJIDiagnosticsErrorBatteryNeedStudy = 3005,
    /**
     *  Battery is not DJI battery.
     */
    DJIDiagnosticsErrorBatteryIllegal = 3006,
    /**
     *  RC FPGA error
     */
    DJIDiagnosticsErrorRemoteControllerFPGAError = 4001,
    /**
     *  RC transmitter error
     */
    DJIDiagnosticsErrorRemoteControllerTransmitterError = 4002,
    /**
     *  RC battery error
     */
    DJIDiagnosticsErrorRemoteControllerBatteryError = 4003,
    /**
     *  RC GPS error
     */
    DJIDiagnosticsErrorRemoteControllerGPSError = 4004,
    /**
     *  RC encryption error
     */
    DJIDiagnosticsErrorRemoteControllerEncryptionError = 4005,
    /**
     *  RC is not calibrated
     */
    DJIDiagnosticsErrorRemoteControllerNeedCalibration = 4006,
    /**
     *  RC battery low
     */
    DJIDiagnosticsErrorRemoteControllerBatteryLow = 4007,
    /**
     *  RC idle for too long
     */
    DJIDiagnosticsErrorRemoteControllerIdleTooLong = 4008,
    /**
     *  RC is reset, please check RC settings
     */
    DJIDiagnosticsErrorRemoteControllerReset = 4009,
    /**
     *  RC overheated
     */
    DJIDiagnosticsErrorRemoteControllerOverHeat = 4010,

    /**
     *  Battery connection to the center board has failed
     */
    DJIDiagnosticsErrorCentralBoardConnectToBatteryError = 5001,
    /**
     *  GPS connection to the center board has failed
     */
    DJIDiagnosticsErrorCentralBoardConnectToGPSError = 5002,
    /**
     *  MC connection to the center board has failed
     */
    DJIDiagnosticsErrorCentralBoardConnectToFCError = 5003,

    /**
     *  Video decoder encryption error
     */
    DJIDiagnosticsErrorVideoDecoderEncryptionError = 6001,
    /**
     *  Deserializer disconnected
     */
    DJIDiagnosticsErrorVideoDecoderConnectToDeserializerError = 6002,

    /**
     *  Aircraft Encoder Error
     */
    DJIDiagnosticsErrorAirEncoderError = 7001,
    /**
     *  Aircraft updating
     */
    DJIDiagnosticsErrorAirEncoderUpgrade = 7002,

    /**
     *  IMU calibration required
     */
    DJIDiagnosticsErrorFlightControllerIMUNeedCalibration = 8001,
    /**
     *  IMU calibration incomplete
     */
    DJIDiagnosticsErrorFlightControllerIMUCalibrationIncomplete = 8002,
    /**
     *  IMU data error
     */
    DJIDiagnosticsErrorFlightControllerIMUDataError = 8003,
    /**
     *  General IMU error
     */
    DJIDiagnosticsErrorFlightControllerIMUError = 8004,
    /**
     *  IMU initialization failed
     */
    DJIDiagnosticsErrorFlightControllerIMUInitFailed = 8005,
    /**
     *  Barometer initialization failed
     */
    DJIDiagnosticsErrorFlightControllerBarometerInitFailed = 8006,
    /**
     *  Barometer error
     */
    DJIDiagnosticsErrorFlightControllerBarometerError = 8007,
    /**
     *  Accelerometer failed
     */
    DJIDiagnosticsErrorFlightControllerAccelerometerInitFailed = 8008,
    /**
     *  Gyroscope error
     */
    DJIDiagnosticsErrorFlightControllerGyroscopeError = 8009,
    /**
     *  Aircraft attitude angle is too large
     */
    DJIDiagnosticsErrorFlightControllerAttitudeError = 8010,
    /**
     *  Data recorder errors
     */
    DJIDiagnosticsErrorFlightControllerDataRecordError = 8011,
    /**
     *  Take-off faiure
     */
    DJIDiagnosticsErrorFlightControllerTakeoffFailed = 8012,
    /**
     *  Unknown flight controller error
     */
    DJIDiagnosticsErrorFlightControllerSystemError = 8013,
    /**
     *  Compass need restart
     */
    DJIDiagnosticsErrorFlightControllerCompassNeedRestart = 8014,
    /**
     *  Compass abnormal
     */
    DJIDiagnosticsErrorFlightControllerCompassAbnormal = 8015,
    /**
     *  Aircraft is warming up
     */
    DJIDiagnosticsErrorFlightControllerWarmingUp = 8016,
    /**
     *  Propeller Guard Mounted
     */
    DJIDiagnosticsErrorVisionPropellerGuard = 9001,
    /**
     *  Vision sensor error
     */
    DJIDiagnosticsErrorVisionSensorError = 9002,
    /**
     *  Vision sensor calibration error
     */
    DJIDiagnosticsErrorVisionSensorCalibrationError = 9003,
    /**
     *  Vision sensor communication error
     */
    DJIDiagnosticsErrorVisionSensorCommunicationError = 9004,
    /**
     *  Vision system error
     */
    DJIDiagnosticsErrorVisionSystemError = 9005,
};

/**
 *  Product Diagnostics.
 */
@interface DJIDiagnostics : NSObject

/**
 *  Diagnostics error code.
 */
@property(nonatomic, readonly) NSInteger code;

/**
 *  The reason of the error.
 */
@property(nonatomic, readonly) NSString *_Nonnull reason;

/**
 *  The suggest solution for the error.
 */
@property(nonatomic, readonly) NSString *_Nullable solution;

@end

NS_ASSUME_NONNULL_END
