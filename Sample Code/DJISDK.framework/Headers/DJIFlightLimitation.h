//
//  DJIFlightLimitation.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIBaseComponent.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *
 *  This class contains the flight status of the aircraft related to the flight limitation, and provides methods to configure the flight limitation.
 */
@interface DJIFlightLimitation : NSObject

/**
 *  `YES` if the aircraft has reached the maximum flight height.
 */
@property(nonatomic, readonly) BOOL hasReachedMaxFlightHeight;

/**
 *  `YES` if the aircraft has reached the maximum flight radius.
 */
@property(nonatomic, readonly) BOOL hasReachedMaxFlightRadius;

/**
 *  Sets the maximum flight height limitation for the aircraft. The `maxHeight` value must be in the range [20, 500] m.
 *
 *  @param maxHeight   Maximum height for the aircraft.
 *  @param completion  Completion block.
 */
- (void)setMaxFlightHeight:(float)maxHeight withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the maximum flight height limitation from the aircraft.
 *
 */
- (void)getMaxFlightHeightWithCompletion:(void (^_Nonnull)(float height, NSError *_Nullable error))completion;

/**
 *  Sets the maximum flight radius limitation for the aircraft. The radius is calculated from the home point. The `maxRadius` value must be in the range [15, 500] m.
 *
 *  @param radius Maximum flight radius for the aircraft.
 *  @param completion  Completion block.
 */
- (void)setMaxFlightRadius:(float)maxRadius withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the maximum flight radius limitation from the aircraft.
 *
 */
- (void)getMaxFlightRadiusWithCompletion:(void (^_Nonnull)(float radius, NSError *_Nullable error))completion;

/**
 *  Sets whether the maximum flight radius limitation is enabled. If `enabled` is `NO`, there is no maximum flight radius limitation.
 *
 *  @param enabled      Maximum flight radius limitation is enabled.
 *  @param completion   Completion block.
 */
- (void)setMaxFlightRadiusLimitationEnabled:(BOOL)enabled withCompletion:(DJICompletionBlock)completion;

/**
 *  Determines whether the maximum flight radius limitation is enabled.
 *
 */
- (void)getMaxFlightRadiusLimitationEnabledWithCompletion:(void (^_Nonnull)(BOOL enabled, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
