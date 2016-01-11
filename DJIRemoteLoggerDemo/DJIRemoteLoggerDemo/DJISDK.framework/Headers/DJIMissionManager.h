/*
 *  DJI iOS Mobile SDK Framework
 *  DJIMissionManager.h
 *
 *  Copyright (c) 2015, DJI.
 *  All rights reserved.
 *
 */

#import "DJIBaseProduct.h"
#import "DJIMission.h"

NS_ASSUME_NONNULL_BEGIN

@class DJIMissionManager;
@class DJIMission;
@class DJIMissionProgressStatus;



@protocol DJIMissionManagerDelegate <NSObject>

@optional

/**
 *  Mission execution state update callback.
 *  Returns current mission and status.  For the waypoint mission, it will include mission state,
 *  target waypoint index, waypoint execution state, as well as error if have.
 *
 *  @param manager Mission object
 *  @param missionProgress Mission progress object
 */
-(void) missionManager:(DJIMissionManager* _Nonnull)manager missionProgressStatus:(DJIMissionProgressStatus* _Nonnull) missionProgress;

@end

@interface DJIMissionManager : NSObject


@property(nonatomic, weak) id<DJIMissionManagerDelegate> delegate;

/**
 * YES if mission is ready to be executed.  It is ready when the uploadMission method completes successfully.
 */
@property(nonatomic, readonly) BOOL isMissionReadyToExecute;

+(DJIMissionManager* _Nullable) sharedInstance;


/**
 * Prepares the mission for execution. For the waypoint mission, data needs to be uploaded to the aircraft (product) and the DJIMissionProgressHandler can be used to monitor upload progress. For the follow me, panorama and hotpoint missions, preparation is only on the Mobile Device side and so returns almost immediately.
 *  @param mission Mission object
 *  @param preparationProgress Progress handler callback method to monitor preparation progress
 *  @param completion Completion block.
 */
-(void) prepareMission:(DJIMission* _Nonnull)mission withProgress:(DJIMissionProgressHandler)preparationProgress withCompletion:(DJICompletionBlock)completion;

/**
 * Downloads the current mission configuration data from aicraft. This method should only be called after a mission has been uploaded.
 *
 *  @param downloadProgress Progress handler callback method to monitor download progress
 *  @param completion Completion block.
 */
-(void) downloadMissionWithProgress:(DJIMissionProgressHandler)downladProgress withCompletion:(DJIDownloadMissionCompletionBlock)completion;

/**
 *  Starts mission execution. Should only be called after prepareMission is successfully called.
 *  If the aircraft isn't flying, it will automatically take off and execute the mission.
 *
 *  @param missionProgress Overall progress of the mission
 *  @param completion Completion block.
 */
-(void) startMissionExecutionWithProgress:(DJIMissionProgressHandler)missionProgress withCompletion:(DJICompletionBlock)completion;

/**
 *  Pauses the current mission being executed and the aircraft will hover in its current location. Current state
 *  will be saved until resumeMissionExecutionWithCompletion is called.
 *  Returns a system busy error if the MissionManager is uploading or downloading the mission.
 *
 */
-(void) pauseMissionExecutionWithCompletion:(DJICompletionBlock)completion;

/**
 * Resumes the currently paused mission.  Returns a system busy error if the MissionManager is uploading or downloading the mission.
 *
 *  @param completion Completion block.
 */
-(void) resumeMissionExecutionWithCompletion:(DJICompletionBlock)completion;

/**
 *  Stops the current mission. The aircraft will hover in place.
 *  Returns a system busy error if the MissionManager is uploading or downloading the mission.
 *
 */
-(void) stopMissionExecutionWithCompletion:(DJICompletionBlock)completion;

/**
 * Returns current executing mission.  This method is should only be called after the mission has started execution.
 *
 *  @param Mission object of current mission.
 */
-(DJIMission* _Nullable) currentExecutingMission;


@end

NS_ASSUME_NONNULL_END
