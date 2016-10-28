//
//  DJIActiveTrackMission.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#import <DJISDK/DJISDKFoundation.h>
#import <DJISDK/DJIMission.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Current ActiveTrack Mission execution state.
 */
typedef NS_ENUM (NSInteger, DJIActiveTrackMissionExecutionState){
    /**
     *  The ActiveTrack Mission is tracking a target.
     */
    DJIActiveTrackMissionExecutionStateTracking,
    /**
     *  The ActiveTrack Mission is tracking a target with low confidence. This
     *  is only an indication that either the aircraft will soon ask for
     *  confirmation that the target is correct, or may loose tracking the
     *  target entirely if confidence doesn't improve.
     */
    DJIActiveTrackMissionExecutionStateTrackingWithLowConfidence,
    /**
     *  At the start of a mission, when a mission is resumed or anytime the
     *  aircraft looses sufficient confidence the target it is tracking, the
     *  aircraft will ask for confirmation that it is tracking the correct
     *  object. The trackingRect in DJIActiveTrackMissionStatus can be used to
     *  see what object the aircraft is tracking. In this state, the aircraft
     *  will hover in place, but continue to track the target. The methods
     *  `acceptConfirmationWithCompletion:` or `rejectConfirmationWithCompletion`
     *  can be used to to confirm or reject the tracking rectangle.
     */
    DJIActiveTrackMissionExecutionStateWaitingForConfirmation,
    /**
     *  Used when tracking cannot continue for reasons other than low confidence.
     *  User returned error to see more details.
     */
    DJIActiveTrackMissionExecutionStateCannotContinue,
    /**
     *  The tracking target lost.
     */
    DJIActiveTrackMissionExecutionStateTargetLost,
    /**
     *  Unknown state.
     */
    DJIActiveTrackMissionExecutionStateUnknown,
};

/**
 *  Different modes of the ActiveTrack Mission. Defaults to Trace, set to others
 *  to enable the feature.
 */
typedef NS_ENUM (NSInteger, DJIActiveTrackMode) {
    /**
     *  Aircraft moves in behind the subject keeping a constant distance to it.
     */
    DJIActiveTrackModeTrace,
    /**
     *  Aircraft moves in parallel with the subject in the frame instead of
     *  behind.
     */
    DJIActiveTrackModeProfile,
    /**
     *  In Spotlight mode, the aircraft camera automatically follows the subject,
     *  but the aircraft does not automatically keep a constant distance with
     *  the subject.
     */
    DJIActiveTrackModeSpotlight,
    /**
     *  The active track mode is unknown.
     */
    DJIActiveTrackModeUnknown
};

/**
 *  Completion block for asynchronous operations. This completion block is used
 *  for methods that return at an unknown future time.
 *
 *  @param activeTrackMode  Active track mode to return. The value is undefined
 *                          if `error` is not nil. 
 *  @param error            An error object if an error occured during async
 *                          operation, or nil if no error occurred.
 */
typedef void (^_Nullable DJIActiveTrackModeCompletionBlock)(DJIActiveTrackMode activeTrackMode, NSError *_Nullable error);

@class DJIActiveTrackMission;

/**
 *  This class provides the real-time status of an executing ActiveTrack Mission.
 */
@interface DJIActiveTrackMissionStatus : DJIMissionProgressStatus

/**
 *  ActiveTrack Mission execution state.
 */
@property(nonatomic, readonly) DJIActiveTrackMissionExecutionState executionState;

/**
 *  A rectangle in the live video view image that represents the target being
 *  tracked. It is only valid when executionState is
 *  `DJIActiveTrackMissionExecutionStateTracking`,
 *  `DJIActiveTrackMissionExecutionStateTrackingWithLowConfidence`,
 *  `DJIActiveTrackMissionExecutionStateWaitingForConfirmation` or
 *  `DJIActiveTrackMissionExecutionStateCannotContinue`.
 *  The rectangle is normalized to [0,1] where (0,0) is the top left of the
 *  video preview and (1,1) is the bottom right.
 */
