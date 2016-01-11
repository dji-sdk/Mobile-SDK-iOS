/*
 *  DJI iOS Mobile SDK Framework
 *  DJILandingGear.h
 *
 *  Copyright (c) 2015, DJI.
 *  All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import <DJISDK/DJIBaseComponent.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Current state of the Landing Gear
 */

typedef NS_ENUM(uint8_t, DJILandingGearStatus){
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
typedef NS_ENUM(uint8_t, DJILandingGearMode){
    /**
     *  Landing Gear can be deployed and retracted through function calls
     */
    DJILandingGearModeNormal,
    /**
     *  Landing Gear is in transport mode (either it is moving into, moving out of, or stopped in transport position)
     */
    DJILandingGearModeTransport,
    /**
     *  Landing Gear automatically transitions between deployed and retracted depending on altitude (transition point is 1.2m above current ground as measured by the ultrasonic sensor)
     */
    DJILandingGearModeAuto,
    /**
     *  Landing Gear is in an unknown mode
     */
    DJILandingGearModeUnknown,
};

@interface DJILandingGear : NSObject

/**
 *  The current state/position of the landing gear
 */
@property(nonatomic, readonly) DJILandingGearStatus status;

/**
 *  The mode the landing gear is in
 */
@property(nonatomic, readonly) DJILandingGearMode mode;

/**
 *  Whether or not the landing gear is supported for the connected aircraft.
 */
- (BOOL)isLandingGearMovable;

/**
 *  Turns on the self-adaptive landing gear. If self-adaptive landing gear is turned on,
 *  when the aircraft is 0.5m above the ground and about to land, the landing gear will
 *  automatically lower. After it takes off, once the aircraft is 0.5m above the ground,
 *  the landing gear will automatically raise up.
 *
 */
-(void) turnOnAutoLandingGearWithCompletion:(DJICompletionBlock)completion;

/**
 *  Turns off the self-adaptive landing gear. If self-adaptive landing gear is turned off,
 *  the aircraft will not automatically lower and raise the landing gear when the aircraft
 *  is 0.5m above the ground.
 *
 */
-(void) turnOffAutoLandingGearWithCompletion:(DJICompletionBlock)completion;

/**
 *  Retracts the landing gear.
 *
 */
-(void) retractLandingGearWithCompletion:(DJICompletionBlock)completion;

/**
 *   Deploys the landing gear.
 *
 */
-(void) deployLandingGearWithCompletion:(DJICompletionBlock)completion;

/**
 *  Enters the transport mode. In transport mode, the landing gear will be in the same plane as the aircraft body, so that it can be easily transported.
 *
 *  @attention If the gimbal is not removed or the ground is not flat, enter transport mode will fail.
 */
-(void) enterTransportModeWithCompletion:(DJICompletionBlock)completion;

/**
 *  Exit transport mode.
 *
 */
-(void) exitTransportModeWithCompletion:(DJICompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
