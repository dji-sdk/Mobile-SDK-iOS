//
//  DJIMissionManager.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import "DJISDKFoundation.h"
#import "DJIMission.h"


NS_ASSUME_NONNULL_BEGIN

@class DJIMissionManager;
@class DJIMission;
@class DJIMissionProgressStatus;

/**
 *  This protocol provides methods to check the mission execution status and result.
 */
@protocol DJIMissionManagerDelegate <NSObject>

@optional

/**
 *  Mission execution finished callback.
 *
 *  @param manager Mission object.
 *  @param error   Indicates whether the mission finished with an error.
 */
- (void)missionManager:(DJIMissionManager *_Nonnull)manager didFinishMissionExecution:(NSError *_Nullable)error;

/**
 *  Mission execution state update callback.
 *  Returns the current mission and status.  For the waypoint mission, it will
 *  include the mission state, target waypoint index, waypoint execution state,
 *  and error if one occurred.
 *
 *  @param manager Mission object.
 *  @param missionProgress Mission progress object.
 */
- (void)missionManager:(DJIMissionManager *_Nonnull)manager missionProgressStatus:(DJIMissionProgressStatus *_Nonnull)missionProgress;

@end

/**
 *  This class manages the execution cycle for a mission. To execute a mission,
 *  you must normally first invoke `prepareMission:withProgress:withCompletion`
 *  to prepare the mission. Then call `startMissionExecutionWithCompletion:` to
 *  start the prepared mission. You can also pause, resume or stop an executing
 *  mission if the mission supports the operation.
 *
 */
@interface DJIMissionManager : NSObject

/**
 *  Returns the DJIMissionManager delegate.
 */
@property(nonatomic, weak) id<DJIMissionManagerDelegate> delegate;

/**
 *  YES if the mission is ready to be executed. It is ready when the
 *  `prepareMission` method completes successfully.
 */
@property(nonatomic, readonly) BOOL isMissionReadyToExecute DJI_API_DEPRECATED("This property will be removed in the future version.");

/**
 *  Returns the instance of DJIMissionManager.
 */
+ (DJIMissionManager *_Nullable)sharedInstance;

/**
 *  Prepares the mission for execution. For the waypoint mission, data must be
 *  uploaded to the aircraft (product), and the `DJIMissionProgressHandler` can
 *  be used to monitor upload progress. The follow-me, panorama, hotpoint and
 *  custom missions require much less time for the preparation phase.
 *  `PrepareMission` fails if a mission is currently executing.
 *
 *  @param mission Mission object
 *  @param preparationProgress Progress handler callback method to monitor preparation progress
 *  @param completion Completion block.
 */
- (void)prepareMission:(DJIMission *_Nonnull)mission
          withProgress:(DJIMissionProgressHandler)preparationProgress
        withCompletion:(DJICompletionBlock)completion;

/**
 *  Downloads the current mission configuration data from aircraft. This method
 *  should only be called after a mission has been prepared. Only waypoint
 *  missions and hot point missions can be downloaded from the aircraft.
 *
 *  @param downloadProgress Progress handler callback method to monitor download progress.
 *  @param completion Completion block.
 */
- (void)downloadMissionWithProgress:(DJIMissionProgressHandler)downladProgress
                     withCompletion:(DJIMissionDownloadCompletionBlock)completion;

/**
 *  Starts mission execution. This method should only be called after
 *  `prepareMission` was successfully called.
 *  For a waypoint mission, if the aircraft is not flying, it will automatically
 *  take off and execute the mission. For a hot point or follow me mission, the
 *  aircraft must be flying before the mission is started. For a custom mission,
 *  the behavior depends on the first mission step.
 *
 *  @param completion Completion block.
 */
- (void)startMissionExecutionWithCompletion:(DJICompletionBlock)completion;

/**
 *  Pauses the current mission being executed. The aircraft will hover in its
 *  current location. The current state will be saved until
 *  `resumeMissionExecutionWithCompletion` is called.
 *  Returns a system busy error if the `MissionManager` is uploading or
 *  downloading the mission.
 *
 *  @param completion Completion block.
 */
- (void)pauseMissionExecutionWithCompletion:(DJICompletionBlock)completion;

/**
 *  Resumes the currently paused mission.  Returns a system busy error if the
 *  `MissionManager` is uploading or downloading the mission.
 *
 *  @param completion Completion block.
 */
- (void)resumeMissionExecutionWithCompletion:(DJICompletionBlock)completion;

/**
 *  Stops the current mission. The aircraft will hover in its current location.
 *  Returns a system busy error if the `MissionManager` is uploading or
 *  downloading the mission.
 *
 *  @param completion Completion block.
 */
- (void)stopMissionExecutionWithCompletion:(DJICompletionBlock)completion;

/**
 *  Returns the current executing mission. This method should only be called
 *  after the mission has started execution.
 *
 *  @param Mission object for the current mission.
 */
- (DJIMission *_Nullable)currentExecutingMission;

@end

NS_ASSUME_NONNULL_END