@property(nonatomic, readonly) CGRect trackingRect;

/**
 *  YES if tracking target is recognized as a human.
 */
@property(nonatomic, readonly) BOOL isHuman;

@end

/**
 *  ActiveTrack Mission allows an aircraft to track a moving subject using the
 *  vision system and without a GPS tracker on the subject. To use an
 *  ActiveTrack mission:
 *      - prepareMission with the rectangle that best represents the target to
 *        track
 *      - startMission to initiate tracking of the object and begin the state
 *        updates (DJIMissionProgressStatus)
 *      - At this point, the aircraft will track the target while hovering in
 *        place.
 *      - Give confirmation that the tracked target is correct with
 *        `acceptConfirmationWithCompletion` and the aircraft will begin flying
 *        relative to the target.
 *      - If the tracking algorithm looses sufficient confidence in tracking the
 *        target, then the aircraft will stop flying relative to the object and
 *        either notify the user (through execution state) that the target is
 *        lost or it needs another confirmation that the target is correct.
 *      - If the mission is paused, the aircraft will hover in place, but
 *        continue tracking the target by adjusting gimbal pitch and aircraft yaw.
 *      - If mission is resumed, confirmation of tracking rectangle will need to
 *        be sent through to start flying relative to target.
 *      - Mission can be canceled with stopMission at any time, or with
 *        `rejectConfirmationWithCompletion` if confirmation of tracking
 *        rectangle is being asked.
 *      - The main camera is used to track the target, so gimbal cannot be
 *        adjusted during an ActiveTrack mission.
 *      - During the mission the aircraft can be manually flown with pitch, roll
 *        and throttle. Yaw and gimbal are automatically controlled to continue
 *        tracking the target.
 *      - If the mission is executing, and after confirmation of the tracking
 *        rectangle has been sent, the aircraft can be manually controlled
 *        horizontally similar to a DJIFlightOrientationModeHomeLock where the
 *        `home` is the tracked target. If aircraft is manually controlled
 *        upward, the aircraft will lift and retreat, and if it is controlled
 *        downward, it will go down and get closer to the target.
 */
@interface DJIActiveTrackMission : DJIMission

/**
 *  ActiveTrack Mission mode. Defaults to DJIActiveTrackModeTrace, adjust to a
 *  different mode before starting mission. Use the asynchronous class methods
 *  once the mission has started.
 *
 *  Additional modes only supported by the Mavic Pro.
 */
@property(nonatomic) DJIActiveTrackMode activeTrackMode;

/**
 *  A bounding box for the target. The rectangle is normalized to [0,1] where
 *  (0,0) is the top left of the video preview and (1,1) is the bottom right.
 *  The `size` parameter of `CGRect` can be set to 0 to initialize the mission
 *  with a point instead of a rectangle. If the mission is initialized with a
 *  point, the vision system will try to recognize object around the point and
 *  return the representative rect in the status delegate.
 */
@property(nonatomic, assign) CGRect rect;

/**
 *  `YES` if the aircraft can retreat (fly backwards) when the target comes
 *  toward it. If no, the aircraft will not retreat and instead rotate the
 *  gimbal pitch down to track the target as it goes underneath. If the target
 *  goes beyond the gimbal's pitch stop, the target will be lost and the mission
 *  will stop.
 *  Default is `NO`.
 */
@property(nonatomic, assign) BOOL isRetreatEnabled;

/**
 *
 *  YES to enable gesture mode. In gesture mode:
 *  - A human subject can be automatically detected if they are moving a little
 *    (instead of requiring a defining rectangle)
 *  - The human subject can accept the confirmation to track them by waving
 *    their arms.
 *  - The tracked human can make the camera shoot a photo by showing a rectangle
 *    with their thumbs and index fingers to the aircraft.
 *  Gesture mode can only be enabled when in trace mode (DJIActiveTrackModeTrace).
 *  Default is NO.
 *
 *  Only supported by Mavic Pro.
 */
