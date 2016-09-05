//
//  DJITakeoffStep.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <DJISDK/DJIMissionStep.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class represents a take-off step for a custom mission. By creating an object of this class and adding it to
 *  a custom mission, a take-off action will be performed during the custom mission execution.
 */

@interface DJITakeoffStep : DJIMissionStep

@end

NS_ASSUME_NONNULL_END