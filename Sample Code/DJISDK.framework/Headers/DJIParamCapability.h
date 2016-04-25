//
//  DJIParamCapability.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  `DJIParamCapability` represents the capability of a parameter of a component or product.
 *  `DJIParamCapability` can be sub-classed to include additional information on the parameter.
 *  `DJIParamCapabilityMinMax` includes the maximum and minimum possible values of the parameter.
 */
@interface DJIParamCapability : NSObject

/**
 *  `YES` if the component or product supports the parameter.
 */
@property(nonatomic, readonly) BOOL isSupported;

@end
