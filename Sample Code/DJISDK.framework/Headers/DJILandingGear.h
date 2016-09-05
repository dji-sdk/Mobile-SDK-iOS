//
//  DJILandingGear.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIBaseComponent.h>
#import <DJISDK/DJILandingGearStructs.h>

NS_ASSUME_NONNULL_BEGIN


/**
 *
 *  This class contains the state of the landing gear. It also provides methods to control the landing gear.
 */
@interface DJILandingGear : NSObject

/**
 *  The current state/position of the landing gear.
 *  It is only supported by Inspire 1.
 */
@property(nonatomic, readonly) DJILandingGearStatus status;

/**
 *  The current landing gear mode.
 */
@property(nonatomic, readonly) DJILandingGearMode mode;

/**
 *  Turns on the self-adaptive landing gear. If self-adaptive landing gear is turned on, the landing gear automatically
 *  transitions between deployed and retracted depending on altitude. During take-off, the transition point is 1.2m above
 *  ground. After take-off (during flight or when landing), the transition point is 0.5m above ground.
 *
 *  @param completion   Completion block that receives the execution result.
 */
- (void)turnOnAutoLandingGearWithCompletion:(DJICompletionBlock)completion;

/**
 *  Turns off the self-adaptive landing gear. If self-adaptive landing gear is turned off,
 *  the aircraft will not automatically lower and raise the landing gear when the aircraft
 *  is 0.5m above the ground.
 *
 *  @param completion   Completion block that receives the execution result.
 */
- (void)turnOffAutoLandingGearWithCompletion:(DJICompletionBlock)completion;

/**
 *  Enters the transport mode. In transport mode, the landing gear will be in the same geometric plane as the aircraft body so it can be easily transported.
 *  It is only supported by Inspire 1.
 *
 *  @param completion   Completion block that receives the execution result.
 *  @attention If the gimbal is not removed or the ground is not flat, the enter transport mode will fail.
 */
- (void)enterTransportModeWithCompletion:(DJICompletionBlock)completion;

/**
 *  Exit transport mode.
 *  It is only supported by Inspire 1.
 *
 *  @param completion   Completion block that receives the execution result.
 *  @attention If the ground is not flat, exit transport mode will fail.
 */
- (void)exitTransportModeWithCompletion:(DJICompletionBlock)completion;

/**
 *  Retracts the landing gear. Should only be used when `setLandingGearMode` is `DJILandingGearModeNormal`.
 *  Only supported by Inspire 1.
 *  For Matrice 600, the landing gear cannot be controlled through the SDK, only automatically by the aircraft or manually by the remote controller.
 *
 *  @param completion   Completion block that receives the execution result.
 */
- (void)retractLandingGearWithCompletion:(DJICompletionBlock)completion;

/**
 *  Deploys the landing gear. Should only be used when `setLandingGearMode` is `DJILandingGearModeNormal`.
 *  Only supported by Inspire 1.
 * For Matrice 600, the landing gear cannot be controlled through the SDK, only automatically by the aircraft or manually by the remote controller.
 *
 *  @param completion   Completion block that receives the execution result.
 */
- (void)deployLandingGearWithCompletion:(DJICompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
