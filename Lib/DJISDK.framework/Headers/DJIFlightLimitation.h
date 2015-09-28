//
//  DJIFlightLimitation.h
//  DJISDK
//
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIObject.h>

@class DJIError;

@protocol DJIFlightLimitation <NSObject>

/**
 *  Whether or not the aircraft has reached max flight height.
 */
@property(nonatomic, readonly) BOOL isReachedMaxFlightHeight;

/**
 *  Whether or not the aricraft has reached max flight radius.
 */
@property(nonatomic, readonly) BOOL isReachedMaxFlightRadius;

/**
 *  Set max flight height limitation for aircraft. maxHeight value should be in range [20, 500] m
 *
 *  @param maxHeight Maximum height can be fly for aircraft
 *  @param block     Remote execute result callback
 */
-(void) setMaxFlightHeight:(float)maxHeight withResult:(DJIExecuteResultBlock)block;

/**
 *  Get max flight heigh limitation from aircraft
 *
 *  @param block Remote execute result callback
 */
-(void) getMaxFlightHeightWithResult:(void(^)(float height, DJIError* error))block;

/**
 *  Set max flight radius limitation for aricraft. the radius is calculated from the home point. maxRadius value should be in range [15, 500] m
 *
 *  @param radius Maximum flight radius can be fly for aircraft.
 *  @param block  Remote execute result callback
 */
-(void) setMaxFlightRadius:(float)maxRadius withResult:(DJIExecuteResultBlock)block;

/**
 *  Get max flight radius limitation from aircraft.
 *
 *  @param block Remote execute result block
 */
-(void) getMaxFlightRadiusWithResult:(void(^)(float radius, DJIError*))block;

/**
 *  Set max flight radius limitation enable. if enable is No, then no max flight radius limitation.
 *
 *  @param enable Max flight radius limitation enable.
 *  @param block  Remote execute result callback
 */
-(void) setMaxFlightRadiusLimitationEnable:(BOOL)enable withResult:(DJIExecuteResultBlock)block;

/**
 *  Get max flight radius limitation enable.
 *
 *  @param block Remote execute result callback
 */
-(void) getMaxFlightRadiusLimitationEnableWithResult:(void (^)(BOOL, DJIError *))block;

@end
