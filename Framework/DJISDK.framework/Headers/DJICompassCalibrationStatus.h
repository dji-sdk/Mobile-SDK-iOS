//
//  DJICompassCalibrationStatus.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#ifndef DJICompassCalibrationStatus_h
#define DJICompassCalibrationStatus_h

/**
 *  Compass Calibration Status.
 */
typedef NS_ENUM (NSUInteger, DJICompassCalibrationStatus){
    /**
     *  Compass not in calibration.
     */
    DJICompassCalibrationStatusNone,
    /**
     *  Compass horizontal calibration. The user should hold the aircraft
     *  horizontally and rotate it 360 degrees.
     */
    DJICompassCalibrationStatusHorizontal,
    /**
     *  Compass vertical calibration. The user should hold the aircraft
     *  vertically, with the nose pointed towards the ground, and rotate
     *  the aircraft 360 degrees.
     */
    DJICompassCalibrationStatusVertical,
    /**
     *  Compass calibration succeeded.
     */
    DJICompassCalibrationStatusSucceeded,
    /**
     *  Compass calibration failed. Make sure there are no magnets or
     *  metal objects near the compass and retry.
     */
    DJICompassCalibrationStatusFailed,
    /**
     *  Compass calibration status unknown.
     */
    DJICompassCalibrationStatusUnknown,
};

#endif /* DJICompassCalibrationStatus_h */
