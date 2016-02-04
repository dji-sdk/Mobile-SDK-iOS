//
//  DJILandingGear.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIBaseComponent.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Current state of the Landing Gear
 */
typedef NS_ENUM (uint8_t, DJILandingGearStatus){
    /**
     *  Landing Gear is in unknown state
     */
    DJILandingGearStatusUnknown,
    /**
     *  Landing Gear is fully deployed (ready for landing)
     */
    DJILandingGearStatusDeployed,
    /**
     *  Landing Gear is fully retracted (ready for flying)
     */
    DJILandingGearStatusRetracted,
    /**
     *  Landing Gear is deploying (getting ready for landing)
     */
    DJILandingGearStatusDeploying,
    /**
     *  Landing Gear is retracting (getting ready for flying)
     */
    DJILandingGearStatusRetracting,
    /**
     *  Landing Gear is stopped
     */
    DJILandingGearStatusStopped,
};

/**
 *  Current Mode of the Landing Gear
 */
typedef NS_ENUM (uint8_t, DJILandingGearMode){
    /**
     *  Landing Gear can be deployed and retracted through function calls
     */
    DJILandingGearModeNormal,
    /**
     *  Landing Gear is in transport mode (either it is moving into, moving out of, or stopped in transport position)
     */
    DJILandingGearModeTransport,
    /**
     *  Landing Gear automatically transitions between deployed and retracted depending on altitude. During take-off, the transition point is 1.2m above ground. After take-off (during flight or when landing), the transition point is 0.5m above ground.
     */
    DJILandingGearModeAuto,
    /**
     *  Landing Gear is in an unknown mode
     */
    DJILandingGearModeUnknown,
};

/**
 *
 *  This class contains the state of the landing gear. It also provides methods to control the landing gear.
 */
@interface DJILandingGear : NSObject

/**
 *  The current state/position of the landing gear.
 */
@property(nonatomic, readonly) DJILandingGearStatus status;

/**
 *  The mode the landing gear is in.
 */
@property(nonatomic, readonly) DJILandingGearMode mode;

/**
 *  YES if the landing gear is supported for the connected aircraft.
 */
- (BOOL)isLandingGearMovable;

/**
 *  Turns on the self-adaptive landing gear. If self-adaptive landing gear is turned on the landing Gear automatically
 *  transitions between deployed and retracted depending on altitude. During take-off, the transition point is 1.2m above
 *  ground. After take-off (during flight or when landing), the transition point is 0.5m above ground.
 */
- (void)turnOnAutoLandingGearWithCompletion:(DJICompletionBlock)completion;

/**
 *  Turns off the self-adaptive landing gear. If self-adaptive landing gear is turned off,
 *  the aircraft will not automatically lower and raise the landing gear when the aircraft
 *  is 0.5m above the ground.
 *
 */
- (void)turnOffAutoLandingGearWithCompletion:(DJICompletionBlock)completion;

/**
 *  Enters the transport mode. In transport mode, the landing gear will be in the same plane as the aircraft body, so that it can be easily transported.
 *
 *  @attention If the gimbal is not removed or the ground is not flat, enter transport mode will fail.
 */
- (void)enterTransportModeWithCompletion:(DJICompletionBlock)completion;

/**
 *  Exit transport mode.
 *
 */
- (void)exitTransportModeWithCompletion:(DJICompletionBlock)completion;

/**
 *  Retracts the landing gear. Should only be used when setLandingGearMode is DJILandingGearModeNormal.
 *
 */
- (void)retractLandingGearWithCompletion:(DJICompletionBlock)completion;

/**
 *  Deploys the landing gear. Should only be used when setLandingGearMode is DJILandingGearModeNormal.
 *
 */
- (void)deployLandingGearWithCompletion:(DJICompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
