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
 *  This class contains the flight status of the aircraft related to the flight limitation. Also, it provides methods to configure the flight limitation.
 */
@interface DJIFlightLimitation : NSObject

/**
 *  YES if aircraft has reached max flight height.
 */
@property(nonatomic, readonly) BOOL hasReachedMaxFlightHeight;

/**
 *  YES if aircraft aircraft has reached max flight radius.
 */
@property(nonatomic, readonly) BOOL hasReachedMaxFlightRadius;

/**
 *  Sets max flight height limitation for aircraft. maxHeight value should be in range [20, 500] m
 *
 *  @param maxHeight   Maximum height for aircraft.
 *  @param completion  Completion block.
 */
- (void)setMaxFlightHeight:(float)maxHeight withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets max flight height limitation from aircraft.
 *
 */
- (void)getMaxFlightHeightWithCompletion:(void (^)(float height, NSError *_Nullable error))completion;

/**
 *  Sets max flight radius limitation for aircraft. The radius is calculated from the home point. maxRadius value should be in range [15, 500] m.
 *
 *  @param radius Maximum flight radius for aircraft.
 *  @param completion  Completion block.
 */
- (void)setMaxFlightRadius:(float)maxRadius withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets max flight radius limitation from aircraft.
 *
 */
- (void)getMaxFlightRadiusWithCompletion:(void (^)(float radius, NSError *_Nullable error))completion;

/**
 *  Sets max flight radius limitation enabled. If enabled is NO, then there is no max flight radius limitation.
 *
 *  @param enabled      Max flight radius limitation enable.
 *  @param completion   Completion block.
 */
- (void)setMaxFlightRadiusLimitationEnabled:(BOOL)enabled withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets max flight radius limitation enabled.
 *
 */
- (void)getMaxFlightRadiusLimitationEnabledWithCompletion:(void (^)(BOOL enabled, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
