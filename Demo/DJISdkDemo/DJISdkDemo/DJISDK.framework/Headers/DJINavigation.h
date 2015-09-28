//
//  DJINavigation.h
//  DJISDK
//
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <DJISDK/DJIFoundation.h>
#import <DJISDK/DJIObject.h>

@protocol DJIFlightControl;
@protocol DJIWaypointMission;
@protocol DJIHotPointMission;
@protocol DJIFollowMeMission;
@protocol DJIIOCMission;

typedef NS_ENUM(uint8_t, DJINavigationMissionType)
{
    /**
     *  The aircraft is in navigation
     *  mode but no mission exists.
     */
    DJINavigationMissionNone,
    /**
     *  Waypoint mission
     */
    DJINavigationMissionWaypoint,
    /**
     *  Hotpoint mission
     */
    DJINavigationMissionHotpoint,
    /**
     *  Follow me mission
     */
    DJINavigationMissionFollowMe,
    /**
     *  IOC (Intelligent Orientation Control) mission
     */
    DJINavigationMissionIOC,
    /**
     *  Unknown mission
     */
    DJINavigationMissionUnknown = 0xFF,
};

/**
 *  Navigation mission base protocol.
 */
@protocol DJINavigationMission <NSObject>

/**
 *  Whether or not the mission is supported for the connected aircraft.
 */
@property(nonatomic, readonly) BOOL isSupported;

/**
 *  Whether or not the mission is already running in the aircraft.
 */
@property(nonatomic, readonly) BOOL isRunning;

/**
 *  Whether or not the mission's parameters is valid for execution. If this property
 *  returns NO, then the attempt to startMission will have failed.
 *
 *  @attention The result of 'isValid' just show whether the mission's local parameters is valid. not for all execution condition.
 */
@property(nonatomic, readonly) BOOL isValid;

/**
 *  Show failure reason for checking parameters of mission. Value will be set after calling 'isValid'.
 */
@property(nonatomic, readonly) NSString* failureReason;

/**
 *  Returns the navigation mission type.
 */
@property(nonatomic, readonly) DJINavigationMissionType missionType;

@end

/**
 *  Current navigation mission status
 */
@interface DJINavigationMissionStatus : NSObject

/**
 *  Returns the navigation mission type as part of the 
 *  current status of the navigation mission.
 */
@property(nonatomic, readonly) DJINavigationMissionType missionType;

-(id) initWithType:(DJINavigationMissionType)type;

@end

/**
 *  Navigation mission status for when there is no mission running.
 */
@interface DJINavigationNoneMissionStatus : DJINavigationMissionStatus

/**
 *  Returns the type of mission that last aborted unexpectedly.
 */
@property(nonatomic, readonly) DJINavigationMissionType lastAbortedMission;

/**
 *  Returns the last error from the last aborted mission. THe goal of this
 *  property is to help assess why a mission failed.
 */
@property(nonatomic, readonly) DJIError* lastError;

@end

@protocol DJINavigationDelegate <NSObject>

@required

/**
 *  Updates the navigation mission status. If the missionType is of type DJINavigationMissionWaypoint
 *  then the missionStatus will be of class DJIWaypointMissionStatus. If missionType is 
 *  DJINavigationMissionHotpoint then the missionStatus will be of class DJIHotpointMissionStatus.
 *  If the missionType is DJINavigationMissionFollowMe then the missionStatus will be of class DJIFollowMeMissionStatus.
 *
 *  @param missionStatus Mission status based on the current mission.
 */
-(void) onNavigationMissionStatusChanged:(DJINavigationMissionStatus*)missionStatus;

@end

@protocol DJINavigation <NSObject>

/**
 *  Navigation delegate
 */
@property(nonatomic, weak) id<DJINavigationDelegate> delegate;

/**
 *  Whether or not the aircraft already in navigation mode.
 */
@property(nonatomic, readonly) BOOL isNavigationMode;

/**
 *  Flight control.
 */
@property(nonatomic, readonly) NSObject<DJIFlightControl>* flightControl;

/**
 *  Waypoint mission.
 */
@property(nonatomic, readonly) NSObject<DJIWaypointMission>* waypointMission;

/**
 *  Hotpoint mission.
 */
@property(nonatomic, readonly) NSObject<DJIHotPointMission>* hotpointMission;

/**
 *  Follow Me mission.
 */
@property(nonatomic, readonly) NSObject<DJIFollowMeMission>* followMeMission;

/**
 *  IOC (Intelligent Orientation Control) mission.
 */
@property(nonatomic, readonly) NSObject<DJIIOCMission>* iocMission;


/**
 *  Enters navigation mode. In order to successfully enter navigation mode, the remote controller's
 *  mode switch should be switched to 'F' mode . If the switch is already on 'F' mode, the user must
 *  switch back and forth between the 'F' mode and another mode to enable navigation control.
 *
 *  @param result Remote execute result callback.
 */
-(void) enterNavigationModeWithResult:(DJIExecuteResultBlock)result;

/**
 *  Exits navigation mode.
 *
 *  @param result Remote execute result callback.
 */
-(void) exitNavigationModeWithResult:(DJIExecuteResultBlock)result;


@end
