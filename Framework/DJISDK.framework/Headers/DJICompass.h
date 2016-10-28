//
//  DJICompass.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIBaseComponent.h>
#import <DJISDK/DJICompassCalibrationStatus.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class contains important status for the compass of the product,
 *  and provides methods to calibrate the compass. Products with
 *  multiple compasses (like the Phantom 4) will have their compass
 *  state fused into one compass class for simplicity.
 */
@interface DJICompass : NSObject

/**
 *  Represents the heading in degrees. True North is 0 degrees, positive
 *  heading is East of North, negative heading is West of North and
 *  heading bounds are [-180, 180].
 */
@property(nonatomic, readonly) double heading;

/**
 *  YES if the compass has an error. If YES, the compass needs calibration.
 */
@property(nonatomic, readonly) BOOL hasError;

/**
 *  YES if the compass is currently calibrating.
 */
@property(nonatomic, readonly) BOOL isCalibrating;

/**
 *  Shows the calibration status.
 */
@property(nonatomic, readonly) DJICompassCalibrationStatus calibrationStatus;

/**
 *  Starts compass calibration. Make sure there are no magnets or metal
 *  objects near the compass.
 */
- (void)startCalibrationWithCompletion:(DJICompletionBlock)completion;

/**
 *  Stops compass calibration.
 *
 */
- (void)stopCalibrationWithCompletion:(DJICompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
