//
//  DJIMissionStep.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIBaseProduct.h"
#import "DJIAircraft.h"
#import "DJIMission.h"
#import "DJIFlightControllerCurrentState.h"
#import "DJICameraSettingsDef.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Abstract class for all mission steps. A mission step represents an operation related to one kind of missions or a component. Developer can create a custom mission with multiple steps to accomplish complex tasks.
 *
 *  @warning The execution of a custom mission highly depends on the combination and order of mission steps. User is responsible to check the relation between steps and organize the steps in reasonable order.
 *
 *  @see DJICustomMission
 */
@interface DJIMissionStep : NSOperation

@end

NS_ASSUME_NONNULL_END
