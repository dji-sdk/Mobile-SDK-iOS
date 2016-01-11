/*
 *  DJI iOS Mobile SDK Framework
 *  DJIMissionStep.h
 *
 *  Copyright (c) 2015, DJI.
 *  All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "DJIBaseProduct.h"
#import "DJIAircraft.h"
#import "DJIMission.h"
#import "DJIFlightControllerCurrentState.h"
#import "DJICameraSettingsDef.h"

NS_ASSUME_NONNULL_BEGIN


@class DJIMissionStep;

typedef void (^ DJICommonStepBlock)(DJICompletionBlock completion);

@interface DJIMissionStep : NSOperation

/**
 *  Whether or not the mission's parameters are valid for execution. If this property
 *  returns NO, then the attempt to startMission will have failed.
 *
  *  @attention The result of 'isValid' just show whether the mission's local parameters is valid. not for all execution condition.
 */
@property(nonatomic, readonly) BOOL isValid;

/**
 *  Show failure reason for checking parameters of mission. Value will be set after calling 'isValid'.
 */
@property(nonatomic, readonly) NSString* failureReason;


/**
 * Generates takeoff block step object
 */
-(void) setTakeoffStepWithCompletion:(DJICompletionBlock)completion;

/**
 * Generates goHome step object
 */
-(void) setGoHomeStepWithCompletion:(DJICompletionBlock)completion;

/**
 * Generates waypoint mission step object
 */
- (void)setWaypointMissionStep:(DJIMission*) mission onProgress:(DJIMissionProgressHandler)progressListener withCompletion:(DJICompletionBlock)completion;

/**
 * Generates hotpoint mission step object, with a duration in seconds.
 */
- (void)setHotpointMissionStep:(DJIMission*) mission withDuration:(unsigned int)durationInSeconds withCompletion:(DJICompletionBlock)completion;

/**
 * Generates followme mission step object, with a duration in seconds.
 */
- (void)setFollowmeMissionStep:(DJIMission*) mission withDuration:(unsigned int)durationInSeconds withCompletion:(DJICompletionBlock)completion;

/**
 * Generates take picture step object.
 *
 */
- (void)setTakePictureStepWithMode:(DJICameraShootPhotoMode)shootMode WithCompletion:(DJICompletionBlock)completion;

/**
 * Generates take continuous picture step object with a duration in seconds.
 */
- (void)setTakeContinuousPictureStepWithDuration:(unsigned int)durationInSeconds withCompletion:(DJICompletionBlock)completion;

/**
 * Generates take video step object with a duration in seconds.
 */
- (void)setTakeVideoStepWithDuration:(unsigned int)durationInSeconds withCompletion:(DJICompletionBlock)completion;

/**
 * Generates gimbal movement step object in which the gimbal will uniformly rotate to the given attitude in the given time period.
 */
- (void)setGimbalAttitude:(DJIAttitude)attitude within:(unsigned int)timeInSeconds withCompletion:(DJICompletionBlock)completion;


@end

NS_ASSUME_NONNULL_END
