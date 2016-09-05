//
//  DJITapFlyMission.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#import <DJISDK/DJIMission.h>
#import <DJISDK/DJISDKFoundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  A cartesian vector in 3D space.
 */
typedef struct
{
    /**
     *  X-value of the cartesian vector.
     */
    double x;
    /**
     *  Y-value of the cartesian vector.
     */
    double y;
    /**
     *  Z-value of the cartesian vector.
     */
    double z;
} DJIVector;

/**
 *  Direction aircraft is moving around or bypassing and obstacle.
 */
typedef NS_ENUM (NSInteger, DJIBypassDirection){
    /**
     *  Flying normally, no obstacle to be avoided.
     */
    DJIBypassDirectionNone,
    /**
     *  Avoid the obstacle by going over the top of it.
     */
    DJIBypassDirectionOver,
    /**
     *  Avoid the obstacle by going to the left of it.
     */
    DJIBypassDirectionLeft,
    /**
     *  Avoid the obstacle by going to the right of it.
     */
    DJIBypassDirectionRight,
    /**
     *  Unknown obstacle avoidance direction
     */
    DJIBypassDirectionUnknown,
};

/**
 *  TapFly Mission execution state.
 */
typedef NS_ENUM (NSInteger, DJITapFlyMissionExecutionState){
    /**
     *  The TapFly Mission cannot execute. The 'error' property will show the reason why.
     */
    DJITapFlyMissionExecutionStateCannotExecute,
    /**
     *  The TapFly Mission is executing normally.
     */
    DJITapFlyMissionExecutionStateExecuting,
    /**
     *  Unknown state.
     */
    DJITapFlyMissionExecutionStateUnknown,
};

/**
 *  This class provides the real-time status of an executing TapFly Mission.
 */
@interface DJITapFlyMissionStatus : DJIMissionProgressStatus

/**
 * Current execution state of TapFly Mission.
 */
@property(nonatomic, readonly) DJITapFlyMissionExecutionState executionState;

/**
 *  The direction the aircraft is moving around or bypassing an obstacle in. Will be DJIBypassDirectionNone if aircraft is not executing an avoidance maneuver.
 */
@property(nonatomic, readonly) DJIBypassDirection bypassDirection;

/**
 *  The direction vector aircraft is travelling in using the N-E-D (North-East-Down) coordinate system.
 */
@property(nonatomic, readonly) DJIVector direction;

/**
 *  The image point from the video feed where the vision system should calculate the flight direction from. The image point is normalized to [0,1] where (0,0) is the top left corner and (1,1) is the bottom right.
 */
@property(nonatomic, readonly) CGPoint imageLocation;

@end

/**
 *  A TapFly Mission is initialized with a position target from the live video stream. The 3D direction of the coordinate is calculated, and the aircraft will proceed to fly in that direction. The aircraft can automatically avoid obstacles when the scene is sufficiently illuminated (more than 300 lux but less than 10,000 lux). The aircraft will stop flying in the direction if it reaches its radius limitation, the mission is stopped, the user pulls back on the pitch stick or if it comes to an obstacle it cannot bypass. The Remote Controller yaw stick can be used to adjust the heading of the aircraft during mission execution, which also adjusts the direction of flight to the new yaw. Using any other stick controls will cancel the mission.
 *
 */
@interface DJITapFlyMission : DJIMission

/**
 *  Aircraft's auto flight speed during the mission. Use setAutoFlightSpeed:withCompletion: to dynamically set the flight speed. Auto flght speed range is [1, 10] m/s.
 */
@property(nonatomic, assign) float autoFlightSpeed;

/**
 *  `YES` allows aircraft to bypass or move around an obstacle by going to the left or right of the obstacle. If it is not enabled, the aircraft will only go over an obstacle to avoid it.
 */
@property(nonatomic, assign) BOOL isHorizontalObstacleAvoidanceEnabled;

/**
 *  The image point from the video feed where the vision system should calculate the flight direction from. The image point is normalized to [0,1] where (0,0) is the top left corner and (1,1) is the bottom right.
 */
@property(nonatomic, assign) CGPoint imageLocationToCalculateDirection;

/**
 *  Set TapFly Mission's auto flight speed.
 */
+ (void)setAutoFlightSpeed:(float)speed withCompletion:(DJICompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END