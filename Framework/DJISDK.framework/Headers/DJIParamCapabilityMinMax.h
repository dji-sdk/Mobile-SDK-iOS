//
//  DJIParamCapabilityMinMax.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#import "DJIParamCapability.h"

/**
 *  `DJIParamCapabilityMinMax` adds the maximum and minimum possible values of the parameter to the base class property of whether the parameter is supported by the component or product.
 */
@interface DJIParamCapabilityMinMax : DJIParamCapability

/**
 *  The valid minimum value of the parameter for the product. If `isSupported` returns `NO`, the value for `min` is undefined.
 */
@property(nonatomic, readonly) NSNumber *min;
/**
 *  The valid maximum value of the parameter for the product. If `isSupported` returns `NO`, the value for `max` is undefined.
 */
@property(nonatomic, readonly) NSNumber *max;

@end
