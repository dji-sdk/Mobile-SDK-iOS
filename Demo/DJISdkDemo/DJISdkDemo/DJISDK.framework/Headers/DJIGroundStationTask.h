//
//  DJIGroundStationTask.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DJIGroundStationWaypoint;


@interface DJIGroundStationTask : NSObject

/**
 *  Waypoints count in the task.
 */
@property(nonatomic, readonly) int waypointCount;

/**
 *  The first waypoint index of task.
 */
@property(nonatomic, assign) int startWaypointIndex;

/**
 *  Whether execute task looply. Default is NO
 */
@property(nonatomic, assign) BOOL isLoop;

/**
 *  Create new task
 *
 */
+(id) newTask;

/**
 *  Add waypoint, The maximum waypoint count is 16.
 *
 *  @param waypoint
 */
-(void) addWaypoint:(DJIGroundStationWaypoint*)waypoint;

/**
 *  Remove one waypoint
 *
 *  @param waypoint Waypoint will be removed
 */
-(void) removeWaypoint:(DJIGroundStationWaypoint*)waypoint;

/**
 *  Remove all waypoints
 */
-(void) removeAllWaypoint;

/**
 *  Get waypoint at index
 *
 *  @param index Index of array
 *
 *  @return Waypoint object
 */
-(DJIGroundStationWaypoint*) waypointAtIndex:(int)index;

/**
 *  Get all waypoints
 *
 *  @return Waypoint array
 */
-(NSArray*) allWaypoints;

@end
