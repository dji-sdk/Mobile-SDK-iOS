//
//  DJIMission.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIBaseProduct.h"

NS_ASSUME_NONNULL_BEGIN


/**
 *  The class is an abstract class representing the progress of an executing mission.
 */
@interface DJIMissionProgressStatus : NSObject

/**
 *  Error happens in mission execution.
 */
@property(nonatomic, readonly) NSError *_Nullable error;

@end

@class DJIMission;

/**
 *  Returns the progress status from 0.0 to 1.0
 */
typedef void (^_Nullable DJIMissionProgressHandler)(float progress);

/**
 *  Download mission completion block.
 *
 *  @param newMission New downloaded mission.
 *  @param error      Error happens in downloading.
 */
typedef void (^_Nullable DJIMissionDownloadCompletionBlock)(DJIMission *_Nullable newMission, NSError *_Nullable error);

/**
 *  The class is an abstract class representing a mission that can be executed by the mission manager.
 */
@interface DJIMission : NSObject

/**
 *  Whether current mission can be paused.
 *
 *  @return YES if mission can be paused. No if mission can not be paused.
 */
- (BOOL)isPausable;

@end

NS_ASSUME_NONNULL_END
