//
//  DJICustomMission.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <DJISDK/DJIMission.h>

NS_ASSUME_NONNULL_BEGIN

@class DJIMissionStep;

/**
 *
 *  This class contains the real-time status of the executing custom mission.
 *
 */
@interface DJICustomMissionStatus : DJIMissionProgressStatus

/**
 *  The mission step that is currently executing.
 */
@property(nonatomic, readonly) DJIMissionStep *_Nullable currentExecutingStep;

/**
 *  The execution progress status of current mission step.
 */
@property(nonatomic, readonly) DJIMissionProgressStatus *_Nullable progressStatus;

@end

/**
 *  In a custom mission, you can create multiple kinds of mission steps to control the aircraft to execute a series of complex tasks. Mission steps will be stored in a queue to execute, there is no limit to the number of mission steps in each custom mission. By using Custom Mission, you can achieve your desired functionality easier and more efficiently.

 *  The `DJICustomMission` class is a subclass of `DJIMission`. You can use it to create a custom mission that
 *  is made up of a sequence of mission steps. A <i>custom mission</i> is a mechanism designed by the Mobile SDK to
 *  simplify the development process. Missions (e.g. a waypoint mission) and operations of components are
 *  represented as mission steps. The developer can use the SDK to accomplish complex tasks by simply creating and organizing steps.
 *
 *  After the custom mission is uploaded and started, the sequence of the mission steps will be executed.
 *
 *  @see DJIMissionStep
 */
@interface DJICustomMission : DJIMission

/**
 *  Create a custom mission with an array of DJIMissionStep objects.
 *
 *  @see DJIMissionStep
 */
- (instancetype _Nullable)initWithSteps:(NSArray<DJIMissionStep *> *_Nonnull)steps;

@end

NS_ASSUME_NONNULL_END
