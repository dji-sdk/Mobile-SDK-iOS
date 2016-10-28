//
//  DJIMissionStep.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Abstract class for all mission steps. A mission step represents an operation related to one kind of mission or a component. You can create a custom mission with multiple steps to accomplish complex tasks.
 *
 *  @warning The execution of a custom mission depends on the combination and order of mission steps. The user must check the relationships between steps and organize the steps in a reasonable order.
 *
 *  @see DJICustomMission
 */
@interface DJIMissionStep : NSOperation

@end

NS_ASSUME_NONNULL_END
