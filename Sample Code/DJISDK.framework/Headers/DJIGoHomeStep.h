//
//  DJIGoHomeStep.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <DJISDK/DJIMissionStep.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class represents a go-home step for a custom mission. By creating an object of this class and adding it to
 *  a custom mission, a go-home action will be performed during the custom mission execution.
 */
@interface DJIGoHomeStep : DJIMissionStep

@end

NS_ASSUME_NONNULL_END