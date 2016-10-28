//
//  DJIFollowMeStep.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <DJISDK/DJIMissionStep.h>

NS_ASSUME_NONNULL_BEGIN

@class DJIFollowMeMission;

/**
 *  This class represents a follow-me step for a custom mission. By creating an object of this class and adding it to
 *  a custom mission, a follow-me action will be performed during the custom mission.
 *  @see DJIFollowMeMission
 */
@interface DJIFollowMeStep : DJIMissionStep

/**
 *  Initialized instance with a follow me mission and duration.
 *
 *  @param mission Mission for follow me step.
 *  @param seconds Duration in seconds for this step.
 *
 *  @return Return instance of DJIFollowMeStep.
 */
- (instancetype _Nullable)initWithFollowMeMission:(DJIFollowMeMission *_Nonnull)mission duration:(float)seconds;

@end

NS_ASSUME_NONNULL_END