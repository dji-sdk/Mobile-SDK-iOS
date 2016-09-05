//
//  DJIMission.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/**
 *  `DJIMissionProgressStatus` is an abstract class representing the progress of an executing mission.
 */
@interface DJIMissionProgressStatus : NSObject

/**
 *  An error has occurred during mission execution.
 */
@property(nonatomic, readonly) NSError *_Nullable error;

@end

@class DJIMission;

/**
 *  Returns the progress status using a range of 0.0 to 1.0.
 */
typedef void (^_Nullable DJIMissionProgressHandler)(float progress);

/**
 *  Download mission completion block.
 *
 *  @param newMission New downloaded mission.
 *  @param error      An error occurred while downloading.
 */
typedef void (^_Nullable DJIMissionDownloadCompletionBlock)(DJIMission *_Nullable newMission, NSError *_Nullable error);

/**
 *  `DJIMission` is an abstract class representing a mission that can be executed by the mission manager.
 */
@interface DJIMission : NSObject

/**
 *  Determines whether current mission can be paused.
 *
 *  @return YES if the mission can be paused. No if the mission can not be paused.
 */
- (BOOL)isPausable;

@end

NS_ASSUME_NONNULL_END
