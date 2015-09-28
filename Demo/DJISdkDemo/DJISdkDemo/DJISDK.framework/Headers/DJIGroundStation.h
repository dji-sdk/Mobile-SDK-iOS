//
//  DJIGroundStation.h
//  DJISDK
//
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIObject.h>
#import <DJISDK/DJINavigation.h>

@protocol GroundStationDelegate;
@class DJIGroundStationTask;
@class DJIError;
@class DJIGroundStationFlyingInfo;


/**
 *  Ground station funcationality supported only in Phantom 2 Vision / Phantom 2 Vision+
 */
@protocol DJIGroundStation

@property(nonatomic, weak) id<GroundStationDelegate> groundStationDelegate;

/**
 *  Ground station task
 */
@property(nonatomic, readonly) DJIGroundStationTask* groundStationTask;

/**
 *  Open ground station. Api was deprecated, use enterNavigationModeWithResult: instead
 */
-(void) openGroundStation;

/**
 *  Close ground station. Api was deprecated, use exitNavigationModeWithResult: instead
 */
-(void) closeGroundStation;

/**
 *  Upload a new task to the airplane.
 *
 *  @param task 
 */
-(void) uploadGroundStationTask:(DJIGroundStationTask*)task;

/**
 *  Download ground station task, if no task on the airplane, property "groundStationTask" will be set to nil.
 */
-(void) downloadGroundStationTask;

/**
 *  Start executing task on the drone, if the airplane not takeoff, it will takeoff automatically and execute the task.
 */
-(void) startGroundStationTask;

/**
 *  Stop executing task on the drone
 */
-(void) stopGroundStationTask;

/**
 *  Pause task, drone will hover at the current place.
 */
-(void) pauseGroundStationTask;

/**
 *  Continue task
 */
-(void) continueGroundStationTask;

/**
 *  Airplane go home
 *  @attention the home point of the drone should have setuped at the begining
 */
-(void) gohome;

/**
 *  Set aircraft pitch rotation speed.
 *
 *  @param pitchSpeed Pitch speed between [-1000, 1000]
 *  @attention This api is valid only after the drone is pausing.
 */
-(BOOL) setAircraftPitchSpeed:(int)pitchSpeed;

/**
 *  Set aircraft roll rotation speed。
 *
 *  @param rollSpeed Roll speed between [-1000, 1000]
 *  @attention This api is valid only after the drone is pausing.
 */
-(BOOL) setAircraftRollSpeed:(int)rollSpeed;

/**
 *  Set aircraft yaw rotation speed.
 *
 *  @param yawSpeed Yaw speed between [-1000, 1000]
 *  @attention This api is valid only after the drone is pausing.
 */
-(BOOL) setAircraftYawSpeed:(int)yawSpeed;

/**
 *  Set aircraft throttle.
 *
 *  @param throttle Throttle value [0 stop, 1 up, 2 down]
 */
-(BOOL) setAircraftThrottle:(int)throttle;

/**
 *  Set aricraft joystick.
 *
 *  @param pitch   Pitch speed between [-1000, 1000]
 *  @param roll    Roll speed between [-1000, 1000]
 *  @param yaw     Yaw speed between [-1000, 1000]
 *  @param throttle Throttle  [0 stop, 1 up, 2 down]
 *  @attention This api is valid only after the drone is pausing.
 */
-(BOOL) setAircraftJoystickWithPitch:(int)pitch Roll:(int)roll Yaw:(int)yaw Throttle:(int)throttle;

@end

typedef NS_ENUM(NSInteger, GSActionType)
{
    GSActionOpen,           //Open ground station
    GSActionClose,          //Close ground station
    GSActionUploadTask,     //Upload task
    GSActionDownloadTask,   //Download task
    GSActionStart,          //Start task
    GSActionStop,           //Stop task
    GSActionPause,          //Pause task
    GSActionContinue,       //Continue task
    GSActionGoHome,         //Go home
};

typedef NS_ENUM(NSInteger, GSExecuteStatus)
{
    GSExecStatusBegan,
    GSExecStatusSucceeded,
    GSExecStatusFailed,
};

typedef NS_ENUM(NSInteger, GSError)
{
    GSErrorTimeout,
    GSErrorGpsNotReady,
    GSErrorGpsSignalWeak,
    GSErrorMotoNotStart,
    GSErrorModeError,
    GSErrorUploadFailed,
    GSErrorDownloadFailed,
    GSErrorExecuteFailed,
    GSErrorRCModeError,
    GSErrorNoMission,
    GSErrorMissionError,
    GSErrorParamError,
    GSErrorOvercrossFlyLimtArea,
    GSErrorMissionEstimateTimeTooLong,
    GSErrorHighPriorityMissionInExecuting,
    GSErrorNotEnoughPower,
    GSErrorNotDefined,
    GSErrorNone,
};

@interface GroundStationExecuteResult : NSObject

/**
 *  Current executing action
 */
@property(nonatomic) GSActionType currentAction;

/**
 *  Execute status
 */
@property(nonatomic) GSExecuteStatus executeStatus;

/**
 *  Error
 */
@property(nonatomic) GSError error;

-(id) initWithAction:(GSActionType)type;

@end


@protocol GroundStationDelegate <NSObject>

@optional
/**
 *  Ground station execute result delegate.
 */
-(void) groundStation:(id<DJIGroundStation>)gs didExecuteWithResult:(GroundStationExecuteResult*)result;

/**
 *  Ground station flying status.
 */
-(void) groundStation:(id<DJIGroundStation>)gs didUpdateFlyingInformation:(DJIGroundStationFlyingInfo*)flyingInfo;
/**
 *  Upload waypoint mission with progress
 *
 *  @param gs       Ground Station Instance
 *  @param progress Upload mission progress, [0, 100]
 */
-(void) groundStation:(id<DJIGroundStation>)gs didUploadWaypointMissionWithProgress:(uint8_t)progress;

/**
 *  Upload waypoint mission with progress
 *
 *  @param gs       Ground Station Instance
 *  @param progress Download mission progress, [0, 100]
 */
-(void) groundStation:(id<DJIGroundStation>)gs didDownloadWaypointMissionWithProgress:(uint8_t)progress;
@end