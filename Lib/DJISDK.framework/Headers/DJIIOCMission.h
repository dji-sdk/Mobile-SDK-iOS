//
//  DJIIOCMission.h
//  DJISDK
//
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJINavigation.h>
#import <DJISDK/DJIObject.h>

/**
 *  IOC(Intelligent Orientation Control) type.
 */
typedef NS_ENUM(uint8_t, DJIIOCType){
    /**
     *  As the aircraft follows a specific route, the direction is locked.
     *  The method lockCourseUsingCurrentDirectionWithResult: will lock
     *  the direction of the aircraft to the current direction.
     */
    DJIIOCTypeCourseLock = 1,
    /**
     *  Having the aircraft in this mode will allow the aircraft to move
     *  towards the home point without having to know the exact
     *  direction the aircraft needs to be in to return to home.
     *  For example, if the aircraft is extremely far out from the home point, 
     *  using the remote controller to move the aircraft backwards will 
     *  move the aircraft towards home instead of backwards.
     *
     *  @note To start a home lock mission successfully, the aircraft should have recorded a home point and the distance of aircraft to the home point should be at least five meters.
     */
    DJIIOCTypeHomeLock = 2,
    /**
     *  Unknown type.
     */
    DJIIOCTypeUnknown = 0xFF,
};

/**
 *  Current IOC mission status.
 */
@interface DJIIOCMissionStatus : DJINavigationMissionStatus

/**
 *  Returns the IOC type. Please take a look at the enum named DJIIOCType at the top of
 *  this file to learn what each of the two types mean.
 */
@property(nonatomic, readonly) DJIIOCType iocType;

/**
 *  Returns the direction of the aircraft which has been locked in. The value for this property
 *  will be in the range of [-180, 180] degrees, where 0 represents true north.
 */
@property(nonatomic, readonly) float lockedCourse;

/**
 *  Returns the error that occured in executing the IOC mission. This will show the user 
 *  why the IOC mission stopped unexpectedly. If error.errorCode returns ERR_Succeeded,
 *  then there was no error.
 */
@property(nonatomic, readonly) DJIError* error;

@end

/**
 *  IOC (Intelligent Orientation Control) mission.
 */
@protocol DJIIOCMission <DJINavigationMission>

/**
 *  Returns IOC type. Please take a look at the enum named DJIIOCType at the top of
 *  this file to see what two types the IOC type can be set to.
 */
@property(nonatomic, assign) DJIIOCType iocType;

/**
 *  Starts the IOC mission.
 *
 *  @param block Remote execute result callback.
 */
-(void) startMissionWithResult:(DJIExecuteResultBlock)block;

/**
 *  Stops the IOC mission.
 *
 *  @param block Remote execute result callback.
 */
-(void) stopMissionWithResult:(DJIExecuteResultBlock)block;

/**
 *  Locks the direction of the aircraft to the current direction for the rest of the course.
 *  This method can be used when the IOC mission type is DJIIOCTypeCourseLock.
 *
 *  @param block Remote execute result callback.
 */
-(void) lockCourseUsingCurrentDirectionWithResult:(DJIExecuteResultBlock)block;

@end

