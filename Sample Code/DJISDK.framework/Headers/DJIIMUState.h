//
//  DJIIMUState.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

/*********************************************************************************/
#pragma mark - DJIIMUStatus
/*********************************************************************************/

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
 *  The state value of Accelerator Sensor.
 */
@property(nonatomic, readonly) DJIIMUSensorStatus acceleratorStatus;

/**
 *  The calibration progress of IMU.
 */
@property(nonatomic, readonly) NSInteger calibrationProgress;

/**
 *  The calibration status of IMU.
 */
@property(nonatomic, readonly) DJIIMUCalibrationStatus calibrationStatus;

@end
