//
//  DJICompass.h
//  DJISDK
//
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIObject.h>

typedef NS_ENUM(NSUInteger, DJICompassCalibrationStatus)
{
    /**
     *  Compass calibration step 1. User should hold the aircraft horizontally and rotate it 360 degree.
     */
    DJICompassCalibrationStep1,
    /**
     *  Compass calibration step 2. User should hold the aircraft vertically, with the nose point towards the ground, and rotate aircraft 360 degrees.
     */
    DJICompassCalibrationStep2,
    /**
     *  Compass calibration succeeded.
     */
    DJICompassCalibrationSucceeded,
    /**
     *  Compass calibration failed. Make sure there are no magnets or metal objects near the compass and retry.
     */
    DJICompassCalibrationFailed,
    /**
     *  Compass calibration status unknown.
     */
    DJICompassCalibrationUnknown,
};

/**
 *  Compass of the aricraft.
 */
@protocol DJICompass <NSObject>

/**
 *  Represents the direction in degrees, where 0 degrees is true North. [-180, 180] degrees. This value is equals to the 'DJIMCSystemState.attitude.yaw'
 */
@property(nonatomic, readonly) double heading;

/**
 *  Whether or not the compass has error. if YES, the compass need to calibration.
 */
@property(nonatomic, readonly) BOOL hasError;

/**
 *  Whether or not the compass is in calibrating.
 */
@property(nonatomic, readonly) BOOL isCalibrating;

/**
 *  Show the calibration status.
 */
@property(nonatomic, readonly) DJICompassCalibrationStatus calibrationStatus;

/**
 *  Start compass calibration. Make sure there are no magnets or metal objects near the compass.
 *
 *  @param block Remote execute result callback.
 */
-(void) startCalibrationWithResult:(DJIExecuteResultBlock)block;

/**
 *  Stop compass calibration.
 *
 *  @param block Remote execute result callback.
 */
-(void) stopCalibrationWithResult:(DJIExecuteResultBlock)block;

@end
