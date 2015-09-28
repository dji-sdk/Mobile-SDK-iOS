//
//  DJIMCSmartGoHome.h
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DJIMCSmartGoHomeData : NSObject

/**
 *  The remain time in second for flight (include landing).
 */
@property(nonatomic, readonly) NSUInteger remainTimeForFlight;

/**
 *  The time in second that need for going to home point from current location.
 */
@property(nonatomic, readonly) NSUInteger timeForGoHome;

/**
 *  The time in seconds that need for landing from current height.
 */
@property(nonatomic, readonly) NSUInteger timeForLanding;

/**
 *  The power percent that need for going to home point from current location.
 */
@property(nonatomic, readonly) NSUInteger powerPercentForGoHome;

/**
 *  The power percent that need for landing from current height.
 */
@property(nonatomic, readonly) NSUInteger powerPercentForLanding;

/**
 *  The max radius in meter for flight. the radius is the distance form home point to drone location.
 */
@property(nonatomic, readonly) float radiusForGoHome;

/**
 *  The drone request for go home. User should response this request the value is YES, or the aircraft will automatically go home after 10 seconds.
 */
@property(nonatomic, readonly) BOOL droneRequestGoHome;

@end
