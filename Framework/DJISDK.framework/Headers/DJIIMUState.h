//
//  DJIIMUState.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*********************************************************************************/
#pragma mark - DJIIMUStatus
/*********************************************************************************/
/**
 *  The different orientations the aircraft needs for a multi-orientation IMU calibration.
 */
typedef NS_ENUM(uint8_t, DJIIMUCalibrationOrientation) {
    /**
     *  The front or nose of the aircraft should be pointed down.
     */
    DJIIMUCalibrationOrientationNoseDown,
    /**
     *  The back or tail of the aircraft should be pointed down.
     */
    DJIIMUCalibrationOrientationTailDown,
    /**
     *  The right or starboard side of the aircraft should be pointed down.
     */
    DJIIMUCalibrationOrientationRightDown,
    /**
     *  The left or port side of the aircraft should be pointed down.
     */
    DJIIMUCalibrationOrientationLeftDown,
    /**
     *  The bottom or underbelly of the aircraft should be pointed down.
     */
    DJIIMUCalibrationOrientationBottomDown,
    /**
     *  The top of the aircraft should be pointed down.
     */
    DJIIMUCalibrationOrientationTopDown
};

/**
 *  IMU calibration status for the current aircraft orientation.
 */
typedef NS_ENUM(uint8_t, DJIIMUMultiOrientationCalibrationStatus) {
    /**
     *  Calibration of current aircraft orientation is in progress.
     */
    DJIIMUMultiOrientationCalibrationStatusCalibrating,
    /**
     *  Calibration of current aircraft orientation is done. The orientation
     *  will be added to `orientationsCalibrated` of
     *  `DJIIMUMultiOrientationCalibrationHint`. The aircraft should be rotated
     *  to a remaining orientation in `orientationsToCalibrate`.
     */
    DJIIMUMultiOrientationCalibrationStatusDone,
    /**
     *  Unknown. Used by products that do not require IMU multi-orientation
     *  calibration.
     */
    DJIIMUMultiOrientationCalibrationStatusUnknown = 0xFF,
};

/**
 *  This class is used to lead the user through an IMU calibration for products
 *  that require calibration at multiple orientations. An example workflow is:
 *  1. Direct the user to orient the aircraft in one of the uncalibrated
 *     orientations in `orientationsToCalibrate`.
 *  2. Monitor `status` until `DJIIMUMultiOrientationCalibrationStatusCalibrating`
 *     turns to `DJIIMUMultiOrientationCalibrationStatusDone`.
 *  3. Repeat until `orientationsToCalibrate` is empty.
 */
@interface DJIIMUMultiOrientationCalibrationHint : NSObject

/**
 *  An array with the aircraft orientations that have not been calibrated yet.
 *  Each element is an `NSNumber` instance with a `DJIIMUCalibrationOrientation`
 *  enum value.
 */
@property(nonatomic, readonly) NSArray<NSNumber *> *orientationsToCalibrate;

/**
 *  An array with the aircraft orientations that have been calibrated.
 *  Each element is an `NSNumber` instance with a `DJIIMUCalibrationOrientation`
 *  enum value.
 */
@property(nonatomic, readonly) NSArray<NSNumber *> *orientationsCalibrated;

/**
 *  The calibration status for the current orientation.
 */
@property(nonatomic, readonly) DJIIMUMultiOrientationCalibrationStatus status;

@end

/**
 *  DJIIMUCalibrationStatus
 */
typedef NS_ENUM (uint8_t, DJIIMUCalibrationStatus){
    /**
     *  IMU not in calibration.
     *  No calibration is executing.
     */
    DJIIMUCalibrationStatusNone,
    /**
     *  Calibrating the IMU.
     */
    DJIIMUCalibrationStatusInProgress,
    /**
     *  Calibrate IMU Succeeded.
     */
    DJIIMUCalibrationStatusSucceeded,
    /**
     *  Calibrate IMU Failed.
     */
    DJIIMUCalibrationStatusFailed,
};

/**
 *  DJI IMU Sensor State
 */
typedef NS_ENUM (NSUInteger, DJIIMUSensorStatus) {

    /**
     *  The IMU Sensor disconnected with the flight controller.
     */
    DJIIMUSensorStatusDisconnect,
    /**
     *  The IMU Sensor is calibrating.
     */
    DJIIMUSensorStatusCalibrating,
    /**
     *  Calibrate the IMU Sensor failed.
     */
    DJIIMUSensorStatusCalibrationFailed,
    /**
     *  The IMU Sensor has data exception.
     *  Please try to calibrate the IMU and restart the aircraft, if the status still exist, you may need to contact DJI for further assistant.
     */
    DJIIMUSensorStatusDataException,
    /**
     *  The IMU Sensor is warming up.
     */
    DJIIMUSensorStatusWarmingUp,
    /**
     *  The IMU Sensor is not static, the aircraft may not be stable enough for it to calculate sensor data correctly.
     */
    DJIIMUSensorStatusMotion,
    /**
     *  The bias value of IMU Sensor is normal, the aircraft can take off safely.
     */
    DJIIMUSensorStatusBiasNormal,
    /**
     *  The bias value of IMU Sensor is medium, the aircraft can take off safely.
     */
    DJIIMUSensorStatusBiasMedium,
    /**
     *  The bias value of IMU Sensor is large, the aircraft cannot take off, IMU calibration is needed.
     */
    DJIIMUSensorStatusBiasLarge,
    /**
     *  The IMU Sensor status is unknown.
     */
    DJIIMUSensorStatusUnknown = 0xFF,

};

/*********************************************************************************/
#pragma mark - DJIInertialMeasurementUnitState
/*********************************************************************************/

/**
 *
 *  This class contains current state of the DJI Inertial Measurement Unit(IMU) State.
 *
 */
@interface DJIIMUState : NSObject

/**
 *  The ID of IMU. It is started from 0.
 */
@property(nonatomic, readonly) NSUInteger imuID;

/**
 *  The state value of Gyroscope Sensor.
 */
@property(nonatomic, readonly) DJIIMUSensorStatus gyroscopeStatus;

/**
 *  The state value of Accelerometer.
 */
@property(nonatomic, readonly) DJIIMUSensorStatus accelerometerStatus;

/**
 *  The calibration progress of IMU in percent.
 */
@property(nonatomic, readonly) NSInteger calibrationProgress;

/**
 *  The calibration status of IMU.
 */
@property(nonatomic, readonly) DJIIMUCalibrationStatus calibrationStatus;

/**
 *  For products that require the user to orient the aircraft during the IMU
 *  calibration, this can be used to inform the user when each orientation is
 *  done.
 *  It is supported by flight controller firmware 3.2.0.0 or above.
 */
@property(nonatomic, readonly, nullable) DJIIMUMultiOrientationCalibrationHint *multiOrientationCalibrationHint;

@end

NS_ASSUME_NONNULL_END

