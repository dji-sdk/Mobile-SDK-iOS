//
//  DJIMissionManager.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import "DJIBaseProduct.h"
#import "DJIMission.h"

NS_ASSUME_NONNULL_BEGIN

@class DJIMissionManager;
@class DJIMission;
@class DJIMissionProgressStatus;

/**
 *  This protocol provides methods to check mission execution status and result.
 */
@protocol DJIMissionManagerDelegate <NSObject>

@optional

/**
 *  Mission execution finished callback.
 *
 *  @param manager Mission object
 *  @param error   Show whether the mission was finished with error.
 */
- (void)missionManager:(DJIMissionManager *_Nonnull)manager didFinishMissionExecution:(NSError *_Nullable)error;

/**
 *  Mission execution state update callback.
 *  Returns current mission and status.  For the waypoint mission, it will include mission state,
 *  target waypoint index, waypoint execution state, as well as error if have.
 *
 *  @param manager Mission object
 *  @param missionProgress Mission progress object
 */
- (void)missionManager:(DJIMissionManager *_Nonnull)manager missionProgressStatus:(DJIMissionProgressStatus *_Nonnull)missionProgress;

@end

/**
 *  This class manages the execution cycle for a mission. To execute a mission, normally user needs to first invoke prepareMission:withProgress:withCompletion to get the mission prepared. Then a user can call startMissionExecutionWithCompletion: to start the prepared mission. User can also pause, resume or stop an executing mission if the mission supports the operation.
 *
 */
@interface DJIMissionManager : NSObject

@property(nonatomic, weak) id<DJIMissionManagerDelegate> delegate;

/**
 *  YES if mission is ready to be executed.  It is ready when the uploadMission method completes successfully.
 */
@property(nonatomic, readonly) BOOL isMissionReadyToExecute;

+ (DJIMissionManager *_Nullable)sharedInstance;

/**
 *  Prepares the mission for execution. For the waypoint mission, data needs to be uploaded to the aircraft (product) and the
 *  DJIMissionProgressHandler can be used to monitor upload progress. The follow-me, panorama, hotpoint and custom missions
 *  require much shorter time for the preparation phase. PrepareMission should fail if a mission is currently executing.
 *
 *  @param mission Mission object
 *  @param preparationProgress Progress handler callback method to monitor preparation progress
 *  @param completion Completion block.
 */
- (void)prepareMission:(DJIMission *_Nonnull)mission withProgress:(DJIMissionProgressHandler)preparationProgress withCompletion:(DJICompletionBlock)completion;

/**
 *  Downloads the current mission configuration data from aircraft. This method should only be called after a mission has been prepared. Only waypoint missions and hot point missions can be downloaded from the aircraft.
 *
 *
 *  @param downloadProgress Progress handler callback method to monitor download progress
 *  @param completion Completion block.
 */
- (void)downloadMissionWithProgress:(DJIMissionProgressHandler)downladProgress withCompletion:(DJIMissionDownloadCompletionBlock)completion;

/**
 *  Starts mission execution. Should only be called after prepareMission is successfully called.
 *  For waypoint mission if the aircraft isn't flying, it will automatically take off and execute the mission. For hot point  and follow me mission, the aircraft needs to be flying before the mission is started. For custom mission, the behaviour depends on the first mission step.
 *
 *  @param completion Completion block.
 */
- (void)startMissionExecutionWithCompletion:(DJICompletionBlock)completion;

/**
 *  Pauses the current mission being executed and the aircraft will hover in its current location. Current state
 *  will be saved until resumeMissionExecutionWithCompletion is called.
 *  Returns a system busy error if the MissionManager is uploading or downloading the mission.
 *
 *  @param completion Completion block.
 */
- (void)pauseMissionExecutionWithCompletion:(DJICompletionBlock)completion;

/**
 *  Resumes the currently paused mission.  Returns a system busy error if the MissionManager is uploading or downloading the mission.
 *
 *  @param completion Completion block.
 */
- (void)resumeMissionExecutionWithCompletion:(DJICompletionBlock)completion;

/**
 *  Stops the current mission. The aircraft will hover in place.
 *  Returns a system busy error if the MissionManager is uploading or downloading the mission.
 *
 *  @param completion Completion block.
 */
- (void)stopMissionExecutionWithCompletion:(DJICompletionBlock)completion;

/**
 *  Returns current executing mission.  This method is should only be called after the mission has started execution.
 *
 *  @param Mission object of current mission.
 */
- (DJIMission *_Nullable)currentExecutingMission;

@end

NS_ASSUME_NONNULL_END