@property(nonatomic, assign) BOOL isGestureModeEnabled;

/**
 *  Sets the active track mode on the currently executing mission. This method
 *  should be used when the ActiveTrack mission is executing. The property
 *  `activeTrackMode` is used before the mission starts.
 *  The active track mode can only be set when gesture mode is not enabled
 *  for the currently executing mission
 *
 *  Only supported by Mavic Pro.
 *
 *  @param activeTrackMode  Active track mode to set. 
 *  @param completion       Completion block that receives the setter result.
 */
+ (void)setActiveTrackMode:(DJIActiveTrackMode)activeTrackMode
            withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the active track mode on currently executing mission. This method
 *  should be used when the ActiveTrack mission is executing. The property
 *  `activeTrackMode` is used before the mission starts. Will return
 *  `DJIActiveTrackModeUnknown` if mission hasn't started.
 *
 *  Only supported by Mavic Pro.
 *
 *  @param completion   Completion block that receives the getter result.
 */
+ (void)getActiveTrackModeWithCompletion:(DJIActiveTrackModeCompletionBlock)completion;

/**
 *  Setting a non-zero speed starts the aircraft circling the target. Speed
 *  can be set within the range [-5, 5] m/s where a positive speed is a
 *  counter-clockwise movement (when viewing from the top). Reverting the speed
 *  to 0 m/s ends the circling movement.
 *  This method can only be called when executing an ActiveTrack mission with
 *  `DJIActiveTrackModeTrace` mode.
 *  Only supported by Mavic Pro.
 *
 *  @param speed        Circular speed to set in m/s.
 *  @param completion   Completion block that receives the setter result.
 */
+ (void)setCircularSpeed:(float)speed
          withCompletion:(DJICompletionBlock)completion;

/**
 *  In an ActiveTrack mission, the aircraft can be set to circle the target
 *  while following it. This method returns the circular speed of the aircraft
 *  in m/s.
 *  Only supported by Mavic Pro.
 *
 *  @param completion   Completion block that receives the getter result.
 */
+ (void)getCirclarSpeedWithCompletion:(DJIFloatCompletionBlock)completion;

/**
 *  When the vision system is not sure the tracking rectangle is around the
 *  user's desired target, it will need confirmation before starting to fly
 *  relative to the target. The vision system will need confirmation whenever
 *  the ActiveTrack mission execution state is
 *  `DJIActiveTrackMissionExecutionStateWaitingForConfirmation`. The
 *  `trackingRect` property of `DJIActiveTrackMissionExecutionState` can be used
 *  to show the user the rectangle the vision system is using. If the user
 *  agrees the rectangle represents the target they want to track, this method
 *  can be called to start flying relative to the target.
 *
 *  @param completion   Completion block that receives the execution result.
 *
 *  @see `rejectConfirmationWithCompletion:`.
 */
+ (void)acceptConfirmationWithCompletion:(DJICompletionBlock)completion;

/**
 *  When the vision system is not sure the tracking rectangle is around the
 *  user's desired target, it will need confirmation before starting to fly
 *  relative to the target. The vision system will need confirmation whenever
 *  the ActiveTrack mission execution state is
 *  `DJIActiveTrackMissionExecutionStateWaitingForConfirmation`. The
 *  `trackingRect` property of `DJIMissionProgressStatus` can be used to show
 *  the user the rectangle the vision system is using. If the user does not
 *  agree the rectangle represents the target they want to track, this method
 *  can be used to stop the Mission.
 *
 *  @param completion   Completion block that receives the execution result.
 *
 *  @see `acceptConfirmationWithCompletion:`.
 */
+ (void)rejectConfirmationWithCompletion:(DJICompletionBlock)completion;

/**
 *  Sets the recommended camera and gimbal configuration that optimizes
 *  performance for the ActiveTrack Mission in most environments.
 *
 *  @param completion   Completion block that receives the execution result.
 */
+ (void)setRecommendedConfigurationWithCompletion:(DJICompletionBlock)completion;


@end

NS_ASSUME_NONNULL_END
