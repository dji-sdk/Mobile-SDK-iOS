//
//  DJICustomMission.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <DJISDK/DJISDK.h>

NS_ASSUME_NONNULL_BEGIN

@class DJIMissionStep;

/**
 *
 *  This class contains real-time status of the executing custom mission.
 *
 */
@interface DJICustomMissionStatus : DJIMissionProgressStatus

/**
 *  The mission step executing in currently.
 */
@property(nonatomic, readonly) DJIMissionStep *_Nullable currentExecutingStep;

/**
 *  The execution progress status of current mission step.
 */
@property(nonatomic, readonly) DJIMissionProgressStatus *_Nullable progressStatus;

@end

/**
 *  The DJICustomMission class is a subclass of DJIMission. You can use it to create a custom mission that
 *  is made up of a sequence of mission steps.
 *  After the custom mission is uploaded and started, the sequence of mission steps will be executed.
 *
 */
@interface DJICustomMission : DJIMission

/**
 *  Create a custom mission with an array of DJIMissionStep objects.
 *  @see DJIMissionStep
 */
- (instancetype _Nullable)initWithSteps:(NSArray<DJIMissionStep *> *_Nonnull)steps;

@end

NS_ASSUME_NONNULL_END
